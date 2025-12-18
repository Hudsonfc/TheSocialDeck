//
//  OnlineRoomView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct OnlineRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showLeaveConfirmation = false
    @State private var showError = false
    @State private var showInviteFriends = false
    @State private var showShareSheet = false
    @State private var showKickConfirmation = false
    @State private var playerToKick: RoomPlayer? = nil
    @State private var toast: ToastMessage? = nil
    @State private var isLeavingRoom = false
    
    var body: some View {
        Group {
            if onlineManager.currentRoom == nil {
                // Loading or error state
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        if onlineManager.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            Text("Loading room...")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        } else {
                            // Enhanced empty state
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 50, weight: .light))
                                    .foregroundColor(Color.orange.opacity(0.6))
                            }
                            
                            VStack(spacing: 12) {
                                if let errorMsg = onlineManager.errorMessage, errorMsg.contains("deleted") {
                                    Text("Room Deleted")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                    
                                    Text("This room no longer exists.\nThe host may have deleted it.")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(Color.gray)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(4)
                                } else {
                                    Text("Room Not Found")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                    
                                    Text("Unable to load this room.\nPlease check your connection and try again.")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(Color.gray)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(4)
                                }
                            }
                            
                            Button(action: {
                                HapticManager.shared.lightImpact()
                                dismiss()
                            }) {
                                Text("Go Back")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    .cornerRadius(12)
                            }
                            .padding(.top, 8)
                        }
                    }
                }
            } else {
                roomContentView
            }
        }
        .alert("Leave Room", isPresented: $showLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                leaveRoomWithAnimation()
            }
        } message: {
            if onlineManager.isHost {
                Text("You are the host. Leaving will transfer host to another player. Are you sure you want to leave?")
            } else {
                Text("Are you sure you want to leave this room? You'll need the room code to rejoin.")
            }
        }
        .alert("Kick Player", isPresented: $showKickConfirmation) {
            Button("Cancel", role: .cancel) {
                playerToKick = nil
            }
            Button("Kick", role: .destructive) {
                if let player = playerToKick {
                    Task {
                        await kickPlayer(player.id)
                    }
                }
                playerToKick = nil
            }
        } message: {
            if let player = playerToKick {
                Text("Are you sure you want to remove \(player.username) from the room?")
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let room = onlineManager.currentRoom {
                ShareSheet(activityItems: [
                    "Join my game room '\(room.roomName)' in The Social Deck! Room Code: \(room.roomCode)"
                ])
            }
        }
        .toast($toast)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(onlineManager.errorMessage ?? "An error occurred")
        }
        .onChange(of: onlineManager.errorMessage) { errorMessage in
            if errorMessage != nil {
                showError = true
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showLeaveConfirmation = true
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if let room = onlineManager.currentRoom {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showInviteFriends) {
            if let room = onlineManager.currentRoom {
                InviteFriendsSheet(room: room)
            }
        }
        .onChange(of: onlineManager.currentRoom?.players.count) { count in
            // Animate player list changes
            if count != nil {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    // Trigger animation
                }
            }
        }
        .onChange(of: onlineManager.currentRoom) { newRoom in
            // Handle room deletion
            if newRoom == nil && onlineManager.errorMessage?.contains("deleted") == true {
                // Room was deleted, show appropriate message
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
    
    private var roomContentView: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    roomCodeHeader
                    playerListSection
                    selectedGameSection
                    actionButtonsSection
                }
            }
            .opacity(isLeavingRoom ? 0.3 : 1.0)
            .blur(radius: isLeavingRoom ? 3 : 0)
            
            if isLeavingRoom {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    
                    Text("Leaving room...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLeavingRoom)
    }
    
    private var roomCodeHeader: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Text("Room Code")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.gray)
                
                Text(onlineManager.currentRoom?.roomCode ?? "")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .tracking(6)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 40)
            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
            .cornerRadius(16)
            
            if let room = onlineManager.currentRoom, room.players.count >= room.maxPlayers - 1 && room.players.count < room.maxPlayers {
                playerLimitWarning(room: room)
            }
            
            Button(action: {
                HapticManager.shared.lightImpact()
                showInviteFriends = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Invite Friends")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .cornerRadius(14)
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 20)
    }
    
    private func playerLimitWarning(room: OnlineRoom) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.orange)
            Text("Room is almost full (\(room.players.count)/\(room.maxPlayers))")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 40)
    }
                    
    private var playerListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            let playerCount = onlineManager.currentRoom?.currentPlayerCount ?? 0
            let maxPlayers = onlineManager.currentRoom?.maxPlayers ?? 4
            Text("Players (\(playerCount)/\(maxPlayers))")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            
            if let players = onlineManager.currentRoom?.players {
                ForEach(players) { player in
                    playerRowView(for: player)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 40)
    }
    
    private func playerRowView(for player: RoomPlayer) -> some View {
        PlayerRowView(
            player: player,
            canKick: onlineManager.isHost && player.id != authManager.userProfile?.userId,
            onKick: {
                playerToKick = player
                showKickConfirmation = true
            }
        )
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
                    
    @ViewBuilder
    private var selectedGameSection: some View {
        Group {
            if let room = onlineManager.currentRoom,
               let gameTypeString = room.selectedGameType,
               let gameType = DeckType(stringValue: gameTypeString) {
                SelectedGameDisplayCard(
                    gameType: gameType,
                    category: room.selectedCategory
                )
                .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
            } else {
                noGameSelectedView
            }
        }
    }
    
    private var noGameSelectedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Game")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                
                Text("No game selected")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color.gray)
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 40)
    }
    
    @ViewBuilder
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            if shouldShowStartGameButton {
                startGameButton
            }
            
            if onlineManager.currentRoom?.status == .waiting {
                readyButton
            }
            
            leaveRoomButton
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 30)
    }
    
    private var shouldShowStartGameButton: Bool {
        guard onlineManager.isHost,
              onlineManager.currentRoom?.status == .waiting,
              onlineManager.currentRoom?.allPlayersReady == true,
              let room = onlineManager.currentRoom else {
            return false
        }
        return room.currentPlayerCount >= 2
    }
    
    private var startGameButton: some View {
        Button(action: {
            Task {
                await onlineManager.startGame()
            }
        }) {
            if onlineManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(16)
            } else {
                Text("Start Game")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(16)
            }
        }
        .disabled(onlineManager.isLoading)
    }
    
    private var readyButton: some View {
        Button(action: {
            Task {
                await onlineManager.toggleReadyStatus()
            }
        }) {
            if onlineManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: 2)
                    )
                    .cornerRadius(16)
            } else {
                let isReady = onlineManager.isCurrentPlayerReady
                Text(isReady ? "Not Ready" : "Ready")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(isReady ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: 2)
                    )
                    .cornerRadius(16)
            }
        }
        .disabled(onlineManager.isLoading)
    }
    
    private var leaveRoomButton: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            showLeaveConfirmation = true
        }) {
            Text("Leave Room")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .cornerRadius(16)
        }
    }
    
    private func kickPlayer(_ playerId: String) async {
        do {
            try await onlineManager.kickPlayer(playerId)
            HapticManager.shared.success()
            toast = ToastMessage(message: "Player removed", type: .success)
        } catch {
            HapticManager.shared.error()
            toast = ToastMessage(message: "Failed to remove player", type: .error)
        }
    }
    
    private func leaveRoomWithAnimation() {
        HapticManager.shared.mediumImpact()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isLeavingRoom = true
        }
        
        Task {
            await onlineManager.leaveRoom()
            
            // Small delay for smooth transition
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Player Row View
struct PlayerRowView: View {
    let player: RoomPlayer
    var canKick: Bool = false
    var onKick: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            AvatarView(
                avatarType: player.avatarType,
                avatarColor: player.avatarColor,
                size: 50
            )
            
            // Username and status
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(player.username)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    if player.isHost {
                        Text("Host")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(8)
                    }
                }
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(player.isReady ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(player.isReady ? "Ready" : "Not Ready")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(player.isReady ? Color.green : Color.gray)
                }
            }
            
            Spacer()
            
            // Kick button (host only, can't kick self)
            if canKick, let onKick = onKick {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    onKick()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        OnlineRoomView()
    }
}
