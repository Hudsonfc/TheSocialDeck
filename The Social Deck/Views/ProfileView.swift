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
    @ObservedObject private var friendService = FriendService.shared
    @ObservedObject private var onlineManager = OnlineManager.shared
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
    @AppStorage("lastSeenFriendRequestIds") private var lastSeenFriendRequestIds: String = ""
    @AppStorage("lastSeenRoomInviteIds") private var lastSeenRoomInviteIds: String = ""
    @State private var showMilestone = false
    @State private var milestoneText = ""
    @State private var toast: ToastMessage? = nil
    @State private var showFriendsList = false

    private var showFriendsBadge: Bool {
        let seenRequestIds = Set(lastSeenFriendRequestIds.split(separator: ",").map(String.init))
        let seenRoomInviteIds = Set(lastSeenRoomInviteIds.split(separator: ",").map(String.init))
        let hasUnseenRequest = friendService.pendingRequests
            .compactMap(\.id)
            .contains { !seenRequestIds.contains($0) }
        let hasUnseenRoomInvite = onlineManager.pendingRoomInvites
            .compactMap(\.id)
            .contains { !seenRoomInviteIds.contains($0) }
        return hasUnseenRequest || hasUnseenRoomInvite
    }
    
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
                profileHeaderSection
                avatarEditorSection
                usernameSection
                statsSection
                milestoneSection
                plusUpgradeSection
                friendsEntrySection
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
        .toast($toast)
        .sheet(isPresented: $showPlusPaywall) {
            TheSocialDeckPlusPopUpView(onDismiss: { showPlusPaywall = false })
                .environmentObject(subManager)
        }
    }
    
    private var profileHeaderSection: some View {
        Text("Your Profile")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            .padding(.top, 20)
    }

    private var avatarEditorSection: some View {
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
                }
                .frame(width: 120, height: 120)
            }
            .buttonStyle(PlainButtonStyle())

            Text("Tap to change avatar")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(Color.gray)
        }
    }

    private var usernameSection: some View {
        VStack(spacing: 8) {
            Text("Username")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.gray)
            ZStack {
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
                HStack {
                    Spacer()
                    Button(action: { showChangeUsername = true }) {
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

            if let createdAt = authManager.userProfile?.createdAt {
                Text("Member since \(createdAt.formatted(.dateTime.month(.wide).day().year()))")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(Color.gray)
            }
        }
    }

    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("Game Statistics")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 12) {
                statTile(icon: "rectangle.stack.fill", value: "\(displayCardsFlipped)", label: "Cards Flipped")
                statTile(icon: "gamecontroller.fill", value: "\(authManager.userProfile?.gamesPlayed ?? 0)", label: "Games Played")
                statTile(icon: "trophy.fill", value: "\(authManager.userProfile?.onlineGamesWon ?? 0)", label: "Online Wins")
            }
        }
        .padding(.horizontal, 40)
    }

    @ViewBuilder
    private var milestoneSection: some View {
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
    }

    @ViewBuilder
    private var plusUpgradeSection: some View {
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
    }

    private var friendsEntrySection: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                HapticManager.shared.lightImpact()
                showFriendsList = true
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.08))
                            .frame(width: 38, height: 38)
                        Image(systemName: "person.2")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Friends")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                        Text("Add friends & invites")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.45), lineWidth: 1.2)
                )
            }
            .buttonStyle(PlainButtonStyle())

            if showFriendsBadge {
                Circle()
                    .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                    .offset(x: -4, y: 4)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showFriendsBadge)
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 40)
    }

    @ViewBuilder
    private func statTile(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
        .cornerRadius(12)
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
