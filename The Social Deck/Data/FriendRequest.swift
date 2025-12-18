//
//  FriendRequest.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseFirestore

enum FriendRequestStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}

struct FriendRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var fromUserId: String
    var toUserId: String
    var status: FriendRequestStatus
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String? = nil,
        fromUserId: String,
        toUserId: String,
        status: FriendRequestStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Check if request is expired (30 days)
    var isExpired: Bool {
        guard status == .pending else { return false }
        let expirationDate = Calendar.current.date(byAdding: .day, value: 30, to: createdAt) ?? createdAt
        return Date() > expirationDate
    }
}

// MARK: - Friend Profile (combines UserProfile with friend request info)
struct FriendProfile: Identifiable, Equatable {
    let id: String // User ID
    let userId: String
    let username: String
    let avatarType: String
    let avatarColor: String
    let friendRequestId: String? // The friend request document ID
    let lastActiveAt: Date? // Last active timestamp
    var isOnline: Bool = false // Online status (updated separately via presence)
    
    init(profile: UserProfile, friendRequestId: String? = nil, isOnline: Bool = false) {
        self.id = profile.userId
        self.userId = profile.userId
        self.username = profile.username
        self.avatarType = profile.avatarType
        self.avatarColor = profile.avatarColor
        self.friendRequestId = friendRequestId
        self.lastActiveAt = profile.lastActiveAt
        self.isOnline = isOnline
    }
    
    static func == (lhs: FriendProfile, rhs: FriendProfile) -> Bool {
        return lhs.userId == rhs.userId
    }
}

