//
//  OnlineColorClashGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
class OnlineColorClashGameManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var gameState: ColorClashGameState?
    @Published var myHand: [ColorClashCard] = []
    @Published var topCard: ColorClashCard?
    @Published var currentColor: CardColor = .red
    @Published var burnedColor: CardColor?
    @Published var currentPlayerId: String = ""
    @Published var isMyTurn: Bool = false
    @Published var turnTimeRemaining: TimeInterval = 30.0
    @Published var showWildColorSelection: Bool = false
    @Published var pendingWildCard: ColorClashCard?
    @Published var winnerId: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private let roomCode: String
    private let myUserId: String
    private let onlineService: OnlineService
    private var gameStateListener: ListenerRegistration?
    private var turnTimer: Timer?
    
    // MARK: - Initialization
    
    init(roomCode: String, myUserId: String) {
        self.roomCode = roomCode
        self.myUserId = myUserId
        self.onlineService = OnlineService.shared
        startListeningToGameState()
    }
    
    deinit {
        gameStateListener?.remove()
        turnTimer?.invalidate()
    }
    
    // MARK: - Game State Listening
    
    private func startListeningToGameState() {
        gameStateListener = onlineService.listenToGameState(roomCode: roomCode) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                switch result {
                case .success(let gameState):
                    self.processGameStateUpdate(gameState)
                case .failure(let error):
                    self.errorMessage = "Failed to sync game state: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func processGameStateUpdate(_ newState: ColorClashGameState) {
        gameState = newState
        
        // Update my hand
        myHand = newState.playerHands[myUserId] ?? []
        
        // Update top card
        topCard = newState.topCard
        
        // Update current color
        currentColor = newState.currentColor
        
        // Update burned color
        burnedColor = newState.burnedColor
        
        // Update current player
        currentPlayerId = newState.currentPlayerId
        isMyTurn = (newState.currentPlayerId == myUserId)
        
        // Update winner
        winnerId = newState.winnerId
        
        // Start/stop turn timer
        if isMyTurn && newState.status == .playing {
            startTurnTimer(turnDuration: newState.turnDuration)
        } else {
            turnTimer?.invalidate()
        }
    }
    
    // MARK: - Turn Timer
    
    private func startTurnTimer(turnDuration: TimeInterval) {
        turnTimer?.invalidate()
        turnTimeRemaining = turnDuration
        
        turnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                self.turnTimeRemaining -= 1.0
                if self.turnTimeRemaining <= 0 {
                    timer.invalidate()
                    await self.handleAutoDraw()
                }
            }
        }
    }
    
    // MARK: - Game Actions
    
    func playCard(_ card: ColorClashCard, selectedColor: CardColor? = nil) async {
        guard isMyTurn, var gameState = gameState else {
            errorMessage = "Not your turn"
            return
        }
        
        guard let cardIndex = myHand.firstIndex(where: { $0.id == card.id }) else {
            errorMessage = "Card not in hand"
            return
        }
        
        guard let currentTopCard = topCard else {
            errorMessage = "No card to play on"
            return
        }
        
        var cardToPlay = card
        if card.type == .wild || card.type == .wildDrawFour {
            if let selectedColor = selectedColor {
                cardToPlay.selectedColor = selectedColor
            } else {
                pendingWildCard = card
                showWildColorSelection = true
                return
            }
        }
        
        // Validate card play (checking burned color rules)
        let isValid = cardToPlay.canPlay(on: currentTopCard, currentColor: currentColor, burnedColor: burnedColor)
        if !isValid && myHand.count > 1 {
            errorMessage = "Cannot play this card - must match color or number"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Remove card from hand
            myHand.remove(at: cardIndex)
            gameState.playerHands[myUserId] = myHand
            
            // Add to discard pile
            gameState.discardPile.append(cardToPlay)
            
            // Update current color
            if let selectedColor = cardToPlay.selectedColor {
                gameState.currentColor = selectedColor
            } else if let cardColor = cardToPlay.color {
                gameState.currentColor = cardColor
            }
            
            // Track who played this card
            gameState.lastActionPlayer = myUserId
            
            // Process action card effects
            processActionCard(cardToPlay, in: &gameState)
            
            // Check for win
            if myHand.isEmpty {
                gameState.status = .finished
                gameState.winnerId = myUserId
            } else {
                // Move to next turn
                advanceTurn(in: &gameState)
            }
            
            // Update game state in Firestore
            try await onlineService.updateGameState(roomCode: roomCode, gameState: gameState)
            
        } catch {
            errorMessage = "Failed to play card: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func selectWildColor(_ color: CardColor) async {
        guard let card = pendingWildCard else { return }
        showWildColorSelection = false
        pendingWildCard = nil
        await playCard(card, selectedColor: color)
    }
    
    func drawCard() async {
        guard isMyTurn, var gameState = gameState else {
            errorMessage = "Not your turn"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Check if there are pending draw cards (from Draw Two/Four)
            if let pendingDraw = gameState.pendingDrawCards, pendingDraw > 0 {
                // Draw pending cards
                for _ in 0..<pendingDraw {
                    if let card = drawCardFromDeck(in: &gameState) {
                        myHand.append(card)
                    }
                }
                gameState.pendingDrawCards = nil
            } else {
                // Draw one card
                if let card = drawCardFromDeck(in: &gameState) {
                    myHand.append(card)
                } else {
                    // Deck is empty, reshuffle discard pile (except top card)
                    reshuffleDeck(in: &gameState)
                    if let card = drawCardFromDeck(in: &gameState) {
                        myHand.append(card)
                    }
                }
            }
            
            gameState.playerHands[myUserId] = myHand
            
            // Advance turn
            advanceTurn(in: &gameState)
            
            // Update game state
            try await onlineService.updateGameState(roomCode: roomCode, gameState: gameState)
            
        } catch {
            errorMessage = "Failed to draw card: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func declareLastCard() async {
        guard isMyTurn, myHand.count == 1, var gameState = gameState else {
            return
        }
        
        gameState.lastCardDeclared[myUserId] = true
        
        do {
            try await onlineService.updateGameState(roomCode: roomCode, gameState: gameState)
        } catch {
            errorMessage = "Failed to declare last card: \(error.localizedDescription)"
        }
    }
    
    func skipTurn() async {
        guard isMyTurn, var gameState = gameState else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Advance turn without drawing or playing
            advanceTurn(in: &gameState)
            
            // Update game state
            try await onlineService.updateGameState(roomCode: roomCode, gameState: gameState)
        } catch {
            errorMessage = "Failed to skip turn: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func handleAutoDraw() async {
        // Timer expired, automatically draw
        await drawCard()
    }
    
    // MARK: - Helper Methods
    
    private func processActionCard(_ card: ColorClashCard, in gameState: inout ColorClashGameState) {
        switch card.type {
        case .skip:
            gameState.skipNextPlayer = true
            
        case .reverse:
            gameState.turnDirection *= -1
            // If only 2 players, reverse acts like skip
            if gameState.playerOrder.count == 2 {
                gameState.skipNextPlayer = true
            }
            
        case .drawTwo:
            gameState.pendingDrawCards = (gameState.pendingDrawCards ?? 0) + 2
            gameState.skipNextPlayer = true
            
        case .wildDrawFour:
            gameState.pendingDrawCards = (gameState.pendingDrawCards ?? 0) + 4
            gameState.skipNextPlayer = true
            
        case .wild, .number:
            break
        }
    }
    
    private func advanceTurn(in gameState: inout ColorClashGameState) {
        // Handle skip - need to skip the next player
        if gameState.skipNextPlayer {
            gameState.skipNextPlayer = false
            // Move to next player first (this is the skipped player)
            if let skippedPlayerId = gameState.nextPlayerId() {
                gameState.currentPlayerId = skippedPlayerId
                if let nextAfterSkip = gameState.nextPlayerId() {
                    gameState.currentPlayerId = nextAfterSkip
                }
            }
        } else {
            // Normal turn advance
            if let nextPlayerId = gameState.nextPlayerId() {
                gameState.currentPlayerId = nextPlayerId
            }
        }
        
        gameState.turnStartedAt = Date()
    }
    
    private func drawCardFromDeck(in gameState: inout ColorClashGameState) -> ColorClashCard? {
        guard !gameState.deck.isEmpty else {
            return nil
        }
        return gameState.deck.removeFirst()
    }
    
    private func reshuffleDeck(in gameState: inout ColorClashGameState) {
        guard gameState.discardPile.count > 1 else {
            return
        }
        
        // Keep top card, shuffle the rest back into deck
        let topCard = gameState.discardPile.removeLast()
        let cardsToShuffle = gameState.discardPile
        gameState.discardPile = [topCard]
        gameState.deck = cardsToShuffle.shuffled()
    }
    
    func stopListening() {
        gameStateListener?.remove()
        gameStateListener = nil
        turnTimer?.invalidate()
    }
}
