//
//  RiddleMeThisOnlineSyncService.swift
//  The Social Deck
//
//  Handles all Firestore reads and writes for the Riddle Me This online game.
//  The host writes state; all players listen and their UIs update in real time.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class RiddleMeThisOnlineSyncService: ObservableObject {
    static let shared = RiddleMeThisOnlineSyncService()

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Published game state (mirrors Firestore fields)

    @Published var currentRiddleIndex: Int = 0
    /// Host has flipped the card; riddle text is now visible to all
    @Published var isCardFlipped: Bool = false
    /// Host has revealed the correct answer; results phase
    @Published var isAnswerRevealed: Bool = false
    /// uid → submitted answer text
    @Published var playerAnswers: [String: String] = [:]
    /// uid → running score (floor 0)
    @Published var playerScores: [String: Int] = [:]
    /// "question" | "answering" | "results"
    @Published var roundPhase: String = "question"

    /// From room document: lobby + in-game timer (Riddle Me This online).
    @Published var timerEnabled: Bool = false
    @Published var timerDuration: Int = 30
    /// Server time when answering began (card flipped); all clients derive countdown locally.
    @Published var roundStartTimestamp: Date?

    @Published var connectionLost: Bool = false

    private init() {}

    // MARK: - Listen

    func startListening(roomId: String) {
        stopListening()
        listener = db.collection("rooms")
            .document(roomId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if error != nil {
                    Task { @MainActor in self.connectionLost = true }
                    return
                }

                guard let data = snapshot?.data() else { return }

                Task { @MainActor in
                    self.connectionLost = false
                    self.currentRiddleIndex = data["rmtCurrentRiddleIndex"] as? Int ?? self.currentRiddleIndex
                    self.isCardFlipped      = data["rmtIsCardFlipped"]      as? Bool ?? self.isCardFlipped
                    self.isAnswerRevealed   = data["rmtIsAnswerRevealed"]   as? Bool ?? self.isAnswerRevealed
                    self.roundPhase         = data["rmtRoundPhase"]         as? String ?? self.roundPhase
                    self.playerAnswers      = data["rmtPlayerAnswers"]      as? [String: String] ?? self.playerAnswers
                    // Firestore can return Int or Int64; normalise to Int
                    if let raw = data["rmtPlayerScores"] as? [String: Any] {
                        var scores: [String: Int] = [:]
                        for (key, val) in raw {
                            if let i = val as? Int { scores[key] = i }
                            else if let i = val as? Int64 { scores[key] = Int(i) }
                        }
                        self.playerScores = scores
                    }

                    if let te = data["timerEnabled"] as? Bool {
                        self.timerEnabled = te
                    } else {
                        self.timerEnabled = false
                    }
                    if let d = data["timerDuration"] as? Int {
                        self.timerDuration = d
                    } else if let d = data["timerDuration"] as? Int64 {
                        self.timerDuration = Int(d)
                    } else {
                        self.timerDuration = 30
                    }
                    if let ts = data["roundStartTimestamp"] as? Timestamp {
                        self.roundStartTimestamp = ts.dateValue()
                    } else {
                        self.roundStartTimestamp = nil
                    }
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        connectionLost = false
    }

    // MARK: - Reset local state when entering a new game

    func resetLocalState() {
        currentRiddleIndex = 0
        isCardFlipped      = false
        isAnswerRevealed   = false
        playerAnswers      = [:]
        playerScores       = [:]
        roundPhase         = "question"
        connectionLost     = false
        timerEnabled       = false
        timerDuration      = 30
        roundStartTimestamp = nil
    }

    // MARK: - Host: initialise round 0

    /// Called once by the host when the game launches to write the initial state fields.
    func initGameState(roomId: String, players: [RoomPlayer]) async throws {
        var initialScores: [String: Int] = [:]
        for player in players { initialScores[player.id] = 0 }

        try await db.collection("rooms").document(roomId).updateData([
            "rmtCurrentRiddleIndex": 0,
            "rmtIsCardFlipped":      false,
            "rmtIsAnswerRevealed":   false,
            "rmtRoundPhase":         "question",
            "rmtPlayerAnswers":      [String: String](),
            "rmtPlayerScores":       initialScores,
            "roundStartTimestamp":   FieldValue.delete()
        ])
    }

    // MARK: - Host: flip the card (question → answering)

    func flipCard(roomId: String) async throws {
        if timerEnabled {
            try await db.collection("rooms").document(roomId).updateData([
                "rmtIsCardFlipped": true,
                "rmtRoundPhase": "answering",
                "roundStartTimestamp": FieldValue.serverTimestamp()
            ])
        } else {
            try await db.collection("rooms").document(roomId).updateData([
                "rmtIsCardFlipped": true,
                "rmtRoundPhase": "answering",
                "roundStartTimestamp": FieldValue.delete()
            ])
        }
    }

    // MARK: - All players: submit answer

    func submitAnswer(roomId: String, uid: String, answer: String) async throws {
        try await db.collection("rooms").document(roomId).updateData([
            "rmtPlayerAnswers.\(uid)": answer
        ])
    }

    // MARK: - Host: reveal answer + score (answering → results)

    /// correctAnswer is the riddle's answer string. Scores are computed here.
    /// allPlayerIds must include every player in the room so non-submitters are also penalised.
    func revealAnswer(roomId: String, correctAnswer: String, currentScores: [String: Int], allPlayerIds: [String]) async throws {
        var newScores = currentScores
        // Score players who submitted
        for (uid, submitted) in playerAnswers {
            let isCorrect = RiddleMeThisOnlineSyncService.matches(submitted: submitted, correct: correctAnswer)
            let current = newScores[uid] ?? 0
            newScores[uid] = isCorrect ? current + 1 : max(0, current - 1)
        }
        // Penalise players who did not submit (same as wrong answer, floor 0)
        for uid in allPlayerIds where playerAnswers[uid] == nil {
            let current = newScores[uid] ?? 0
            newScores[uid] = max(0, current - 1)
        }

        try await db.collection("rooms").document(roomId).updateData([
            "rmtIsAnswerRevealed": true,
            "rmtRoundPhase":       "results",
            "rmtPlayerScores":     newScores,
            "roundStartTimestamp": FieldValue.delete()
        ])
    }

    // MARK: - Host: advance to next round

    func nextRound(roomId: String, nextIndex: Int) async throws {
        try await db.collection("rooms").document(roomId).updateData([
            "rmtCurrentRiddleIndex": nextIndex,
            "rmtIsCardFlipped":      false,
            "rmtIsAnswerRevealed":   false,
            "rmtRoundPhase":         "question",
            "rmtPlayerAnswers":      [String: String](),
            "roundStartTimestamp":   FieldValue.delete()
        ])
    }

    // MARK: - Host: end game

    func endGame(roomId: String) async throws {
        try await db.collection("rooms").document(roomId).updateData([
            "rmtRoundPhase": "ended",
            "roundStartTimestamp": FieldValue.delete()
        ])
    }

    // MARK: - Answer matching (case-insensitive contains)

    static func matches(submitted: String, correct: String) -> Bool {
        let s = submitted.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let c = correct.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty, !c.isEmpty else { return false }
        return s.contains(c) || c.contains(s)
    }

    deinit {
        listener?.remove()
    }
}

// MARK: - Deterministic card shuffle keyed to room code

/// Returns cards in a stable shuffled order that is identical on every device
/// given the same roomCode string. Used so all online players see the same riddles.
func riddleDeterministicShuffle(_ cards: [Card], roomCode: String) -> [Card] {
    let seed = roomCode.unicodeScalars.reduce(0) { acc, scalar in
        acc &* 31 &+ Int(bitPattern: UInt(scalar.value))
    }
    var rng = SeededRNG(seed: UInt64(bitPattern: Int64(seed)))
    var result = cards
    result.shuffle(using: &rng)
    return result
}

private struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        // Ensure non-zero state (xorshift requires nonzero)
        state = seed == 0 ? 6364136223846793005 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
