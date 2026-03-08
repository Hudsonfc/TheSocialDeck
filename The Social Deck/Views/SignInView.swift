//
//  SignInView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentNonce: String?
    @State private var showError = false
    
    private let benefits: [(title: String, subtitle: String)] = [
        ("Your profile", "Pick an avatar and display name"),
        ("Cards Flipped", "Track how many cards you've revealed"),
        ("More coming soon", "Friends, online play and more on the way")
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero
                    VStack(spacing: 20) {
                        Image("TheSocialDeckLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(.top, 32)
                        
                        VStack(spacing: 8) {
                            Text("Welcome to your account")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.primaryText)
                                .multilineTextAlignment(.center)
                            
                            Text("Sign in to save your profile and get the most out of The Social Deck.")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding(.bottom, 28)
                    
                    // Benefit list (bullet points)
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(benefits.enumerated()), id: \.offset) { _, benefit in
                            HStack(alignment: .top, spacing: 14) {
                                Text("•")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryAccent)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(benefit.title)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    Text(benefit.subtitle)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondaryText)
                                }
                                
                                Spacer(minLength: 0)
                            }
                            .padding(18)
                            .background(Color.secondaryBackground)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.borderColor, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    
                    // Sign in button or loading
                    if authManager.isLoading {
                        VStack(spacing: 14) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.primaryAccent)
                            Text("Signing in...")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    } else {
                        VStack(spacing: 12) {
                            SignInWithAppleButton(.signIn) { request in
                                let nonce = randomNonceString()
                                currentNonce = nonce
                                request.requestedScopes = [.fullName, .email]
                                request.nonce = sha256(nonce)
                            } onCompletion: { result in
                                handleSignInResult(result)
                            }
                            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                            .frame(height: 54)
                            .cornerRadius(14)
                            
                            Text("Quick and private — we only use your Apple ID to create your profile.")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.tertiaryText)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isLoading)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authManager.errorMessage ?? "Sign in failed. Please try again.")
        }
        .onChange(of: authManager.errorMessage) { error in
            if error != nil {
                showError = true
            }
        }
    }
    
    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            handleSignInWithApple(authorization: authorization)
        case .failure(let error):
            authManager.errorMessage = "Sign in failed: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func handleSignInWithApple(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            authManager.errorMessage = "Failed to process Apple sign in"
            return
        }
        
        // Extract user information from Apple credential
        // Note: Apple only provides name/email on FIRST sign-in
        let appleUserInfo = AppleUserInfo(
            firstName: appleIDCredential.fullName?.givenName,
            lastName: appleIDCredential.fullName?.familyName,
            email: appleIDCredential.email
        )
        
        Task {
            await authManager.signInWithApple(idToken: idTokenString, nonce: nonce, appleUserInfo: appleUserInfo)
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            guard errorCode == errSecSuccess else {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

#Preview {
    NavigationView {
        SignInView()
            .environmentObject(AuthManager.shared)
    }
}


