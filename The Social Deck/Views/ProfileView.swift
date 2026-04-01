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
    @State private var friendsBadgePopScale: CGFloat = 1

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

    /// Total pending items (for badge count display only — visibility still uses unseen-ID logic).
    private var friendsBadgePendingTotal: Int {
        friendService.pendingRequests.count + onlineManager.pendingRoomInvites.count
    }

    /// `nil` = show dot only (e.g. edge case); otherwise digit or "9+".
    private var friendsBadgeCountLabel: String? {
        let n = friendsBadgePendingTotal
        guard n >= 1 else { return nil }
        return n > 9 ? "9+" : "\(n)"
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
                        .foregroundColor(.primaryAccent)
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
                    Color.appBackground
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.primaryAccent)
                        Text("Loading profile...")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
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
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                profileHeaderSection
                avatarEditorSection
                usernameSection
                statsSection
                plusUpgradeSection
                friendsEntrySection
                Spacer()
                    .frame(height: 40)
            }
            .opacity(contentOpacity)

            if showMilestone {
                milestoneDropBanner
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
            }
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
                            .foregroundColor(.primaryText)
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
                        .foregroundColor(.primaryText)
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
            .foregroundColor(.primaryText)
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
                                    .fill(Color.cardBackground)
                                    .frame(width: 36, height: 36)
                                    .shadow(color: Color.shadowColor, radius: 4, x: 0, y: 2)
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primaryAccent)
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
                .foregroundColor(.secondaryText)
        }
    }

    private var usernameSection: some View {
        VStack(spacing: 8) {
            Text("Username")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
            ZStack {
                HStack(spacing: 8) {
                    Spacer()
                    Text(authManager.userProfile?.username ?? "Player")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
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
                        .background(Color.primaryAccent)
                        .cornerRadius(20)
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button(action: { showChangeUsername = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primaryAccent)
                            .padding(10)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 40)

            if let createdAt = authManager.userProfile?.createdAt {
                Text("Member since \(createdAt.formatted(.dateTime.month(.wide).day().year()))")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
            }
        }
    }

    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("Game Statistics")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 12) {
                statTile(icon: "rectangle.stack.fill", value: "\(displayCardsFlipped)", label: "Cards Flipped")
                statTile(icon: "gamecontroller.fill", value: "\(authManager.userProfile?.gamesPlayed ?? 0)", label: "Games Played")
                statTile(icon: "trophy.fill", value: "\(authManager.userProfile?.onlineGamesWon ?? 0)", label: "Online Wins")
            }
        }
        .padding(.horizontal, 40)
    }

    private var milestoneDropBanner: some View {
        HStack(spacing: 10) {
            Text("🎉")
                .font(.system(size: 20))
            VStack(alignment: .leading, spacing: 2) {
                Text(milestoneText)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
                Text("Keep flipping!")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
            }
            Spacer()
            Button(action: {
                withAnimation(.easeOut(duration: 0.25)) { showMilestone = false }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondaryText)
                    .padding(6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.green.opacity(0.12))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.35), lineWidth: 1)
        )
        .padding(.horizontal, 24)
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
                        .foregroundColor(.primaryAccent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Upgrade to TheSocialDeck+")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                        Text("Unlock exclusive Plus games")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.primaryAccent.opacity(0.08))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryAccent.opacity(0.28), lineWidth: 1)
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
                            .fill(Color.primaryAccent.opacity(0.12))
                            .frame(width: 38, height: 38)
                        Image(systemName: "person.2")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primaryAccent)
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
                        .foregroundColor(.primaryAccent)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Color.cardBackground)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.primaryAccent.opacity(0.45), lineWidth: 1.2)
                )
            }
            .buttonStyle(PlainButtonStyle())

            if showFriendsBadge {
                profileFriendsNotificationBadge(
                    countLabel: friendsBadgeCountLabel,
                    popScale: friendsBadgePopScale
                )
                // Slightly past the rounded corner — iOS-style icon badge overlap
                .offset(x: 10, y: -9)
                .allowsHitTesting(false)
                .transition(.opacity)
            }
        }
        .onChange(of: showFriendsBadge) { _, visible in
            if visible { playFriendsBadgePopAnimation() }
        }
        .padding(.top, 8)
        .padding(.horizontal, 40)
    }

    private func playFriendsBadgePopAnimation() {
        friendsBadgePopScale = 0.42
        withAnimation(.spring(response: 0.38, dampingFraction: 0.52)) {
            friendsBadgePopScale = 1.0
        }
    }

    /// Red badge with white ring; numeric label when count ≥ 1, else compact dot.
    @ViewBuilder
    private func profileFriendsNotificationBadge(countLabel: String?, popScale: CGFloat) -> some View {
        let brandRed = Color.primaryAccent
        let stroke: CGFloat = 2

        Group {
            if let text = countLabel {
                Text(text)
                    .font(.system(size: text == "9+" ? 9 : 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .padding(.horizontal, 5)
                    .frame(minWidth: 19, minHeight: 19)
                    .background(
                        Capsule()
                            .fill(brandRed)
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.appBackground, lineWidth: stroke)
                    )
            } else {
                Circle()
                    .fill(brandRed)
                    .frame(width: 11, height: 11)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.appBackground, lineWidth: stroke)
                    )
            }
        }
        .scaleEffect(popScale)
    }

    @ViewBuilder
    private func statTile(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primaryAccent)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color.secondaryBackground)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.25)) {
                    showMilestone = false
                }
            }
        }
    }

}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(AuthManager.shared)
            .environmentObject(SubscriptionManager.shared)
            .environmentObject(AvatarStoreManager.shared)
    }
}
