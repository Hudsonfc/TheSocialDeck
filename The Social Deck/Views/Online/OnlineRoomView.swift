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
    @State private var showLeaveConfirmation = false
    @State private var showError = false
    @State private var showInviteFriends = false
    
    var body: some View {
        Group {
            if onlineManager.currentRoom == nil {
                // Loading or error state
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        if onlineManager.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            Text("Loading room...")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        } else {
                            Text("Room not found")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.gray)
                            
                            Button("Go Back") {
                                dismiss()
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
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
                Task {
                    await onlineManager.leaveRoom()
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to leave this room?")
        }
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
    }
    
    private var roomContentView: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Room Code Header with Invite Button
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Room Code")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color.gray)
                            
                            Text(onlineManager.currentRoom?.roomCode ?? "")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .tracking(4)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 40)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .cornerRadius(16)
                        
                        // Invite Friends Button
                        Button(action: {
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
                    
                    // Player List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Players (\(onlineManager.currentRoom?.currentPlayerCount ?? 0)/\(onlineManager.currentRoom?.maxPlayers ?? 4))")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        if let players = onlineManager.currentRoom?.players {
                            ForEach(players) { player in
                                PlayerRowView(player: player)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 40)
                    
                    // Show selected game to all players
                    if let room = onlineManager.currentRoom,
                       let gameTypeString = room.selectedGameType,
                       let gameType = DeckType(stringValue: gameTypeString) {
                        SelectedGameDisplayCard(
                            gameType: gameType,
                            category: room.selectedCategory
                        )
                        .padding(.horizontal, 40)
                    } else {
                        // Show placeholder message when no game is selected
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
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Start Game Button (Host only, when all ready)
                        if onlineManager.isHost &&
                           onlineManager.currentRoom?.status == .waiting &&
                           onlineManager.currentRoom?.allPlayersReady == true &&
                           (onlineManager.currentRoom?.currentPlayerCount ?? 0) >= 2 {
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
                        
                        // Ready Button (All players)
                        if onlineManager.currentRoom?.status == .waiting {
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
                                    Text(onlineManager.isCurrentPlayerReady ? "Not Ready" : "Ready")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 55)
                                        .background(onlineManager.isCurrentPlayerReady ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1) : Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: 2)
                                        )
                                        .cornerRadius(16)
                                }
                            }
                            .disabled(onlineManager.isLoading)
                        }
                        
                        // Leave Room Button
                        Button(action: {
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
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
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
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showInviteFriends) {
            if let room = onlineManager.currentRoom {
                InviteFriendsSheet(room: room)
            }
        }
        .onDisappear {
            // Cleanup if navigating away (but don't leave room automatically)
            // User must explicitly leave via button
        }
    }
}

// MARK: - Player Row View
struct PlayerRowView: View {
    let player: RoomPlayer
    
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
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        OnlineRoomView()
    }
}
