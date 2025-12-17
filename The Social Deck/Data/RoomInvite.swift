//
//  RoomInvite.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseFirestore

enum RoomInviteStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case expired = "expired"
}

struct RoomInvite: Codable, Identifiable {
    @DocumentID var id: String?
    var roomCode: String
    var roomName: String
    var fromUserId: String // User who sent the invite
    var toUserId: String // User who received the invite
    var status: RoomInviteStatus
    var createdAt: Date
    var expiresAt: Date
    
    init(
        id: String? = nil,
        roomCode: String,
        roomName: String,
        fromUserId: String,
        toUserId: String,
        status: RoomInviteStatus = .pending,
        createdAt: Date = Date(),
        expiresAt: Date = Date().addingTimeInterval(3600) // 1 hour from now
    ) {
        self.id = id
        self.roomCode = roomCode
        self.roomName = roomName
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.status = status
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }
    
    var isExpired: Bool {
        return Date() > expiresAt
    }
}

