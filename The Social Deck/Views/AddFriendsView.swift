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
            Color.white
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
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
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
            // Enhanced Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
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
            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0xE5/255.0, green: 0xE5/255.0, blue: 0xE5/255.0), lineWidth: 1)
            )
            .padding(.horizontal, 40)
            .padding(.bottom, 24)
            
            if isSearching {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.3)
                        .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    Text("Searching...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.gray)
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
                    .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("Find Friends")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text("Enter at least 2 characters to search\nfor friends to add")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }
    
    private var noResultsState: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.slash.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            
            VStack(spacing: 12) {
                Text("No Users Found")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text("Try searching with a different username")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                
                Text("Make sure you're typing at least 2 characters")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color.gray.opacity(0.7))
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
                                .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(Color.gray.opacity(0.5))
                        }
                        
                        VStack(spacing: 8) {
                            Text("No Pending Requests")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Text("Friend requests you receive\nwill appear here")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
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
            // Avatar with shadow
            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                
                AvatarView(
                    avatarType: profile.avatarType,
                    avatarColor: profile.avatarColor,
                    size: 56
                )
            }
            
            // User info
            VStack(alignment: .leading, spacing: 6) {
                Text(profile.username)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text("@\(profile.username.lowercased())")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
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
                        .foregroundColor(Color.gray)
                        .frame(width: 32, height: 32)
                        .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
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
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
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
            return Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
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
        HStack(spacing: 16) {
            if let profile = profile {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    
                    AvatarView(
                        avatarType: profile.avatarType,
                        avatarColor: profile.avatarColor,
                        size: 56
                    )
                }
                
                // User info
                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.username)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Text("Wants to be friends")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 10) {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        Task {
                            await rejectRequest()
                        }
                    }) {
                        Text("Decline")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.gray)
                            .frame(width: 75, height: 36)
                            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
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
                    .frame(width: 75, height: 36)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(10)
                    .disabled(isProcessing)
                }
            } else if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.9)
                        Spacer()
                }
                .padding(.vertical, 16)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
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

#Preview {
    NavigationView {
        AddFriendsView()
    }
}
