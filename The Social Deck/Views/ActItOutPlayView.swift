//
//  ActItOutPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 12/31/24.
//

import SwiftUI

struct ActItOutPlayView: View {
    @ObservedObject var manager: ActItOutGameManager
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var cardRotation: Double = 0
    @State private var showEndView: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showHomeAlert: Bool = false
    @State private var cardOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var actionButtonsOpacity: Double = 0
    @State private var actionButtonsOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, home button, and progress
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
                    
                    // Back button
                    if manager.canGoBack {
                        Button(action: {
                            previousCard()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Previous")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.primaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(20)
                        }
                        .padding(.leading, 12)
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    Text("\(manager.currentCardIndex + 1) / \(manager.cards.count)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Current player indicator
                if manager.isFlipped {
                    Text("\(manager.currentPlayer)'s Turn")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.buttonBackground)
                        .padding(.bottom, 8)
                }
                
                // Timer (if enabled and card is flipped)
                if manager.timerEnabled && manager.isFlipped {
                    Text("\(manager.timeRemaining)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(manager.timeRemaining <= 10 ? Color.buttonBackground : .primaryText)
                        .padding(.bottom, 8)
                }
                
                Spacer()
                
                // "Act It Out" label
                Text("Act It Out")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.buttonBackground)
                    .padding(.bottom, 24)
                
                // Card
                if let currentCard = manager.currentCard() {
                    ZStack {
                        // Card front - visible when rotation < 90
                        ActItOutCardFrontView()
                            .opacity(cardRotation < 90 ? 1 : 0)
                        
                        // Card back - visible when rotation >= 90, pre-rotated 180
                        ActItOutCardBackView(text: currentCard.text)
                            .opacity(cardRotation >= 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                    .frame(width: 320, height: 480)
                    .rotation3DEffect(
                        .degrees(cardRotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .offset(x: cardOffset)
                    .id(currentCard.id)
                    .onTapGesture {
                        if !isTransitioning && !manager.isFlipped {
                            toggleCard()
                        }
                    }
                    .padding(.bottom, 24)
                }
                
                Spacer()
                
                // Action buttons (shown when card is flipped)
                if manager.isFlipped {
                    HStack(spacing: 12) {
                        // Skip button
                        if manager.skipsRemaining > 0 {
                            Button(action: {
                                HapticManager.shared.lightImpact()
                                skipCard()
                            }) {
                                Text("Skip (\(manager.skipsRemaining))")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.buttonBackground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.appBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.buttonBackground, lineWidth: 2)
                                    )
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Next button
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            if manager.currentCardIndex >= manager.cards.count - 1 {
                                showEndView = true
                            } else {
                                nextCard()
                            }
                        }) {
                            Text(manager.currentCardIndex >= manager.cards.count - 1 ? "Finish" : "Next")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.buttonBackground)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .opacity(actionButtonsOpacity)
                    .offset(y: actionButtonsOffset)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: manager.isFlipped)
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
                    destination: ActItOutEndView(deck: deck, selectedCategories: selectedCategories, roundsPlayed: manager.cards.count),
                    isActive: $showEndView
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
        .onChange(of: manager.isFlipped) { oldValue, newValue in
            if newValue {
                // Show action buttons when card is flipped
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    actionButtonsOpacity = 1.0
                    actionButtonsOffset = 0
                }
            } else {
                // Hide action buttons
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    actionButtonsOpacity = 0
                    actionButtonsOffset = 20
                }
            }
        }
        .onAppear {
            // Initialize button state
            if manager.isFlipped {
                actionButtonsOpacity = 1.0
                actionButtonsOffset = 0
            }
        }
    }
    
    private func toggleCard() {
        if manager.isFlipped {
            // Flip back to front
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
            }
        } else {
            // Flip to back
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
            }
        }
    }
    
    private func skipCard() {
        isTransitioning = true
        
        // Reset rotation and hide buttons
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            cardRotation = 0
            actionButtonsOpacity = 0
        }
        
        // Slide current card left out of screen
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = -500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            manager.skipCard()
            
            // Position new card off screen to the right
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                cardOffset = 500
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                // Slide new card in from right
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    cardOffset = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTransitioning = false
                }
            }
        }
    }
    
    private func previousCard() {
        isTransitioning = true
        
        // Reset rotation and hide buttons
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            cardRotation = 0
            actionButtonsOpacity = 0
        }
        
        // Slide current card right out of screen
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = 500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // Reset flip state before going back
            if manager.isFlipped {
                manager.flipCard()
            }
            
            // Position new card off screen to the left
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                cardOffset = -500
            }
            
            manager.previousCard()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                // Slide previous card in from left
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    cardOffset = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTransitioning = false
                }
            }
        }
    }
    
    private func nextCard() {
        isTransitioning = true
        
        // Fade out button and reset rotation
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            actionButtonsOpacity = 0
            actionButtonsOffset = 20
            cardRotation = 0
        }
        
        // Slide current card left out of screen
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = -500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // Reset flip state before moving to next card
            if manager.isFlipped {
                manager.flipCard()
            }
            
            // Position new card off screen to the right
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                cardOffset = 500
            }
            
            manager.nextCard()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                // Slide new card in from right
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    cardOffset = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTransitioning = false
                }
            }
        }
    }
}

// MARK: - Card Views

struct ActItOutCardFrontView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0xB0/255.0, green: 0xE9/255.0, blue: 0x8D/255.0))
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack {
                Image(systemName: "theatermasks.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                Text("Tap to reveal")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
            }
        }
    }
}

struct ActItOutCardBackView: View {
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0xB0/255.0, green: 0xE9/255.0, blue: 0x8D/255.0))
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Text("Act It Out")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(text)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("Act this out!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                    .padding(.top, 16)
            }
        }
    }
}

#Preview {
    NavigationView {
        ActItOutPlayView(
            manager: ActItOutGameManager(
                deck: Deck(
                    title: "Act It Out",
                    description: "Test",
                    numberOfCards: 3,
                    estimatedTime: "5-10 min",
                    imageName: "AIO 2.0",
                    type: .actItOut,
                    cards: [
                        Card(text: "Brushing teeth", category: "Actions & Verbs", cardType: nil),
                        Card(text: "Elephant", category: "Animals", cardType: nil),
                        Card(text: "Being surprised", category: "Emotions & Expressions", cardType: nil)
                    ],
                    availableCategories: ["Actions & Verbs", "Animals"]
                ),
                selectedCategories: ["Actions & Verbs", "Animals"],
                players: ["Player 1", "Player 2"],
                cardCount: 3,
                timerEnabled: true,
                timerDuration: 60
            ),
            deck: Deck(
                title: "Act It Out",
                description: "Test",
                numberOfCards: 3,
                estimatedTime: "5-10 min",
                imageName: "AIO 2.0",
                type: .actItOut,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Actions & Verbs", "Animals"]
        )
    }
}

