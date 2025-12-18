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
    @State private var navigateToRoom = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if onlineManager.isLoading && onlineManager.pendingRoomInvites.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.3)
                        .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    Text("Loading invites...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.gray)
                }
            } else if onlineManager.pendingRoomInvites.isEmpty {
                // No invites
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                    
                    VStack(spacing: 8) {
                        Text("No Room Invites")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("Room invites from friends\nwill appear here")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
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
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: onlineManager.pendingRoomInvites.count)
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
        .background(
            NavigationLink(
                destination: OnlineRoomView(),
                isActive: $navigateToRoom
            ) {
                EmptyView()
            }
        )
        .onAppear {
            Task {
                await onlineManager.loadPendingRoomInvites()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: onlineManager.currentRoom) { room in
            if room != nil {
                navigateToRoom = true
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
            // Inviter info
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
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("Room: \(invite.roomName)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                        
                        // Expiration countdown
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
            
            // Room code
            VStack(spacing: 8) {
                Text("Room Code")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.gray)
                
                Text(invite.roomCode)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .tracking(4)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
            .cornerRadius(16)
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    Task {
                        await declineInvite()
                    }
                }) {
                    Text("Decline")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
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
                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .cornerRadius(12)
                .disabled(isProcessing)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
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
            HapticManager.shared.error()
            return
        }
        isProcessing = true
        HapticManager.shared.success()
        await onlineManager.acceptRoomInvite(inviteId)
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

