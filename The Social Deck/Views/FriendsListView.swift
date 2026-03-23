//
//  FriendsListView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Production mode
// App Store/live builds must use real Firestore data.
private let friendsListUsesMockData = false

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
    /// Mock-only: outgoing preview rows after “Add” from search sheet
    @State private var mockSentUsernames: [String] = []
    /// Mock-only: live preview friends shown in the Friends tab
    @State private var mockFriendsPreview: [FriendProfile] = Self.mockFriends
    /// Mock-only: live copy of pending incoming invites (starts from FriendsListMock, shrinks on Accept/Decline)
    @State private var mockPendingInvites: [MockFriendInvite] = FriendsListMock.pendingFriendInvites
    /// Mock-only: room invites preview rows in Rooms tab
    @State private var mockRoomInvites: [MockRoomInvitePreview] = FriendsListMock.roomInvites
    /// Mock-only: friends accepted from the Requests tab preview
    @State private var mockAcceptedFriends: [FriendProfile] = []

    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    private var friendsToShow: [FriendProfile] {
        friendsListUsesMockData ? mockFriendsPreview + mockAcceptedFriends : friendService.friends
    }

    private var showLoadingState: Bool {
        !friendsListUsesMockData && friendService.isLoading
    }

    private var roomInviteBadgeCount: Int {
        if friendsListUsesMockData { return mockRoomInvites.count }
        return onlineManager.pendingRoomInvites.count
    }

    private var incomingRequestBadgeCount: Int {
        if friendsListUsesMockData { return mockPendingInvites.count }
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

    // MARK: - Friends tab

    @ViewBuilder
    private var friendsTabContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                if friendsListUsesMockData {
                    Text("Preview — mock data")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .padding(.horizontal, 4)
                }

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
                                useMockProfileData: friendsListUsesMockData,
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
            Text("No friends yet")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
            Text("Tap the search icon (top right) to find people. After you send a request, it appears under Requests.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - Room invites tab

    private var roomInvitesTabContent: some View {
        Group {
            if friendsListUsesMockData {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preview — mock data")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)

                        if mockRoomInvites.isEmpty {
                            Text("No room invites")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .padding(.top, 4)
                        } else {
                            ForEach(mockRoomInvites) { invite in
                                MockRoomInviteCard(invite: invite) { action in
                                    HapticManager.shared.lightImpact()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        mockRoomInvites.removeAll { $0.id == invite.id }
                                    }
                                    toast = ToastMessage(message: "Preview — \(action) room invite", type: .success)
                                }
                            }
                        }
                    }
                    .responsiveHorizontalPadding()
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
            } else {
                RoomInvitesView(embeddedInFriendsHub: true)
                    .refreshable {
                        await refreshRoomInvitesList()
                    }
            }
        }
    }

    // MARK: - Requests tab

    @ViewBuilder
    private var requestsTabContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                if friendsListUsesMockData {
                    Text("Preview — mock data")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }

                requestsSectionHeader("Received")
                if friendsListUsesMockData {
                    ForEach(mockPendingInvites) { invite in
                        MockFriendRequestRow(invite: invite) { action in
                            HapticManager.shared.lightImpact()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                mockPendingInvites.removeAll { $0.id == invite.id }
                                if action == "Accept" {
                                    let profile = UserProfile(
                                        userId: invite.id.uuidString,
                                        username: invite.username,
                                        avatarType: invite.avatarType,
                                        avatarColor: invite.avatarColor,
                                        isOnline: true
                                    )
                                    mockAcceptedFriends.append(FriendProfile(profile: profile, isOnline: true))
                                }
                            }
                        }
                    }
                    if mockPendingInvites.isEmpty {
                        Text("No incoming friend requests")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .padding(.vertical, 8)
                    }
                } else if friendService.pendingRequests.isEmpty {
                    Text("No incoming friend requests")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .padding(.vertical, 8)
                } else {
                    ForEach(pendingRequestsWithIds, id: \.0) { _, request in
                        PendingRequestRow(request: request)
                    }
                }

                requestsSectionHeader("Sent")
                if friendsListUsesMockData {
                    ForEach(mockSentUsernames, id: \.self) { name in
                        MockOutgoingFriendRow(username: name)
                    }
                    if mockSentUsernames.isEmpty {
                        Text("Use search to add someone — they’ll show up here as a pending request.")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .padding(.vertical, 4)
                    }
                } else if friendService.sentRequests.isEmpty {
                    Text("No outgoing requests")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .padding(.vertical, 8)
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
        if friendsListUsesMockData {
            toast = ToastMessage(message: "Preview data — nothing to refresh", type: .success)
            return
        }
        do {
            try await friendService.loadFriends()
            toast = ToastMessage(message: "Friends list refreshed", type: .success)
        } catch {
            toast = ToastMessage(message: "Failed to refresh", type: .error)
        }
    }

    private func refreshRequestsList() async {
        HapticManager.shared.lightImpact()
        if friendsListUsesMockData {
            toast = ToastMessage(message: "Preview data — nothing to refresh", type: .success)
            return
        }
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
        if friendsListUsesMockData {
            toast = ToastMessage(message: "Preview data — nothing to refresh", type: .success)
            return
        }
        await onlineManager.loadPendingRoomInvites()
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
                        ForEach(FriendsHubTab.allCases, id: \.rawValue) { tab in
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
                friendsListUsesMockData: friendsListUsesMockData,
                onRequestSent: { username in
                    if friendsListUsesMockData, let name = username, !mockSentUsernames.contains(name) {
                        mockSentUsernames.insert(name, at: 0)
                    }
                    selectedHubTab = .requests
                    Task {
                        try? await friendService.loadSentRequests()
                    }
                }
            )
        }
        .onAppear {
            // Mark badge as seen — always runs regardless of mock/real mode.
            let seenRequestIds = friendsListUsesMockData
                ? ""
                : friendService.pendingRequests.compactMap(\.id).joined(separator: ",")
            let seenRoomInviteIds = friendsListUsesMockData
                ? ""
                : onlineManager.pendingRoomInvites.compactMap(\.id).joined(separator: ",")
            UserDefaults.standard.set(seenRequestIds, forKey: "lastSeenFriendRequestIds")
            UserDefaults.standard.set(seenRoomInviteIds, forKey: "lastSeenRoomInviteIds")

            guard !friendsListUsesMockData else { return }
            Task {
                do {
                    try await friendService.loadFriends()
                    try await friendService.loadPendingRequests()
                    try await friendService.loadSentRequests()
                    await onlineManager.loadPendingRoomInvites()
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
            guard !friendsListUsesMockData else { return }
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
            guard !friendsListUsesMockData else { return }
            Task {
                switch newTab {
                case .requests:
                    try? await friendService.loadSentRequests()
                    try? await friendService.loadPendingRequests()
                case .roomInvites:
                    await onlineManager.loadPendingRoomInvites()
                case .friends:
                    break
                }
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
        if friendsListUsesMockData {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                mockFriendsPreview.removeAll { $0.userId == friend.userId }
                mockAcceptedFriends.removeAll { $0.userId == friend.userId }
            }
            toast = ToastMessage(message: "\(friend.username) removed (preview)", type: .success)
            return
        }
        do {
            try await friendService.removeFriend(friend.userId)
            HapticManager.shared.success()
            toast = ToastMessage(message: "\(friend.username) removed", type: .success)
        } catch {
            HapticManager.shared.error()
            toast = ToastMessage(message: "Failed to remove friend", type: .error)
        }
    }

    /// Mock profiles for search sheet when `friendsListUsesMockData` is on
    static let mockSearchPreviewProfiles: [UserProfile] = [
        UserProfile(userId: "sr_mock_1", username: "caseyplays", avatarType: "avatar 1", avatarColor: "purple"),
        UserProfile(userId: "sr_mock_2", username: "rileyK", avatarType: "avatar 2", avatarColor: "blue"),
        UserProfile(userId: "sr_mock_3", username: "sam_night", avatarType: "avatar 3", avatarColor: "green")
    ]

    private static let mockFriends: [FriendProfile] = [
        FriendProfile(
            profile: UserProfile(
                userId: "mock_friend_1",
                username: "Maya",
                avatarType: "avatar 2",
                avatarColor: "yellow",
                lastActiveAt: Date(),
                isOnline: true,
                isPlus: true
            ),
            isOnline: true
        ),
        FriendProfile(
            profile: UserProfile(
                userId: "mock_friend_2",
                username: "Jordan",
                avatarType: "avatar 3",
                avatarColor: "green",
                lastActiveAt: Date().addingTimeInterval(-120),
                isOnline: true
            ),
            isOnline: true
        ),
        FriendProfile(
            profile: UserProfile(
                userId: "mock_friend_3",
                username: "Chris",
                avatarType: "avatar 1",
                avatarColor: "blue",
                lastActiveAt: Date().addingTimeInterval(-3600 * 3),
                isOnline: false
            ),
            isOnline: false
        ),
        FriendProfile(
            profile: UserProfile(
                userId: "mock_friend_4",
                username: "Taylor",
                avatarType: "avatar 4",
                avatarColor: "red",
                lastActiveAt: Date().addingTimeInterval(-86400),
                isOnline: false
            ),
            isOnline: false
        )
    ]
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
    let friendsListUsesMockData: Bool
    var onRequestSent: (String?) -> Void

    @State private var searchText = ""
    @State private var searchResults: [UserProfile] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showBlockConfirmation = false
    @State private var userToBlock: UserProfile?
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
                                        },
                                        onBlock: {
                                            userToBlock = profile
                                            showBlockConfirmation = true
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
        .alert("Block User", isPresented: $showBlockConfirmation) {
            Button("Cancel", role: .cancel) { userToBlock = nil }
            Button("Block", role: .destructive) {
                if let user = userToBlock {
                    Task { await blockUser(user.userId) }
                }
                userToBlock = nil
            }
        } message: {
            if let user = userToBlock {
                Text("Block \(user.username)? You won’t be able to send them friend requests.")
            }
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
        if friendsListUsesMockData {
            try? await Task.sleep(nanoseconds: 350_000_000)
            let q = query.lowercased()
            let mockUsers = FriendsListView.mockSearchPreviewProfiles.filter {
                $0.username.lowercased().contains(q)
            }
            await MainActor.run {
                searchResults = mockUsers
                isSearching = false
            }
            return
        }
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
        if friendsListUsesMockData {
            await MainActor.run {
                HapticManager.shared.success()
                onRequestSent(profile.username)
                toast = ToastMessage(message: "Request sent (preview)", type: .success)
                dismiss()
            }
            return
        }
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

    private func blockUser(_ userId: String) async {
        do {
            try await friendService.blockUser(userId)
            await MainActor.run {
                HapticManager.shared.success()
                toast = ToastMessage(message: "User blocked", type: .success)
                if searchText.count >= 2 {
                    Task { await performSearch(query: searchText) }
                }
            }
        } catch {
            await MainActor.run {
                toast = ToastMessage(message: "Failed to block", type: .error)
            }
        }
    }
}

// MARK: - Mock outgoing row (preview)

private struct MockOutgoingFriendRow: View {
    let username: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.secondaryBackground)
                    .frame(width: 48, height: 48)
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.primaryAccent.opacity(0.7))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(username)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
                Text("Request sent · waiting for them to accept")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.secondaryBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderColor.opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - Mock invites metadata

private enum FriendsListMock {
    static let pendingFriendInvites: [MockFriendInvite] = [
        MockFriendInvite(username: "Sam", avatarType: "avatar 1", avatarColor: "purple"),
        MockFriendInvite(username: "Riley", avatarType: "avatar 2", avatarColor: "blue")
    ]

    static let roomInvites: [MockRoomInvitePreview] = [
        MockRoomInvitePreview(
            inviterName: "Maya",
            inviterAvatarType: "avatar 2",
            inviterAvatarColor: "yellow",
            roomName: "Saturday Night",
            roomCode: "4827"
        ),
        MockRoomInvitePreview(
            inviterName: "Jordan",
            inviterAvatarType: "avatar 3",
            inviterAvatarColor: "teal",
            roomName: "Quick Match",
            roomCode: "9154"
        )
    ]
}

private struct MockFriendInvite: Identifiable {
    let id = UUID()
    let username: String
    let avatarType: String
    let avatarColor: String
}

private struct MockRoomInvitePreview: Identifiable {
    let id = UUID()
    let inviterName: String
    let inviterAvatarType: String
    let inviterAvatarColor: String
    let roomName: String
    let roomCode: String
}

private struct MockRoomInviteCard: View {
    let invite: MockRoomInvitePreview
    var onAction: (String) -> Void

    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 10) {
                AvatarView(
                    avatarType: invite.inviterAvatarType,
                    avatarColor: invite.inviterAvatarColor,
                    size: 58
                )
                Text("\(invite.inviterName) invited you")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
                Text("Room: \(invite.roomName)")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
            }

            VStack(spacing: 6) {
                Text("Room Code")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                Text(invite.roomCode)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.primaryText)
                    .tracking(3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.secondaryBackground)
            .cornerRadius(12)

            HStack(spacing: 10) {
                Button("Decline") { onAction("Declined") }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0xF0/255.0, green: 0xF0/255.0, blue: 0xF0/255.0))
                    .cornerRadius(10)

                Button("Accept") { onAction("Accepted") }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(brandRed)
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderColor.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct MockFriendRequestRow: View {
    let invite: MockFriendInvite
    var onAction: (String) -> Void

    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                AvatarView(avatarType: invite.avatarType, avatarColor: invite.avatarColor, size: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(invite.username)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .lineLimit(1)
                    Text("Wants to be friends")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(Color.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 8) {
                Spacer(minLength: 0)
                Button("Decline") {
                    onAction("Decline")
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(red: 0xF0/255.0, green: 0xF0/255.0, blue: 0xF0/255.0))
                .cornerRadius(10)
                .fixedSize(horizontal: true, vertical: false)

                Button("Accept") {
                    onAction("Accept")
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(brandRed)
                .cornerRadius(10)
                .fixedSize(horizontal: true, vertical: false)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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
        .presentationDetents([.height(305)])
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
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
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
        .background(Color.white)
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
            gamesPlayed: 24,
            totalCardsFlipped: 312,
            onlineGamesPlayed: 9,
            onlineGamesWon: 4,
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
                    Color.white.opacity(0.0)
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
                        .stroke(Color.white, lineWidth: 4)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
                .offset(y: 36),
                alignment: .bottom
            )
            .padding(.bottom, 52)

            VStack(spacing: 7) {
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

                Text("Member since \(formattedDate(fullProfile?.createdAt ?? Date()))")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
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
                    statCard(title: "Games Played", value: "\(profile.gamesPlayed)", icon: "gamecontroller.fill")
                    statCard(title: "Cards Flipped", value: "\(profile.totalCardsFlipped)", icon: "rectangle.on.rectangle.angled.fill")
                    statCard(title: "Online Wins", value: "\(profile.onlineGamesWon)", icon: "trophy.fill")
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
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
                .background(Color.white)
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
                            .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                        AvatarView(
                            avatarType: friend.avatarType,
                            avatarColor: friend.avatarColor,
                            size: 100
                        )
                    }

                    VStack(spacing: 8) {
                        Text("Invite \(friend.username)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))

                        Text("Room: \(room.roomName)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                }

                // Room code
                VStack(spacing: 16) {
                    Text("Room Code")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.gray)

                    Text(room.roomCode)
                        .font(.system(size: 42, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .tracking(6)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 20)
                        .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
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
                    "Join my game room '\(room.roomName)' in The Social Deck! Room Code: \(room.roomCode)"
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
