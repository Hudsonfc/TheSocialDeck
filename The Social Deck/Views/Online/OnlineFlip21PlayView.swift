//
//  OnlineFlip21PlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct OnlineFlip21PlayView: View {
    @StateObject private var manager: OnlineFlip21GameManager
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var cardFlipRotations: [String: Double] = [:]
    @State private var cardOffsets: [String: CGSize] = [:]
    @State private var cardScales: [String: CGFloat] = [:]
    @State private var newlyDealtCardIds: Set<String> = []
    @State private var animatingCardIds: Set<String> = []
    @State private var dealerHandValue: Int = 0
    @State private var displayedDealerHandValue: Int = 0
    @State private var visibleResultPlayerIds: Set<String> = []
    
    let roomCode: String
    let myUserId: String
    
    init(roomCode: String, myUserId: String) {
        self.roomCode = roomCode
        self.myUserId = myUserId
        _manager = StateObject(wrappedValue: OnlineFlip21GameManager(roomCode: roomCode, myUserId: myUserId))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0x0F/255.0, green: 0x1F/255.0, blue: 0x1F/255.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                topBar
                
                // Main game area
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Dealer area (top)
                        dealerArea
                            .frame(height: geometry.size.height * 0.25)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        
                        // Other players status (middle)
                        otherPlayersStatus
                            .frame(height: geometry.size.height * 0.15)
                            .padding(.horizontal, 20)
                        
                        // My hand (center)
                        myHandArea
                            .frame(height: geometry.size.height * 0.35)
                            .padding(.horizontal, 20)
                        
                        // Action buttons (bottom)
                        actionButtons
                            .frame(height: geometry.size.height * 0.25)
                            .padding(.bottom, 20)
                            .padding(.horizontal, 20)
                    }
                }
            }
            
            // Round results overlay
            if let roundResults = manager.roundResults, let gameState = manager.gameState, gameState.roundStatus == .finished {
                roundResultsOverlay(results: roundResults)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Initialize card rotations
            initializeCardRotations()
            // Initialize dealer hand value
            if !manager.dealerHand.isEmpty {
                dealerHandValue = manager.dealerHand.calculateValue()
                displayedDealerHandValue = dealerHandValue
            }
        }
        .onChange(of: manager.myHand) { oldValue, newValue in
            handleHandChange(oldHand: oldValue, newHand: newValue)
            // Re-initialize scales for new cards
            for card in newValue {
                if cardScales[card.id] == nil {
                    cardScales[card.id] = 1.0
                }
            }
        }
        .onChange(of: manager.dealerHand) { oldValue, newValue in
            handleDealerHandChange(oldHand: oldValue, newHand: newValue)
            // Update dealer hand value with animation
            let newValue = newValue.calculateValue()
            if dealerHandValue != newValue {
                dealerHandValue = newValue
                animateDealerHandValue(from: displayedDealerHandValue, to: newValue)
            }
        }
        .onChange(of: manager.roundResults) { oldValue, newValue in
            // Animate round results appearing one by one
            if let newResults = newValue, let gameState = manager.gameState, gameState.roundStatus == .finished {
                animateRoundResults(results: newResults)
            } else {
                visibleResultPlayerIds.removeAll()
            }
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            if let gameState = manager.gameState {
                VStack(spacing: 4) {
                    Text("Round \(gameState.roundNumber)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if let score = gameState.scores[myUserId] {
                        Text("Wins: \(score)")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            // Spacer for balance
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    // MARK: - Dealer Area
    
    private var dealerArea: some View {
        VStack(spacing: 8) {
            // Dealer avatar - centered above "DEALER" text, right below "Round 1"
            Image("Flip21 Dealer")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .opacity(0.8)
                .clipped()
            
            Text("DEALER")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .tracking(2)
            
            if let gameState = manager.gameState {
                if gameState.roundStatus == .dealerTurn || gameState.roundStatus == .resolving || gameState.roundStatus == .finished {
                    // Show dealer value when revealed with count-up animation
                    Text("\(displayedDealerHandValue)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.2), value: displayedDealerHandValue)
                }
            }
            
            // Dealer cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(manager.dealerHand.enumerated()), id: \.element.id) { index, card in
                        PlayingCardView(card: card)
                            .frame(width: 70, height: 100)
                            .rotation3DEffect(
                                .degrees(cardFlipRotations[card.id] ?? (card.isRevealed ? 0 : 180)),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .offset(cardOffsets[card.id] ?? .zero)
                            .scaleEffect(cardScales[card.id] ?? 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: cardOffsets[card.id])
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: cardScales[card.id])
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Other Players Status
    
    private var otherPlayersStatus: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if let gameState = manager.gameState, let room = onlineManager.currentRoom {
                    ForEach(room.players.filter { $0.id != myUserId }, id: \.id) { player in
                        PlayerStatusIndicator(
                            player: player,
                            status: gameState.playerStatuses[player.id] ?? .active,
                            handValue: getHandValue(for: player.id, gameState: gameState),
                            isCurrentTurn: gameState.currentPlayerId == player.id
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func getHandValue(for playerId: String, gameState: Flip21GameState) -> Int? {
        guard let hand = gameState.playerHands[playerId] else { return nil }
        return hand.calculateValue()
    }
    
    // MARK: - My Hand Area
    
    private var myHandArea: some View {
        VStack(spacing: 16) {
            Text("YOUR HAND")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .tracking(2)
            
            Text("\(manager.myHand.calculateValue())")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(manager.myHand.isBusted() ? Color(red: 0xFF/255.0, green: 0x44/255.0, blue: 0x44/255.0) : .white)
            
            // My cards
            HStack(spacing: 12) {
                ForEach(Array(manager.myHand.enumerated()), id: \.element.id) { index, card in
                    PlayingCardView(card: card)
                        .frame(width: 80, height: 112)
                        .rotation3DEffect(
                            .degrees(cardFlipRotations[card.id] ?? (card.isRevealed ? 0 : 180)),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .offset(cardOffsets[card.id] ?? .zero)
                        .scaleEffect(cardScales[card.id] ?? 1.0)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            if let gameState = manager.gameState {
                if gameState.roundStatus == .playerTurns && manager.isMyTurn && manager.myStatus == .active {
                    HStack(spacing: 16) {
                        // Hit button
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            animateHitAction()
                            Task {
                                await manager.hit()
                            }
                        }) {
                            Text("HIT")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0))
                                .cornerRadius(12)
                        }
                        .disabled(manager.isLoading)
                        .opacity(manager.isLoading ? 0.6 : 1.0)
                        
                        // Lock button
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            animateLockAction()
                            Task {
                                await manager.lock()
                            }
                        }) {
                            Text("LOCK")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .cornerRadius(12)
                        }
                        .disabled(manager.isLoading)
                        .opacity(manager.isLoading ? 0.6 : 1.0)
                    }
                } else if gameState.roundStatus == .finished {
                    // Next round button - only show to winners
                    if manager.didPlayerWinRound() {
                        Button(action: {
                            Task {
                                await manager.startNextRound()
                            }
                        }) {
                            Text("NEXT ROUND")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0))
                                .cornerRadius(12)
                        }
                        .disabled(manager.isLoading)
                        .opacity(manager.isLoading ? 0.6 : 1.0)
                    } else {
                        // Eliminated players see elimination message
                        Text("ELIMINATED")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0))
                            .cornerRadius(12)
                    }
                } else {
                    // Waiting state
                    Text(statusMessage(for: gameState))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
            }
        }
        .padding(.top, 20)
    }
    
    private func statusMessage(for gameState: Flip21GameState) -> String {
        switch gameState.roundStatus {
        case .dealing:
            return "Dealing cards..."
        case .playerTurns:
            if let currentPlayerId = gameState.currentPlayerId,
               let room = onlineManager.currentRoom,
               let currentPlayer = room.players.first(where: { $0.id == currentPlayerId }) {
                if currentPlayerId == myUserId {
                    return "Your turn"
                } else {
                    return "\(currentPlayer.username)'s turn"
                }
            }
            return "Waiting..."
        case .dealerTurn:
            return "Dealer's turn..."
        case .resolving:
            return "Resolving round..."
        case .finished:
            return "Round finished"
        }
    }
    
    // MARK: - Round Results Overlay
    
    private func roundResultsOverlay(results: [String: RoundResult]) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Round Results")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                if let room = onlineManager.currentRoom {
                    ForEach(room.players, id: \.id) { player in
                        if let result = results[player.id], visibleResultPlayerIds.contains(player.id) {
                            HStack {
                                Text(player.username)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text(resultText(result))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(resultColor(result))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(result == .win ? Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0).opacity(0.3) : Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                    }
                }
                
                // Show Next Round button only to winners (in the overlay)
                if manager.didPlayerWinRound() {
                    Button(action: {
                        Task {
                            await manager.startNextRound()
                        }
                    }) {
                        Text("NEXT ROUND")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0))
                            .cornerRadius(12)
                    }
                    .disabled(manager.isLoading)
                    .opacity(manager.isLoading ? 0.6 : 1.0)
                    .padding(.top, 8)
                }
            }
            .padding(24)
            .background(Color(red: 0x1A/255.0, green: 0x1A/255.0, blue: 0x1A/255.0))
            .cornerRadius(16)
            .padding(.horizontal, 40)
        }
    }
    
    private func resultText(_ result: RoundResult) -> String {
        switch result {
        case .win: return "WIN"
        case .loss: return "LOSS"
        case .push: return "PUSH"
        }
    }
    
    private func resultColor(_ result: RoundResult) -> Color {
        switch result {
        case .win: return Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0)
        case .loss: return Color(red: 0xFF/255.0, green: 0x44/255.0, blue: 0x44/255.0)
        case .push: return Color.white.opacity(0.7)
        }
    }
    
    // MARK: - Card Animation Helpers
    
    private func initializeCardRotations() {
        // Initialize rotations and positions for all cards
        for card in manager.myHand {
            cardFlipRotations[card.id] = card.isRevealed ? 0 : 180
            if cardOffsets[card.id] == nil {
                cardOffsets[card.id] = .zero
            }
            if cardScales[card.id] == nil {
                cardScales[card.id] = 1.0
            }
        }
        for card in manager.dealerHand {
            cardFlipRotations[card.id] = card.isRevealed ? 0 : 180
            if cardOffsets[card.id] == nil {
                cardOffsets[card.id] = .zero
            }
            if cardScales[card.id] == nil {
                cardScales[card.id] = 1.0
            }
        }
    }
    
    private func handleHandChange(oldHand: [Flip21Card], newHand: [Flip21Card]) {
        // Find newly added cards and animate them
        for newCard in newHand {
            if !oldHand.contains(where: { $0.id == newCard.id }) {
                // New card added - animate slide-in and flip
                newlyDealtCardIds.insert(newCard.id)
                cardFlipRotations[newCard.id] = 180
                cardOffsets[newCard.id] = CGSize(width: 0, height: -50)
                cardScales[newCard.id] = 0.8
                
                // Animate flip
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    cardFlipRotations[newCard.id] = newCard.isRevealed ? 0 : 180
                }
                
                // Animate slide-in and scale
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    cardOffsets[newCard.id] = .zero
                    cardScales[newCard.id] = 1.0
                }
                
                // Remove from newly dealt after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    newlyDealtCardIds.remove(newCard.id)
                }
            } else if let oldCard = oldHand.first(where: { $0.id == newCard.id }),
                      oldCard.isRevealed != newCard.isRevealed {
                // Card reveal status changed - animate flip
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    cardFlipRotations[newCard.id] = newCard.isRevealed ? 0 : 180
                }
            }
        }
    }
    
    private func handleDealerHandChange(oldHand: [Flip21Card], newHand: [Flip21Card]) {
        // Find newly added cards or cards that were revealed
        for (index, newCard) in newHand.enumerated() {
            if !oldHand.contains(where: { $0.id == newCard.id }) {
                // New card added to dealer - animate slide-in with delay based on index
                cardFlipRotations[newCard.id] = 180
                cardOffsets[newCard.id] = CGSize(width: 50, height: 0)
                cardScales[newCard.id] = 0.8
                
                let delay = Double(index) * 0.2
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // Animate flip if card is revealed
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        cardFlipRotations[newCard.id] = newCard.isRevealed ? 0 : 180
                    }
                    
                    // Animate slide-in and scale
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        cardOffsets[newCard.id] = .zero
                        cardScales[newCard.id] = 1.0
                    }
                }
            } else if let oldCard = oldHand.first(where: { $0.id == newCard.id }),
                      oldCard.isRevealed != newCard.isRevealed && !newCard.isRevealed {
                // Card was revealed (flipped from face-down to face-up) - animate flip
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    cardFlipRotations[newCard.id] = 0
                }
            }
        }
    }
    
    private func animateDealerHandValue(from: Int, to: Int) {
        // Animate count-up from current displayed value to target value
        let steps = abs(to - from)
        guard steps > 0 else { return }
        
        let duration = min(0.6, Double(steps) * 0.08) // Cap at 0.6 seconds
        let stepDuration = max(0.03, duration / Double(steps))
        
        var currentStep = 1
        let increment = from < to ? 1 : -1
        
        let timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            let newValue = from + (currentStep * increment)
            displayedDealerHandValue = newValue
            currentStep += 1
            
            if currentStep > steps {
                displayedDealerHandValue = to
                timer.invalidate()
            }
        }
        
        // Keep timer reference
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private func animateRoundResults(results: [String: RoundResult]) {
        visibleResultPlayerIds.removeAll()
        
        guard let room = onlineManager.currentRoom else { return }
        let players = room.players.filter { results[$0.id] != nil }
        
        // Animate results appearing one by one
        for (index, player) in players.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    _ = visibleResultPlayerIds.insert(player.id)
                }
            }
        }
    }
    
    private func animateHitAction() {
        // Animate all cards in hand with a subtle bounce
        for card in manager.myHand {
            // Initialize scale if needed
            if cardScales[card.id] == nil {
                cardScales[card.id] = 1.0
            }
            
            // Trigger animation
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                cardScales[card.id] = 1.08
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    cardScales[card.id] = 1.0
                }
            }
        }
    }
    
    private func animateLockAction() {
        // Animate all cards in hand with a subtle scale down then back
        for card in manager.myHand {
            // Initialize scale if needed
            if cardScales[card.id] == nil {
                cardScales[card.id] = 1.0
            }
            
            // Trigger animation
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                cardScales[card.id] = 0.92
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    cardScales[card.id] = 1.0
                }
            }
        }
    }
}

// MARK: - Playing Card View

struct PlayingCardView: View {
    let card: Flip21Card
    
    var body: some View {
        ZStack {
            // Card back (visible when not revealed or rotated < 90)
            if !card.isRevealed {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0x1A/255.0, green: 0x4A/255.0, blue: 0x7A/255.0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
            
            // Card front (visible when revealed)
            if card.isRevealed {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .overlay(
                        VStack(spacing: 0) {
                            // Top section
                            HStack {
                                // Top-left rank and suit (upright)
                                HStack(spacing: 2) {
                                    Text(card.rank.displayName)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(suitColor(card.suit))
                                    suitSymbol(card.suit)
                                        .font(.system(size: 12))
                                        .foregroundColor(suitColor(card.suit))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.top, 8)
                            
                            Spacer()
                            
                            // Center suit (larger)
                            suitSymbol(card.suit)
                                .font(.system(size: 32))
                                .foregroundColor(suitColor(card.suit))
                            
                            Spacer()
                            
                            // Bottom section
                            HStack {
                                Spacer()
                                // Bottom-right rank and suit (rotated 180 degrees)
                                HStack(spacing: 2) {
                                    Text(card.rank.displayName)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(suitColor(card.suit))
                                    suitSymbol(card.suit)
                                        .font(.system(size: 12))
                                        .foregroundColor(suitColor(card.suit))
                                }
                                .rotationEffect(.degrees(180))
                            }
                            .padding(.horizontal, 8)
                            .padding(.bottom, 8)
                        }
                    )
            }
        }
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private func suitColor(_ suit: CardSuit) -> Color {
        switch suit {
        case .hearts, .diamonds:
            return Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
        case .spades, .clubs:
            return Color.black
        }
    }
    
    private func suitSymbol(_ suit: CardSuit) -> some View {
        Group {
            switch suit {
            case .hearts:
                Text("♥")
            case .diamonds:
                Text("♦")
            case .spades:
                Text("♠")
            case .clubs:
                Text("♣")
            }
        }
    }
}

// MARK: - Player Status Indicator

struct PlayerStatusIndicator: View {
    let player: RoomPlayer
    let status: PlayerRoundStatus
    let handValue: Int?
    let isCurrentTurn: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            // Avatar with status indicators
            ZStack {
                // Avatar
                AvatarView(
                    avatarType: player.avatarType,
                    avatarColor: player.avatarColor,
                    size: 50
                )
                
                // Turn indicator (glow/border)
                if isCurrentTurn {
                    Circle()
                        .stroke(Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0), lineWidth: 3)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0).opacity(0.6), radius: 8)
                }
                
                // Status indicator dot (top-right corner)
                statusIndicatorDot
                    .offset(x: 18, y: -18)
            }
            
            // Username
            Text(player.username)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
            
            // Hand value
            if let value = handValue {
                Text("\(value)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(handValueColor)
            } else {
                // Placeholder when no value yet
                Text("—")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .frame(width: 80)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: isCurrentTurn ? 2 : 1)
        )
    }
    
    private var statusIndicatorDot: some View {
        Circle()
            .fill(statusDotColor)
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
    }
    
    private var statusDotColor: Color {
        switch status {
        case .active:
            return Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0) // Green for playing
        case .locked:
            return Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) // Red for locked
        case .busted:
            return Color(red: 0xFF/255.0, green: 0x44/255.0, blue: 0x44/255.0) // Bright red for busted
        }
    }
    
    private var backgroundColor: Color {
        if isCurrentTurn {
            return Color.white.opacity(0.12)
        } else {
            return Color.white.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if isCurrentTurn {
            return Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0)
        } else {
            return Color.white.opacity(0.1)
        }
    }
    
    private var handValueColor: Color {
        switch status {
        case .active:
            return .white
        case .locked:
            return Color.white.opacity(0.8)
        case .busted:
            return Color(red: 0xFF/255.0, green: 0x44/255.0, blue: 0x44/255.0)
        }
    }
}

