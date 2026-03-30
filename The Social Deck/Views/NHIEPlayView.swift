//
//  NHIEPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct NHIEPlayView: View {
    @ObservedObject var manager: NHIEGameManager
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
    @State private var showOnlineGuestLeave = false
    @State private var showOnlineHostEveryone = false
    @State private var showOnlineHostMulti = false
    @State private var nextButtonOpacity: Double = 0
    @State private var nextButtonOffset: CGFloat = 20
    @State private var cardOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var dragOffset: CGFloat = 0

    private var isTurnModeOnline: Bool {
        roomId != nil && syncService.remoteClassicTurnsEnabled
    }

    private var canControlOnlineCard: Bool {
        guard roomId != nil else { return true }
        if !isTurnModeOnline { return isHost }
        guard let me = currentUserId else { return false }
        let turnId = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
        return turnId.isEmpty ? isHost : turnId == me
    }

    private var waitingForTurnText: String {
        if !isTurnModeOnline { return "Waiting for host to flip card" }
        let tid = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
        if let list = players, let p = list.first(where: { $0.id == tid }) {
            return "Waiting for \(p.username) to flip card"
        }
        return "Waiting for current player to flip card"
    }
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, back button, and progress
                HStack {
                    Button(action: { handleOnlineOrOfflineBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }

                    if manager.canGoBack && roomId == nil {
                        ClassicGameCompactPreviousButton(action: { previousCard() })
                            .padding(.leading, 8)
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    if let currentCard = manager.currentCard() {
                        Text("\(manager.currentIndex + 1) / \(manager.cards.count)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                    }
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Online: player avatars + host/you indication (compact single line)
                if let players = players, !players.isEmpty, roomId != nil {
                    OnlinePlayerStripView(
                        players: players,
                        currentUserId: currentUserId,
                        activeTurnPlayerId: isTurnModeOnline ? syncService.remoteTurnPlayerId : nil
                    )
                        .padding(.bottom, 8)
                }

                // Card area fills remaining space so top bar and bottom hint stay visible
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    // "Never Have I Ever" label
                    Text("Never Have I Ever")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.buttonBackground)
                        .padding(.bottom, 32)
                    // Card
                    if let currentCard = manager.currentCard() {
                        ZStack {
                            // Card front - visible when rotation < 90
                            CardFrontView(text: currentCard.text)
                                .opacity(cardRotation < 90 ? 1 : 0)
                            // Card back - visible when rotation >= 90, pre-rotated 180
                            CardBackView(text: currentCard.text)
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
                        .id(currentCard.id) // Force SwiftUI to treat each card as unique
                        .onTapGesture {
                            if !canControlOnlineCard { return }
                            if !isTransitioning {
                                toggleCard()
                            }
                        }
                        .gesture(
                            (swipeNavigationEnabled && canControlOnlineCard) ? DragGesture()
                                .onChanged { value in
                                    if !isTransitioning {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if !isTransitioning {
                                        let swipeThreshold: CGFloat = 100
                                        if value.translation.width > swipeThreshold && manager.canGoBack {
                                            previousCard()
                                        } else if value.translation.width < -swipeThreshold && !manager.isFinished {
                                            nextCard()
                                        }
                                        dragOffset = 0
                                    }
                                } : nil
                        )
                        .padding(.bottom, 32)
                    }
                    if roomId != nil && !manager.isFlipped && !canControlOnlineCard {
                        Text(waitingForTurnText)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxHeight: .infinity)

                // Next button or swipe instruction
                if manager.isFlipped {
                    if roomId != nil && !canControlOnlineCard {
                        Text(waitingForTurnText)
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

            OnlineGameExitAlertsView(
                guestLeave: $showOnlineGuestLeave,
                hostEveryone: $showOnlineHostEveryone,
                hostMulti: $showOnlineHostMulti
            )
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: NHIEEndView(deck: deck, selectedCategories: selectedCategories, cardsPlayed: manager.cards.count),
                isActive: $showEndView
            ) {
                EmptyView()
            }
        )
        .onChange(of: manager.isFlipped) { oldValue, newValue in
            if newValue {
                // Show next button smoothly
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    nextButtonOpacity = 1.0
                    nextButtonOffset = 0
                }
            } else {
                // Hide next button smoothly
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
        .onChange(of: syncService.classicRemoteSyncVersion) { _, _ in
            applyClassicRemoteSyncIfNonHost()
        }
    }

    private func handleOnlineOrOfflineBack() {
        guard roomId != nil else {
            dismiss()
            return
        }
        if isHost {
            let n = players?.count ?? 0
            if n > 2 {
                showOnlineHostMulti = true
            } else {
                showOnlineHostEveryone = true
            }
        } else {
            showOnlineGuestLeave = true
        }
    }

    /// Non-host: apply host's card index + face-up/face-down from Firestore together.
    private func applyClassicRemoteSyncIfNonHost() {
        guard roomId != nil else { return }
        let targetIndex = syncService.remoteCardIndex
        let flipped = syncService.remoteClassicCardFlipped
        if targetIndex != manager.currentIndex {
            jumpToCard(targetIndex)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
                self.alignCardRotationToRemoteFlipped(flipped)
            }
        } else {
            alignCardRotationToRemoteFlipped(flipped)
        }
    }

    private func alignCardRotationToRemoteFlipped(_ flipped: Bool) {
        guard flipped != manager.isFlipped else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                cardRotation = flipped ? 180 : 0
            }
            return
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            cardRotation = flipped ? 180 : 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if flipped != self.manager.isFlipped {
                self.manager.flipCard()
            }
        }
    }

    private func toggleCard() {
        if !canControlOnlineCard { return }
        HapticManager.shared.lightImpact()

        let willBeFlipped = !manager.isFlipped
        if let rid = roomId {
            if isTurnModeOnline {
                let turn = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
                let owner = turn.isEmpty ? (currentUserId ?? "") : turn
                Task { try? await SyncService.shared.updateClassicTurnRoundState(roomId: rid, cardIndex: manager.currentIndex, isFlipped: willBeFlipped, turnPlayerId: owner) }
            } else if isHost {
                Task { try? await SyncService.shared.updateClassicCardProgress(roomId: rid, index: manager.currentIndex, isFlipped: willBeFlipped) }
            }
        }

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
        if !canControlOnlineCard { return }
        isTransitioning = true
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            cardRotation = 0
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = 500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if manager.isFlipped { manager.flipCard() }
            
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) { cardOffset = -500 }
            
            manager.previousCard()

            if let roomId = roomId {
                let turn = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
                if isTurnModeOnline {
                    Task { try? await SyncService.shared.updateClassicTurnRoundState(roomId: roomId, cardIndex: manager.currentIndex, isFlipped: false, turnPlayerId: turn) }
                } else if isHost {
                    Task { try? await SyncService.shared.updateClassicCardProgress(roomId: roomId, index: manager.currentIndex, isFlipped: false) }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isTransitioning = false }
            }
        }
    }
    
    private func nextCard() {
        if !canControlOnlineCard { return }
        isTransitioning = true
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            nextButtonOpacity = 0
            nextButtonOffset = 20
            cardRotation = 0
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = -500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if manager.isFlipped { manager.flipCard() }
            
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) { cardOffset = 500 }
            
            manager.nextCard()

            if let roomId = roomId {
                if isTurnModeOnline {
                    let turn = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
                    let from = turn.isEmpty ? (currentUserId ?? "") : turn
                    let nextTurn = SyncService.nextClockwisePlayerId(from: from, in: players ?? [])
                    Task { try? await SyncService.shared.updateClassicTurnRoundState(roomId: roomId, cardIndex: manager.currentIndex, isFlipped: false, turnPlayerId: nextTurn) }
                } else if isHost {
                    Task { try? await SyncService.shared.updateClassicCardProgress(roomId: roomId, index: manager.currentIndex, isFlipped: false) }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isTransitioning = false }
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

struct CardFrontView: View {
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text("Never Have I Ever")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text("Tap to reveal")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
        }
    }
}

struct CardBackView: View {
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Text(text)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)
            }
        }
    }
}

#Preview {
    NavigationView {
        NHIEPlayView(
            manager: NHIEGameManager(
                deck: Deck(
                    title: "Never Have I Ever",
                    description: "Test",
                    numberOfCards: 3,
                    estimatedTime: "5-10 min",
                    imageName: "NHIE artwork",
                    type: .neverHaveIEver,
                    cards: [
                        Card(text: "been skydiving", category: "Wild", cardType: nil),
                        Card(text: "lied about my age", category: "Party", cardType: nil),
                        Card(text: "kissed a stranger", category: "Wild", cardType: nil)
                    ],
                    availableCategories: ["Party", "Wild"]
                ),
                selectedCategories: ["Party", "Wild"]
            ),
            deck: Deck(
                title: "Never Have I Ever",
                description: "Test",
                numberOfCards: 3,
                estimatedTime: "5-10 min",
                imageName: "NHIE artwork",
                type: .neverHaveIEver,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

