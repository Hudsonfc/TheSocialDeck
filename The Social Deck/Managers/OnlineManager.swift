//
//  OnlineManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class OnlineManager: ObservableObject {
    static let shared = OnlineManager()
    
    private let db = Firestore.firestore()
    private let onlineService = OnlineService.shared
    private let authManager = AuthManager.shared
    
    @Published var currentRoom: OnlineRoom?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isConnected: Bool = false
    
    nonisolated(unsafe) private var roomListener: ListenerRegistration?
    nonisolated(unsafe) private var roomInvitesListener: ListenerRegistration?
    private var roomInvitesListeningForUserId: String?
    private var isLeavingRoom = false

    /// Stale-room cleanup runs at most once per signed-in user per app process.
    private static var staleRoomCleanupCompletedForUserId: String?
    private var scheduledPostGameRoomDeletionTask: Task<Void, Never>?

    /// True when this device called `leaveRoom()` — avoids showing "host left" after self-initiated leave in `OnlineGameContainerView`.
    private(set) var userChoseToLeaveRoomSession = false

    private init() {}
    
    // MARK: - Room Lifecycle
    
    /// Creates a new room
    func createRoom(roomName: String, maxPlayers: Int, isPrivate: Bool, gameType: String? = nil) async {
        guard let userId = authManager.userProfile?.userId,
              let profile = authManager.userProfile else {
            errorMessage = "You must be signed in to create a room"
            return
        }
        
        isLoading = true
        errorMessage = nil
        userChoseToLeaveRoomSession = false

        do {
            // Create RoomPlayer from UserProfile
            let player = RoomPlayer(
                id: userId,
                username: profile.username,
                avatarType: profile.avatarType,
                avatarColor: profile.avatarColor,
                isReady: false,
                joinedAt: Date(),
                isHost: true
            )

            let room = try await onlineService.createRoom(
                roomName: roomName,
                maxPlayers: maxPlayers,
                isPrivate: isPrivate,
                createdBy: userId,
                playerProfile: player,
                gameType: gameType
            )
            
            currentRoom = room
            isConnected = true
            
            // Start listening to room updates
            startListeningToRoom(roomCode: room.roomCode)
            
        } catch {
            errorMessage = "Failed to create room: \(error.localizedDescription)"
            isConnected = false
        }
        
        isLoading = false
    }
    
    /// Joins an existing room
    func joinRoom(roomCode: String) async {
        guard let userId = authManager.userProfile?.userId,
              let profile = authManager.userProfile else {
            errorMessage = "You must be signed in to join a room"
            if !authManager.isAuthenticated {
                errorMessage = "Your session has expired. Please sign in again."
            }
            print("[OnlineManager.joinRoom] No profile/auth — aborting")
            return
        }

        if let currentRoom = currentRoom {
            if currentRoom.roomCode.uppercased() == roomCode.uppercased() {
                print("[OnlineManager.joinRoom] Already in this room — no-op")
                return
            } else {
                errorMessage = "You're already in a room. Please leave your current room first."
                print("[OnlineManager.joinRoom] Already in room \(currentRoom.roomCode) — cannot join \(roomCode)")
                return
            }
        }

        isLoading = true
        errorMessage = nil
        userChoseToLeaveRoomSession = false

        do {
            let normalizedCode = roomCode.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)

            guard !normalizedCode.isEmpty else {
                errorMessage = "Room code cannot be empty"
                isLoading = false
                return
            }

            print("[OnlineManager.joinRoom] Joining room \(normalizedCode) as \(userId) (\(profile.username))")

            let player = RoomPlayer(
                id: userId,
                username: profile.username,
                avatarType: profile.avatarType,
                avatarColor: profile.avatarColor,
                isReady: false,
                joinedAt: Date(),
                isHost: false
            )

            let room = try await onlineService.joinRoom(
                roomCode: normalizedCode,
                playerProfile: player
            )

            print("[OnlineManager.joinRoom] joinRoom returned successfully. Room code: \(room.roomCode), players: \(room.players.count)")
            currentRoom = room
            isConnected = true
            print("[OnlineManager.joinRoom] currentRoom is now set: \(currentRoom != nil)")

            startListeningToRoom(roomCode: normalizedCode)

        } catch {
            print("[OnlineManager.joinRoom] *** ERROR *** \(error)")
            if let nsError = error as NSError?, nsError.code == 401 || error.localizedDescription.contains("authenticated") {
                errorMessage = "Your session has expired. Please sign in again."
            } else if error.localizedDescription == "This room is full" {
                errorMessage = "Room Full: This room is full. Ask the host to increase the player limit or join another room."
            } else {
                errorMessage = "Failed to join room: \(error.localizedDescription)"
            }
            isConnected = false
        }

        isLoading = false
    }

    /// Adopts a room created outside the normal flow (e.g. matchmaking host) and attaches the room listener.
    func adoptRoomFromExternalCreate(_ room: OnlineRoom) {
        currentRoom = room
        isConnected = true
        isLoading = false
        errorMessage = nil
        userChoseToLeaveRoomSession = false
        startListeningToRoom(roomCode: room.roomCode)
    }
    
    /// Leaves the current room
    func leaveRoom() async {
        guard let roomCode = currentRoom?.roomCode,
              let userId = authManager.userProfile?.userId else {
            cancelScheduledPostGameRoomDeletion()
            cleanup()
            return
        }
        
        isLeavingRoom = true
        isLoading = true
        errorMessage = nil
        cancelScheduledPostGameRoomDeletion()
        userChoseToLeaveRoomSession = true

        do {
            try await onlineService.leaveRoom(roomCode: roomCode, playerId: userId)
            cleanup()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to leave room: \(error.localizedDescription)"
            cleanup()
        }
        
        isLoading = false
        isLeavingRoom = false
    }

    // MARK: - Stale rooms (launch)

    /// Runs `OnlineService.cleanupStaleRooms()` once per app launch for each signed-in user.
    func cleanupStaleRoomsOnLaunchIfNeeded() async {
        guard authManager.isAuthenticated, let uid = authManager.userProfile?.userId else { return }
        guard Self.staleRoomCleanupCompletedForUserId != uid else { return }
        Self.staleRoomCleanupCompletedForUserId = uid
        do {
            try await onlineService.cleanupStaleRooms()
        } catch {
            // Non-fatal; avoid surfacing to the user on launch
        }
    }

    // MARK: - Post–game-end room deletion (host)

    /// After a natural game end, delete the Firestore room after `delaySeconds` so players can finish the end screen.
    /// Only the host schedules this; deletion re-verifies host on the server read.
    func scheduleRoomDeletionAfterGameEnd(roomCode: String, delaySeconds: UInt64 = 60) {
        guard isHost else { return }
        scheduledPostGameRoomDeletionTask?.cancel()
        let code = roomCode
        scheduledPostGameRoomDeletionTask = Task {
            try? await Task.sleep(nanoseconds: delaySeconds * 1_000_000_000)
            guard !Task.isCancelled else { return }
            try? await onlineService.deleteRoomDocumentIfCurrentUserIsHost(roomCode: code)
            await MainActor.run {
                if OnlineManager.shared.currentRoom?.roomCode == code {
                    OnlineManager.shared.cleanup()
                }
            }
        }
    }

    func cancelScheduledPostGameRoomDeletion() {
        scheduledPostGameRoomDeletionTask?.cancel()
        scheduledPostGameRoomDeletionTask = nil
    }
    
    // MARK: - Player Actions
    
    /// Toggles the current player's ready status
    func toggleReadyStatus() async {
        guard let roomCode = currentRoom?.roomCode,
              let userId = authManager.userProfile?.userId else {
            errorMessage = "Not in a room"
            return
        }
        
        guard let currentPlayer = currentRoom?.players.first(where: { $0.id == userId }) else {
            errorMessage = "Player not found in room"
            return
        }
        
        let newReadyStatus = !currentPlayer.isReady
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await onlineService.updatePlayerReadyStatus(
                roomCode: roomCode,
                playerId: userId,
                isReady: newReadyStatus
            )
            // Room will update via listener
        } catch {
            errorMessage = "Failed to update ready status: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Room Settings (Host Only)
    
    /// Updates the selected game type (host only)
    func selectGameType(_ gameType: DeckType?) async {
        guard let roomCode = currentRoom?.roomCode else {
            errorMessage = "Not in a room"
            return
        }
        
        guard isHost else {
            errorMessage = "Only the host can change game settings"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await onlineService.updateRoomSettings(
                roomCode: roomCode,
                gameType: gameType,
                category: nil
            )
            // Room will update via listener
        } catch {
            errorMessage = "Failed to update game type: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Updates the selected category (host only)
    func selectCategory(_ category: String?) async {
        guard let roomCode = currentRoom?.roomCode else {
            errorMessage = "Not in a room"
            return
        }
        
        guard isHost else {
            errorMessage = "Only the host can change game settings"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await onlineService.updateRoomSettings(
                roomCode: roomCode,
                gameType: nil,
                category: category
            )
            // Room will update via listener
        } catch {
            errorMessage = "Failed to update category: \(error.localizedDescription)"
        }
        
        isLoading = false
    }

    /// Updates card count for classic games (host only). nil = use all cards.
    func updateCardCount(_ cardCount: Int?) async {
        guard let roomCode = currentRoom?.roomCode, isHost else { return }
        do {
            try await onlineService.updateCardCount(roomCode: roomCode, cardCount: cardCount)
            // Room listener will receive the updated room from Firestore
        } catch {
            errorMessage = "Failed to update settings"
        }
    }

    /// Updates host-selected categories for online classic/date/couple games.
    func updateClassicSelectedCategories(_ categories: [String]?) async {
        guard let roomCode = currentRoom?.roomCode, isHost else { return }
        do {
            try await onlineService.updateClassicSelectedCategories(roomCode: roomCode, categories: categories)
        } catch {
            errorMessage = "Failed to update categories"
        }
    }

    /// Updates Riddle Me This timer settings in the lobby (host only).
    func updateRiddleTimer(enabled: Bool, durationSeconds: Int) async {
        guard let roomCode = currentRoom?.roomCode, isHost else { return }
        do {
            try await onlineService.updateRiddleTimerSettings(
                roomCode: roomCode,
                timerEnabled: enabled,
                timerDuration: durationSeconds
            )
        } catch {
            errorMessage = "Failed to update timer settings"
        }
    }

    /// Act Natural lobby: two unknowns toggle (host only).
    func updateActNaturalTwoUnknowns(_ twoUnknowns: Bool) async {
        guard let roomCode = currentRoom?.roomCode, isHost else { return }
        do {
            try await onlineService.updateActNaturalTwoUnknowns(roomCode: roomCode, twoUnknowns: twoUnknowns)
        } catch {
            errorMessage = "Failed to update Act Natural settings"
        }
    }

    /// What Would You Do lobby: anonymous mode (host only).
    func updateWhatWouldYouDoAnonymousMode(_ anonymous: Bool) async {
        guard let roomCode = currentRoom?.roomCode, isHost else { return }
        do {
            try await onlineService.updateWhatWouldYouDoAnonymousMode(roomCode: roomCode, anonymous: anonymous)
        } catch {
            errorMessage = "Failed to update What Would You Do settings"
        }
    }

    /// Updates classic/date/couple turn mode in the lobby (host only).
    func updateClassicTurnsEnabled(_ enabled: Bool) async {
        guard let roomCode = currentRoom?.roomCode, isHost else { return }
        do {
            try await onlineService.updateClassicTurnsSetting(roomCode: roomCode, enabled: enabled)
        } catch {
            errorMessage = "Failed to update turn settings"
        }
    }

    /// Starts the game (host only)
    func startGame() async {
        guard let roomCode = currentRoom?.roomCode else {
            errorMessage = "Not in a room"
            return
        }
        
        guard isHost else {
            errorMessage = "Only the host can start the game"
            return
        }
        
        guard let room = currentRoom else {
            errorMessage = "Room not found"
            return
        }
        
        guard room.allPlayersReady && room.players.count >= 2 else {
            errorMessage = "All players must be ready and at least 2 players required"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await onlineService.startGame(roomCode: roomCode)
            // Room status will update via listener
        } catch {
            errorMessage = "Failed to start game: \(error.localizedDescription)"
        }
        
        isLoading = false
    }

    /// Host-only: return everyone from active game back to lobby.
    func returnRoomToLobby() async {
        guard let roomCode = currentRoom?.roomCode, isHost else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await onlineService.returnRoomToLobby(roomCode: roomCode)
        } catch {
            errorMessage = "Failed to return to lobby: \(error.localizedDescription)"
        }
        isLoading = false
    }

    /// Host-only: pass host to the next player and leave the in-game session (3+ players). Call `dismiss()` after success to leave the game UI.
    func hostLeaveGamePassHostToNext() async {
        guard let roomCode = currentRoom?.roomCode,
              let userId = authManager.userProfile?.userId,
              isHost else { return }

        isLeavingRoom = true
        isLoading = true
        errorMessage = nil
        userChoseToLeaveRoomSession = true

        do {
            try await onlineService.hostLeaveInGamePromoteNext(roomCode: roomCode, leavingPlayerId: userId)
            cleanup()
        } catch {
            userChoseToLeaveRoomSession = false
            errorMessage = "Failed to leave: \(error.localizedDescription)"
        }

        isLoading = false
        isLeavingRoom = false
    }
    
    // MARK: - Real-Time Listening
    
    /// Starts listening to room updates
    private func startListeningToRoom(roomCode: String) {
        // Remove existing listener if any
        removeRoomListener()
        
        roomListener = onlineService.listenToRoom(roomCode: roomCode) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let room):
                    self?.userChoseToLeaveRoomSession = false
                    self?.currentRoom = room
                    self?.isConnected = true
                    
                    // Check if room was deleted or player was removed
                    if let userId = self?.authManager.userProfile?.userId, self?.isLeavingRoom != true {
                        if !room.players.contains(where: { $0.id == userId }) {
                            self?.cleanup()
                            self?.errorMessage = "You were removed from the room"
                        }
                    }
                    
                case .failure(let error):
                    guard self?.isLeavingRoom != true else { return }
                    let errorMsg = error.localizedDescription
                    
                    if errorMsg.contains("not found") || errorMsg.contains("Room not found") {
                        self?.cleanup()
                        self?.errorMessage = "This room has been deleted or no longer exists"
                    } else {
                        self?.errorMessage = "Room update failed: \(errorMsg)"
                        self?.isConnected = false
                    }
                }
            }
        }
    }
    
    /// Removes the room listener
    func removeRoomListener() {
        roomListener?.remove()
        roomListener = nil
    }
    
    // MARK: - Cleanup
    
    /// Cleans up room state and listeners
    func cleanup() {
        cancelScheduledPostGameRoomDeletion()
        removeRoomListener()
        currentRoom = nil
        isConnected = false
    }
    
    deinit {
        roomListener?.remove()
    }
    
    // MARK: - Helper Properties
    
    /// Checks if current user is the host
    var isHost: Bool {
        guard let userId = authManager.userProfile?.userId,
              let room = currentRoom else {
            return false
        }
        return room.hostId == userId
    }
    
    /// Gets the current player from the room
    var currentPlayer: RoomPlayer? {
        guard let userId = authManager.userProfile?.userId,
              let room = currentRoom else {
            return nil
        }
        return room.players.first { $0.id == userId }
    }
    
    /// Checks if current player is ready
    var isCurrentPlayerReady: Bool {
        return currentPlayer?.isReady ?? false
    }
    
    // MARK: - Room Invites
    
    @Published var pendingRoomInvites: [RoomInvite] = []

    /// Invite IDs the user hid with a home-banner swipe (still pending server-side). Keeps profile/tab badges accurate until Decline/Accept.
    @Published private(set) var bannerSwipePinnedRoomInviteIds: Set<String> = []

    /// Use for home avatar, Friends “Rooms” tab, etc. Union of live pending docs and swipe-pinned IDs so a transient empty snapshot doesn’t zero the badge.
    var roomInviteCountForBadge: Int {
        let pids = Set(pendingRoomInvites.compactMap(\.id))
        return pids.union(bannerSwipePinnedRoomInviteIds).count
    }

    func pinRoomInviteForBadgeAfterBannerSwipeDismiss(inviteId: String) {
        bannerSwipePinnedRoomInviteIds.insert(inviteId)
    }

    private func unpinRoomInviteForBadge(inviteId: String) {
        bannerSwipePinnedRoomInviteIds.remove(inviteId)
    }

    /// Start realtime listener so invite UI/badges update instantly.
    func startListeningToRoomInvites() {
        guard let currentUserId = authManager.userProfile?.userId else { return }
        if roomInvitesListeningForUserId == currentUserId, roomInvitesListener != nil {
            return
        }
        stopListeningToRoomInvites()
        roomInvitesListeningForUserId = currentUserId

        let query = db.collection("roomInvites")
            .whereField("toUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: RoomInviteStatus.pending.rawValue)
            .whereField("expiresAt", isGreaterThan: Timestamp(date: Date()))
            .order(by: "createdAt", descending: true)

        roomInvitesListener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            Task { @MainActor in
                if let error = error {
                    self.errorMessage = "Failed to listen to invites: \(error.localizedDescription)"
                    return
                }

                guard let snapshot = snapshot else {
                    self.pendingRoomInvites = []
                    return
                }

                self.pendingRoomInvites = snapshot.documents.compactMap { doc in
                    var invite = try? doc.data(as: RoomInvite.self)
                    invite?.id = doc.documentID
                    return invite
                }

                let pids = Set(self.pendingRoomInvites.compactMap(\.id))
                if !pids.isEmpty {
                    self.bannerSwipePinnedRoomInviteIds = self.bannerSwipePinnedRoomInviteIds.intersection(pids)
                }
            }
        }

        Task { @MainActor in
            await self.prefetchPendingRoomInvitesFromServer()
        }
    }

    func stopListeningToRoomInvites() {
        roomInvitesListener?.remove()
        roomInvitesListener = nil
        pendingRoomInvites = []
        bannerSwipePinnedRoomInviteIds = []
        roomInvitesListeningForUserId = nil
    }
    
    /// Send a room invite to a friend
    func sendRoomInvite(toUserId: String) async {
        guard let room = currentRoom else {
            errorMessage = "No active room"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await onlineService.sendRoomInvite(
                roomCode: room.roomCode,
                roomName: room.roomName,
                toUserId: toUserId
            )

            // Push notification — fire-and-forget
            if let senderUsername = authManager.userProfile?.username {
                let gameName = room.selectedGameType ?? "a game"
                Task {
                    await NotificationManager.shared.sendRoomInviteNotification(
                        toUserId: toUserId,
                        fromUsername: senderUsername,
                        gameName: gameName
                    )
                }
            }
        } catch {
            errorMessage = "Failed to send invite: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Load pending room invites (e.g. Room Invites UI).
    func loadPendingRoomInvites() async {
        await loadPendingRoomInvitesInternal(showGlobalLoading: true)
    }

    /// One-shot fetch for home badge / banner without toggling global `isLoading` (avoids blocking other UI).
    func prefetchPendingRoomInvitesFromServer() async {
        await loadPendingRoomInvitesInternal(showGlobalLoading: false)
    }

    private func loadPendingRoomInvitesInternal(showGlobalLoading: Bool) async {
        if showGlobalLoading {
            isLoading = true
        }
        errorMessage = nil
        defer {
            if showGlobalLoading {
                isLoading = false
            }
        }

        do {
            pendingRoomInvites = try await onlineService.getPendingRoomInvites()
            let pids = Set(pendingRoomInvites.compactMap(\.id))
            if !pids.isEmpty {
                bannerSwipePinnedRoomInviteIds = bannerSwipePinnedRoomInviteIds.intersection(pids)
            }
        } catch {
            errorMessage = "Failed to load invites: \(error.localizedDescription)"
        }
    }
    
    /// Accept a room invite
    func acceptRoomInvite(_ inviteId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let invite = pendingRoomInvites.first { $0.id == inviteId }
            guard let roomCode = invite?.roomCode else {
                print("[OnlineManager] acceptRoomInvite — invite \(inviteId) not found in pendingRoomInvites")
                errorMessage = "Invite not found"
                isLoading = false
                return
            }
            
            print("[OnlineManager] acceptRoomInvite — marking invite \(inviteId) as accepted (room: \(roomCode))")
            try await onlineService.acceptRoomInvite(inviteId)
            
            pendingRoomInvites.removeAll { $0.id == inviteId }
            unpinRoomInviteForBadge(inviteId: inviteId)
            
            print("[OnlineManager] acceptRoomInvite — joining room \(roomCode)")
            await joinRoom(roomCode: roomCode)
            
            if currentRoom != nil {
                print("[OnlineManager] acceptRoomInvite — joined successfully, currentRoom set")
            } else {
                print("[OnlineManager] acceptRoomInvite — joinRoom finished but currentRoom is nil. error: \(errorMessage ?? "none")")
            }
            
        } catch {
            print("[OnlineManager] acceptRoomInvite — error: \(error)")
            errorMessage = "Failed to accept invite: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Decline a room invite
    func declineRoomInvite(_ inviteId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await onlineService.declineRoomInvite(inviteId)
            pendingRoomInvites.removeAll { $0.id == inviteId }
            unpinRoomInviteForBadge(inviteId: inviteId)
        } catch {
            errorMessage = "Failed to decline invite: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Room Management
    
    /// Kick a player from the room (host only)
    func kickPlayer(_ playerId: String) async throws {
        guard let roomCode = currentRoom?.roomCode else {
            throw NSError(domain: "OnlineManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not in a room"])
        }
        
        guard isHost else {
            throw NSError(domain: "OnlineManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can kick players"])
        }
        
        guard playerId != authManager.userProfile?.userId else {
            throw NSError(domain: "OnlineManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot kick yourself"])
        }
        
        try await onlineService.kickPlayer(roomCode: roomCode, playerId: playerId)
        // Room will update via listener
    }
}
