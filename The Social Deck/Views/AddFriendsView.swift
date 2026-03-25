//
//  AddFriendsView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct AddFriendsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var friendService = FriendService.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var searchText: String = ""
    @State private var searchResults: [UserProfile] = []
    @State private var isSearching: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var selectedTab: Int = 0 // 0 = Search, 1 = Pending
    @State private var searchTask: Task<Void, Never>?
    @State private var toast: ToastMessage? = nil
    @State private var showBlockConfirmation = false
    @State private var userToBlock: UserProfile? = nil
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab selector with better styling
                Picker("", selection: $selectedTab) {
                    Text("Search").tag(0)
                    Text("Pending").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                if selectedTab == 0 {
                    searchView
                } else {
                    pendingRequestsView
                }
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
                        .foregroundColor(.primaryText)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                do {
                    try await friendService.loadPendingRequests()
                    try await friendService.loadSentRequests()
                    friendService.startListeningToPendingRequests()
                } catch {
                    // Handle error silently on appear
                }
            }
        }
        .onDisappear {
            friendService.stopListeningToPendingRequests()
            searchTask?.cancel()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Block User", isPresented: $showBlockConfirmation) {
            Button("Cancel", role: .cancel) {
                userToBlock = nil
            }
            Button("Block", role: .destructive) {
                if let user = userToBlock {
                    Task {
                        await blockUser(user.userId)
                    }
                }
                userToBlock = nil
            }
        } message: {
            if let user = userToBlock {
                Text("Are you sure you want to block \(user.username)? You won't be able to send friend requests to them.")
            }
        }
        .toast($toast)
    }
    
    private func blockUser(_ userId: String) async {
        do {
            try await friendService.blockUser(userId)
            HapticManager.shared.success()
            toast = ToastMessage(message: "User blocked", type: .success)
            // Refresh search to update UI
            if !searchText.isEmpty {
                await performSearch(query: searchText)
            }
        } catch {
            HapticManager.shared.error()
            toast = ToastMessage(message: "Failed to block user", type: .error)
        }
    }
    
    // MARK: - Search View
    
    private var searchView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.primaryAccent)
                    .font(.system(size: 18, weight: .medium))
                
                TextField("Search by username", text: $searchText)
                    .font(.system(size: 16, design: .rounded))
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .onChange(of: searchText) { newValue in
                        // Cancel previous search task
                        searchTask?.cancel()
                        
                        // Clear results immediately if search is too short
                        if newValue.isEmpty || newValue.count < 2 {
                            searchResults = []
                            isSearching = false
                            return
                        }
                        
                        // Debounce the search
                        searchTask = Task {
                            // Wait a bit before searching to avoid too many requests
                            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                            
                            // Check if task was cancelled
                            guard !Task.isCancelled else { return }
                            
                            await performSearch(query: newValue)
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            searchText = ""
                            searchResults = []
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.gray.opacity(0.6))
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.secondaryBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.borderColor.opacity(0.4), lineWidth: 1)
            )
            .padding(.horizontal, 40)
            .padding(.bottom, 24)
            
            if isSearching {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.3)
                        .tint(Color.primaryAccent)
                    Text("Searching...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                .padding(.top, 60)
            } else if searchText.isEmpty {
                emptySearchState
            } else if searchResults.isEmpty {
                noResultsState
            } else {
                searchResultsList
            }
        }
    }
    
    private var emptySearchState: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.secondaryBackground)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color.primaryAccent.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("Find Friends")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                
                Text("Enter at least 2 characters to search\nfor friends to add")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }
    
    private var noResultsState: some View {
        VStack(spacing: 24) {
            Image("woman confused")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            VStack(spacing: 12) {
                Text("No Users Found")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                
                Text("Try searching with a different username")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text("Make sure you're typing at least 2 characters")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.tertiaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }
    
    private var searchResultsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(searchResults) { profile in
                    UserSearchResultRow(
                        profile: profile,
                        onSendRequest: {
                            Task {
                                await sendFriendRequest(to: profile.userId)
                            }
                        },
                        onBlock: {
                            userToBlock = profile
                            showBlockConfirmation = true
                        }
                    )
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Pending Requests View
    
    private var pendingRequestsView: some View {
        ScrollView {
            VStack(spacing: 12) {
                if friendService.pendingRequests.isEmpty {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.secondaryBackground)
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(.secondaryText.opacity(0.5))
                        }
                        
                        VStack(spacing: 8) {
                            Text("No Pending Requests")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.primaryText)
                            
                            Text("Friend requests you receive\nwill appear here")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.top, 100)
                } else {
                    ForEach(friendService.pendingRequests) { request in
                        PendingRequestRow(request: request)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 8)
                }
            }
        }
        .refreshable {
            HapticManager.shared.lightImpact()
            Task {
                do {
                    try await friendService.loadPendingRequests()
                    toast = ToastMessage(message: "Requests refreshed", type: .success)
                } catch {
                    toast = ToastMessage(message: "Failed to refresh", type: .error)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func performSearch(query: String) async {
        // Check if task was cancelled
        guard !Task.isCancelled else { return }
        
        guard !query.isEmpty, query.count >= 2 else {
            await MainActor.run {
                searchResults = []
                isSearching = false
            }
            return
        }
        
        await MainActor.run {
            isSearching = true
        }
        
        do {
            let results = try await friendService.searchUsers(by: query)
            
            // Check again if task was cancelled before updating UI
            guard !Task.isCancelled else { return }
            
            // Filter out current user
            let currentUserId = authManager.userProfile?.userId
            await MainActor.run {
                searchResults = results.filter { $0.userId != currentUserId }
                isSearching = false
            }
        } catch {
            // Only update UI if not cancelled
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                errorMessage = "Failed to search users: \(error.localizedDescription)"
                showError = true
                searchResults = []
                isSearching = false
            }
        }
    }
    
    private func sendFriendRequest(to userId: String) async {
        do {
            try await friendService.sendFriendRequest(to: userId)
            HapticManager.shared.success()
            toast = ToastMessage(message: "Friend request sent", type: .success)
            // Refresh search to update button state
            if !searchText.isEmpty {
                await performSearch(query: searchText)
            }
        } catch {
            HapticManager.shared.error()
            errorMessage = "Failed to send friend request: \(error.localizedDescription)"
            showError = true
        }
    }
}

// MARK: - User Search Result Row

struct UserSearchResultRow: View {
    @StateObject private var friendService = FriendService.shared
    let profile: UserProfile
    let onSendRequest: () -> Void
    let onBlock: () -> Void
    @State private var requestStatus: String = "" // "pending", "sent", "friend", ""
    @State private var isSending: Bool = false
    @State private var showMenu = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.cardBackground)
                    .shadow(color: Color.shadowColor, radius: 4, x: 0, y: 2)
                
                AvatarView(
                    avatarType: profile.avatarType,
                    avatarColor: profile.avatarColor,
                    size: 56
                )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(profile.username)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("@\(profile.username.lowercased())")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 8)
            
            // Action buttons
            HStack(spacing: 8) {
                // Menu button (block option)
                Menu {
                    Button(role: .destructive, action: {
                        HapticManager.shared.lightImpact()
                        onBlock()
                    }) {
                        Label("Block User", systemImage: "hand.raised.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(Color.secondaryBackground)
                        .cornerRadius(8)
                }
                
                // Add/Send button
                Button(action: {
                    guard !isSending && requestStatus != "friend" && requestStatus != "sent" else { return }
                    HapticManager.shared.lightImpact()
                    isSending = true
                    onSendRequest()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isSending = false
                    }
                }) {
                if isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(buttonText)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 90, height: 36)
            .background(buttonColor)
            .cornerRadius(10)
            .disabled(requestStatus == "friend" || requestStatus == "sent" || isSending)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 3)
        .onAppear {
            checkRequestStatus()
        }
    }
    
    private var buttonText: String {
        switch requestStatus {
        case "friend":
            return "Friends"
        case "sent":
            return "Sent"
        case "pending":
            return "Accept"
        default:
            return "Add"
        }
    }
    
    private var buttonColor: Color {
        switch requestStatus {
        case "friend":
            return Color.gray.opacity(0.4)
        case "sent":
            return Color.gray.opacity(0.4)
        case "pending":
            return Color.green
        default:
            return Color.primaryAccent
        }
    }
    
    private func checkRequestStatus() {
        // Check if already friends
        if friendService.friends.contains(where: { $0.userId == profile.userId }) {
            requestStatus = "friend"
            return
        }
        
        // Check if request already sent
        if friendService.sentRequests.contains(where: { $0.toUserId == profile.userId }) {
            requestStatus = "sent"
            return
        }
        
        // Check if pending request received from this user
        if friendService.pendingRequests.contains(where: { $0.fromUserId == profile.userId }) {
            requestStatus = "pending"
            return
        }
        
        requestStatus = ""
    }
}

// MARK: - Pending Request Row

struct PendingRequestRow: View {
    @StateObject private var friendService = FriendService.shared
    let request: FriendRequest
    @State private var profile: UserProfile? = nil
    @State private var isLoading = true
    @State private var isProcessing = false
    @State private var toast: ToastMessage? = nil
    
    var body: some View {
        Group {
            if let profile = profile {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.cardBackground)
                                .shadow(color: Color.shadowColor, radius: 3, x: 0, y: 1)
                            
                            AvatarView(
                                avatarType: profile.avatarType,
                                avatarColor: profile.avatarColor,
                                size: 48
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.username)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                                .lineLimit(1)
                            
                            Text("Wants to be friends")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack(spacing: 8) {
                        Spacer(minLength: 0)
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            Task {
                                await rejectRequest()
                            }
                        }) {
                            Text("Decline")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .frame(width: 88, height: 36)
                                .background(Color.secondaryBackground)
                                .cornerRadius(10)
                        }
                        .disabled(isProcessing)
                        
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            Task {
                                await acceptRequest()
                            }
                        }) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Accept")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 88, height: 36)
                        .background(Color.primaryAccent)
                        .cornerRadius(10)
                        .disabled(isProcessing)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.9)
                    Spacer()
                }
                .padding(.vertical, 12)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .shadow(color: Color.shadowColor, radius: 4, x: 0, y: 2)
        .task {
            await loadProfile()
        }
    }
    
    private func loadProfile() async {
        do {
            profile = try await friendService.getUserProfile(userId: request.fromUserId)
            isLoading = false
        } catch {
            isLoading = false
        }
    }
    
    private func acceptRequest() async {
        guard let requestId = request.id else { return }
        isProcessing = true
        do {
            try await friendService.acceptFriendRequest(requestId)
            HapticManager.shared.success()
        } catch {
            HapticManager.shared.error()
        }
        isProcessing = false
    }
    
    private func rejectRequest() async {
        guard let requestId = request.id else { return }
        isProcessing = true
        do {
            try await friendService.rejectFriendRequest(requestId)
            HapticManager.shared.lightImpact()
        } catch {
            HapticManager.shared.error()
        }
        isProcessing = false
    }
}

// MARK: - Sent friend request row (outgoing, pending)

struct SentFriendRequestRow: View {
    @StateObject private var friendService = FriendService.shared
    let request: FriendRequest
    @State private var profile: UserProfile?
    @State private var isLoading = true
    @State private var isCancelling = false
    @State private var showCancelConfirmation = false

    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    var body: some View {
        HStack(spacing: 14) {
            if let profile = profile {
                ZStack {
                    Circle()
                        .fill(Color.cardBackground)
                        .shadow(color: Color.shadowColor, radius: 3, x: 0, y: 1)
                    AvatarView(
                        avatarType: profile.avatarType,
                        avatarColor: profile.avatarColor,
                        size: 48
                    )
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.username)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    Text("Request pending")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    HapticManager.shared.lightImpact()
                    showCancelConfirmation = true
                } label: {
                    if isCancelling {
                        ProgressView()
                            .scaleEffect(0.75)
                            .frame(width: 68, height: 30)
                    } else {
                        Text("Cancel")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .frame(width: 68, height: 30)
                            .background(Color.secondaryBackground)
                            .cornerRadius(8)
                    }
                }
                .disabled(isCancelling)
                .buttonStyle(.plain)
            } else if isLoading {
                ProgressView()
                    .scaleEffect(0.9)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .shadow(color: Color.shadowColor, radius: 4, x: 0, y: 2)
        .confirmationDialog(
            "Cancel request to \(profile?.username ?? "this user")?",
            isPresented: $showCancelConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cancel request", role: .destructive) {
                Task { await cancelRequest() }
            }
            Button("Keep", role: .cancel) {}
        }
        .task {
            await loadProfile()
        }
    }

    private func loadProfile() async {
        do {
            profile = try await friendService.getUserProfile(userId: request.toUserId)
            isLoading = false
        } catch {
            isLoading = false
        }
    }

    private func cancelRequest() async {
        guard let requestId = request.id else { return }
        isCancelling = true
        do {
            try await friendService.cancelFriendRequest(requestId)
            HapticManager.shared.lightImpact()
            // The sentRequests listener/reload will remove the row automatically
        } catch {
            HapticManager.shared.error()
        }
        isCancelling = false
    }
}

#Preview {
    NavigationView {
        AddFriendsView()
    }
}
