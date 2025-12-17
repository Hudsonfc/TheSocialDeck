//
//  InviteFriendsSheet.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct InviteFriendsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var friendService = FriendService.shared
    @StateObject private var onlineManager = OnlineManager.shared
    let room: OnlineRoom
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var invitedFriendIds: Set<String> = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                if friendService.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        Text("Loading friends...")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                } else if friendService.friends.isEmpty {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(Color.gray.opacity(0.5))
                        }
                        
                        VStack(spacing: 8) {
                            Text("No Friends Yet")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Text("Add friends to invite them to rooms")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 100)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(friendService.friends) { friend in
                                InviteFriendRow(
                                    friend: friend,
                                    room: room,
                                    isInvited: invitedFriendIds.contains(friend.userId),
                                    onInvite: {
                                        Task {
                                            await inviteFriend(friend.userId)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Invite Friends")
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
            .onAppear {
                Task {
                    do {
                        try await friendService.loadFriends()
                    } catch {
                        errorMessage = "Failed to load friends"
                        showError = true
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func inviteFriend(_ userId: String) async {
        do {
            try await onlineManager.sendRoomInvite(toUserId: userId)
            await MainActor.run {
                invitedFriendIds.insert(userId)
            }
        } catch {
            errorMessage = "Failed to send invite: \(error.localizedDescription)"
            showError = true
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
        HStack(spacing: 16) {
            // Avatar
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
                
                Text(isInvited ? "Invite sent" : "Tap to invite")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(isInvited ? Color.green : Color.gray)
            }
            
            Spacer()
            
            // Invite button
            Button(action: {
                guard !isInvited && !isSending else { return }
                isSending = true
                onInvite()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSending = false
                }
            }) {
                if isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else if isInvited {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 44, height: 44)
            .background(isInvited ? Color.green : Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
            .cornerRadius(12)
            .disabled(isInvited || isSending)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
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

