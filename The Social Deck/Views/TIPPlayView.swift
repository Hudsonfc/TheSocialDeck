//
//  TIPPlayView.swift
//  The Social Deck
//
//  Created for Take It Personally game
//

import SwiftUI

struct TIPPlayView: View {
    @ObservedObject var manager: TIPGameManager
    let deck: Deck
    let selectedCategories: [String]
    var roomId: String? = nil
    var isHost: Bool = false
    var players: [RoomPlayer]? = nil
    var currentUserId: String? = nil
    @ObservedObject private var syncService = SyncService.shared
    @Environment(\.dismiss) private var dismiss
    @AppStorage("swipeNavigationEnabled") private var swipeNavigationEnabled = false
    @AppStorage("totalCardsFlipped") private var totalCardsFlipped: Int = 0
    @State private var cardRotation: Double = 0
    @State private var showEndView: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showHomeAlert: Bool = false
    @State private var nextButtonOpacity: Double = 0
    @State private var nextButtonOffset: CGFloat = 20
    @State private var cardOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, back button, and progress
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
                    if manager.canGoBack && (roomId == nil || isHost) {
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
                    Text("\(manager.gamePosition + 1) / \(manager.cards.count)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Online: player avatars + host/you indication
                if let players = players, !players.isEmpty, roomId != nil {
                    OnlinePlayerStripView(players: players, currentUserId: currentUserId)
                        .padding(.bottom, 8)
                }
                
                Spacer()
                
                // "Take It Personally" label
                Text("Take It Personally")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.buttonBackground)
                    .padding(.bottom, 32)
                
                // Card
                ZStack {
                    // Card front - visible when rotation < 90
                    TIPCardFrontView(card: manager.currentCard)
                        .opacity(cardRotation < 90 ? 1 : 0)
                    
                    // Card back - visible when rotation >= 90, pre-rotated 180
                    TIPCardBackView(card: manager.currentCard)
                        .opacity(cardRotation >= 90 ? 1 : 0)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
                .frame(width: ResponsiveSize.cardWidth, height: ResponsiveSize.cardHeight)
                .rotation3DEffect(
                    .degrees(cardRotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .offset(x: cardOffset + dragOffset)
                .id(manager.currentCard.id) // Force SwiftUI to treat each card as unique
                .onTapGesture {
                    if !isTransitioning {
                        toggleCard()
                    }
                }
                .gesture(
                    (swipeNavigationEnabled && (roomId == nil || isHost)) ? DragGesture()
                        .onChanged { value in
                            if !isTransitioning {
                                dragOffset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            if !isTransitioning {
                                let swipeThreshold: CGFloat = 100
                                if value.translation.width > swipeThreshold && manager.canGoBack {
                                    // Swipe right - go to previous
                                    previousCard()
                                } else if value.translation.width < -swipeThreshold && !manager.isFinished && manager.isFlipped {
                                    // Swipe left - go to next (only if card is revealed)
                                    nextCard()
                                }
                                dragOffset = 0
                            }
                        } : nil
                )
                .padding(.bottom, 32)
                
                Spacer()
                
                // Next button or swipe instruction (shown when card is flipped)
                if manager.isFlipped {
                    if roomId != nil && !isHost {
                        Text("Waiting for host to advance…")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                    } else if swipeNavigationEnabled {
                        // Swipe instruction text
                        Text("Swipe right to go to next card or left to go to previous card")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                    } else {
                        // Next button
                        Button(action: {
                            if manager.isFinished {
                                showEndView = true
                            } else {
                                nextCard()
                            }
                        }) {
                            Text(manager.isFinished ? "Finish" : "Next")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.buttonBackground)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                        .opacity(nextButtonOpacity)
                        .offset(y: nextButtonOffset)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                    }
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
                    destination: NHIEEndView(deck: deck, selectedCategories: selectedCategories, cardsPlayed: manager.cards.count),
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
                // Show Next button when card is revealed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        nextButtonOpacity = 1.0
                        nextButtonOffset = 0
                    }
                }
            } else {
                // Hide Next button when card is flipped back
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    nextButtonOpacity = 0
                    nextButtonOffset = 20
                }
            }
        }
        .onChange(of: manager.isFinished) { oldValue, newValue in
            if newValue {
                // Automatically navigate to end view when game is finished
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showEndView = true
                }
            }
        }
        .onAppear {
            if let roomId = roomId {
                SyncService.shared.startListening(roomId: roomId)
            }
            // Initialize button state
            if manager.isFlipped {
                nextButtonOpacity = 1.0
                nextButtonOffset = 0
            }
        }
        .onDisappear {
            if roomId != nil {
                SyncService.shared.stopListening()
            }
        }
        .onChange(of: syncService.remoteCardIndex) { _, newIndex in
            guard roomId != nil, !isHost, newIndex != manager.currentIndex else { return }
            jumpToCard(newIndex)
        }
    }
    
    private func toggleCard() {
        HapticManager.shared.lightImpact()
        
        if manager.isFlipped {
            // Flip back to front
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
            }
        } else {
            // Flip to back to show full content
            totalCardsFlipped += 1
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
            }
        }
    }
    
    private func previousCard() {
        // Online non-hosts can flip/reveal locally, but card progression is host-controlled.
        if roomId != nil && !isHost { return }
        isTransitioning = true
        
        // Reset rotation and hide buttons
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            cardRotation = 0
            nextButtonOpacity = 0
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
            
            // Position new card off screen to the left BEFORE changing the card
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                cardOffset = -500
            }
            
            // Now change the card
            manager.previousCard()

            if let roomId = roomId, isHost {
                Task { try? await SyncService.shared.updateCardIndex(roomId: roomId, index: manager.currentIndex) }
            }
            
            // Small delay to ensure the card view has updated
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
        // Online non-hosts can flip/reveal locally, but card progression is host-controlled.
        if roomId != nil && !isHost { return }
        isTransitioning = true
        
        // Fade out button and reset rotation
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            nextButtonOpacity = 0
            nextButtonOffset = 20
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
            
            // Position new card off screen to the right BEFORE changing the card
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                cardOffset = 500
            }
            
            // Now change the card
            manager.nextCard()

            if let roomId = roomId, isHost {
                let indexToSend = manager.isFinished ? manager.cards.count : manager.currentIndex
                Task { try? await SyncService.shared.updateCardIndex(roomId: roomId, index: indexToSend) }
            }
            
            // Small delay to ensure the card view has updated
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

    // Animates directly to a target index (used for online non-host sync).
    private func jumpToCard(_ targetIndex: Int) {
        guard !isTransitioning else { return }
        let isForward = targetIndex >= manager.currentIndex
        isTransitioning = true

        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            nextButtonOpacity = 0
            nextButtonOffset = 20
            cardRotation = 0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = isForward ? -500 : 500
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if manager.isFlipped { manager.flipCard() }

            var transaction = Transaction(animation: .none)
            withTransaction(transaction) { cardOffset = isForward ? 500 : -500 }
            manager.goToIndex(targetIndex)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isTransitioning = false }
            }
        }
    }
}

struct TIPCardFrontView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text("Take It Personally")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text("Tap to reveal")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
        }
    }
}

struct TIPCardBackView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            // Prompt centered in the card
            Text(card.text)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    NavigationView {
        TIPPlayView(
            manager: TIPGameManager(
                deck: Deck(
                    title: "Take It Personally",
                    description: "Bold statements about the group",
                    numberOfCards: 60,
                    estimatedTime: "20-30 min",
                    imageName: "take it personally",
                    type: .takeItPersonally,
                    cards: allTIPCards,
                    availableCategories: ["Party", "Wild", "Friends", "Couples"]
                ),
                selectedCategories: ["Party", "Wild"],
                cardCount: 20
            ),
            deck: Deck(
                title: "Take It Personally",
                description: "Bold statements about the group",
                numberOfCards: 60,
                estimatedTime: "20-30 min",
                imageName: "take it personally",
                type: .takeItPersonally,
                cards: allTIPCards,
                availableCategories: ["Party", "Wild", "Friends", "Couples"]
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}
