//
//  MatchmakingService.swift
//  The Social Deck
//
//  Firestore-backed queue: when ≥4 players share a gameType, earliest joiner creates a room
//  and writes `matchedRoomCode` on other queued players' documents. They join via OnlineService,
//  then all queue documents are removed.
//
//  Firestore rules must allow: read on matchmaking for your matchmaking flow; each user create/update/delete
//  own doc; and (typically) the designated host must be allowed to update `matchedRoomCode` on peers'
//  documents, or use a Cloud Function to assign matches.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class MatchmakingService {
    static let shared = MatchmakingService()

    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    private var queueListener: ListenerRegistration?
    private var selfDocumentListener: ListenerRegistration?

    /// Game type for the active queue session (must match listener filter).
    private var activeGameType: String?
    /// Profile used when joining the queue and when calling `joinRoom`.
    private var queuedPlayerProfile: RoomPlayer?
    /// Prevents duplicate host match formation from rapid snapshot churn.
    private var isFormingMatch = false
    /// Prevents duplicate `joinRoom` if the self-doc listener fires more than once.
    private var didCompleteMatchJoin = false

    private init() {}

    // MARK: - Public API

    /// Enters the matchmaking queue for `gameType` and starts listening for a full lobby.
    func joinQueue(gameType: String, playerProfile: RoomPlayer) {
        leaveQueue()

        guard let uid = auth.currentUser?.uid, uid == playerProfile.id else {
            print("[MatchmakingService] joinQueue aborted: not signed in or profile id mismatch")
            return
        }

        activeGameType = gameType
        queuedPlayerProfile = playerProfile
        didCompleteMatchJoin = false

        let docRef = db.collection(Self.collectionName).document(uid)
        let payload: [String: Any] = [
            FieldKeys.userId: uid,
            FieldKeys.username: playerProfile.username,
            FieldKeys.avatarName: playerProfile.avatarType,
            FieldKeys.joinedAt: FieldValue.serverTimestamp(),
            FieldKeys.gameType: gameType
        ]

        Task {
            do {
                try await docRef.setData(payload, merge: false)
                await MainActor.run {
                    self.attachQueueListener(gameType: gameType)
                    self.attachSelfDocumentListener(uid: uid)
                }
            } catch {
                print("[MatchmakingService] joinQueue write failed: \(error.localizedDescription)")
                await MainActor.run { self.clearSessionState(removeFirestoreDoc: false) }
            }
        }
    }

    /// Leaves the queue: removes Firestore document (best effort) and all listeners.
    func leaveQueue() {
        queueListener?.remove()
        queueListener = nil
        selfDocumentListener?.remove()
        selfDocumentListener = nil

        let uid = auth.currentUser?.uid
        isFormingMatch = false

        if let uid {
            Task {
                try? await db.collection(Self.collectionName).document(uid).delete()
            }
        }

        clearSessionState(removeFirestoreDoc: false)
    }

    // MARK: - Firestore

    private static let collectionName = "matchmaking"

    private enum FieldKeys {
        static let userId = "userId"
        static let username = "username"
        static let avatarName = "avatarName"
        static let joinedAt = "joinedAt"
        static let gameType = "gameType"
        static let matchedRoomCode = "matchedRoomCode"
    }

    private func attachQueueListener(gameType: String) {
        queueListener?.remove()
        queueListener = db.collection(Self.collectionName)
            .whereField(FieldKeys.gameType, isEqualTo: gameType)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    print("[MatchmakingService] queue listener error: \(error.localizedDescription)")
                    return
                }
                guard let snapshot else { return }
                Task { @MainActor in
                    self.handleQueueSnapshot(snapshot)
                }
            }
    }

    /// Observes only the current user's document so non-hosts react when `matchedRoomCode` is set.
    private func attachSelfDocumentListener(uid: String) {
        selfDocumentListener?.remove()
        selfDocumentListener = db.collection(Self.collectionName)
            .document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    print("[MatchmakingService] self doc listener error: \(error.localizedDescription)")
                    return
                }
                guard let snapshot, snapshot.exists,
                      let data = snapshot.data(),
                      let code = data[FieldKeys.matchedRoomCode] as? String,
                      !code.isEmpty
                else { return }

                Task { await self.handleMatchedRoomCode(code: code) }
            }
    }

    @MainActor
    private func handleQueueSnapshot(_ snapshot: QuerySnapshot) {
        guard let uid = auth.currentUser?.uid,
              let gameType = activeGameType,
              !isFormingMatch
        else { return }

        let searching = snapshot.documents.compactMap { doc -> (String, Date)? in
            guard (doc.data()[FieldKeys.matchedRoomCode] as? String)?.isEmpty != false else { return nil }
            guard let ts = doc.data()[FieldKeys.joinedAt] as? Timestamp else { return nil }
            let id = doc.documentID
            return (id, ts.dateValue())
        }

        guard searching.count >= Self.requiredMatchCount else { return }

        let sorted = searching.sorted {
            if $0.1 != $1.1 { return $0.1 < $1.1 }
            return $0.0 < $1.0
        }

        let batchIds = sorted.prefix(Self.requiredMatchCount).map(\.0)
        guard batchIds.count == Self.requiredMatchCount else { return }

        let hostId = batchIds[0]
        guard hostId == uid else { return }

        guard let playerProfile = queuedPlayerProfile else { return }

        isFormingMatch = true

        Task {
            await self.formMatchAsHost(
                gameType: gameType,
                hostPlayer: playerProfile,
                batchUserIds: Array(batchIds)
            )
        }
    }

    private func formMatchAsHost(
        gameType: String,
        hostPlayer: RoomPlayer,
        batchUserIds: [String]
    ) async {
        defer {
            Task { @MainActor [weak self] in
                self?.isFormingMatch = false
            }
        }

        let others = Array(batchUserIds.dropFirst())
        guard others.count == Self.requiredMatchCount - 1 else { return }

        do {
            let room = try await OnlineService.shared.createRoom(
                roomName: "Matchmaking",
                maxPlayers: Self.requiredMatchCount,
                isPrivate: false,
                createdBy: hostPlayer.id,
                playerProfile: RoomPlayer(
                    id: hostPlayer.id,
                    username: hostPlayer.username,
                    avatarType: hostPlayer.avatarType,
                    avatarColor: hostPlayer.avatarColor,
                    isReady: false,
                    joinedAt: Date(),
                    isHost: true
                ),
                gameType: gameType
            )

            let code = room.roomCode

            for otherId in others {
                let ref = db.collection(Self.collectionName).document(otherId)
                try await ref.updateData([FieldKeys.matchedRoomCode: code])
            }

            await MainActor.run {
                OnlineManager.shared.adoptRoomFromExternalCreate(room)
            }

            try await db.collection(Self.collectionName).document(hostPlayer.id).delete()
        } catch {
            print("[MatchmakingService] formMatchAsHost failed: \(error.localizedDescription)")
        }
    }

    private func handleMatchedRoomCode(code: String) async {
        guard !didCompleteMatchJoin else { return }
        guard let profile = queuedPlayerProfile else { return }

        didCompleteMatchJoin = true

        Task { @MainActor [weak self] in
            guard let self else { return }
            await self.performNonHostMatchJoin(code: code, profileId: profile.id)
        }
    }

    @MainActor
    private func performNonHostMatchJoin(code: String, profileId: String) async {
        await OnlineManager.shared.joinRoom(roomCode: code)

        if OnlineManager.shared.currentRoom != nil, OnlineManager.shared.errorMessage == nil {
            queueListener?.remove()
            queueListener = nil
            selfDocumentListener?.remove()
            selfDocumentListener = nil
            clearSessionState(removeFirestoreDoc: false)
            Task {
                try? await db.collection(Self.collectionName).document(profileId).delete()
            }
        } else {
            didCompleteMatchJoin = false
            print("[MatchmakingService] joinRoom did not attach a room; staying in queue for retry")
        }
    }

    private func clearSessionState(removeFirestoreDoc: Bool) {
        activeGameType = nil
        queuedPlayerProfile = nil
        didCompleteMatchJoin = false
        isFormingMatch = false
    }

    private static let requiredMatchCount = 4
}
