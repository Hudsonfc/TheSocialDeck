//
//  AuthManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import GameKit

/// Helper structure to pass Apple Sign In user information
struct AppleUserInfo {
    let firstName: String?
    let lastName: String?
    let email: String?
    
    /// Formats the name into a username
    var formattedUsername: String? {
        if let firstName = firstName, !firstName.isEmpty {
            if let lastName = lastName, !lastName.isEmpty {
                return "\(firstName) \(lastName)"
            }
            return firstName
        }
        return nil
    }
}

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    private let authService = AuthService.shared
    private let db = Firestore.firestore()
    
    @Published var userProfile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var isAuthenticated: Bool {
        return authService.isUserAuthenticated
    }
    
    nonisolated(unsafe) private var profileListener: ListenerRegistration?
    
    private init() {
        setupAuthListener()
    }
    
    // MARK: - Setup
    
    private func setupAuthListener() {
        // Listen to auth state changes
        authService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let userId = user?.uid {
                    self?.loadUserProfile(userId: userId)
                } else {
                    self?.userProfile = nil
                    self?.removeProfileListener()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Authentication
    
    /// Sign in with Apple
    func signInWithApple(idToken: String, nonce: String, appleUserInfo: AppleUserInfo? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signInWithApple(idToken: idToken, nonce: nonce)
            if let userId = authService.currentUserId {
                await createProfileIfNeeded(userId: userId, appleUserInfo: appleUserInfo)
            }
        } catch {
            errorMessage = "Failed to sign in with Apple: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Sign out
    func signOut() {
        do {
            try authService.signOut()
            userProfile = nil
            removeProfileListener()
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Profile Management
    
    /// Load user profile from Firestore
    private func loadUserProfile(userId: String) {
        removeProfileListener()
        
        let profileRef = db.collection("profiles").document(userId)
        
        profileListener = profileRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let error = error {
                    self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                    return
                }
                
                guard let document = snapshot, document.exists else {
                    // Profile doesn't exist, create it
                    // Note: appleUserInfo will be nil on subsequent sign-ins (Apple only provides it once)
                    await self.createProfileIfNeeded(userId: userId, appleUserInfo: nil)
                    return
                }
                
                do {
                    self.userProfile = try document.data(as: UserProfile.self)
                    // Link Game Center player ID if authenticated with Game Center but not linked yet
                    await self.linkGameCenterIfNeeded()
                } catch {
                    self.errorMessage = "Failed to decode profile: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Create profile if it doesn't exist
    private func createProfileIfNeeded(userId: String, appleUserInfo: AppleUserInfo? = nil) async {
        let profileRef = db.collection("profiles").document(userId)
        
        do {
            let document = try await profileRef.getDocument()
            if !document.exists {
                // Determine username from Apple info or generate default
                let username: String
                if let formattedName = appleUserInfo?.formattedUsername {
                    username = formattedName
                } else {
                    username = "Player \(String(userId.prefix(6)))"
                }
                
                // Get Game Center player ID if authenticated
                let gameCenterPlayerID = GameCenterService.shared.isAuthenticated ? GameCenterService.shared.gameCenterPlayerID : nil
                await createProfile(userId: userId, username: username, email: appleUserInfo?.email, gameCenterPlayerID: gameCenterPlayerID)
            }
        } catch {
            errorMessage = "Failed to check profile: \(error.localizedDescription)"
        }
    }
    
    /// Create a new user profile
    private func createProfile(userId: String, username: String, email: String? = nil, gameCenterPlayerID: String? = nil) async {
        let profile = UserProfile(
            userId: userId,
            username: username,
            email: email,
            gameCenterPlayerID: gameCenterPlayerID
        )
        
        do {
            let profileRef = db.collection("profiles").document(userId)
            try profileRef.setData(from: profile)
        } catch {
            errorMessage = "Failed to create profile: \(error.localizedDescription)"
        }
    }
    
    /// Update username
    func updateUsername(_ newUsername: String) async {
        guard let userId = authService.currentUserId else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let profileRef = db.collection("profiles").document(userId)
            try await profileRef.updateData([
                "username": newUsername,
                "updatedAt": Timestamp(date: Date())
            ])
        } catch {
            errorMessage = "Failed to update username: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Update avatar (type and color)
    func updateAvatar(type: String, color: String) async {
        guard let userId = authService.currentUserId else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let profileRef = db.collection("profiles").document(userId)
            try await profileRef.updateData([
                "avatarType": type,
                "avatarColor": color,
                "updatedAt": Timestamp(date: Date())
            ])
        } catch {
            errorMessage = "Failed to update avatar: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Link Game Center player ID to profile if authenticated with Game Center
    private func linkGameCenterIfNeeded() async {
        let gameCenterService = GameCenterService.shared
        
        // Only link if Game Center is authenticated and profile doesn't have Game Center ID yet
        guard gameCenterService.isAuthenticated,
              let gameCenterPlayerID = gameCenterService.gameCenterPlayerID,
              userProfile?.gameCenterPlayerID == nil else {
            return
        }
        
        await linkGameCenterPlayerID(gameCenterPlayerID)
    }
    
    /// Link Game Center player ID to profile
    func linkGameCenterPlayerID(_ playerID: String) async {
        guard let userId = authService.currentUserId else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let profileRef = db.collection("profiles").document(userId)
            try await profileRef.updateData([
                "gameCenterPlayerID": playerID,
                "updatedAt": Timestamp(date: Date())
            ])
        } catch {
            errorMessage = "Failed to link Game Center: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Update stats
    func updateStats(
        gamesPlayed: Int? = nil,
        gamesWon: Int? = nil,
        totalCardsSeen: Int? = nil,
        favoriteGame: String? = nil,
        onlineGamesPlayed: Int? = nil,
        onlineGamesWon: Int? = nil
    ) async {
        guard let userId = authService.currentUserId else { return }
        
        do {
            let profileRef = db.collection("profiles").document(userId)
            var updateData: [String: Any] = [
                "updatedAt": Timestamp(date: Date())
            ]
            
            if let gamesPlayed = gamesPlayed {
                updateData["gamesPlayed"] = FieldValue.increment(Int64(gamesPlayed))
            }
            if let gamesWon = gamesWon {
                updateData["gamesWon"] = FieldValue.increment(Int64(gamesWon))
            }
            if let totalCardsSeen = totalCardsSeen {
                updateData["totalCardsSeen"] = FieldValue.increment(Int64(totalCardsSeen))
            }
            if let favoriteGame = favoriteGame {
                updateData["favoriteGame"] = favoriteGame
            }
            if let onlineGamesPlayed = onlineGamesPlayed {
                updateData["onlineGamesPlayed"] = FieldValue.increment(Int64(onlineGamesPlayed))
            }
            if let onlineGamesWon = onlineGamesWon {
                updateData["onlineGamesWon"] = FieldValue.increment(Int64(onlineGamesWon))
            }
            
            try await profileRef.updateData(updateData)
        } catch {
            errorMessage = "Failed to update stats: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Cleanup
    
    nonisolated private func removeProfileListener() {
        profileListener?.remove()
        profileListener = nil
    }
    
    deinit {
        removeProfileListener()
    }
}
