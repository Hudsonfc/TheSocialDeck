//
//  ActNaturalOnlineSyncService.swift
//  The Social Deck
//
//  Firestore sync for Act Natural online: reveal → discussion → roles revealed → ended.
//

import Foundation
import FirebaseFirestore

// MARK: - Deterministic setup (same on every device for a room)

func actNaturalSortedWords() -> [ActNaturalWord] {
    actNaturalWords.sorted {
        if $0.category != $1.category { return $0.category < $1.category }
        return $0.word.localizedCaseInsensitiveCompare($1.word) == .orderedAscending
    }
}

func actNaturalSecretWord(roomCode: String, roundIndex: Int) -> ActNaturalWord {
    let sorted = actNaturalSortedWords()
    let shuffled = actNaturalDeterministicShuffleWords(sorted, salt: roomCode + "|AN_W|\(roundIndex)")
    return shuffled[0]
}

/// Sorted user IDs → same unknown assignment for all clients (per round).
func actNaturalUnknownUserIds(
    roomCode: String,
    sortedPlayerIds: [String],
    twoUnknownsFromLobby: Bool,
    roundIndex: Int
) -> Set<String> {
    let n = sortedPlayerIds.count
    guard n >= 2 else { return [] }
    let target: Int
    if n == 2 {
        target = 1
    } else if twoUnknownsFromLobby && n >= 4 {
        target = 2
    } else if n >= 6 {
        target = 2
    } else {
        target = 1
    }
    let capped = min(target, max(1, n - 1))
    var order = Array(0..<n)
    var rng = ActNaturalSeededRNG(seed: actNaturalSeed(from: roomCode + "|AN_U|\(roundIndex)"))
    order.shuffle(using: &rng)
    return Set(order.prefix(capped).map { sortedPlayerIds[$0] })
}

private func actNaturalDeterministicShuffleWords(_ words: [ActNaturalWord], salt: String) -> [ActNaturalWord] {
    var rng = ActNaturalSeededRNG(seed: actNaturalSeed(from: salt))
    var result = words
    result.shuffle(using: &rng)
    return result
}

private func actNaturalSeed(from string: String) -> UInt64 {
    let i = string.unicodeScalars.reduce(0) { acc, scalar in
        acc &* 31 &+ Int(bitPattern: UInt(scalar.value))
    }
    return UInt64(bitPattern: Int64(i))
}

private struct ActNaturalSeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 6364136223846793005 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

// MARK: - Sync service

@MainActor
class ActNaturalOnlineSyncService: ObservableObject {
    static let shared = ActNaturalOnlineSyncService()

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    /// "reveal" | "discussion" | "revealed" | "ended"
    @Published var phase: String = "reveal"
    @Published var flipped: [String: Bool] = [:]
    @Published var rolesRevealed: Bool = false
    @Published var roundIndex: Int = 0

    @Published var timerEnabled: Bool = false
    @Published var timerDuration: Int = 300
    @Published var roundStartTimestamp: Date?

    @Published var connectionLost: Bool = false

    private init() {}

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
                    self.phase = data["actNaturalPhase"] as? String ?? "reveal"

                    if let raw = data["actNaturalFlipped"] as? [String: Any] {
                        var out: [String: Bool] = [:]
                        for (key, val) in raw {
                            if let b = val as? Bool { out[key] = b }
                        }
                        self.flipped = out
                    } else {
                        self.flipped = [:]
                    }

                    self.rolesRevealed = data["actNaturalRolesRevealed"] as? Bool ?? false

                    if let ri = data["actNaturalRoundIndex"] as? Int {
                        self.roundIndex = ri
                    } else if let ri = data["actNaturalRoundIndex"] as? Int64 {
                        self.roundIndex = Int(ri)
                    } else {
                        self.roundIndex = 0
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
                        self.timerDuration = 300
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

    /// Clears singleton state and stops Firestore listener — use when leaving Act Natural or when another online game is shown.
    func teardownSession() {
        stopListening()
        resetLocalState()
    }

    func resetLocalState() {
        phase = "reveal"
        flipped = [:]
        rolesRevealed = false
        roundIndex = 0
        timerEnabled = false
        timerDuration = 300
        roundStartTimestamp = nil
        connectionLost = false
    }

    /// Host only — once when the play view appears.
    func initGameState(roomId: String) async throws {
        try await db.collection("rooms").document(roomId).updateData([
            "actNaturalPhase": "reveal",
            "actNaturalFlipped": [String: Bool](),
            "actNaturalRolesRevealed": false,
            "actNaturalRoundIndex": 0,
            "roundStartTimestamp": FieldValue.delete()
        ])
    }

    func hostAdvanceToNextRound(roomId: String, nextRoundIndex: Int) async throws {
        try await db.collection("rooms").document(roomId).updateData([
            "actNaturalRoundIndex": nextRoundIndex,
            "actNaturalPhase": "reveal",
            "actNaturalFlipped": [String: Bool](),
            "actNaturalRolesRevealed": false,
            "roundStartTimestamp": FieldValue.delete()
        ])
    }

    func markPlayerFlipped(roomId: String, uid: String) async throws {
        try await db.collection("rooms").document(roomId).updateData([
            "actNaturalFlipped.\(uid)": true
        ])
    }

    func hostProceedToDiscussion(roomId: String) async throws {
        var data: [String: Any] = [
            "actNaturalPhase": "discussion",
            "actNaturalRolesRevealed": false
        ]
        if timerEnabled {
            data["roundStartTimestamp"] = FieldValue.serverTimestamp()
        } else {
            data["roundStartTimestamp"] = FieldValue.delete()
        }
        try await db.collection("rooms").document(roomId).updateData(data)
    }

    func hostRevealRoles(roomId: String) async throws {
        try await db.collection("rooms").document(roomId).updateData([
            "actNaturalRolesRevealed": true,
            "roundStartTimestamp": FieldValue.delete()
        ])
    }

    func hostFinishGame(roomId: String) async throws {
        try await db.collection("rooms").document(roomId).updateData([
            "actNaturalPhase": "ended",
            "roundStartTimestamp": FieldValue.delete()
        ])
    }

    deinit {
        listener?.remove()
    }
}
