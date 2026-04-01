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
    /// Lowercase copy of username — used for case-insensitive Firestore prefix search.
    /// Populated on new profiles from app version 1.4+ only; older profiles may not have this field.
    var usernameLower: String?
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
    var totalCardsFlipped: Int
    var favoriteGame: String?
    
    // Saved favourites (raw DeckType values)
    var favoritedGames: [String]
    
    // Online stats
    var onlineGamesPlayed: Int
    var onlineGamesWon: Int
    
    // Activity tracking
    var lastActiveAt: Date? // Last time user was active in the app
    
    // Presence — updated via ScenePhase
    var isOnline: Bool
    // Optional subscription marker for showing Plus badge on other users' profiles
    var isPlus: Bool?
    // FCM token for push notifications — written by the device on every launch
    var fcmToken: String?
    /// StoreKit product IDs for purchased premium avatars (non-consumable).
    var purchasedAvatars: [String] = []
    
    init(
        id: String? = nil,
        userId: String,
        username: String,
        usernameLower: String? = nil,
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
        totalCardsFlipped: Int = 0,
        favoriteGame: String? = nil,
        favoritedGames: [String] = [],
        onlineGamesPlayed: Int = 0,
        onlineGamesWon: Int = 0,
        lastActiveAt: Date? = nil,
        isOnline: Bool = false,
        isPlus: Bool? = nil,
        fcmToken: String? = nil,
        purchasedAvatars: [String] = []
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.usernameLower = usernameLower ?? username.lowercased()
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
        self.totalCardsFlipped = totalCardsFlipped
        self.favoriteGame = favoriteGame
        self.favoritedGames = favoritedGames
        self.onlineGamesPlayed = onlineGamesPlayed
        self.onlineGamesWon = onlineGamesWon
        self.lastActiveAt = lastActiveAt
        self.isOnline = isOnline
        self.isPlus = isPlus
        self.fcmToken = fcmToken
        self.purchasedAvatars = purchasedAvatars
    }
    
    // Custom decoder so that fields added after account creation don't break decoding
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                  = try c.decodeIfPresent(String.self,   forKey: .id)
        userId              = try c.decode(String.self,            forKey: .userId)
        username            = try c.decode(String.self,            forKey: .username)
        usernameLower       = try c.decodeIfPresent(String.self,   forKey: .usernameLower)
        email               = try c.decodeIfPresent(String.self,   forKey: .email)
        gameCenterPlayerID  = try c.decodeIfPresent(String.self,   forKey: .gameCenterPlayerID)
        avatarType          = try c.decode(String.self,            forKey: .avatarType)
        avatarColor         = try c.decode(String.self,            forKey: .avatarColor)
        createdAt           = try c.decode(Date.self,              forKey: .createdAt)
        updatedAt           = try c.decode(Date.self,              forKey: .updatedAt)
        lastUsernameChanged = try c.decodeIfPresent(Date.self,     forKey: .lastUsernameChanged)
        gamesPlayed         = try c.decodeIfPresent(Int.self,      forKey: .gamesPlayed)    ?? 0
        gamesWon            = try c.decodeIfPresent(Int.self,      forKey: .gamesWon)       ?? 0
        totalCardsSeen      = try c.decodeIfPresent(Int.self,      forKey: .totalCardsSeen) ?? 0
        totalCardsFlipped   = try c.decodeIfPresent(Int.self,      forKey: .totalCardsFlipped) ?? 0
        favoriteGame        = try c.decodeIfPresent(String.self,   forKey: .favoriteGame)
        favoritedGames      = try c.decodeIfPresent([String].self, forKey: .favoritedGames) ?? []
        onlineGamesPlayed   = try c.decodeIfPresent(Int.self,      forKey: .onlineGamesPlayed) ?? 0
        onlineGamesWon      = try c.decodeIfPresent(Int.self,      forKey: .onlineGamesWon)    ?? 0
        lastActiveAt        = try c.decodeIfPresent(Date.self,     forKey: .lastActiveAt)
        isOnline            = try c.decodeIfPresent(Bool.self,     forKey: .isOnline) ?? false
        isPlus              = try c.decodeIfPresent(Bool.self,     forKey: .isPlus)
        fcmToken            = try c.decodeIfPresent(String.self,   forKey: .fcmToken)
        purchasedAvatars    = try c.decodeIfPresent([String].self,  forKey: .purchasedAvatars) ?? []
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
