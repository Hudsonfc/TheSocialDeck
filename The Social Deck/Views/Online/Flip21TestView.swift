//
//  Flip21TestView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct Flip21TestView: View {
    @StateObject private var testManager = TestFlip21GameManager()
    @StateObject private var onlineManager = OnlineManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var cardFlipRotations: [String: Double] = [:]
    @State private var cardOffsets: [String: CGSize] = [:]
    @State private var cardScales: [String: CGFloat] = [:]
    @State private var newlyDealtCardIds: Set<String> = []
    @State private var animatingCardIds: Set<String> = []
    @State private var dealerHandValue: Int = 0
    @State private var displayedDealerHandValue: Int = 0
    @State private var visibleResultPlayerIds: Set<String> = []
    
    // Mock players for testing
    private let fakePlayers: [RoomPlayer] = [
        RoomPlayer(id: "testUser123", username: "You", avatarType: "avatar 1", avatarColor: "blue", isReady: true, isHost: true),
        RoomPlayer(id: "player1", username: "Alex", avatarType: "avatar 2", avatarColor: "red", isReady: true),
        RoomPlayer(id: "player2", username: "Jordan", avatarType: "avatar 3", avatarColor: "green", isReady: true)
    ]
    
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
            if let roundResults = testManager.roundResults, testManager.roundStatus == .finished {
                roundResultsOverlay(results: roundResults)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            testManager.setupTestGame()
            initializeCardRotations()
            // Initialize dealer hand value
            if !testManager.dealerHand.isEmpty {
                dealerHandValue = testManager.dealerHand.calculateValue()
                displayedDealerHandValue = dealerHandValue
            }
        }
        .onChange(of: testManager.myHand) { oldValue, newValue in
            handleHandChange(oldHand: oldValue, newHand: newValue)
            // Re-initialize scales for new cards
            for card in newValue {
                if cardScales[card.id] == nil {
                    cardScales[card.id] = 1.0
                }
            }
        }
        .onChange(of: testManager.dealerHand) { oldValue, newValue in
            handleDealerHandChange(oldHand: oldValue, newHand: newValue)
            // Update dealer hand value with animation
            let newValue = newValue.calculateValue()
            if dealerHandValue != newValue {
                dealerHandValue = newValue
                animateDealerHandValue(from: displayedDealerHandValue, to: newValue)
            }
        }
        .onChange(of: testManager.roundResults) { oldValue, newValue in
            // Animate round results appearing one by one
            if let newResults = newValue, testManager.roundStatus == .finished {
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
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Round \(testManager.roundNumber)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                if testManager.myScore > 0 {
                    Text("Wins: \(testManager.myScore)")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
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
        VStack(spacing: 12) {
            Text("DEALER")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .tracking(2)
            
            if testManager.roundStatus == .dealerTurn || testManager.roundStatus == .resolving || testManager.roundStatus == .finished {
                // Show dealer value when revealed with count-up animation
                Text("\(displayedDealerHandValue)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .animation(.easeInOut(duration: 0.2), value: displayedDealerHandValue)
            }
            
            // Dealer cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(testManager.dealerHand.enumerated()), id: \.element.id) { index, card in
                        PlayingCardView(card: card)
                            .frame(width: 70, height: 100)
                            .rotation3DEffect(
                                .degrees(cardFlipRotations[card.id] ?? (card.isRevealed ? 0 : 180)),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .offset(cardOffsets[card.id] ?? .zero)
                            .scaleEffect(cardScales[card.id] ?? 1.0)
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
                ForEach(fakePlayers.filter { $0.id != "testUser123" && !testManager.isPlayerEliminated($0.id) }, id: \.id) { player in
                    PlayerStatusIndicator(
                        player: player,
                        status: testManager.playerStatuses[player.id] ?? .active,
                        handValue: testManager.playerHands[player.id]?.calculateValue(),
                        isCurrentTurn: testManager.currentPlayerId == player.id
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    // MARK: - My Hand Area
    
    private var myHandArea: some View {
        VStack(spacing: 16) {
            Text("YOUR HAND")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .tracking(2)
            
            Text("\(testManager.myHand.calculateValue())")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(testManager.myHand.isBusted() ? Color(red: 0xFF/255.0, green: 0x44/255.0, blue: 0x44/255.0) : .white)
            
            // My cards
            HStack(spacing: 12) {
                ForEach(Array(testManager.myHand.enumerated()), id: \.element.id) { index, card in
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
            if testManager.roundStatus == .playerTurns && testManager.isMyTurn && testManager.myStatus == .active {
                HStack(spacing: 16) {
                    // Hit button
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        animateHitAction()
                        testManager.hit()
                    }) {
                        Text("HIT")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0))
                            .cornerRadius(12)
                    }
                    
                    // Lock button
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        animateLockAction()
                        testManager.lock()
                    }) {
                        Text("LOCK")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(12)
                    }
                }
            } else if testManager.roundStatus == .finished {
                // Next round button - only show to winners
                if testManager.didPlayerWinRound("testUser123") {
                    Button(action: {
                        testManager.startNextRound()
                    }) {
                        Text("NEXT ROUND")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0))
                            .cornerRadius(12)
                    }
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
                Text(statusMessage)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
        }
        .padding(.top, 20)
    }
    
    private var statusMessage: String {
        switch testManager.roundStatus {
        case .dealing:
            return "Dealing cards..."
        case .playerTurns:
            if testManager.isMyTurn {
                return "Your turn"
            } else {
                return "Other player's turn"
            }
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
                
                ForEach(fakePlayers, id: \.id) { player in
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
                
                // Show Next Round button only to winners (in the overlay)
                if testManager.didPlayerWinRound("testUser123") {
                    Button(action: {
                        testManager.startNextRound()
                    }) {
                        Text("NEXT ROUND")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0x1A/255.0, green: 0x8A/255.0, blue: 0x5A/255.0))
                            .cornerRadius(12)
                    }
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
        case .push:             return Color.white.opacity(0.7)
        }
    }
    
    // MARK: - Card Animation Helpers
    
    private func initializeCardRotations() {
        // Initialize rotations and positions for all cards
        for card in testManager.myHand {
            cardFlipRotations[card.id] = card.isRevealed ? 0 : 180
            if cardOffsets[card.id] == nil {
                cardOffsets[card.id] = .zero
            }
            if cardScales[card.id] == nil {
                cardScales[card.id] = 1.0
            }
        }
        for card in testManager.dealerHand {
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
                      oldCard.isRevealed != newCard.isRevealed && newCard.isRevealed {
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
        
        let players = fakePlayers.filter { results[$0.id] != nil }
        
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
        for card in testManager.myHand {
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
        for card in testManager.myHand {
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

// MARK: - Test Game Manager

@MainActor
class TestFlip21GameManager: ObservableObject {
    @Published var myHand: [Flip21Card] = []
    @Published var dealerHand: [Flip21Card] = []
    @Published var myStatus: PlayerRoundStatus = .active
    @Published var isMyTurn: Bool = true
    @Published var roundResults: [String: RoundResult]?
    @Published var roundStatus: Flip21RoundStatus = .dealing
    @Published var roundNumber: Int = 1
    @Published var myScore: Int = 0
    @Published var currentPlayerId: String = "testUser123"
    @Published var playerHands: [String: [Flip21Card]] = [:]
    @Published var playerStatuses: [String: PlayerRoundStatus] = [:]
    
    private var deck: [Flip21Card] = []
    private var playerIds = ["testUser123", "player1", "player2"] // Now mutable for elimination
    private var currentPlayerIndex: Int = 0
    private var scores: [String: Int] = [:]
    private var isProcessingAITurn: Bool = false
    private var eliminatedPlayers: Set<String> = []
    
    func setupTestGame() {
        // Create and shuffle deck
        deck = Flip21Card.createStandardDeck()
        deck.shuffle()
        
        // Deal initial cards
        dealInitialCards()
        
        roundStatus = .playerTurns
        currentPlayerIndex = 0
        currentPlayerId = playerIds[0]
        isMyTurn = (currentPlayerId == "testUser123")
        
        // If first player is AI, start their turn
        if !isMyTurn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.simulateAIPlayerTurn()
            }
        }
    }
    
    func hit() {
        guard isMyTurn, myStatus == .active else { return }
        guard !deck.isEmpty else {
            reshuffleDeck()
            return
        }
        
        var drawnCard = deck.removeFirst()
        drawnCard.isRevealed = true
        myHand.append(drawnCard)
        playerHands["testUser123"] = myHand
        
        // Check if busted
        if myHand.isBusted() {
            myStatus = .busted
            playerStatuses["testUser123"] = .busted
        }
        advanceToNextPlayer()
    }
    
    func lock() {
        guard isMyTurn, myStatus == .active else { return }
        
        myStatus = .locked
        playerStatuses["testUser123"] = .locked
        advanceToNextPlayer()
    }
    
    func startNextRound() {
        guard let roundResults = roundResults else { return }
        
        // Eliminate losers (and pushes - only winners advance)
        for (playerId, result) in roundResults {
            if result != .win {
                eliminatedPlayers.insert(playerId)
            }
        }
        
        // Filter out eliminated players
        playerIds = playerIds.filter { !eliminatedPlayers.contains($0) }
        
        // Check if game is over (only one or zero players left)
        guard playerIds.count > 1 else {
            // Game over - only winner(s) remain
            return
        }
        
        roundNumber += 1
        roundStatus = .dealing
        self.roundResults = nil
        
        // Clear hands for remaining players only
        dealerHand = []
        for playerId in playerIds {
            playerHands[playerId] = []
            playerStatuses[playerId] = .active
        }
        myHand = []
        myStatus = .active
        
        // Deal initial cards
        dealInitialCards()
        
        roundStatus = .playerTurns
        currentPlayerIndex = 0
        currentPlayerId = playerIds[0]
        isMyTurn = (currentPlayerId == "testUser123")
        
        // If first player is AI, start their turn
        if !isMyTurn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.simulateAIPlayerTurn()
            }
        }
    }
    
    func isPlayerEliminated(_ playerId: String) -> Bool {
        return eliminatedPlayers.contains(playerId)
    }
    
    func didPlayerWinRound(_ playerId: String) -> Bool {
        guard let roundResults = roundResults else { return false }
        return roundResults[playerId] == .win
    }
    
    private func dealInitialCards() {
        // Ensure deck has enough cards
        if deck.count < (playerIds.count * 1 + 1) {
            reshuffleDeck()
        }
        
        // Deal 1 card to each player (revealed to themselves)
        for playerId in playerIds {
            var hand: [Flip21Card] = []
            guard !deck.isEmpty else { break }
            var card = deck.removeFirst()
            card.isRevealed = true // Players can see their own cards
            hand.append(card)
            playerHands[playerId] = hand
            playerStatuses[playerId] = .active
            if playerId == "testUser123" {
                myHand = hand
            }
        }
        
        // Deal 1 face-up card to dealer
        dealerHand = []
        if !deck.isEmpty {
            var dealerCard = deck.removeFirst()
            dealerCard.isRevealed = true // Face-up
            dealerHand.append(dealerCard)
        }
    }
    
    private func advanceToNextPlayer() {
        // Check if all active (non-eliminated) players finished first
        let activePlayerIds = playerIds.filter { !eliminatedPlayers.contains($0) }
        let allFinished = activePlayerIds.allSatisfy { playerId in
            let status = playerStatuses[playerId] ?? .active
            return status == .locked || status == .busted
        }
        
        if allFinished {
            processDealerTurn()
            return
        }
        
        // Advance to next active (non-eliminated) player
        let startIndex = currentPlayerIndex
        var attempts = 0
        var foundNextPlayer = false
        let maxAttempts = playerIds.count * 2 // Safety: check up to 2 full cycles
        
        while attempts < maxAttempts {
            currentPlayerIndex = (currentPlayerIndex + 1) % playerIds.count
            currentPlayerId = playerIds[currentPlayerIndex]
            attempts += 1
            
            // Skip eliminated players
            if eliminatedPlayers.contains(currentPlayerId) {
                continue
            }
            
            // Check if this player is still active (not locked or busted)
            let status = playerStatuses[currentPlayerId] ?? .active
            if status == .active {
                foundNextPlayer = true
                break
            }
            
            // If we've looped back to start after checking all players, break
            if currentPlayerIndex == startIndex && attempts > 1 {
                break
            }
        }
        
        // If no active player found, something went wrong
        guard foundNextPlayer else {
            processDealerTurn()
            return
        }
        
        isMyTurn = (currentPlayerId == "testUser123")
        
        // If it's an AI player's turn, simulate their turn
        if !isMyTurn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.simulateAIPlayerTurn()
            }
        }
    }
    
    private func simulateAIPlayerTurn() {
        // Prevent multiple AI turns from running simultaneously
        guard !isProcessingAITurn else { return }
        isProcessingAITurn = true
        
        guard let hand = playerHands[currentPlayerId], !hand.isEmpty else {
            isProcessingAITurn = false
            advanceToNextPlayer()
            return
        }
        
        let handValue = hand.calculateValue()
        let isBusted = hand.isBusted()
        
        // AI strategy: hit if below 17, or if 17-19 with some randomness
        if isBusted {
            // Already busted, should not happen but safety check
            playerStatuses[currentPlayerId] = .busted
            isProcessingAITurn = false
            advanceToNextPlayer()
        } else if handValue >= 17 {
            // Lock if 17 or higher
            playerStatuses[currentPlayerId] = .locked
            isProcessingAITurn = false
            advanceToNextPlayer()
        } else if handValue >= 15 {
            // 15-16: 70% chance to hit, 30% to lock
            if Double.random(in: 0...1) < 0.7 {
                aiHit()
            } else {
                playerStatuses[currentPlayerId] = .locked
                isProcessingAITurn = false
                advanceToNextPlayer()
            }
        } else {
            // Below 15: always hit
            aiHit()
        }
    }
    
    private func aiHit() {
        if deck.isEmpty {
            reshuffleDeck()
        }
        
        guard !deck.isEmpty else {
            isProcessingAITurn = false
            advanceToNextPlayer()
            return
        }
        
        var drawnCard = deck.removeFirst()
        drawnCard.isRevealed = true
        
        if var hand = playerHands[currentPlayerId] {
            hand.append(drawnCard)
            playerHands[currentPlayerId] = hand
            
            // Check if busted
            if hand.isBusted() {
                playerStatuses[currentPlayerId] = .busted
                isProcessingAITurn = false
                advanceToNextPlayer()
            } else {
                // Continue AI turn - make another decision after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.simulateAIPlayerTurn()
                }
            }
        } else {
            isProcessingAITurn = false
            advanceToNextPlayer()
        }
    }
    
    private func processDealerTurn() {
        roundStatus = .dealerTurn
        isProcessingAITurn = false
        
        // Dealer automatically draws cards one at a time until reaching 17+
        drawDealerCard()
    }
    
    private func drawDealerCard() {
        guard dealerHand.calculateValue() < 17 else {
            // Dealer is done, resolve round
            resolveRound()
            return
        }
        
        if deck.isEmpty {
            reshuffleDeck()
        }
        
        guard !deck.isEmpty else {
            resolveRound()
            return
        }
        
        // Draw card
        var drawnCard = deck.removeFirst()
        drawnCard.isRevealed = true
        dealerHand.append(drawnCard)
        
        // Continue drawing after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.drawDealerCard()
        }
    }
    
    private func resolveRound() {
        roundStatus = .resolving
        
        let dealerValue = dealerHand.calculateValue()
        let dealerBusted = dealerHand.isBusted()
        
        var results: [String: RoundResult] = [:]
        
        for playerId in playerIds {
            let hand = playerHands[playerId] ?? []
            let playerValue = hand.calculateValue()
            let playerBusted = hand.isBusted()
            let status = playerStatuses[playerId] ?? .active
            
            if status == .locked {
                if playerBusted {
                    results[playerId] = .loss
                } else if dealerBusted {
                    results[playerId] = .win
                    scores[playerId] = (scores[playerId] ?? 0) + 1
                } else if playerValue > dealerValue {
                    results[playerId] = .win
                    scores[playerId] = (scores[playerId] ?? 0) + 1
                } else if playerValue == dealerValue {
                    results[playerId] = .push
                } else {
                    results[playerId] = .loss
                }
            } else if status == .busted {
                results[playerId] = .loss
            }
        }
        
        roundResults = results
        myScore = scores["testUser123"] ?? 0
        roundStatus = .finished
    }
    
    private func reshuffleDeck() {
        // Collect all cards
        var allCards: [Flip21Card] = []
        for (_, hand) in playerHands {
            allCards.append(contentsOf: hand)
        }
        if let firstDealerCard = dealerHand.first {
            allCards.append(contentsOf: dealerHand.dropFirst())
            dealerHand = [firstDealerCard]
        } else {
            allCards.append(contentsOf: dealerHand)
            dealerHand = []
        }
        allCards.append(contentsOf: deck)
        
        // Reset and reshuffle
        for i in 0..<allCards.count {
            allCards[i].isRevealed = false
        }
        deck = allCards.shuffled()
    }
}

