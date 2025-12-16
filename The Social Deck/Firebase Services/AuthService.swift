//
//  AuthService.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    
    private init() {
        // Set initial authentication state immediately
        let currentUser = auth.currentUser
        self.currentUser = currentUser
        self.isAuthenticated = currentUser != nil
        
        // Listen to auth state changes for future updates
        auth.addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isAuthenticated = user != nil
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Sign in with Apple
    func signInWithApple(idToken: String, nonce: String) async throws {
        let credential = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: nonce, fullName: nil)
        let result = try await auth.signIn(with: credential)
        self.currentUser = result.user
        self.isAuthenticated = true
    }
    
    /// Sign out
    func signOut() throws {
        try auth.signOut()
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    /// Get current user ID
    var currentUserId: String? {
        return auth.currentUser?.uid
    }
    
    /// Check if user is authenticated
    var isUserAuthenticated: Bool {
        return auth.currentUser != nil
    }
}
