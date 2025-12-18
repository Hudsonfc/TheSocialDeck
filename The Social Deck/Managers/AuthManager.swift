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
                // Generate a unique username (don't use Apple name)
                let username = await generateUniqueUsername()
                
                // Get Game Center player ID if authenticated
                let gameCenterPlayerID = GameCenterService.shared.isAuthenticated ? GameCenterService.shared.gameCenterPlayerID : nil
                await createProfile(userId: userId, username: username, email: appleUserInfo?.email, gameCenterPlayerID: gameCenterPlayerID)
            }
        } catch {
            errorMessage = "Failed to check profile: \(error.localizedDescription)"
        }
    }
    
    /// Generate a unique username
    private func generateUniqueUsername() async -> String {
        let adjectives = ["Swift", "Bold", "Cool", "Epic", "Mighty", "Noble", "Rapid", "Vivid", "Zest", "Peak", "Apex", "Nova", "Zen", "Rift", "Frost", "Flame", "Wave", "Sky", "Star", "Moon"]
        let nouns = ["Player", "Gamer", "Champion", "Legend", "Hero", "Warrior", "Ace", "Pro", "Elite", "Master", "Rookie", "Sage", "Bolt", "Storm", "Blade", "Arrow", "Pilot", "Captain", "Ranger", "Hunter"]
        
        // Try combinations first
        for _ in 0..<10 {
            let adjective = adjectives.randomElement() ?? "Swift"
            let noun = nouns.randomElement() ?? "Player"
            let randomNum = Int.random(in: 100...9999)
            let candidate = "\(adjective)\(noun)\(randomNum)"
            
            if await isUsernameAvailable(candidate) {
                return candidate
            }
        }
        
        // Fallback to Player + random number
        var attempts = 0
        while attempts < 50 {
            let randomNum = Int.random(in: 1000...999999)
            let candidate = "Player\(randomNum)"
            
            if await isUsernameAvailable(candidate) {
                return candidate
            }
            attempts += 1
        }
        
        // Final fallback with timestamp
        let timestamp = Int(Date().timeIntervalSince1970) % 1000000
        return "Player\(timestamp)"
    }
    
    /// Check if a username is available
    private func isUsernameAvailable(_ username: String) async -> Bool {
        do {
            let querySnapshot = try await db.collection("profiles")
                .whereField("username", isEqualTo: username)
                .limit(to: 1)
                .getDocuments()
            
            return querySnapshot.documents.isEmpty
        } catch {
            // If check fails, assume it's available (better than blocking signup)
            return true
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
    
    /// Check if user can change username (monthly limit)
    func canChangeUsername() -> Bool {
        guard let profile = userProfile,
              let lastChanged = profile.lastUsernameChanged else {
            return true // Never changed before, so can change
        }
        
        let calendar = Calendar.current
        let daysSinceLastChange = calendar.dateComponents([.day], from: lastChanged, to: Date()).day ?? 0
        
        return daysSinceLastChange >= 30
    }
    
    /// Update username
    func updateUsername(_ newUsername: String) async {
        guard let userId = authService.currentUserId else { return }
        
        // Check monthly limit
        if !canChangeUsername() {
            errorMessage = "You can only change your username once per month."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Check if username is available (excluding current user)
        let trimmedUsername = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedUsername.isEmpty else {
            errorMessage = "Username cannot be empty"
            isLoading = false
            return
        }
        
        // Check if username is already taken by another user
        let isAvailable = await isUsernameAvailableForUpdate(trimmedUsername, currentUserId: userId)
        if !isAvailable {
            errorMessage = "This username is already taken. Please choose another one."
            isLoading = false
            return
        }
        
        do {
            let profileRef = db.collection("profiles").document(userId)
            try await profileRef.updateData([
                "username": trimmedUsername,
                "lastUsernameChanged": Timestamp(date: Date()),
                "updatedAt": Timestamp(date: Date())
            ])
        } catch {
            errorMessage = "Failed to update username: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Check if username is available for change (public method for validation)
    func isUsernameAvailableForChange(_ username: String) async -> Bool {
        guard let userId = authService.currentUserId else { return false }
        return await isUsernameAvailableForUpdate(username, currentUserId: userId)
    }
    
    /// Check if a username is available for update (excluding current user's username)
    private func isUsernameAvailableForUpdate(_ username: String, currentUserId: String) async -> Bool {
        do {
            let querySnapshot = try await db.collection("profiles")
                .whereField("username", isEqualTo: username)
                .limit(to: 1)
                .getDocuments()
            
            // If no documents found, username is available
            guard let document = querySnapshot.documents.first else {
                return true
            }
            
            // If the document belongs to the current user, it's available (they're just keeping their current username)
            return document.documentID == currentUserId
        } catch {
            // If check fails, allow the update (better than blocking user)
            return true
        }
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
