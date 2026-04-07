//
//  FriendsListView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import FirebaseFirestore

private enum FriendsHubTab: String, CaseIterable {
    case friends = "Friends"
    case requests = "Requests"
    case roomInvites = "Rooms"
}

struct FriendsListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var friendService = FriendService.shared
    @StateObject private var onlineManager = OnlineManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var showError = false
    @State private var selectedFriend: FriendProfile? = nil
    @State private var showInviteSheet = false
    @State private var showRemoveConfirmation = false
    @State private var friendToRemove: FriendProfile? = nil
    @State private var toast: ToastMessage? = nil
    @State private var showSearchSheet = false
    @State private var selectedHubTab: FriendsHubTab = .friends
    @State private var showLobbyFullScreen = false
    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    private var friendsToShow: [FriendProfile] {
        friendService.friends
    }

    private var showLoadingState: Bool {
        friendService.isLoading
    }

    private var roomInviteBadgeCount: Int {
        return onlineManager.roomInviteCountForBadge
    }

    private var incomingRequestBadgeCount: Int {
        return friendService.pendingRequests.count
    }

    private var pendingRequestsWithIds: [(String, FriendRequest)] {
        friendService.pendingRequests.compactMap { req in
            guard let id = req.id else { return nil }
            return (id, req)
        }
    }

    private var sentRequestsWithIds: [(String, FriendRequest)] {
        friendService.sentRequests.compactMap { req in
            guard let id = req.id else { return nil }
            return (id, req)
        }
    }

    private var visibleHubTabs: [FriendsHubTab] {
        [.friends, .requests, .roomInvites]
    }

    // MARK: - Friends tab

    @ViewBuilder
    private var friendsTabContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(friendsToShow.count) friend\(friendsToShow.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .padding(.horizontal, 4)

                if friendsToShow.isEmpty {
                    friendsEmptyPlaceholder
                } else {
                    VStack(spacing: 6) {
                        ForEach(friendsToShow) { friend in
                            FriendRowView(
                                friend: friend,
                                useMockProfileData: false,
                                onInvite: {
                                    HapticManager.shared.lightImpact()
                                    selectedFriend = friend
                                    showInviteSheet = true
                                },
                                onRemove: {
                                    friendToRemove = friend
                                    showRemoveConfirmation = true
                                }
                            )
                        }
                    }
                }
            }
            .responsiveHorizontalPadding()
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .refreshable {
            await refreshFriendsList()
        }
    }

    private var friendsEmptyPlaceholder: some View {
        VStack(spacing: 20) {
            Image("man crying artwork")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("No friends yet")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("Tap the search icon (top right) to find people. After you send a request, it appears under Requests.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 360, alignment: .center)
        .padding(.vertical, 32)
    }

    // MARK: - Room invites tab

    private var roomInvitesTabContent: some View {
        RoomInvitesView(embeddedInFriendsHub: true)
            .refreshable {
                await refreshRoomInvitesList()
            }
    }

    // MARK: - Requests tab

    @ViewBuilder
    private var requestsTabContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                requestsSectionHeader("Received")
                if friendService.pendingRequests.isEmpty {
                    Text("No incoming friend requests")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                } else {
                    ForEach(pendingRequestsWithIds, id: \.0) { _, request in
                        PendingRequestRow(request: request)
                    }
                }

                requestsSectionHeader("Sent")
                if friendService.sentRequests.isEmpty {
                    Text("No outgoing requests")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                } else {
                    ForEach(sentRequestsWithIds, id: \.0) { _, request in
                        SentFriendRequestRow(request: request)
                    }
                }
            }
            .responsiveHorizontalPadding()
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .refreshable {
            await refreshRequestsList()
        }
    }

    private func requestsSectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(.secondaryText)
            .tracking(0.8)
    }

    private func refreshFriendsList() async {
        HapticManager.shared.lightImpact()
        do {
            try await friendService.loadFriends()
            toast = ToastMessage(message: "Friends list refreshed", type: .success)
        } catch {
            toast = ToastMessage(message: "Failed to refresh", type: .error)
        }
    }

    private func refreshRequestsList() async {
        HapticManager.shared.lightImpact()
        do {
            try await friendService.loadPendingRequests()
            try await friendService.loadSentRequests()
            toast = ToastMessage(message: "Requests refreshed", type: .success)
        } catch {
            toast = ToastMessage(message: "Failed to refresh", type: .error)
        }
    }

    private func refreshRoomInvitesList() async {
        HapticManager.shared.lightImpact()
        // Realtime listener keeps this list live; refresh stays as a lightweight UX affordance.
        toast = ToastMessage(message: "Room invites refreshed", type: .success)
    }

    private func hubTabBadgeCount(for tab: FriendsHubTab) -> Int {
        switch tab {
        case .friends: return 0
        case .requests: return incomingRequestBadgeCount
        case .roomInvites: return roomInviteBadgeCount
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Tabs — same visual language as Play2View `CategoryTab`
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(visibleHubTabs, id: \.rawValue) { tab in
                            FriendsHubCategoryTab(
                                title: tab.rawValue,
                                isSelected: selectedHubTab == tab,
                                badgeCount: hubTabBadgeCount(for: tab)
                            )
                            .onTapGesture {
                                if selectedHubTab != tab {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedHubTab = tab
                                    }
                                    HapticManager.shared.lightImpact()
                                }
                            }
                        }
                    }
                    .responsiveHorizontalPadding()
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedHubTab)
                .padding(.top, 8)
                .padding(.bottom, 8)

                if showLoadingState {
                    Spacer()
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.primaryAccent)
                        Text("Loading friends...")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                    Spacer()
                } else {
                    TabView(selection: $selectedHubTab) {
                        friendsTabContent
                            .tag(FriendsHubTab.friends)
                        requestsTabContent
                            .tag(FriendsHubTab.requests)
                        roomInvitesTabContent
                            .tag(FriendsHubTab.roomInvites)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryText)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    showSearchSheet = true
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.primaryAccent)
                }
                .accessibilityLabel("Search and add friends")
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showSearchSheet) {
            FriendsSearchSheet(
                onRequestSent: { username in
                    selectedHubTab = .requests
                    Task {
                        try? await friendService.loadSentRequests()
                    }
                }
            )
        }
        .onAppear {
            // Mark badge as seen based on current live data.
            let seenRequestIds = friendService.pendingRequests.compactMap(\.id).joined(separator: ",")
            let seenRoomInviteIds = onlineManager.pendingRoomInvites.compactMap(\.id).joined(separator: ",")
            UserDefaults.standard.set(seenRequestIds, forKey: "lastSeenFriendRequestIds")
            UserDefaults.standard.set(seenRoomInviteIds, forKey: "lastSeenRoomInviteIds")
            Task {
                do {
                    try await friendService.loadFriends()
                    try await friendService.loadPendingRequests()
                    try await friendService.loadSentRequests()
                    friendService.startListeningToFriends()
                    friendService.startListeningToPendingRequests()
                    friendService.startListeningToSentRequests()
                    // Update seen IDs after fresh data loads
                    UserDefaults.standard.set(
                        friendService.pendingRequests.compactMap(\.id).joined(separator: ","),
                        forKey: "lastSeenFriendRequestIds"
                    )
                    UserDefaults.standard.set(
                        onlineManager.pendingRoomInvites.compactMap(\.id).joined(separator: ","),
                        forKey: "lastSeenRoomInviteIds"
                    )
                } catch {
                    showError = true
                }
            }
        }
        .onDisappear {
            friendService.stopListeningToFriends()
            friendService.stopListeningToPendingRequests()
            friendService.stopListeningToSentRequests()
        }
        // Navigate to the correct tab when the user taps a push notification
        .onChange(of: notificationManager.pendingDeepLink) { _, destination in
            guard let destination = destination else { return }
            withAnimation {
                switch destination {
                case .requests:   selectedHubTab = .requests
                case .roomInvites: selectedHubTab = .roomInvites
                }
            }
            notificationManager.pendingDeepLink = nil
        }
        .onChange(of: selectedHubTab) { _, newTab in
            Task {
                switch newTab {
                case .requests:
                    try? await friendService.loadSentRequests()
                    try? await friendService.loadPendingRequests()
                case .roomInvites:
                    break
                case .friends:
                    break
                }
            }
        }
        .onChange(of: onlineManager.currentRoom) { _, room in
            print("[FriendsListView] onChange currentRoom fired — room: \(room?.roomCode ?? "nil"), tab: \(selectedHubTab.rawValue), showLobby: \(showLobbyFullScreen)")
            if room != nil && !showLobbyFullScreen {
                print("[FriendsListView] currentRoom set — presenting lobby fullScreenCover")
                showLobbyFullScreen = true
            }
        }
        .fullScreenCover(isPresented: $showLobbyFullScreen, onDismiss: {
            print("[FriendsListView] Lobby fullScreenCover dismissed")
        }) {
            NavigationStack {
                LobbyView()
            }
        }
        .sheet(isPresented: $showInviteSheet) {
            if let friend = selectedFriend, let room = onlineManager.currentRoom {
                InviteFriendView(friend: friend, room: room)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(friendService.errorMessage ?? "Failed to load friends")
        }
        .sheet(isPresented: $showRemoveConfirmation, onDismiss: { friendToRemove = nil }) {
            if let friend = friendToRemove {
                RemoveFriendConfirmSheet(
                    friend: friend,
                    onConfirmRemove: {
                        Task {
                            await removeFriend(friend)
                        }
                    }
                )
            }
        }
        .toast($toast)
    }
    
    private func removeFriend(_ friend: FriendProfile) async {
        do {
            try await friendService.removeFriend(friend.userId)
            HapticManager.shared.success()
            toast = ToastMessage(message: "\(friend.username) removed", type: .success)
        } catch {
            HapticManager.shared.error()
            toast = ToastMessage(message: "Failed to remove friend", type: .error)
        }
    }

}

// MARK: - Hub tab (Play2View-style underline + optional badge)

private struct FriendsHubCategoryTab: View {
    let title: String
    let isSelected: Bool
    var badgeCount: Int = 0

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: isSelected ? .bold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? Color.primaryAccent : Color.secondaryText)

                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.primaryAccent)
                        .clipShape(Capsule())
                }
            }

            Rectangle()
                .fill(isSelected ? Color.primaryAccent : Color.clear)
                .frame(height: 3)
        }
    }
}

// MARK: - Search sheet (add friends)

private struct FriendsSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var friendService = FriendService.shared
    @StateObject private var authManager = AuthManager.shared
    var onRequestSent: (String?) -> Void

    @State private var searchText = ""
    @State private var searchResults: [UserProfile] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var toast: ToastMessage?

    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    searchBar
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 16)

                    if isSearching {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(Color.primaryAccent)
                        Spacer()
                    } else if searchText.count < 2 {
                        searchHintEmpty
                    } else if searchResults.isEmpty {
                        searchNoResults
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(searchResults) { profile in
                                    UserSearchResultRow(
                                        profile: profile,
                                        onSendRequest: {
                                            Task { await sendRequest(to: profile) }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("Add friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.primaryAccent)
                }
            }
        }
        .onDisappear { searchTask?.cancel() }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .toast($toast)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.primaryAccent)
                .font(.system(size: 18, weight: .medium))
            TextField("Search by username", text: $searchText)
                .font(.system(size: 16, design: .rounded))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: searchText) { _, newValue in
                    searchTask?.cancel()
                    if newValue.isEmpty || newValue.count < 2 {
                        searchResults = []
                        isSearching = false
                        return
                    }
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        guard !Task.isCancelled else { return }
                        await performSearch(query: newValue)
                    }
                }
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    searchResults = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondaryText.opacity(0.6))
                        .font(.system(size: 18))
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.secondaryBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderColor.opacity(0.4), lineWidth: 1)
        )
    }

    private var searchHintEmpty: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color.primaryAccent.opacity(0.45))
            Text("Search by username")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
            Text("Enter at least 2 characters to find people and send a request.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
        }
    }

    private var searchNoResults: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("No users found")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
            Text("Try a different username.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
            Spacer()
        }
    }

    private func performSearch(query: String) async {
        guard query.count >= 2 else { return }
        await MainActor.run { isSearching = true }
        do {
            let results = try await friendService.searchUsers(by: query)
            let uid = authManager.userProfile?.userId
            await MainActor.run {
                searchResults = results.filter { $0.userId != uid }
                isSearching = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                searchResults = []
                isSearching = false
            }
        }
    }

    private func sendRequest(to profile: UserProfile) async {
        do {
            try await friendService.sendFriendRequest(to: profile.userId)
            await MainActor.run {
                HapticManager.shared.success()
                onRequestSent(profile.username)
                toast = ToastMessage(message: "Friend request sent", type: .success)
                if !searchText.isEmpty {
                    Task { await performSearch(query: searchText) }
                }
            }
        } catch {
            await MainActor.run {
                HapticManager.shared.error()
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

}

// MARK: - Remove friend (modern sheet)

private struct RemoveFriendConfirmSheet: View {
    @Environment(\.dismiss) private var dismiss
    let friend: FriendProfile
    var onConfirmRemove: () -> Void

    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondaryText.opacity(0.22))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 18)

            AvatarView(
                avatarType: friend.avatarType,
                avatarColor: friend.avatarColor,
                size: 56
            )
            .padding(.bottom, 14)

            Text("Remove \(friend.username)?")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)

            Text("They won’t be notified. You can add them again anytime from search.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 28)

            Spacer(minLength: 20)

            VStack(spacing: 10) {
                Button {
                    HapticManager.shared.mediumImpact()
                    onConfirmRemove()
                    dismiss()
                } label: {
                    Text("Remove friend")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(brandRed)
                        .cornerRadius(14)
                }

                Button {
                    HapticManager.shared.lightImpact()
                    dismiss()
                } label: {
                    Text("Keep friend")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.visible)
    }
}

private struct FriendActionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let friend: FriendProfile
    let onViewProfile: () -> Void
    let onRemove: () -> Void

    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondaryText.opacity(0.22))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 16)

            AvatarView(
                avatarType: friend.avatarType,
                avatarColor: friend.avatarColor,
                size: 52
            )
            .padding(.bottom, 12)

            Text(friend.username)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .padding(.bottom, 18)

            VStack(spacing: 10) {
                Button {
                    HapticManager.shared.lightImpact()
                    onViewProfile()
                    dismiss()
                } label: {
                    Label("View profile", systemImage: "person.crop.circle")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.secondaryBackground)
                        .cornerRadius(12)
                }

                Button {
                    HapticManager.shared.lightImpact()
                    onRemove()
                    dismiss()
                } label: {
                    Label("Remove friend", systemImage: "trash")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(brandRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(brandRed.opacity(0.08))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)

            Button {
                HapticManager.shared.lightImpact()
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .padding(.top, 14)
                    .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Friend Row View

struct FriendRowView: View {
    let friend: FriendProfile
    var useMockProfileData: Bool = false
    let onInvite: () -> Void
    let onRemove: () -> Void

    @State private var showFriendActions = false
    @State private var showProfile = false

    private let avatarSize: CGFloat = 42
    private var canInviteToRoom: Bool { OnlineManager.shared.currentRoom != nil }

    var body: some View {
        ZStack {
            // Invisible NavigationLink triggered programmatically
            NavigationLink(
                destination: FriendProfileView(
                    friend: friend,
                    initialProfile: previewProfile,
                    shouldLoadFromFirestore: !useMockProfileData
                ),
                isActive: $showProfile
            ) {
                EmptyView()
            }
            .hidden()

            HStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    AvatarView(
                        avatarType: friend.avatarType,
                        avatarColor: friend.avatarColor,
                        size: avatarSize
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.borderColor.opacity(0.35), lineWidth: 1)
                    )

                    Circle()
                        .fill(friend.isOnline ? Color.green : Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color.cardBackground, lineWidth: 2))
                        .offset(x: 1, y: 1)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.username)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .lineLimit(1)

                    Text(statusSubtitle)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                Button {
                    HapticManager.shared.lightImpact()
                    showFriendActions = true
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondaryText.opacity(0.78))
                        .frame(width: 32, height: 32)
                        .background(Color.secondaryBackground)
                        .clipShape(Circle())
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Friend actions")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                HapticManager.shared.lightImpact()
                showProfile = true
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.borderColor.opacity(0.34), lineWidth: 1)
        )
        .sheet(isPresented: $showFriendActions) {
            FriendActionsSheet(
                friend: friend,
                onViewProfile: {
                    showProfile = true
                },
                onRemove: onRemove
            )
        }
    }

    private var previewProfile: UserProfile {
        UserProfile(
            userId: friend.userId,
            username: friend.username,
            avatarType: friend.avatarType,
            avatarColor: friend.avatarColor,
            createdAt: Date(timeIntervalSinceNow: -3600 * 24 * 120),
            totalCardsFlipped: 312,
            lastActiveAt: friend.lastActiveAt,
            isOnline: friend.isOnline,
            isPlus: friend.username == "Maya"
        )
    }

    private var statusSubtitle: String {
        if friend.isOnline {
            return "Online"
        }
        if let lastActive = friend.lastActiveAt {
            return "Active \(formatLastActive(lastActive))"
        }
        return "Offline"
    }
    
    private func formatLastActive(_ date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Friend Profile View

struct FriendProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let friend: FriendProfile
    var initialProfile: UserProfile? = nil
    var shouldLoadFromFirestore: Bool = true

    @State private var fullProfile: UserProfile?
    @State private var isLoading: Bool
    @State private var showRemoveSheet = false

    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
    private let db = Firestore.firestore()

    init(
        friend: FriendProfile,
        initialProfile: UserProfile? = nil,
        shouldLoadFromFirestore: Bool = true
    ) {
        self.friend = friend
        self.initialProfile = initialProfile
        self.shouldLoadFromFirestore = shouldLoadFromFirestore
        _fullProfile = State(initialValue: initialProfile)
        _isLoading = State(initialValue: shouldLoadFromFirestore && initialProfile == nil)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(brandRed)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        profileHeader
                        statsSection
                            .padding(.top, 14)
                        removeFriendButton
                    }
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryText)
                }
            }
        }
        .sheet(isPresented: $showRemoveSheet) {
            RemoveFriendConfirmSheet(friend: friend, onConfirmRemove: {
                Task { await removeFriendAndDismiss() }
            })
        }
        .task { await loadFullProfile() }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    brandRed.opacity(0.16),
                    brandRed.opacity(0.08),
                    Color.appBackground.opacity(0.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 170)
            .overlay(
                AvatarView(
                    avatarType: friend.avatarType,
                    avatarColor: friend.avatarColor,
                    size: 110
                )
                .overlay(
                    Circle()
                        .stroke(Color.cardBackground, lineWidth: 4)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
                .offset(y: 36),
                alignment: .bottom
            )
            .padding(.bottom, 52)

            VStack(spacing: 16) {
                HStack {
                    Spacer(minLength: 0)
                    HStack(spacing: 8) {
                        Text(friend.username)
                            .font(.system(size: 27, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        if fullProfile?.isPlus == true {
                            Label("PLUS", systemImage: "crown.fill")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(brandRed)
                                .cornerRadius(9)
                        }
                        Circle()
                            .fill(friend.isOnline ? Color.green : Color.gray.opacity(0.5))
                            .frame(width: 10, height: 10)
                    }
                    .lineLimit(1)
                    Spacer(minLength: 0)
                }

                Text("Member since \(formattedDate(fullProfile?.createdAt ?? Date()))")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.borderColor.opacity(0.35), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(spacing: 12) {
            if let profile = fullProfile {
                HStack(spacing: 10) {
                    statCard(title: "Cards Flipped", value: "\(profile.totalCardsFlipped)", icon: "rectangle.on.rectangle.angled.fill")
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(brandRed.opacity(0.8))
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
            Text(title)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.borderColor.opacity(0.35), lineWidth: 1)
        )
    }

    // MARK: - Remove button

    private var removeFriendButton: some View {
        Button {
            HapticManager.shared.lightImpact()
            showRemoveSheet = true
        } label: {
            Text("Remove Friend")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(brandRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandRed.opacity(0.45), lineWidth: 1.2)
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func loadFullProfile() async {
        guard shouldLoadFromFirestore else {
            isLoading = false
            return
        }
        do {
            let snapshot = try await db.collection("profiles").document(friend.userId).getDocument()
            if snapshot.exists {
                fullProfile = try? snapshot.data(as: UserProfile.self)
            }
        } catch {
            // Non-fatal — show what we have from FriendProfile
        }
        if fullProfile == nil {
            fullProfile = initialProfile
        }
        isLoading = false
    }

    private func removeFriendAndDismiss() async {
        do {
            try await FriendService.shared.removeFriend(friend.userId)
            HapticManager.shared.success()
            dismiss()
        } catch {
            HapticManager.shared.error()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

}

// MARK: - Invite Friend View

struct InviteFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    let friend: FriendProfile
    let room: OnlineRoom
    @State private var showShareSheet = false
    @State private var inviteSent = false
    @State private var isSendingInvite = false

    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 20)

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.secondaryBackground)
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)

                        AvatarView(
                            avatarType: friend.avatarType,
                            avatarColor: friend.avatarColor,
                            size: 100
                        )
                    }

                    VStack(spacing: 8) {
                        Text("Invite \(friend.username)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)

                        Text("Room: \(room.roomName)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                }

                // Room code
                VStack(spacing: 16) {
                    Text("Room Code")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)

                    Text(room.roomCode)
                        .font(.system(size: 42, weight: .bold, design: .monospaced))
                        .foregroundColor(.primaryText)
                        .tracking(6)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 20)
                        .background(Color.tertiaryBackground)
                        .cornerRadius(20)
                }
                .padding(.horizontal, 40)

                VStack(spacing: 12) {
                    // In-app invite button
                    Button {
                        guard !inviteSent else { return }
                        HapticManager.shared.mediumImpact()
                        isSendingInvite = true
                        Task {
                            await onlineManager.sendRoomInvite(toUserId: friend.userId)
                            isSendingInvite = false
                            inviteSent = true
                        }
                    } label: {
                        Group {
                            if isSendingInvite {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else if inviteSent {
                                Label("Invite sent!", systemImage: "checkmark")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            } else {
                                Label("Send invite to \(friend.username)", systemImage: "paperplane.fill")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(inviteSent ? Color.green : brandRed)
                        .cornerRadius(14)
                        .animation(.easeInOut(duration: 0.2), value: inviteSent)
                    }
                    .disabled(inviteSent || isSendingInvite)

                    // Share-sheet fallback
                    Button {
                        showShareSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Share room code")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.secondaryBackground)
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
            .navigationTitle("Invite Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(brandRed)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [
                    "Hey! Join my game on The Social Deck \u{1F0CF}\nRoom code: \(room.roomCode)\nDownload the app: https://apps.apple.com/app/the-social-deck/id6740043553"
                ])
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationView {
        FriendsListView()
    }
}
