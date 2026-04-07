//
//  RoomInvitesView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct RoomInvitesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showLobbyFullScreen = false
    /// When `true`, hides the nav back button (used inside Friends hub tab).
    /// Navigation after invite accept is handled by the parent (FriendsListView).
    var embeddedInFriendsHub: Bool = false

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            if onlineManager.isLoading && onlineManager.pendingRoomInvites.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.3)
                        .tint(Color.primaryAccent)
                    Text("Loading invites...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
            } else if onlineManager.pendingRoomInvites.isEmpty {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.secondaryBackground)
                            .frame(width: 120, height: 120)

                        Image(systemName: "envelope.fill")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(.secondaryText.opacity(0.5))
                    }

                    VStack(spacing: 8) {
                        Text("No Room Invites")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)

                        Text("Room invites from friends\nwill appear here")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(onlineManager.pendingRoomInvites) { invite in
                            RoomInviteCard(invite: invite)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                    .padding(.horizontal, embeddedInFriendsHub ? 20 : 40)
                    .padding(.vertical, 20)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: onlineManager.roomInviteCountForBadge)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !embeddedInFriendsHub {
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
        }
        .navigationBarBackButtonHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: onlineManager.currentRoom) { room in
            print("[RoomInvitesView] onChange currentRoom — room: \(room?.roomCode ?? "nil"), embedded: \(embeddedInFriendsHub), showLobby: \(showLobbyFullScreen)")
            if room != nil && !embeddedInFriendsHub && !showLobbyFullScreen {
                print("[RoomInvitesView] Presenting lobby fullScreenCover (standalone mode)")
                showLobbyFullScreen = true
            }
        }
        .fullScreenCover(isPresented: $showLobbyFullScreen) {
            NavigationStack {
                LobbyView()
            }
        }
    }
}

// MARK: - Room Invite Card

struct RoomInviteCard: View {
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    let invite: RoomInvite
    @State private var inviterProfile: UserProfile? = nil
    @State private var isLoadingProfile = true
    @State private var isProcessing = false
    @StateObject private var countdownTimer: CountdownTimer
    
    init(invite: RoomInvite) {
        self.invite = invite
        _countdownTimer = StateObject(wrappedValue: CountdownTimer(targetDate: invite.expiresAt))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let profile = inviterProfile {
                VStack(spacing: 16) {
                    AvatarView(
                        avatarType: profile.avatarType,
                        avatarColor: profile.avatarColor,
                        size: 70
                    )
                    
                    VStack(spacing: 6) {
                        Text("\(profile.username) invited you")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                        
                        Text("Room: \(invite.roomName)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                        
                        if !countdownTimer.isExpired {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.orange)
                                Text("Expires in \(countdownTimer.formattedTime)")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.orange)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.top, 4)
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.red)
                                Text("Expired")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.red)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.top, 4)
                        }
                    }
                }
            } else if isLoadingProfile {
                ProgressView()
                    .scaleEffect(0.9)
            }
            
            VStack(spacing: 8) {
                Text("Room Code")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                
                Text(invite.roomCode)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.primaryText)
                    .tracking(4)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(Color.tertiaryBackground)
            .cornerRadius(16)
            
            HStack(spacing: 12) {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    Task {
                        await declineInvite()
                    }
                }) {
                    Text("Decline")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.secondaryBackground)
                        .cornerRadius(12)
                }
                .disabled(isProcessing)
                
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    Task {
                        await acceptInvite()
                    }
                }) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Text("Accept")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.primaryAccent)
                .cornerRadius(12)
                .disabled(isProcessing)
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.shadowColor, radius: 12, x: 0, y: 4)
        .task {
            await loadInviterProfile()
            countdownTimer.start()
        }
        .onDisappear {
            countdownTimer.stop()
        }
    }
    
    private func loadInviterProfile() async {
        do {
            let profile = try await FriendService.shared.getUserProfile(userId: invite.fromUserId)
            await MainActor.run {
                inviterProfile = profile
                isLoadingProfile = false
            }
        } catch {
            await MainActor.run {
                isLoadingProfile = false
            }
        }
    }
    
    private func acceptInvite() async {
        guard let inviteId = invite.id, !countdownTimer.isExpired else {
            print("[RoomInviteCard] acceptInvite guard failed — id: \(invite.id ?? "nil"), expired: \(countdownTimer.isExpired)")
            HapticManager.shared.error()
            return
        }
        print("[RoomInviteCard] acceptInvite starting — inviteId: \(inviteId), roomCode: \(invite.roomCode)")
        isProcessing = true
        HapticManager.shared.success()
        await onlineManager.acceptRoomInvite(inviteId)
        print("[RoomInviteCard] acceptInvite completed — currentRoom: \(onlineManager.currentRoom?.roomCode ?? "nil"), error: \(onlineManager.errorMessage ?? "none")")
        isProcessing = false
    }
    
    private func declineInvite() async {
        guard let inviteId = invite.id else { return }
        isProcessing = true
        await onlineManager.declineRoomInvite(inviteId)
        isProcessing = false
    }
}

#Preview {
    NavigationView {
        RoomInvitesView()
    }
}

