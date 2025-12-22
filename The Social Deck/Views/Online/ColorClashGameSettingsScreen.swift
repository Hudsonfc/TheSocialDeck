//
//  ColorClashGameSettingsScreen.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ColorClashGameSettingsScreen: View {
    let game: OnlineGamePlaceholder
    @StateObject private var onlineManager = OnlineManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var maxPlayers: Int
    @State private var showError = false
    @State private var navigateToRoom = false
    @State private var turnTimerSeconds: Int = 60
    @State private var autoPlayEnabled: Bool = true
    
    init(game: OnlineGamePlaceholder) {
        self.game = game
        let defaultPlayers = max(game.minPlayers, min(game.maxPlayers, (game.minPlayers + game.maxPlayers) / 2))
        _maxPlayers = State(initialValue: defaultPlayers)
    }
    
    private var playerCountOptions: [Int] {
        Array(game.minPlayers...game.maxPlayers)
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0xFA/255.0, green: 0xFA/255.0, blue: 0xFA/255.0),
                    Color.white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Game artwork
                    Image(game.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipped()
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.top, 20)
                    
                    // Game title
                    Text(game.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    
                    // Player Count Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Max Players")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        HStack(spacing: 12) {
                            ForEach(playerCountOptions, id: \.self) { count in
                                Button(action: {
                                    HapticManager.shared.lightImpact()
                                    maxPlayers = count
                                }) {
                                    Text("\(count)")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(maxPlayers == count ? .white : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                        .frame(width: 60, height: 44)
                                        .background(maxPlayers == count ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 40)
                    
                    // Game Settings Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Game Settings")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        // Turn Timer Setting
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "timer")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                
                                Text("Turn Timer")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            }
                            
                            Text("Time limit for each player's turn")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                            
                            HStack(spacing: 12) {
                                ForEach([30, 60, 90, 120], id: \.self) { seconds in
                                    Button(action: {
                                        HapticManager.shared.lightImpact()
                                        turnTimerSeconds = seconds
                                        // Store timer preference (can be added to room later)
                                    }) {
                                        Text("\(seconds)s")
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(turnTimerSeconds == seconds ? .white : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                            .frame(width: 60, height: 36)
                                            .background(turnTimerSeconds == seconds ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Auto-play Setting
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    
                                    Text("Auto-play on Timeout")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                }
                                
                                Text("Automatically draw a card when timer expires")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(Color.gray)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $autoPlayEnabled)
                                .labelsHidden()
                                .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 40)
                    
                    // Create Room button
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            Task {
                                await onlineManager.createRoom(
                                    roomName: game.title,
                                    maxPlayers: maxPlayers,
                                    isPrivate: false,
                                    gameType: game.gameType
                                )
                                
                                if onlineManager.currentRoom != nil {
                                    navigateToRoom = true
                                } else if onlineManager.errorMessage != nil {
                                    showError = true
                                }
                            }
                        }) {
                            Text(onlineManager.isLoading ? "Creating Room..." : "Create Room")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .cornerRadius(16)
                        }
                        .disabled(onlineManager.isLoading)
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            
            // Navigation link to room
            NavigationLink(
                destination: OnlineRoomView(),
                isActive: $navigateToRoom
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(onlineManager.errorMessage ?? "Failed to create room")
        }
    }
}

#Preview {
    NavigationView {
        ColorClashGameSettingsScreen(
            game: OnlineGamePlaceholder(
                title: "Color Clash",
                description: "A fast-paced card game",
                imageName: "color clash artwork logo",
                hasCategories: false,
                availableCategories: [],
                gameType: "colorClash",
                minPlayers: 2,
                maxPlayers: 6
            )
        )
    }
}

