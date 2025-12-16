//
//  UserProfile.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var username: String
    var email: String? // From Apple Sign In (only provided on first sign-in)
    var gameCenterPlayerID: String? // Game Center player identifier
    var avatarType: String // SF Symbol name
    var avatarColor: String // Color name (red, blue, etc.)
    var createdAt: Date
    var updatedAt: Date
    var lastUsernameChanged: Date? // When the username was last changed (for monthly limit)
    
    // Stats
    var gamesPlayed: Int
    var gamesWon: Int
    var totalCardsSeen: Int
    var favoriteGame: String?
    
    // Online stats
    var onlineGamesPlayed: Int
    var onlineGamesWon: Int
    
    init(
        id: String? = nil,
        userId: String,
        username: String,
        email: String? = nil,
        gameCenterPlayerID: String? = nil,
        avatarType: String = "avatar 1",
        avatarColor: String = "red",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastUsernameChanged: Date? = nil,
        gamesPlayed: Int = 0,
        gamesWon: Int = 0,
        totalCardsSeen: Int = 0,
        favoriteGame: String? = nil,
        onlineGamesPlayed: Int = 0,
        onlineGamesWon: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.email = email
        self.gameCenterPlayerID = gameCenterPlayerID
        self.avatarType = avatarType
        self.avatarColor = avatarColor
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastUsernameChanged = lastUsernameChanged
        self.gamesPlayed = gamesPlayed
        self.gamesWon = gamesWon
        self.totalCardsSeen = totalCardsSeen
        self.favoriteGame = favoriteGame
        self.onlineGamesPlayed = onlineGamesPlayed
        self.onlineGamesWon = onlineGamesWon
    }
    
    var winRate: Double {
        guard gamesPlayed > 0 else { return 0.0 }
        return Double(gamesWon) / Double(gamesPlayed) * 100.0
    }
    
    var onlineWinRate: Double {
        guard onlineGamesPlayed > 0 else { return 0.0 }
        return Double(onlineGamesWon) / Double(onlineGamesPlayed) * 100.0
    }
}
