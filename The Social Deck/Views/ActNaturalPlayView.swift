//
//  ActNaturalPlayView.swift
//  The Social Deck
//
//  Created by AI Assistant
//

import SwiftUI

struct ActNaturalPlayView: View {
    @ObservedObject var manager: ActNaturalGameManager
    let deck: Deck
    @Environment(\.dismiss) private var dismiss
    @State private var cardRotation: Double = 0
    @State private var showingBack: Bool = false
    @State private var hasFlippedOnce: Bool = false
    @State private var navigateToDiscussion: Bool = false
    @State private var showHomeAlert: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit and home button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    
                    // Home button
                    Button(action: {
                        showHomeAlert = true
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 12)
                    
                    Spacer()
                    
                    // Progress indicator
                    Text("\(manager.currentPlayerIndex + 1) / \(manager.players.count)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Player name indicator
                if let currentPlayer = manager.currentPlayer {
                    VStack(spacing: 8) {
                        Text("Pass the phone to")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        
                        Text(currentPlayer.name)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color.buttonBackground)
                    }
                    .padding(.bottom, 32)
                    
                    // Card
                    ZStack {
                        // Card front - visible when rotation < 90
                        ActNaturalCardFrontView()
                            .opacity(cardRotation < 90 ? 1 : 0)
                        
                        // Card back - visible when rotation >= 90, pre-rotated 180
                        ActNaturalCardBackView(player: currentPlayer, secretWord: manager.secretWord?.word ?? "")
                            .opacity(cardRotation >= 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                    .frame(width: 320, height: 480)
                    .rotation3DEffect(
                        .degrees(cardRotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .onTapGesture {
                        toggleCard()
                    }
                    .padding(.bottom, 32)
                }
                
                Spacer()
                
                // Next button - show once card has been flipped at least once
                if hasFlippedOnce {
                    Button(action: {
                        continueToNext()
                    }) {
                        Text(manager.currentPlayerIndex == manager.players.count - 1 ? "Start Discussion" : "Pass to Next Player")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.buttonBackground)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .opacity(buttonOpacity)
                    .offset(y: buttonOffset)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Go to Home?", isPresented: $showHomeAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Go Home", role: .destructive) {
                navigateToHome = true
            }
        } message: {
            Text("Are you sure you want to go back to the home screen? Your progress will be lost.")
        }
        .background(
            Group {
                NavigationLink(
                    destination: ActNaturalDiscussionView(manager: manager, deck: deck),
                    isActive: $navigateToDiscussion
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: HomeView(),
                    isActive: $navigateToHome
                ) {
                    EmptyView()
                }
            }
        )
    }
    
    private func toggleCard() {
        HapticManager.shared.lightImpact()
        
        if showingBack {
            // Flip back to front
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                showingBack = false
            }
        } else {
            // Flip to back
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                showingBack = true
                if !manager.currentPlayer!.hasViewed {
                    manager.markCurrentPlayerViewed()
                }
                
                // Show button with smooth animation on first flip
                if !hasFlippedOnce {
                    hasFlippedOnce = true
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                        buttonOpacity = 1.0
                        buttonOffset = 0
                    }
                }
            }
        }
    }
    
    private func continueToNext() {
        // Fade out button and reset card
        withAnimation(.easeOut(duration: 0.2)) {
            buttonOpacity = 0
            buttonOffset = 20
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            cardRotation = 0
            showingBack = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            hasFlippedOnce = false
            manager.moveToNextPlayer()
            
            // Check if all players viewed - use smoother transition
            if manager.gamePhase == .discussion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        navigateToDiscussion = true
                    }
                }
            }
        }
    }
}

// MARK: - Card Views

struct ActNaturalCardFrontView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text("Act Natural")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text("Tap to reveal")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
        }
    }
}

struct ActNaturalCardBackView: View {
    let player: ActNaturalPlayer
    let secretWord: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            if player.isUnknown {
                // Unknown player view
                VStack(spacing: 24) {
                    Image(systemName: "eye.trianglebadge.exclamationmark.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.buttonBackground)
                    
                    Text("You are the Unknown")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 12) {
                        Text("You do NOT know the word")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                            .multilineTextAlignment(.center)
                        
                        Text("Listen carefully and try to figure out what it is. Blend in!")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 32)
                }
                .padding(32)
            } else {
                // Regular player with word
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                    
                    Text("The Secret Word")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    
                    Text(secretWord)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Text("Subtly mention this word during discussion")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(32)
            }
        }
    }
}

#Preview {
    NavigationView {
        ActNaturalPlayView(
            manager: ActNaturalGameManager(),
            deck: Deck(
                title: "Act Natural",
                description: "Test",
                numberOfCards: 200,
                estimatedTime: "10-20 min",
                imageName: "AN 2.0",
                type: .actNatural,
                cards: [],
                availableCategories: []
            )
        )
    }
}
