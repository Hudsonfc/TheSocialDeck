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
    @EnvironmentObject var subManager: SubscriptionManager
    @State private var showError = false
    @State private var showAvatarSelection = false
    @State private var showChangeUsername = false
    @State private var contentOpacity: Double = 0
    @State private var tempAvatarType: String = "person.fill"
    @State private var tempAvatarColor: String = "red"
    @State private var showSaveSuccess = false
    @State private var showSignOutConfirmation = false
    @State private var showPlusPaywall = false
    @AppStorage("totalCardsFlipped") private var totalCardsFlipped: Int = 0
    @AppStorage("lastMilestoneCelebrated") private var lastMilestoneCelebrated: Int = 0
    @State private var showMilestone = false
    @State private var milestoneText = ""
    @State private var toast: ToastMessage? = nil
    
    private let milestones = [50, 100, 250, 500, 1000, 2500, 5000]
    
    private var displayCardsFlipped: Int {
        max(totalCardsFlipped, authManager.userProfile?.totalCardsFlipped ?? 0)
    }
    
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
                                VStack(spacing: 8) {
                    // Username label
                    Text("Username")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.gray)
                    
                    ZStack {
                        // Centered username + optional Plus badge
                        HStack(spacing: 8) {
                            Spacer()
                            Text(authManager.userProfile?.username ?? "Player")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            if subManager.isPlus {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 11, weight: .bold))
                                    Text("Plus")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .cornerRadius(20)
                            }
                            Spacer()
                        }
                                    
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
                    
                    // Member since
                    if let createdAt = authManager.userProfile?.createdAt {
                        Text("Member since \(createdAt.formatted(.dateTime.month(.wide).day().year()))")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                }
                    
                // Stats Section
                VStack(spacing: 16) {
                    Text("Game Statistics")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Cards Flipped stat
                    VStack(spacing: 8) {
                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        Text("\(displayCardsFlipped)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        Text("Cards Flipped")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                // Milestone banner
                if showMilestone {
                    HStack(spacing: 10) {
                        Text("🎉")
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(milestoneText)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            Text("Keep flipping!")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        }
                        Spacer()
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.25)) { showMilestone = false }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.gray)
                                .padding(6)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(red: 0xF0/255.0, green: 0xF9/255.0, blue: 0xF0/255.0))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 40)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Upgrade to Plus (only shown to non-Plus users)
                if !subManager.isPlus {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        showPlusPaywall = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Upgrade to TheSocialDeck+")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                Text("Unlock exclusive Plus games")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.06))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.25), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 40)
                }
                
                // Online & friends coming soon
                HStack(alignment: .center, spacing: 14) {
                    Image(systemName: "person.2.badge.gearshape")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.gray)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Online play & adding friends coming soon.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x3A/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        HStack(spacing: 6) {
                            InstagramIconView(size: 14)
                                .foregroundColor(Color.gray)
                            Text("Follow @thesocialdeckapp on Instagram")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Color(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0))
                .cornerRadius(12)
                .padding(.top, 8)
                .padding(.horizontal, 40)
                
                // Spacer for spacing
                Spacer()
                    .frame(height: 40)
                    }
                    .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                contentOpacity = 1.0
            }
            Task {
                await authManager.syncCardsFlipped(localCount: totalCardsFlipped)
                await authManager.syncFavorites(localFavorites: FavoritesManager.shared.favoriteGameTypes)
            }
            checkMilestone()
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
        .toast($toast)
        .sheet(isPresented: $showPlusPaywall) {
            TheSocialDeckPlusPopUpView(onDismiss: { showPlusPaywall = false })
                .environmentObject(subManager)
        }
    }
    
    private func checkMilestone() {
        let count = displayCardsFlipped
        guard count > 0 else { return }
        if let reached = milestones.last(where: { count >= $0 }), reached > lastMilestoneCelebrated {
            lastMilestoneCelebrated = reached
            milestoneText = "You've flipped \(reached) cards!"
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                showMilestone = true
            }
        }
    }

}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(AuthManager.shared)
            .environmentObject(SubscriptionManager.shared)
    }
}
