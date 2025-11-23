//
//  AuthService.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import UIKit
import FirebaseAuth
import AuthenticationServices
import CryptoKit

enum AuthState {
    case loggedIn
    case loggedOut
    case loading
}

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email address"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .emailAlreadyInUse:
            return "Email is already in use"
        case .userNotFound:
            return "User not found"
        case .wrongPassword:
            return "Incorrect password"
        case .networkError:
            return "Network error. Please check your connection"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

final class AuthService: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var currentUser: User?
    @Published var isAnonymous: Bool = false
    @Published var providers: [String] = []
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.updateAuthState(user: user)
            }
        }
    }
    
    func updateAuthState(user: User?) {
        self.currentUser = user
        self.isAnonymous = user?.isAnonymous ?? false
        
        if let user = user {
            self.providers = user.providerData.map { $0.providerID }
            self.authState = .loggedIn
        } else {
            self.providers = []
            self.authState = .loggedOut
        }
    }
    
    // MARK: - Public Properties
    
    var uid: String? {
        return currentUser?.uid
    }
    
    // MARK: - Anonymous Sign In
    
    func signInAnonymously() async throws {
        do {
            let result = try await Auth.auth().signInAnonymously()
            await MainActor.run {
                self.updateAuthState(user: result.user)
            }
        } catch {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - Email & Password
    
    func createEmailAccount(email: String, password: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            await MainActor.run {
                self.updateAuthState(user: result.user)
            }
        } catch {
            throw mapAuthError(error)
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await MainActor.run {
                self.updateAuthState(user: result.user)
            }
        } catch {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - Sign In with Apple
    
    func signInWithApple() async throws {
        let nonce = randomNonceString()
        currentNonce = nonce
        let hashedNonce = sha256(nonce)
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        return try await withCheckedThrowingContinuation { continuation in
            authorizationController.delegate = AppleSignInDelegate(continuation: continuation, authService: self)
            authorizationController.presentationContextProvider = AppleSignInPresentationContext()
            authorizationController.performRequests()
        }
    }
    
    // MARK: - Upgrade Anonymous Account
    
    func upgradeAnonymousToEmail(email: String, password: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        guard currentUser.isAnonymous else {
            throw AuthError.unknown(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not anonymous"]))
        }
        
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        do {
            let result = try await currentUser.link(with: credential)
            await MainActor.run {
                self.updateAuthState(user: result.user)
            }
        } catch {
            throw mapAuthError(error)
        }
    }
    
    func upgradeAnonymousToApple() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        guard currentUser.isAnonymous else {
            throw AuthError.unknown(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not anonymous"]))
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let hashedNonce = sha256(nonce)
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = AppleUpgradeDelegate(
                currentUser: currentUser,
                continuation: continuation,
                authService: self
            )
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = AppleSignInPresentationContext()
            authorizationController.performRequests()
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            Task { @MainActor in
                self.updateAuthState(user: nil)
            }
        } catch {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func mapAuthError(_ error: Error) -> AuthError {
        if let authError = error as NSError? {
            switch authError.code {
            case AuthErrorCode.invalidEmail.rawValue:
                return .invalidEmail
            case AuthErrorCode.weakPassword.rawValue:
                return .weakPassword
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return .emailAlreadyInUse
            case AuthErrorCode.userNotFound.rawValue:
                return .userNotFound
            case AuthErrorCode.wrongPassword.rawValue:
                return .wrongPassword
            case AuthErrorCode.networkError.rawValue:
                return .networkError
            default:
                return .unknown(error)
            }
        }
        return .unknown(error)
    }
}

// MARK: - Apple Sign In Helpers

private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let continuation: CheckedContinuation<Void, Error>
    private weak var authService: AuthService?
    
    init(continuation: CheckedContinuation<Void, Error>, authService: AuthService) {
        self.continuation = continuation
        self.authService = authService
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation.resume(throwing: AuthError.unknown(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential"])))
            return
        }
        
        guard let nonce = currentNonce else {
            continuation.resume(throwing: AuthError.unknown(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."])))
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            continuation.resume(throwing: AuthError.unknown(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        
        Task {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                await MainActor.run {
                    self.authService?.updateAuthState(user: result.user)
                }
                continuation.resume()
            } catch {
                continuation.resume(throwing: self.mapAuthError(error))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: mapAuthError(error))
    }
    
    private func mapAuthError(_ error: Error) -> AuthError {
        if let authError = error as NSError? {
            switch authError.code {
            case AuthErrorCode.invalidEmail.rawValue:
                return .invalidEmail
            case AuthErrorCode.weakPassword.rawValue:
                return .weakPassword
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return .emailAlreadyInUse
            case AuthErrorCode.userNotFound.rawValue:
                return .userNotFound
            case AuthErrorCode.wrongPassword.rawValue:
                return .wrongPassword
            case AuthErrorCode.networkError.rawValue:
                return .networkError
            default:
                return .unknown(error)
            }
        }
        return .unknown(error)
    }
}

private class AppleUpgradeDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let currentUser: User
    private let continuation: CheckedContinuation<Void, Error>
    private weak var authService: AuthService?
    
    init(currentUser: User, continuation: CheckedContinuation<Void, Error>, authService: AuthService) {
        self.currentUser = currentUser
        self.continuation = continuation
        self.authService = authService
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation.resume(throwing: AuthError.unknown(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential"])))
            return
        }
        
        guard let nonce = currentNonce else {
            continuation.resume(throwing: AuthError.unknown(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."])))
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            continuation.resume(throwing: AuthError.unknown(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        
        Task {
            do {
                let result = try await currentUser.link(with: credential)
                await MainActor.run {
                    self.authService?.updateAuthState(user: result.user)
                }
                continuation.resume()
            } catch {
                continuation.resume(throwing: self.mapAuthError(error))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: mapAuthError(error))
    }
    
    private func mapAuthError(_ error: Error) -> AuthError {
        if let authError = error as NSError? {
            switch authError.code {
            case AuthErrorCode.invalidEmail.rawValue:
                return .invalidEmail
            case AuthErrorCode.weakPassword.rawValue:
                return .weakPassword
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return .emailAlreadyInUse
            case AuthErrorCode.userNotFound.rawValue:
                return .userNotFound
            case AuthErrorCode.wrongPassword.rawValue:
                return .wrongPassword
            case AuthErrorCode.networkError.rawValue:
                return .networkError
            default:
                return .unknown(error)
            }
        }
        return .unknown(error)
    }
}

private class AppleSignInPresentationContext: NSObject, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available for Apple Sign In")
        }
        return window
    }
}

// MARK: - Nonce Generation for Apple Sign In

private var currentNonce: String?

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0..<16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
    return hashString
}
