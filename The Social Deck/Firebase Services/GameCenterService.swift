//
//  GameCenterService.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import GameKit
import Combine

class GameCenterService: NSObject, ObservableObject {
    static let shared = GameCenterService()
    
    @Published var isAuthenticated: Bool = false
    @Published var localPlayer: GKLocalPlayer?
    @Published var playerID: String?
    @Published var displayName: String?
    @Published var errorMessage: String?
    @Published var needsAuthentication: Bool = false
    
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
            
            if let error = error {
                self.errorMessage = "Game Center authentication failed: \(error.localizedDescription)"
                self.isAuthenticated = false
                self.localPlayer = nil
                self.playerID = nil
                self.displayName = nil
                return
            }
            
            if let viewController = viewController {
                // Game Center sign-in view controller needs to be presented
                // Set flag so UI can present it
                DispatchQueue.main.async {
                    self.needsAuthentication = true
                }
                self.isAuthenticated = false
                self.localPlayer = nil
                self.playerID = nil
                self.displayName = nil
                // Note: You'll need to present viewController from your view when needsAuthentication is true
                return
            }
            
            // Player is authenticated
            if localPlayer.isAuthenticated {
                self.localPlayer = localPlayer
                self.playerID = localPlayer.gamePlayerID
                self.displayName = localPlayer.displayName
                self.isAuthenticated = true
                self.errorMessage = nil
            } else {
                self.isAuthenticated = false
                self.localPlayer = nil
                self.playerID = nil
                self.displayName = nil
            }
        }
    }
    
    /// Manually trigger authentication (useful for retry)
    func reauthenticate() {
        authenticatePlayer()
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
}

