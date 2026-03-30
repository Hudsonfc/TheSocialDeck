//
//  SyncService.swift
//  The Social Deck
//

import Foundation
import FirebaseFirestore
import Combine

/// Handles real-time card index synchronisation for classic online card games.
/// The host writes the current card index and flip state to the room document in Firestore;
/// all other players listen and their view updates to match.
@MainActor
class SyncService: ObservableObject {
    static let shared = SyncService()

    private let db = Firestore.firestore()

    /// Reflects the latest card index received from Firestore.
    @Published var remoteCardIndex: Int = 0

    /// When true, the host has flipped the current card; non-hosts mirror this (no local tap flip).
    @Published var remoteClassicCardFlipped: Bool = false

    /// Bumps on each Firestore snapshot so views can apply index + flip together (avoids ordering glitches).
    @Published var classicRemoteSyncVersion: Int = 0

    /// Lobby setting reflected on room document: when true, classic/date/couple games use rotating turns.
    @Published var remoteClassicTurnsEnabled: Bool = false

    /// User id whose turn it is for online Truth or Dare / Would You Rather.
    @Published var remoteTurnPlayerId: String = ""

    /// In TOR, `currentIndex` may differ from game position when showing the switched truth/dare card.
    @Published var remoteTorDisplayIndex: Int = 0

    @Published var remoteTorHasAccepted: Bool = false

    /// Would You Rather: "A", "B", or empty when none selected.
    @Published var remoteWyrSelectedOption: String = ""

    /// Quickfire Couples: "A", "B", or empty when none selected.
    @Published var remoteQuickfireSelectedOption: String = ""

    /// True when the Firestore listener has fired an error (e.g. connection lost).
    /// Automatically clears when a successful snapshot is received.
    @Published var connectionLost: Bool = false

    private var cardIndexListener: ListenerRegistration?

    private init() {}

    // MARK: - Host writes

    /// Call this from the host whenever the card index advances or the card is reset to face-down.
    /// - Parameters:
    ///   - roomId: The room document ID (same as roomCode).
    ///   - index: The new card index to write.
    ///   - isFlipped: Whether the current card is showing its back (flipped) side.
    func updateClassicCardProgress(roomId: String, index: Int, isFlipped: Bool) async throws {
        try await db.collection("rooms")
            .document(roomId)
            .updateData([
                "currentCardIndex": index,
                "classicCardFlipped": isFlipped
            ])
    }

    /// Online Truth or Dare: full sync including switched card index, accept state, and whose turn it is.
    func updateTruthOrDareOnlineState(
        roomId: String,
        gamePosition: Int,
        displayIndex: Int,
        isFlipped: Bool,
        hasAccepted: Bool,
        turnPlayerId: String
    ) async throws {
        try await db.collection("rooms").document(roomId).updateData([
            "currentCardIndex": gamePosition,
            "classicCardFlipped": isFlipped,
            "torDisplayIndex": displayIndex,
            "torHasAccepted": hasAccepted,
            "classicTurnPlayerId": turnPlayerId
        ])
    }

    /// Online Would You Rather: card index, flip, selection visible to all, and turn.
    func updateWouldYouRatherOnlineState(
        roomId: String,
        cardIndex: Int,
        isFlipped: Bool,
        turnPlayerId: String,
        selectedOption: String?
    ) async throws {
        var payload: [String: Any] = [
            "currentCardIndex": cardIndex,
            "classicCardFlipped": isFlipped,
            "classicTurnPlayerId": turnPlayerId
        ]
        if let opt = selectedOption {
            payload["wyrSelectedOption"] = opt
        } else {
            payload["wyrSelectedOption"] = FieldValue.delete()
        }
        try await db.collection("rooms").document(roomId).updateData(payload)
    }

    /// Generic online classic/date/couple sync for turn-based rounds (non TOR/WYR specific state).
    func updateClassicTurnRoundState(
        roomId: String,
        cardIndex: Int,
        isFlipped: Bool,
        turnPlayerId: String
    ) async throws {
        try await db.collection("rooms").document(roomId).updateData([
            "currentCardIndex": cardIndex,
            "classicCardFlipped": isFlipped,
            "classicTurnPlayerId": turnPlayerId
        ])
    }

    /// Online Quickfire Couples: card index, flip, option selection, and turn.
    func updateQuickfireCouplesOnlineState(
        roomId: String,
        cardIndex: Int,
        isFlipped: Bool,
        turnPlayerId: String,
        selectedOption: String?
    ) async throws {
        var payload: [String: Any] = [
            "currentCardIndex": cardIndex,
            "classicCardFlipped": isFlipped,
            "classicTurnPlayerId": turnPlayerId
        ]
        if let opt = selectedOption {
            payload["quickfireSelectedOption"] = opt
        } else {
            payload["quickfireSelectedOption"] = FieldValue.delete()
        }
        try await db.collection("rooms").document(roomId).updateData(payload)
    }

    /// Host-only: set first player as turn holder when field is missing (TOR / WYR online).
    func seedClassicTurnPlayerIfNeeded(roomId: String, players: [RoomPlayer]) async throws {
        guard let firstId = players.first?.id, !firstId.isEmpty else { return }
        let ref = db.collection("rooms").document(roomId)
        let snap = try await ref.getDocument()
        guard let data = snap.data() else { return }
        let existing = (data["classicTurnPlayerId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !existing.isEmpty { return }
        let idx = data["currentCardIndex"] as? Int ?? 0
        try await ref.updateData([
            "classicTurnPlayerId": firstId,
            "torDisplayIndex": data["torDisplayIndex"] as? Int ?? idx,
            "torHasAccepted": false,
            "wyrSelectedOption": FieldValue.delete(),
            "quickfireSelectedOption": FieldValue.delete()
        ])
    }

    static func nextClockwisePlayerId(from currentId: String, in players: [RoomPlayer]) -> String {
        let ids = players.map(\.id)
        guard !ids.isEmpty, let i = ids.firstIndex(of: currentId) else { return ids.first ?? currentId }
        return ids[(i + 1) % ids.count]
    }

    /// Legacy path — prefer `updateClassicCardProgress` so flip state stays in sync.
    func updateCardIndex(roomId: String, index: Int) async throws {
        try await updateClassicCardProgress(roomId: roomId, index: index, isFlipped: false)
    }

    // MARK: - All players listen

    /// Start listening to card index changes on the given room.
    /// Published `remoteCardIndex` is updated on every Firestore snapshot.
    /// - Parameter roomId: The room document ID (same as roomCode).
    func startListening(roomId: String) {
        stopListening()
        cardIndexListener = db.collection("rooms")
            .document(roomId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if error != nil {
                    Task { @MainActor in
                        self.connectionLost = true
                    }
                    return
                }

                guard let data = snapshot?.data() else { return }

                Task { @MainActor in
                    self.connectionLost = false
                    self.remoteClassicTurnsEnabled = data["classicTurnsEnabled"] as? Bool ?? false
                    if let index = data["currentCardIndex"] as? Int {
                        self.remoteCardIndex = index
                    }
                    if let flipped = data["classicCardFlipped"] as? Bool {
                        self.remoteClassicCardFlipped = flipped
                    } else {
                        self.remoteClassicCardFlipped = false
                    }

                    if let tid = data["classicTurnPlayerId"] as? String {
                        self.remoteTurnPlayerId = tid
                    } else {
                        self.remoteTurnPlayerId = ""
                    }

                    if let tdi = data["torDisplayIndex"] as? Int {
                        self.remoteTorDisplayIndex = tdi
                    } else {
                        self.remoteTorDisplayIndex = self.remoteCardIndex
                    }

                    if let ta = data["torHasAccepted"] as? Bool {
                        self.remoteTorHasAccepted = ta
                    } else {
                        self.remoteTorHasAccepted = false
                    }

                    if let wyr = data["wyrSelectedOption"] as? String, !wyr.isEmpty {
                        self.remoteWyrSelectedOption = wyr
                    } else {
                        self.remoteWyrSelectedOption = ""
                    }

                    if let qfc = data["quickfireSelectedOption"] as? String, !qfc.isEmpty {
                        self.remoteQuickfireSelectedOption = qfc
                    } else {
                        self.remoteQuickfireSelectedOption = ""
                    }

                    self.classicRemoteSyncVersion += 1
                }
            }
    }

    /// Stop listening to card index changes.
    func stopListening() {
        cardIndexListener?.remove()
        cardIndexListener = nil
        connectionLost = false
        remoteClassicCardFlipped = false
        remoteClassicTurnsEnabled = false
        remoteTurnPlayerId = ""
        remoteTorDisplayIndex = 0
        remoteTorHasAccepted = false
        remoteWyrSelectedOption = ""
        remoteQuickfireSelectedOption = ""
        classicRemoteSyncVersion = 0
    }

    deinit {
        cardIndexListener?.remove()
    }
}
