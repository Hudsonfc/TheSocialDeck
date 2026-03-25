//
//  InviteFriendsSheet.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

private enum InviteTab: String, CaseIterable {
    case friends = "Invite a Friend"
    case search = "Search Player"
}

struct InviteFriendsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var friendService = FriendService.shared
    @StateObject private var onlineManager = OnlineManager.shared
    let room: OnlineRoom
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var invitedUserIds: Set<String> = []
    @State private var selectedTab: InviteTab = .friends
    @State private var showShareSheet = false

    // Search state
    @State private var searchText = ""
    @State private var searchResults: [UserProfile] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    tabSelector
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    if selectedTab == .friends {
                        friendsContent
                    } else {
                        searchContent
                    }

                    shareButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Invite Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryAccent)
                }
            }
            .onAppear {
                Task {
                    do { try await friendService.loadFriends() }
                    catch {
                        errorMessage = "Failed to load friends"
                        showError = true
                    }
                }
            }
            .onDisappear { searchTask?.cancel() }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [
                    "Hey! Join my game on The Social Deck \u{1F0CF}\nRoom code: \(room.roomCode)\nDownload the app: https://apps.apple.com/app/the-social-deck/id6740043553"
                ])
            }
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(InviteTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                    HapticManager.shared.lightImpact()
                } label: {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: tab == .friends ? "person.2.fill" : "magnifyingglass")
                                .font(.system(size: 13, weight: .semibold))
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: selectedTab == tab ? .bold : .medium, design: .rounded))
                        }
                        .foregroundColor(selectedTab == tab ? .primaryAccent : .secondaryText)
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(selectedTab == tab ? Color.primaryAccent : Color.clear)
                            .frame(height: 2.5)
                            .cornerRadius(2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Friends List Content

    private var friendsContent: some View {
        Group {
            if friendService.isLoading {
                Spacer()
                VStack(spacing: 16) {
                    ProgressView().scaleEffect(1.3).tint(Color.primaryAccent)
                    Text("Loading friends...").font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(.secondaryText)
                }
                Spacer()
            } else if friendService.friends.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 44, weight: .light))
                        .foregroundColor(.secondaryText.opacity(0.5))
                    Text("No Friends Yet")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    Text("Use the Search tab to find players by username")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(friendService.friends) { friend in
                            InviteFriendRow(
                                friend: friend,
                                room: room,
                                isInvited: invitedUserIds.contains(friend.userId),
                                onInvite: { Task { await sendInvite(userId: friend.userId) } }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }
            }
        }
    }

    // MARK: - Search Content

    private var searchContent: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

            if isSearching {
                Spacer()
                ProgressView().scaleEffect(1.3).tint(Color.primaryAccent)
                Spacer()
            } else if searchText.count < 2 {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.primaryAccent.opacity(0.4))
                    Text("Search by username")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    Text("Enter at least 2 characters to find a player")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                Spacer()
            } else if searchResults.isEmpty {
                Spacer()
                Text("No players found")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondaryText)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(searchResults) { profile in
                            SearchInviteRow(
                                profile: profile,
                                isInvited: invitedUserIds.contains(profile.userId),
                                onInvite: { Task { await sendInvite(userId: profile.userId) } }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.primaryAccent)
                .font(.system(size: 16, weight: .medium))
            TextField("Search by username", text: $searchText)
                .font(.system(size: 15, design: .rounded))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: searchText) { _, newValue in
                    searchTask?.cancel()
                    if newValue.count < 2 {
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
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.secondaryBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.borderColor.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button {
            HapticManager.shared.lightImpact()
            showShareSheet = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                Text("Share Room Code")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.secondaryBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.borderColor.opacity(0.35), lineWidth: 1)
            )
        }
    }

    // MARK: - Helpers

    private func sendInvite(userId: String) async {
        await onlineManager.sendRoomInvite(toUserId: userId)
        await MainActor.run { invitedUserIds.insert(userId) }
    }

    private func performSearch(query: String) async {
        guard query.count >= 2 else { return }
        await MainActor.run { isSearching = true }
        do {
            let results = try await friendService.searchUsers(by: query)
            let myId = AuthManager.shared.userProfile?.userId
            let alreadyInRoom = Set(room.players.map(\.id))
            await MainActor.run {
                searchResults = results.filter { $0.userId != myId && !alreadyInRoom.contains($0.userId) }
                isSearching = false
            }
        } catch {
            await MainActor.run {
                searchResults = []
                isSearching = false
            }
        }
    }
}

// MARK: - Invite Friend Row

struct InviteFriendRow: View {
    let friend: FriendProfile
    let room: OnlineRoom
    let isInvited: Bool
    let onInvite: () -> Void
    @State private var isSending = false

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(
                avatarType: friend.avatarType,
                avatarColor: friend.avatarColor,
                size: 44
            )

            Text(friend.username)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.primaryText)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                guard !isInvited && !isSending else { return }
                HapticManager.shared.lightImpact()
                isSending = true
                onInvite()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isSending = false }
            } label: {
                Group {
                    if isSending {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(0.8)
                    } else if isInvited {
                        Label("Sent", systemImage: "checkmark").font(.system(size: 13, weight: .semibold, design: .rounded))
                    } else {
                        Label("Invite", systemImage: "paperplane.fill").font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(width: 80, height: 36)
                .background(isInvited ? Color.green : Color.primaryAccent)
                .cornerRadius(10)
            }
            .disabled(isInvited || isSending)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.borderColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Search Invite Row

private struct SearchInviteRow: View {
    let profile: UserProfile
    let isInvited: Bool
    let onInvite: () -> Void
    @State private var isSending = false

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(
                avatarType: profile.avatarType,
                avatarColor: profile.avatarColor,
                size: 44
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.username)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text("@\(profile.username.lowercased())")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                guard !isInvited && !isSending else { return }
                HapticManager.shared.lightImpact()
                isSending = true
                onInvite()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isSending = false }
            } label: {
                Group {
                    if isSending {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(0.8)
                    } else if isInvited {
                        Label("Sent", systemImage: "checkmark").font(.system(size: 13, weight: .semibold, design: .rounded))
                    } else {
                        Label("Invite", systemImage: "paperplane.fill").font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(width: 80, height: 36)
                .background(isInvited ? Color.green : Color.primaryAccent)
                .cornerRadius(10)
            }
            .disabled(isInvited || isSending)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.borderColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    InviteFriendsSheet(room: OnlineRoom(
        roomCode: "ABCD",
        roomName: "Test Room",
        createdBy: "test",
        hostId: "test"
    ))
}
