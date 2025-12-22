//
//  OnlineGameContainerView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct OnlineGameContainerView: View {
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showWalkthrough = false
    @State private var showLoadingScreen = false
    @State private var hasShownLoading = false
    @AppStorage("colorClashShowWalkthrough") private var showWalkthroughPreference = false
    
    var body: some View {
        Group {
            if showWalkthrough && showWalkthroughPreference {
                ColorClashWalkthroughView(showCloseButton: false)
                    .onDisappear {
                        // After walkthrough is dismissed, show loading screen
                        showLoadingScreen = true
                    }
            } else if showLoadingScreen && !hasShownLoading {
                ColorClashLoadingScreen()
                    .onAppear {
                        // Show loading screen for 3 seconds, then proceed to game
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                hasShownLoading = true
                                showLoadingScreen = false
                            }
                        }
                    }
            } else if let room = onlineManager.currentRoom,
               let gameType = room.selectedGameType,
               let myUserId = authManager.userProfile?.userId {
                
                switch gameType {
                case "colorClash":
                    OnlineColorClashPlayView(roomCode: room.roomCode, myUserId: myUserId)
                default:
                    // Placeholder for other games
                    VStack(spacing: 24) {
                        Text("Game: \(gameType)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text("Coming soon...")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            } else {
                // Loading state
                VStack(spacing: 24) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading game...")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            // Show walkthrough first if preference is enabled
            if showWalkthroughPreference {
                showWalkthrough = true
            } else {
                // Skip walkthrough, go straight to loading
                showLoadingScreen = true
            }
        }
    }
}

