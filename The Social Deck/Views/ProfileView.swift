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
    @State private var showError = false
    @State private var showAvatarSelection = false
    @State private var showChangeUsername = false
    @State private var contentOpacity: Double = 0
    @State private var tempAvatarType: String = "person.fill"
    @State private var tempAvatarColor: String = "red"
    @State private var showSaveSuccess = false
    @State private var showSignOutConfirmation = false
    @State private var showAddFriends = false
    @State private var showFriendsList = false
    @StateObject private var friendService = FriendService.shared
    @State private var toast: ToastMessage? = nil
    
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
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
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
                .transition(.opacity)
            } else {
                // Profile view
                profileContentView
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: authManager.isLoading)
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
                                            
                                            Image(systemName: "pencil")
                                                .font(.system(size: 14, weight: .semibold))
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
                VStack(spacing: 12) {
                    // Username label
                    Text("Username")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.gray)
                    
                    ZStack {
                        // Centered username
                        Text(authManager.userProfile?.username ?? "Player")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        // Pencil button aligned to trailing
                        HStack {
                            Spacer()
                            Button(action: {
                                showChangeUsername = true
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    .padding(10)
                                    .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
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
                
                // Friends Section
                VStack(spacing: 16) {
                    // Add Friends Button
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        showAddFriends = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Add Friends")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Added Friends Button
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        showFriendsList = true
                    }) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Text("Added Friends")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Spacer()
                            
                            // Friend count badge
                            if !friendService.friends.isEmpty {
                                Text("\(friendService.friends.count)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    .cornerRadius(12)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 40)
                
                // Spacer for spacing
                Spacer()
                    .frame(height: 40)
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            // Animate content appearance smoothly
            withAnimation(.easeInOut(duration: 0.5)) {
                contentOpacity = 1.0
            }
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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive, action: {
                        showSignOutConfirmation = true
                    }) {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .frame(width: 44, height: 44)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
            .background(
                Group {
                    NavigationLink(
                        destination: avatarSelectionDestination,
                        isActive: $showAvatarSelection
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: ChangeUsernameView(),
                        isActive: $showChangeUsername
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: AddFriendsView(),
                        isActive: $showAddFriends
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: FriendsListView(),
                        isActive: $showFriendsList
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
            )
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authManager.errorMessage ?? "An unknown error occurred")
        }
        .alert("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onChange(of: authManager.errorMessage) { error in
            if error != nil {
                showError = true
            }
        }
        .onAppear {
            Task {
                try? await friendService.loadFriends()
            }
        }
        .toast($toast)
    }
    
}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(AuthManager.shared)
    }
}
