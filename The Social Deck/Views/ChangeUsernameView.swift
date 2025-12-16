//
//  ChangeUsernameView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ChangeUsernameView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var newUsername: String = ""
    @State private var validationMessage: String = ""
    @State private var isValidating: Bool = false
    @State private var showError: Bool = false
    @State private var canChangeUsername: Bool = true
    @State private var daysUntilNextChange: Int = 0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Title
                    Text("Change Username")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                    
                    // Current username
                    VStack(spacing: 8) {
                        Text("Current Username")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                        
                        Text(authManager.userProfile?.username ?? "Player")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    }
                    .padding(.vertical, 20)
                    
                    // Monthly limit info
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            
                            if canChangeUsername {
                                Text("You can change your username once per month")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            } else {
                                Text("You can change your username again in \(daysUntilNextChange) day\(daysUntilNextChange == 1 ? "" : "s")")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                        )
                    }
                    .padding(.horizontal, 40)
                    
                    // New username input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("New Username")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        TextField("Enter new username", text: $newUsername)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(validationMessage.isEmpty ? Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0) : (validationMessage.contains("✓") ? Color.green.opacity(0.1) : Color.red.opacity(0.1)))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(validationMessage.isEmpty ? Color.clear : (validationMessage.contains("✓") ? Color.green : Color.red), lineWidth: 2)
                            )
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .disabled(!canChangeUsername || authManager.isLoading)
                            .onChange(of: newUsername) { _ in
                                validateUsername()
                            }
                        
                        // Validation message
                        if !validationMessage.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: validationMessage.contains("✓") ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(validationMessage.contains("✓") ? Color.green : Color.red)
                                
                                Text(validationMessage)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(validationMessage.contains("✓") ? Color.green : Color.red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Save button
                    Button(action: {
                        saveUsername()
                    }) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Change Username")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(canSave() ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color.gray)
                        )
                    }
                    .disabled(!canSave() || authManager.isLoading)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
            }
        }
        .onAppear {
            checkCanChangeUsername()
            newUsername = authManager.userProfile?.username ?? ""
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authManager.errorMessage ?? "An error occurred")
        }
        .onChange(of: authManager.errorMessage) { error in
            if error != nil {
                showError = true
            }
        }
    }
    
    private func checkCanChangeUsername() {
        guard let profile = authManager.userProfile,
              let lastChanged = profile.lastUsernameChanged else {
            canChangeUsername = true
            return
        }
        
        let calendar = Calendar.current
        let daysSinceLastChange = calendar.dateComponents([.day], from: lastChanged, to: Date()).day ?? 0
        
        if daysSinceLastChange < 30 {
            canChangeUsername = false
            daysUntilNextChange = 30 - daysSinceLastChange
        } else {
            canChangeUsername = true
        }
    }
    
    private func validateUsername() {
        let trimmed = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Clear validation if empty
        if trimmed.isEmpty {
            validationMessage = ""
            return
        }
        
        // Check if it's the same as current username
        if trimmed.lowercased() == authManager.userProfile?.username.lowercased() {
            validationMessage = ""
            return
        }
        
        // Check length
        if trimmed.count < 3 {
            validationMessage = "Username must be at least 3 characters"
            return
        }
        
        if trimmed.count > 20 {
            validationMessage = "Username must be 20 characters or less"
            return
        }
        
        // Check for valid characters (alphanumeric, underscores, hyphens)
        let validPattern = "^[a-zA-Z0-9_-]+$"
        if trimmed.range(of: validPattern, options: .regularExpression) == nil {
            validationMessage = "Username can only contain letters, numbers, underscores, and hyphens"
            return
        }
        
        // Check for inappropriate words
        if containsInappropriateWords(trimmed) {
            validationMessage = "Username contains inappropriate words. Please choose another."
            return
        }
        
        // If all basic validations pass, show a positive indicator
        validationMessage = "✓ Username format is valid"
    }
    
    private func containsInappropriateWords(_ text: String) -> Bool {
        let inappropriateWords = [
            "fuck", "shit", "damn", "bitch", "asshole", "cunt", "nigger", "nigga",
            "retard", "fag", "faggot", "whore", "slut", "pussy", "dick", "cock",
            "ass", "bastard", "piss", "hell", "crap", "bitch", "sex", "xxx",
            "porn", "drug", "weed", "cocaine", "alcohol", "drunk"
        ]
        
        let lowercased = text.lowercased()
        
        for word in inappropriateWords {
            if lowercased.contains(word) {
                return true
            }
        }
        
        return false
    }
    
    private func canSave() -> Bool {
        guard canChangeUsername else { return false }
        
        let trimmed = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Must not be empty
        if trimmed.isEmpty {
            return false
        }
        
        // Must be different from current username
        if trimmed.lowercased() == authManager.userProfile?.username.lowercased() {
            return false
        }
        
        // Must pass validation (either empty or has checkmark)
        if !validationMessage.isEmpty && !validationMessage.contains("✓") {
            return false
        }
        
        // If validation message is empty, run basic checks
        if validationMessage.isEmpty {
            if trimmed.count < 3 || trimmed.count > 20 {
                return false
            }
            if containsInappropriateWords(trimmed) {
                return false
            }
            let validPattern = "^[a-zA-Z0-9_-]+$"
            if trimmed.range(of: validPattern, options: .regularExpression) == nil {
                return false
            }
        }
        
        // Check length
        if trimmed.count < 3 || trimmed.count > 20 {
            return false
        }
        
        // Check for inappropriate words
        if containsInappropriateWords(trimmed) {
            return false
        }
        
        return true
    }
    
    private func saveUsername() {
        let trimmed = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Final validation
        if trimmed.isEmpty {
            validationMessage = "Username cannot be empty"
            return
        }
        
        if trimmed.count < 3 {
            validationMessage = "Username must be at least 3 characters"
            return
        }
        
        if trimmed.count > 20 {
            validationMessage = "Username must be 20 characters or less"
            return
        }
        
        if containsInappropriateWords(trimmed) {
            validationMessage = "Username contains inappropriate words. Please choose another."
            return
        }
        
        // Check if it's the same as current username
        if trimmed.lowercased() == authManager.userProfile?.username.lowercased() {
            validationMessage = "This is already your current username"
            return
        }
        
        // Check uniqueness
        Task {
            isValidating = true
            let isAvailable = await authManager.isUsernameAvailableForChange(trimmed)
            isValidating = false
            
            await MainActor.run {
                if isAvailable {
                    // Save the username
                    Task {
                        await authManager.updateUsername(trimmed)
                        // Dismiss if successful (error handling in alert)
                        if authManager.errorMessage == nil {
                            try? await Task.sleep(nanoseconds: 300_000_000)
                            dismiss()
                        } else {
                            // Show the error message
                            validationMessage = authManager.errorMessage ?? "Failed to change username"
                        }
                    }
                } else {
                    validationMessage = "This username is already taken. Please choose another."
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ChangeUsernameView()
            .environmentObject(AuthManager.shared)
    }
}

