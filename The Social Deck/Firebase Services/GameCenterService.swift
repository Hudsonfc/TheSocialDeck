//
//  GameCenterService.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import GameKit
import Combine
import FirebaseFirestore
import SwiftUI

class GameCenterService: NSObject, ObservableObject {
    static let shared = GameCenterService()
    
    @Published var isAuthenticated: Bool = false
    @Published var localPlayer: GKLocalPlayer?
    @Published var playerID: String?
    @Published var displayName: String?
    @Published var errorMessage: String?
    @Published var needsAuthentication: Bool = false
    @Published var authenticationViewController: UIViewController?
    
    private override init() {
        super.init()
        authenticatePlayer()
    }
    
    // MARK: - Authentication
    
    /// Authenticate the local Game Center player
    func authenticatePlayer() {
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    // Handle authentication errors
                    let errorDescription = error.localizedDescription
                    if errorDescription.contains("not recognized") || errorDescription.contains("notRecognized") {
                        self.errorMessage = "This app needs to be registered with Game Center. Please ensure Game Center is enabled for this app in your Apple Developer account."
                    } else {
                        self.errorMessage = "Game Center authentication failed: \(errorDescription)"
                    }
                    self.isAuthenticated = false
                    self.localPlayer = nil
                    self.playerID = nil
                    self.displayName = nil
                    self.needsAuthentication = false
                    self.authenticationViewController = nil
                    return
                }
                
                if let viewController = viewController {
                    // Game Center sign-in view controller needs to be presented
                    self.authenticationViewController = viewController
                    self.needsAuthentication = true
                    self.isAuthenticated = false
                    self.localPlayer = nil
                    self.playerID = nil
                    self.displayName = nil
                    return
                }
                
                // Player is authenticated
                if localPlayer.isAuthenticated {
                    self.localPlayer = localPlayer
                    self.playerID = localPlayer.gamePlayerID
                    self.displayName = localPlayer.displayName
                    self.isAuthenticated = true
                    self.errorMessage = nil
                    self.needsAuthentication = false
                    self.authenticationViewController = nil
                } else {
                    // Not authenticated and no view controller provided
                    // This can happen if user disabled Game Center, dismissed sign-in, or app isn't registered
                    self.isAuthenticated = false
                    self.localPlayer = nil
                    self.playerID = nil
                    self.displayName = nil
                    self.needsAuthentication = false
                    self.authenticationViewController = nil
                    
                    // If we don't have an error message yet, provide guidance
                    if self.errorMessage == nil {
                        self.errorMessage = "Please sign in to Game Center through your device's Settings app, or ensure this app is registered with Game Center in App Store Connect."
                    }
                }
            }
        }
    }
    
    /// Manually trigger authentication (useful for retry)
    func reauthenticate() {
        DispatchQueue.main.async {
            let localPlayer = GKLocalPlayer.local
            self.errorMessage = nil
            
            // If already authenticated, just update state
            if localPlayer.isAuthenticated {
                self.localPlayer = localPlayer
                self.playerID = localPlayer.gamePlayerID
                self.displayName = localPlayer.displayName
                self.isAuthenticated = true
                self.errorMessage = nil
                self.needsAuthentication = false
                self.authenticationViewController = nil
                return
            }
            
            // Reset handler completely first
            localPlayer.authenticateHandler = nil
            
            // Set the handler again - Game Center should call it immediately if auth is needed
            // Note: Game Center may not call the handler again if it's already been determined
            // that the user needs to sign in through Settings
            self.authenticatePlayer()
        }
    }
    
    // MARK: - Player Info
    
    /// Get the current Game Center player ID
    var gameCenterPlayerID: String? {
        return localPlayer?.gamePlayerID
    }
    
    /// Get the current Game Center display name
    var gameCenterDisplayName: String? {
        return localPlayer?.displayName
    }
    
    /// Check if Game Center is available on this device
    var isGameCenterAvailable: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    // MARK: - Friends
    
    @Published var friends: [GKPlayer] = []
    @Published var gameCenterFriends: [GameCenterFriend] = []
    @Published var isLoadingFriends: Bool = false
    
    /// Load Game Center friends list and their app profiles
    func loadFriends() async throws {
        guard let localPlayer = localPlayer, localPlayer.isAuthenticated else {
            throw NSError(domain: "GameCenterService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Player not authenticated with Game Center"])
        }
        
        await MainActor.run {
            isLoadingFriends = true
        }
        
        do {
            // Load friends from Game Center
            // Note: Using async/await API available in iOS 14+
            // If loadFriendPlayers() doesn't work, we'll need to handle it differently
            let gameCenterPlayers: [GKPlayer]
            
            // Load friends using continuation to wrap completion handler API
            gameCenterPlayers = try await withCheckedThrowingContinuation { continuation in
                localPlayer.loadFriendPlayers { players, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        // players is optional, so unwrap it or use empty array
                        continuation.resume(returning: players ?? [])
                    }
                }
            }
            
            // Load app profiles for these friends from Firestore
            var friendsWithProfiles: [GameCenterFriend] = []
            let db = Firestore.firestore()
            
            for player in gameCenterPlayers {
                // Query Firestore for profile with matching gameCenterPlayerID
                let querySnapshot = try await db.collection("profiles")
                    .whereField("gameCenterPlayerID", isEqualTo: player.gamePlayerID)
                    .limit(to: 1)
                    .getDocuments()
                
                var appProfile: UserProfile? = nil
                if let document = querySnapshot.documents.first {
                    appProfile = try? document.data(as: UserProfile.self)
                }
                
                let friend = GameCenterFriend(gameCenterPlayer: player, appProfile: appProfile)
                friendsWithProfiles.append(friend)
            }
            
            await MainActor.run {
                friends = gameCenterPlayers
                gameCenterFriends = friendsWithProfiles
                isLoadingFriends = false
            }
        } catch {
            await MainActor.run {
                isLoadingFriends = false
                errorMessage = "Failed to load friends: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - Invites
    
    /// Send a room invite to a friend via Game Center
    func sendRoomInvite(to playerID: String, roomCode: String, roomName: String) async throws {
        guard let localPlayer = localPlayer, localPlayer.isAuthenticated else {
            throw NSError(domain: "GameCenterService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Player not authenticated with Game Center"])
        }
        
        // Create invite message with room code
        let inviteMessage = "Join my game room '\(roomName)'! Room Code: \(roomCode)"
        
        // Load the player to invite using continuation to wrap completion handler API
        let players: [GKPlayer] = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[GKPlayer], Error>) in
            GKPlayer.loadPlayers(forIdentifiers: [playerID]) { players, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    // players is optional, so unwrap it or use empty array
                    continuation.resume(returning: players ?? [])
                }
            }
        }
        guard let playerToInvite = players.first else {
            throw NSError(domain: "GameCenterService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Friend not found"])
        }
        
        // For now, we'll use the system share sheet or a custom invite mechanism
        // Game Center doesn't have a direct "send invite" API, but we can use:
        // 1. GKMatchmaker (for matchmaking-based invites)
        // 2. Custom URL scheme to handle invites
        // 3. Push notifications via your backend
        
        // For this implementation, we'll create a way to share the room code
        // The actual invite sending will be handled via a share sheet or deep link
    }
}

