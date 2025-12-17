//
//  FriendsListView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct FriendsListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var friendService = FriendService.shared
    @StateObject private var onlineManager = OnlineManager.shared
    @State private var showError = false
    @State private var selectedFriend: FriendProfile? = nil
    @State private var showInviteSheet = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if friendService.isLoading {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    
                    Text("Loading friends...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.gray)
                }
            } else if friendService.friends.isEmpty {
                // No friends - enhanced empty state
                VStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.4))
                    }
                    
                    VStack(spacing: 12) {
                        Text("No Friends Yet")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("Search for friends by username\nto add them and start playing together")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, 40)
            } else {
                // Friends list with header
                VStack(spacing: 0) {
                    // Header with count
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Friends")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Text("\(friendService.friends.count) friend\(friendService.friends.count == 1 ? "" : "s")")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(friendService.friends) { friend in
                                FriendRowView(
                                    friend: friend,
                                    onInvite: {
                                        selectedFriend = friend
                                        showInviteSheet = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    }
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
                    try await friendService.loadFriends()
                    friendService.startListeningToFriends()
                } catch {
                    showError = true
                }
            }
        }
        .onDisappear {
            friendService.stopListeningToFriends()
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
    }
}

// MARK: - Friend Row View

struct FriendRowView: View {
    let friend: FriendProfile
    let onInvite: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar with shadow
            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                
                AvatarView(
                    avatarType: friend.avatarType,
                    avatarColor: friend.avatarColor,
                    size: 56
                )
            }
            
            // Friend info
            VStack(alignment: .leading, spacing: 6) {
                Text(friend.username)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.green)
                    
                    Text("Friend")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color.green)
                }
            }
            
            Spacer()
            
            // Invite button (only if in a room)
            if OnlineManager.shared.currentRoom != nil {
                Button(action: onInvite) {
                    HStack(spacing: 6) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Invite")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Invite Friend View

struct InviteFriendView: View {
    @Environment(\.dismiss) private var dismiss
    let friend: FriendProfile
    let room: OnlineRoom
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 20)
                
                // Friend info with enhanced styling
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
                
                // Room code with better styling
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
                
                // Share button
                Button(action: {
                    showShareSheet = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Share Room Code")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(14)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationTitle("Invite Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
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
