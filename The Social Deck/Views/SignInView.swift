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
    @State private var currentNonce: String?
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
            VStack(spacing: 32) {
                    // Logo
                    Image("TheSocialDeckLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .padding(.top, 20)
                    
                    // Title and subtitle
                    VStack(spacing: 8) {
                Text("The Social Deck")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text("Sign in to continue")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                    
                    // Info about signing in
                    VStack(spacing: 20) {
                        HStack(alignment: .top, spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Create Your Profile")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                Text("Personalize your avatar and track your progress")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(Color.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer()
                        }
                        
                        HStack(alignment: .top, spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "network")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Access Online Features")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                Text("Play with friends and join online rooms")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(Color.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer()
                        }
                        
                        HStack(alignment: .top, spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Track Your Game Stats")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                Text("See your wins, games played, and more")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                
                Spacer()
                        }
                    }
                    .padding(.vertical, 28)
                    .padding(.horizontal, 28)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                    .padding(.horizontal, 40)
                    
                    // Loading indicator or Sign in button
                    if authManager.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            Text("Signing in...")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        }
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                // Sign in with Apple Button
                SignInWithAppleButton(.signIn) { request in
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = sha256(nonce)
                } onCompletion: { result in
                            handleSignInResult(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 55)
                .cornerRadius(12)
                .padding(.horizontal, 40)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
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


