//
//  SyncService.swift
//  The Social Deck
//

import Foundation
import FirebaseFirestore
import Combine

/// Handles real-time card index synchronisation for classic online card games.
/// The host writes the current card index to the room document in Firestore;
/// all other players listen and their view updates to match.
@MainActor
class SyncService: ObservableObject {
    static let shared = SyncService()

    private let db = Firestore.firestore()

    /// Reflects the latest card index received from Firestore.
    @Published var remoteCardIndex: Int = 0

    /// True when the Firestore listener has fired an error (e.g. connection lost).
    /// Automatically clears when a successful snapshot is received.
    @Published var connectionLost: Bool = false

    private var cardIndexListener: ListenerRegistration?

    private init() {}

    // MARK: - Host writes

    /// Call this from the host whenever the card index advances.
    /// - Parameters:
    ///   - roomId: The room document ID (same as roomCode).
    ///   - index: The new card index to write.
    func updateCardIndex(roomId: String, index: Int) async throws {
        try await db.collection("rooms")
            .document(roomId)
            .updateData(["currentCardIndex": index])
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

                guard
                    let data = snapshot?.data(),
                    let index = data["currentCardIndex"] as? Int
                else { return }

                Task { @MainActor in
                    self.connectionLost = false
                    self.remoteCardIndex = index
                }
            }
    }

    /// Stop listening to card index changes.
    func stopListening() {
        cardIndexListener?.remove()
        cardIndexListener = nil
        connectionLost = false
    }

    deinit {
        cardIndexListener?.remove()
    }
}
