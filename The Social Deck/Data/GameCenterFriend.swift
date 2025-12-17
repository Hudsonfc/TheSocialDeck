//
//  GameCenterFriend.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import GameKit

/// Represents a Game Center friend with optional app profile data
struct GameCenterFriend: Identifiable, Equatable {
    let id: String // Game Center Player ID
    let gameCenterPlayer: GKPlayer
    var appProfile: UserProfile? // Optional Firebase profile if friend has signed in to app
    
    init(gameCenterPlayer: GKPlayer, appProfile: UserProfile? = nil) {
        self.id = gameCenterPlayer.gamePlayerID
        self.gameCenterPlayer = gameCenterPlayer
        self.appProfile = appProfile
    }
    
    /// Display name (prefers app username, falls back to Game Center display name)
    var displayName: String {
        return appProfile?.username ?? gameCenterPlayer.displayName
    }
    
    /// Avatar type (from app profile if available, otherwise nil)
    var avatarType: String {
        return appProfile?.avatarType ?? "person.fill"
    }
    
    /// Avatar color (from app profile if available, otherwise default red)
    var avatarColor: String {
        return appProfile?.avatarColor ?? "red"
    }
    
    /// Whether friend has signed into the app
    var hasAppProfile: Bool {
        return appProfile != nil
    }
    
    static func == (lhs: GameCenterFriend, rhs: GameCenterFriend) -> Bool {
        return lhs.id == rhs.id
    }
}



