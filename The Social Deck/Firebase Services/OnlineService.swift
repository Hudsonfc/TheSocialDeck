//
//  OnlineService.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class OnlineService {
    static let shared = OnlineService()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private init() {}
    
    // MARK: - Room Code Generation
    
    /// Generates a unique room code (4-6 uppercase alphanumeric characters)
    private func generateRoomCode() async throws -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let codeLength = 4
        
        var attempts = 0
        let maxAttempts = 10
        
        while attempts < maxAttempts {
            let code = String((0..<codeLength).map { _ in characters.randomElement()! })
            
            // Check if code already exists
            let roomRef = db.collection("rooms").document(code)
            let snapshot = try await roomRef.getDocument()
            
            if !snapshot.exists {
                return code
            }
            
            attempts += 1
        }
        
        throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate unique room code after \(maxAttempts) attempts"])
    }
    
    // MARK: - Room Creation
    
    /// Creates a new room in Firestore
    func createRoom(
        roomName: String,
        maxPlayers: Int,
        isPrivate: Bool,
        createdBy: String,
        playerProfile: RoomPlayer
    ) async throws -> OnlineRoom {
        guard let currentUser = auth.currentUser, currentUser.uid == createdBy else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let roomCode = try await generateRoomCode()
        
        let room = OnlineRoom(
            roomCode: roomCode,
            roomName: roomName,
            createdBy: createdBy,
            createdAt: Date(),
            status: .waiting,
            maxPlayers: maxPlayers,
            isPrivate: isPrivate,
            players: [playerProfile],
            hostId: createdBy
        )
        
        let roomRef = db.collection("rooms").document(roomCode)
        try await roomRef.setData(from: room)
        
        return room
    }
    
    // MARK: - Room Joining
    
    /// Joins an existing room
    func joinRoom(roomCode: String, playerProfile: RoomPlayer) async throws -> OnlineRoom {
        guard auth.currentUser != nil else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, var room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        // Check if room is full
        guard room.players.count < room.maxPlayers else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room is full"])
        }
        
        // Check if room is in game (can't join during active game)
        guard room.status == .waiting else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot join room while game is in progress"])
        }
        
        // Check if player is already in room
        guard !room.players.contains(where: { $0.id == playerProfile.id }) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Already in this room"])
        }
        
        // Add player to room
        room.players.append(playerProfile)
        
        // Encode players array properly for Firestore
        let encoder = Firestore.Encoder()
        let playersData = try room.players.map { try encoder.encode($0) }
        try await roomRef.updateData(["players": playersData])
        
        return room
    }
    
    // MARK: - Room Leaving
    
    /// Leaves a room (removes player from room)
    func leaveRoom(roomCode: String, playerId: String) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, var room = try? snapshot.data(as: OnlineRoom.self) else {
            // Room doesn't exist, that's fine - we're already out
            return
        }
        
        // Remove player from room
        room.players.removeAll { $0.id == playerId }
        
        // If room is empty, delete it
        if room.players.isEmpty {
            try await roomRef.delete()
            return
        }
        
        // If host left, transfer host to next player (or first player)
        if room.hostId == playerId {
            room.hostId = room.players.first?.id ?? ""
            // Update the first player to be host
            if var firstPlayer = room.players.first {
                firstPlayer.isHost = true
                room.players[0] = firstPlayer
            }
            
            let encoder = Firestore.Encoder()
            let playersData = try room.players.map { try encoder.encode($0) }
            try await roomRef.updateData([
                "players": playersData,
                "hostId": room.hostId
            ])
        } else {
            // Just update players array
            let encoder = Firestore.Encoder()
            let playersData = try room.players.map { try encoder.encode($0) }
            try await roomRef.updateData(["players": playersData])
        }
    }
    
    // MARK: - Room Updates
    
    /// Updates a player's ready status
    func updatePlayerReadyStatus(roomCode: String, playerId: String, isReady: Bool) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, var room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        // Update player's ready status
        if let index = room.players.firstIndex(where: { $0.id == playerId }) {
            room.players[index].isReady = isReady
            let encoder = Firestore.Encoder()
            let playersData = try room.players.map { try encoder.encode($0) }
            try await roomRef.updateData(["players": playersData])
        }
    }
    
    /// Updates room settings (game type, category) - host only
    func updateRoomSettings(roomCode: String, gameType: DeckType?, category: String?) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can update room settings"])
        }
        
        var updateData: [String: Any] = [:]
        
        if let gameType = gameType {
            updateData["selectedGameType"] = gameType.stringValue
        } else {
            updateData["selectedGameType"] = FieldValue.delete()
        }
        
        if let category = category {
            updateData["selectedCategory"] = category
        } else {
            updateData["selectedCategory"] = FieldValue.delete()
        }
        
        try await roomRef.updateData(updateData)
    }
    
    /// Starts the game (updates room status to .starting, then .inGame)
    func startGame(roomCode: String) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can start the game"])
        }
        
        guard room.status == .waiting else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Game already started or ended"])
        }
        
        guard room.allPlayersReady && room.players.count >= 2 else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "All players must be ready and at least 2 players required"])
        }
        
        // Update room status to inGame and set game started time
        try await roomRef.updateData([
            "status": RoomStatus.inGame.rawValue,
            "gameStartedAt": Timestamp(date: Date())
        ])
    }
    
    // MARK: - Room Listening
    
    /// Listens to room updates in real-time
    func listenToRoom(roomCode: String, completion: @escaping (Result<OnlineRoom, Error>) -> Void) -> ListenerRegistration {
        let roomRef = db.collection("rooms").document(roomCode)
        
        return roomRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])))
                return
            }
            
            do {
                let room = try snapshot.data(as: OnlineRoom.self)
                completion(.success(room))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Room Validation
    
    /// Validates if a room code exists and can be joined
    func validateRoomCode(_ roomCode: String) async throws -> Bool {
        let roomRef = db.collection("rooms").document(roomCode.uppercased())
        let snapshot = try await roomRef.getDocument()
        return snapshot.exists
    }
    
    /// Gets a room by code (without joining)
    func getRoom(roomCode: String) async throws -> OnlineRoom? {
        let roomRef = db.collection("rooms").document(roomCode.uppercased())
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists else {
            return nil
        }
        
        return try? snapshot.data(as: OnlineRoom.self)
    }
    
    // MARK: - Room Invites
    
    /// Send a room invite to a user
    func sendRoomInvite(roomCode: String, roomName: String, toUserId: String) async throws {
        guard let fromUserId = auth.currentUser?.uid else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Check if invite already exists and is pending
        let existingInviteQuery = db.collection("roomInvites")
            .whereField("roomCode", isEqualTo: roomCode)
            .whereField("toUserId", isEqualTo: toUserId)
            .whereField("status", isEqualTo: RoomInviteStatus.pending.rawValue)
            .limit(to: 1)
        
        let existingInviteSnapshot = try await existingInviteQuery.getDocuments()
        if !existingInviteSnapshot.documents.isEmpty {
            // Invite already exists and is pending
            return
        }
        
        // Create new invite
        let invite = RoomInvite(
            roomCode: roomCode,
            roomName: roomName,
            fromUserId: fromUserId,
            toUserId: toUserId
        )
        
        let _ = try db.collection("roomInvites").addDocument(from: invite)
    }
    
    /// Get pending room invites for current user
    func getPendingRoomInvites() async throws -> [RoomInvite] {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let query = db.collection("roomInvites")
            .whereField("toUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: RoomInviteStatus.pending.rawValue)
            .whereField("expiresAt", isGreaterThan: Timestamp(date: Date()))
            .order(by: "createdAt", descending: true)
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents.compactMap { doc -> RoomInvite? in
            var invite = try? doc.data(as: RoomInvite.self)
            invite?.id = doc.documentID
            return invite
        }
    }
    
    /// Accept a room invite
    func acceptRoomInvite(_ inviteId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let inviteRef = db.collection("roomInvites").document(inviteId)
        let inviteSnapshot = try await inviteRef.getDocument()
        
        guard let invite = try? inviteSnapshot.data(as: RoomInvite.self),
              invite.toUserId == currentUserId,
              invite.status == .pending,
              !invite.isExpired else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid or expired invite"])
        }
        
        // Update invite status
        try await inviteRef.updateData([
            "status": RoomInviteStatus.accepted.rawValue
        ])
    }
    
    /// Decline a room invite
    func declineRoomInvite(_ inviteId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let inviteRef = db.collection("roomInvites").document(inviteId)
        let inviteSnapshot = try await inviteRef.getDocument()
        
        guard let invite = try? inviteSnapshot.data(as: RoomInvite.self),
              invite.toUserId == currentUserId,
              invite.status == .pending else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid invite"])
        }
        
        // Update invite status
        try await inviteRef.updateData([
            "status": RoomInviteStatus.declined.rawValue
        ])
    }
    
    // MARK: - Room Deletion
    
    /// Deletes a room (host only)
    func deleteRoom(roomCode: String) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can delete the room"])
        }
        
        try await roomRef.delete()
    }
    
    // MARK: - Player Management
    
    /// Kick a player from the room (host only)
    func kickPlayer(roomCode: String, playerId: String) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, var room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can kick players"])
        }
        
        guard playerId != currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot kick yourself"])
        }
        
        // Remove player from room
        room.players.removeAll { $0.id == playerId }
        
        // Update room
        let encoder = Firestore.Encoder()
        let playersData = try room.players.map { try encoder.encode($0) }
        try await roomRef.updateData(["players": playersData])
    }
    
    // MARK: - Room Timeout
    
    /// Check and clean up inactive rooms (should be called periodically)
    /// Note: This should ideally be handled by a Cloud Function
    func cleanupInactiveRooms(inactivityTimeout: TimeInterval = 3600) async throws {
        // Clean up rooms that have been inactive for more than 1 hour
        let cutoffDate = Date().addingTimeInterval(-inactivityTimeout)
        let cutoffTimestamp = Timestamp(date: cutoffDate)
        
        let query = db.collection("rooms")
            .whereField("status", isEqualTo: RoomStatus.waiting.rawValue)
            .whereField("createdAt", isLessThan: cutoffTimestamp)
        
        let snapshot = try await query.getDocuments()
        
        for doc in snapshot.documents {
            // Check if room has no players or is old
            if let room = try? doc.data(as: OnlineRoom.self), room.players.isEmpty || room.createdAt < cutoffDate {
                try await doc.reference.delete()
            }
        }
    }
}
