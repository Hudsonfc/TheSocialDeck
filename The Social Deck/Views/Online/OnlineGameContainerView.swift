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
            if let room = onlineManager.currentRoom,
               let gameType = room.selectedGameType,
               let myUserId = authManager.userProfile?.userId {
                
                switch gameType {
                case "colorClash":
                    // Color Clash specific walkthrough/loading
                    Group {
            if showWalkthrough && showWalkthroughPreference {
                ColorClashWalkthroughView(showCloseButton: false)
                    .onDisappear {
                        showLoadingScreen = true
                    }
            } else if showLoadingScreen && !hasShownLoading {
                ColorClashLoadingScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                hasShownLoading = true
                                showLoadingScreen = false
                            }
                        }
                    }
                        } else {
                    OnlineColorClashPlayView(roomCode: room.roomCode, myUserId: myUserId)
                        }
                    }
                    .onAppear {
                        if showWalkthroughPreference {
                            showWalkthrough = true
                        } else {
                            showLoadingScreen = true
                        }
                    }
                case "flip21":
                    OnlineFlip21PlayView(roomCode: room.roomCode, myUserId: myUserId)
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
    }
}

