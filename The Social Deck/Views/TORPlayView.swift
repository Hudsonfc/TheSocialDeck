//
//  TORPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct TORPlayView: View {
    @ObservedObject var manager: TORGameManager
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
    @State private var acceptSwitchButtonsOpacity: Double = 0
    @State private var acceptSwitchButtonsOffset: CGFloat = 20
    @State private var cardOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var dragOffset: CGFloat = 0

    /// Online TOR / WYR: only the synced turn player may control the round (host seeds turn if missing).
    private var isMyClassicTurn: Bool {
        guard roomId != nil, let uid = currentUserId else { return true }
        if !syncService.remoteClassicTurnsEnabled { return isHost }
        let tid = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
        if tid.isEmpty { return isHost }
        return tid == uid
    }

    private var waitingForActivePlayerLine: String {
        if !syncService.remoteClassicTurnsEnabled { return "Waiting for host…" }
        let tid = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let pl = players, !pl.isEmpty, !tid.isEmpty,
              let name = pl.first(where: { $0.id == tid })?.username else {
            return "Waiting for the current player…"
        }
        return "Waiting for \(name)…"
    }

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
                    
                    if manager.canGoBack && roomId == nil {
                        ClassicGameCompactPreviousButton(action: { previousCard() })
                            .padding(.leading, 8)
                    }
                    
                    Spacer()
                    
                    // Progress indicator (uses gamePosition which tracks original card, not switched card)
                    Text("\(manager.gamePosition + 1) / \(manager.cards.count)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Online: player avatars + host/you indication (compact single line)
                if let players = players, !players.isEmpty, roomId != nil {
                    OnlinePlayerStripView(
                        players: players,
                        currentUserId: currentUserId,
                        activeTurnPlayerId: syncService.remoteTurnPlayerId
                    )
                    .padding(.bottom, 8)
                }

                // Card area fills remaining space so top bar and bottom hint stay visible
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    // "Truth or Dare" label
                    Text("Truth or Dare")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.buttonBackground)
                        .padding(.bottom, 32)
                    // Card
                    if let currentCard = manager.currentCard() {
                        ZStack {
                            TORCardFrontView(card: currentCard)
                                .opacity(cardRotation < 90 ? 1 : 0)
                            TORCardBackView(card: currentCard)
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
                        .id(currentCard.id)
                        .onTapGesture {
                            if roomId != nil && !isMyClassicTurn { return }
                            if !isTransitioning { toggleCard() }
                        }
                        .gesture(
                            (swipeNavigationEnabled && (roomId == nil || isMyClassicTurn)) ? DragGesture()
                                .onChanged { value in
                                    if !isTransitioning { dragOffset = value.translation.width }
                                }
                                .onEnded { value in
                                    if !isTransitioning {
                                        let swipeThreshold: CGFloat = 100
                                        if value.translation.width > swipeThreshold && manager.canGoBack {
                                            previousCard()
                                        } else if value.translation.width < -swipeThreshold && !manager.isFinished && manager.hasAccepted {
                                            nextCard()
                                        }
                                        dragOffset = 0
                                    }
                                } : nil
                        )
                        .padding(.bottom, 32)
                    }
                    if roomId != nil && !manager.isFlipped && !isMyClassicTurn && manager.currentCard() != nil {
                        Text(waitingForActivePlayerLine + " to reveal the card.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxHeight: .infinity)

                if roomId != nil && manager.isFlipped && !manager.hasAccepted && !isMyClassicTurn {
                    Text(waitingForActivePlayerLine)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 12)
                }

                // Accept/Switch — only the player whose turn it is (online) or anyone (local)
                if manager.isFlipped && !manager.hasAccepted && (roomId == nil || isMyClassicTurn) {
                    HStack(spacing: 12) {
                        // Accept button
                        Button(action: {
                            acceptCard()
                        }) {
                            Text("Accept")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.buttonBackground)
                                .cornerRadius(12)
                        }
                        
                        // Switch button
                        if manager.canSwitch, let currentCard = manager.currentCard(), let cardType = currentCard.cardType {
                            Button(action: {
                                switchToOpposite()
                            }) {
                                Text("Switch to \(cardType == .truth ? "Dare" : "Truth")")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.buttonBackground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.buttonBackground, lineWidth: 2)
                                    )
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .opacity(acceptSwitchButtonsOpacity)
                    .offset(y: acceptSwitchButtonsOffset)
                }
                
                if manager.hasAccepted {
                    if roomId != nil && !isMyClassicTurn {
                        Text(waitingForActivePlayerLine)
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
                    destination: TOREndView(deck: deck, selectedCategories: selectedCategories, cardsPlayed: manager.cards.count),
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
            if newValue && !manager.hasAccepted {
                // Show Accept/Switch buttons when card content is revealed
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    acceptSwitchButtonsOpacity = 1.0
                    acceptSwitchButtonsOffset = 0
                }
            } else if !newValue || manager.hasAccepted {
                // Hide Accept/Switch buttons
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    acceptSwitchButtonsOpacity = 0
                    acceptSwitchButtonsOffset = 20
                }
            }
        }
        .onChange(of: manager.hasAccepted) { oldValue, newValue in
            if newValue {
                // Hide Accept/Switch buttons
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    acceptSwitchButtonsOpacity = 0
                    acceptSwitchButtonsOffset = 20
                }
                // Show Next button after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        nextButtonOpacity = 1.0
                        nextButtonOffset = 0
                    }
                }
            } else {
                // Hide Next button when card is unaccepted
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
                if isHost && syncService.remoteClassicTurnsEnabled {
                    Task {
                        try? await SyncService.shared.seedClassicTurnPlayerIfNeeded(roomId: roomId, players: players ?? [])
                    }
                }
            }
            applyTORFirestoreSnapshot()
            if manager.isFlipped && !manager.hasAccepted {
                acceptSwitchButtonsOpacity = 1.0
                acceptSwitchButtonsOffset = 0
            } else if manager.hasAccepted {
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
            if roomId != nil {
                applyTORFirestoreSnapshot()
            }
        }
    }

    private func applyTORFirestoreSnapshot() {
        guard roomId != nil else { return }
        let gp = syncService.remoteCardIndex
        let di = syncService.remoteTorDisplayIndex
        let flipped = syncService.remoteClassicCardFlipped
        let acc = syncService.remoteTorHasAccepted

        if gp >= manager.cards.count {
            manager.applyOnlineSyncState(gamePosition: gp, displayIndex: 0, isFlipped: false, hasAccepted: false)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                cardRotation = 0
            }
            return
        }

        if manager.gamePosition == gp,
           manager.currentIndex == di,
           manager.isFlipped == flipped,
           manager.hasAccepted == acc {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                cardRotation = flipped ? 180 : 0
            }
            return
        }

        manager.applyOnlineSyncState(gamePosition: gp, displayIndex: di, isFlipped: flipped, hasAccepted: acc)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            cardRotation = flipped ? 180 : 0
        }
    }

    private func pushTORStateToFirestore() {
        guard let rid = roomId, isMyClassicTurn else { return }
        let turnId = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
        let turn = turnId.isEmpty ? (currentUserId ?? "") : turnId
        Task {
            try? await SyncService.shared.updateTruthOrDareOnlineState(
                roomId: rid,
                gamePosition: manager.gamePosition,
                displayIndex: manager.currentIndex,
                isFlipped: manager.isFlipped,
                hasAccepted: manager.hasAccepted,
                turnPlayerId: turn
            )
        }
    }

    private func toggleCard() {
        if roomId != nil && !isMyClassicTurn { return }
        HapticManager.shared.lightImpact()

        if manager.isFlipped {
            // Flip back to front
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
                pushTORStateToFirestore()
            }
        } else {
            // Flip to back to show full content
            totalCardsFlipped += 1
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
                pushTORStateToFirestore()
            }
        }
    }
    
    private func acceptCard() {
        manager.acceptCard()
        pushTORStateToFirestore()
    }
    
    private func switchToOpposite() {
        // Smooth transition: flip back slightly, then flip to new card
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            cardRotation = 90 // Halfway point for smooth transition
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            manager.switchToOppositeType()
            // Continue flip to show new card's full content
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                cardRotation = 180
            }
            pushTORStateToFirestore()
        }
    }
    
    private func previousCard() {
        if roomId != nil && !isMyClassicTurn { return }
        isTransitioning = true

        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            cardRotation = 0
            acceptSwitchButtonsOpacity = 0
            nextButtonOpacity = 0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = 500 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if manager.isFlipped { manager.flipCard() }
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) { cardOffset = -500 }
            manager.previousCard()
            pushTORStateToFirestore()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isTransitioning = false }
            }
        }
    }

    private func nextCard() {
        if roomId != nil && !isMyClassicTurn { return }
        isTransitioning = true

        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            nextButtonOpacity = 0
            nextButtonOffset = 20
            cardRotation = 0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = -500 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if manager.isFlipped { manager.flipCard() }
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) { cardOffset = 500 }
            manager.nextCard()

            if let rid = roomId {
                let pl = players ?? []
                let fromId = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
                let from = fromId.isEmpty ? (currentUserId ?? "") : fromId
                let nextTurn = pl.isEmpty ? from : SyncService.nextClockwisePlayerId(from: from, in: pl)
                let gp = manager.isFinished ? manager.cards.count : manager.gamePosition
                let di = manager.isFinished ? max(0, manager.cards.count - 1) : manager.currentIndex
                Task {
                    try? await SyncService.shared.updateTruthOrDareOnlineState(
                        roomId: rid,
                        gamePosition: gp,
                        displayIndex: di,
                        isFlipped: false,
                        hasAccepted: false,
                        turnPlayerId: nextTurn
                    )
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isTransitioning = false }
            }
        }
    }
}

struct TORCardFrontView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Image(systemName: "mouth.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text("Truth or Dare")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text("Tap to reveal")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
        }
    }
}

struct TORCardBackView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            // Show full content (type + text)
            VStack(spacing: 16) {
                if let cardType = card.cardType {
                    Text(cardType == .truth ? "Truth" : "Dare")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                }
                
                Text(card.text)
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
        TORPlayView(
            manager: TORGameManager(
                deck: Deck(
                    title: "Truth or Dare",
                    description: "Test",
                    numberOfCards: 3,
                    estimatedTime: "5-10 min",
                    imageName: "TOD artwork",
                    type: .truthOrDare,
                    cards: [
                        Card(text: "What's your biggest secret?", category: "Party", cardType: .truth),
                        Card(text: "Do 20 push-ups", category: "Party", cardType: .dare),
                        Card(text: "Have you ever cheated?", category: "Wild", cardType: .truth)
                    ],
                    availableCategories: ["Party", "Wild"]
                ),
                selectedCategories: ["Party", "Wild"]
            ),
            deck: Deck(
                title: "Truth or Dare",
                description: "Test",
                numberOfCards: 3,
                estimatedTime: "5-10 min",
                imageName: "TOD artwork",
                type: .truthOrDare,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

