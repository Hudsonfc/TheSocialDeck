//
//  BlockedUser.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseFirestore

struct BlockedUser: Codable, Identifiable {
    @DocumentID var id: String?
    var blockedById: String // User who blocked
    var blockedUserId: String // User who was blocked
    var blockedAt: Date
    
    init(
        id: String? = nil,
        blockedById: String,
        blockedUserId: String,
        blockedAt: Date = Date()
    ) {
        self.id = id
        self.blockedById = blockedById
        self.blockedUserId = blockedUserId
        self.blockedAt = blockedAt
    }
}

