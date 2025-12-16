//
//  ProfileView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var isEditingUsername = false
    @State private var editedUsername = ""
    @State private var showError = false
    @State private var showAvatarSelection = false
    @State private var contentOpacity: Double = 0
    @State private var tempAvatarType: String = "person.fill"
    @State private var tempAvatarColor: String = "red"
    @State private var showSaveSuccess = false
    
    var avatarSelectionDestination: some View {
        AvatarSelectionView(
            selectedAvatarType: $tempAvatarType,
            selectedAvatarColor: $tempAvatarColor
        )
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await authManager.updateAvatar(type: tempAvatarType, color: tempAvatarColor)
                        // Show success indicator with smooth animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showSaveSuccess = true
                        }
                        // Wait a moment then dismiss with smooth animation
                        try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2 seconds
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showAvatarSelection = false
                        }
                        // Reset after navigation completes
                        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                        showSaveSuccess = false
                    }
                }) {
                    if showSaveSuccess {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Saved!")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color.green)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showSaveSuccess)
            }
        }
        .onAppear {
            if let profile = authManager.userProfile {
                tempAvatarType = profile.avatarType
                tempAvatarColor = profile.avatarColor
            }
        }
    }
    
    var body: some View {
        Group {
            if !authManager.isAuthenticated {
                // Show sign-in view if not authenticated
                SignInView()
            } else if authManager.isLoading && authManager.userProfile == nil {
                // Loading state
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        Text("Loading profile...")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                }
            } else {
                // Profile view
                profileContentView
            }
        }
    }
    
    private var profileContentView: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Title
                Text("Your Profile")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .padding(.top, 20)
                
                // Avatar Section with edit button
                VStack(spacing: 16) {
                        Button(action: {
                            showAvatarSelection = true
                        }) {
                            ZStack {
                                AvatarView(
                                    avatarType: authManager.userProfile?.avatarType ?? "person.fill",
                                    avatarColor: authManager.userProfile?.avatarColor ?? "red",
                                    size: 120
                                )
                                
                                // Edit indicator overlay - pencil icon in white circle
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 36, height: 36)
                                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                            
                                            Image(systemName: "pencil.fill")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                        }
                                        .padding(6)
                                    }
                                }
                                .frame(width: 120, height: 120)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    Text("Tap to change avatar")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(Color.gray)
                }
                
                // Username Section
                VStack(spacing: 16) {
                    if isEditingUsername {
                        VStack(spacing: 12) {
                            TextField("Username", text: $editedUsername)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                .cornerRadius(12)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    cancelEditing()
                                }) {
                                    Text("Cancel")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    saveUsername()
                                }) {
                                    Text("Save")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                        .cornerRadius(12)
                                }
                                .disabled(authManager.isLoading)
                            }
                        }
                        .padding(.horizontal, 40)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        HStack(spacing: 12) {
                            Text(authManager.userProfile?.username ?? "Player")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    startEditingUsername()
                                }
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    .padding(10)
                                    .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 40)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                    
                // Stats Section
                if let profile = authManager.userProfile {
                    VStack(spacing: 16) {
                        Text("Game Statistics")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Compact stats in a grid
                        HStack(spacing: 12) {
                            // Games Played
                            VStack(spacing: 8) {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                Text("\(profile.gamesPlayed)")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                Text("Games")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                            .cornerRadius(12)
                            
                            // Win Rate
                            VStack(spacing: 8) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                Text(String(format: "%.0f%%", profile.winRate))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                Text("Win Rate")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                            .cornerRadius(12)
                            
                            // Cards Seen
                            VStack(spacing: 8) {
                                Image(systemName: "rectangle.stack.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                Text("\(profile.totalCardsSeen)")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                Text("Cards")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                // Spacer to push sign out button to bottom
                Spacer()
                    
                // Sign Out Button
                Button(action: {
                    authManager.signOut()
                }) {
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .opacity(contentOpacity)
        }
        .navigationBarTitleDisplayMode(.inline)
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
        .navigationBarBackButtonHidden(true)
        .background(
            NavigationLink(
                destination: avatarSelectionDestination,
                isActive: $showAvatarSelection
            ) {
                EmptyView()
            }
            .hidden()
        )
        .onAppear {
            // Animate content appearance
            withAnimation(.easeInOut(duration: 0.3)) {
                contentOpacity = 1.0
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authManager.errorMessage ?? "An unknown error occurred")
        }
        .onChange(of: authManager.errorMessage) { error in
            if error != nil {
                showError = true
            }
        }
    }
    
    private func startEditingUsername() {
        editedUsername = authManager.userProfile?.username ?? ""
        isEditingUsername = true
    }
    
    private func cancelEditing() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isEditingUsername = false
            editedUsername = ""
        }
    }
    
    private func saveUsername() {
        guard !editedUsername.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        Task {
            await authManager.updateUsername(editedUsername.trimmingCharacters(in: .whitespaces))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isEditingUsername = false
            }
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(AuthManager.shared)
    }
}
