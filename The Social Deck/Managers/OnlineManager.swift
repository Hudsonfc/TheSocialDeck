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
    
    private let onlineService = OnlineService.shared
    private let authManager = AuthManager.shared
    
    @Published var currentRoom: OnlineRoom?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isConnected: Bool = false
    
    nonisolated(unsafe) private var roomListener: ListenerRegistration?
    
    private init() {}
    
    // MARK: - Room Lifecycle
    
    /// Creates a new room
    func createRoom(roomName: String, maxPlayers: Int, isPrivate: Bool) async {
        guard let userId = authManager.userProfile?.userId,
              let profile = authManager.userProfile else {
            errorMessage = "You must be signed in to create a room"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
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
                playerProfile: player
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
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Normalize room code (uppercase)
            let normalizedCode = roomCode.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !normalizedCode.isEmpty else {
                errorMessage = "Room code cannot be empty"
                isLoading = false
                return
            }
            
            // Create RoomPlayer from UserProfile
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
            
            currentRoom = room
            isConnected = true
            
            // Start listening to room updates
            startListeningToRoom(roomCode: normalizedCode)
            
        } catch {
            errorMessage = "Failed to join room: \(error.localizedDescription)"
            isConnected = false
        }
        
        isLoading = false
    }
    
    /// Leaves the current room
    func leaveRoom() async {
        guard let roomCode = currentRoom?.roomCode,
              let userId = authManager.userProfile?.userId else {
            cleanup()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await onlineService.leaveRoom(roomCode: roomCode, playerId: userId)
            cleanup()
        } catch {
            errorMessage = "Failed to leave room: \(error.localizedDescription)"
            // Still cleanup locally even if Firestore update fails
            cleanup()
        }
        
        isLoading = false
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
    
    // MARK: - Real-Time Listening
    
    /// Starts listening to room updates
    private func startListeningToRoom(roomCode: String) {
        // Remove existing listener if any
        removeRoomListener()
        
        roomListener = onlineService.listenToRoom(roomCode: roomCode) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let room):
                    self?.currentRoom = room
                    self?.isConnected = true
                    
                    // Check if room was deleted or player was removed
                    if let userId = self?.authManager.userProfile?.userId {
                        if !room.players.contains(where: { $0.id == userId }) {
                            // Player was removed from room
                            self?.cleanup()
                            self?.errorMessage = "You were removed from the room"
                        }
                    }
                    
                case .failure(let error):
                    self?.errorMessage = "Room update failed: \(error.localizedDescription)"
                    self?.isConnected = false
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
        } catch {
            errorMessage = "Failed to send invite: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Load pending room invites
    func loadPendingRoomInvites() async {
        isLoading = true
        errorMessage = nil
        
        do {
            pendingRoomInvites = try await onlineService.getPendingRoomInvites()
        } catch {
            errorMessage = "Failed to load invites: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Accept a room invite
    func acceptRoomInvite(_ inviteId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let invite = pendingRoomInvites.first { $0.id == inviteId }
            guard let roomCode = invite?.roomCode else {
                errorMessage = "Invite not found"
                isLoading = false
                return
            }
            
            try await onlineService.acceptRoomInvite(inviteId)
            
            // Remove from pending invites
            pendingRoomInvites.removeAll { $0.id == inviteId }
            
            // Join the room
            await joinRoom(roomCode: roomCode)
            
        } catch {
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
