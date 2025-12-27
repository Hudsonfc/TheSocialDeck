//
//  OnlineFlip21GameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
class OnlineFlip21GameManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var gameState: Flip21GameState?
    @Published var myHand: [Flip21Card] = []
    @Published var dealerHand: [Flip21Card] = []
    @Published var myStatus: PlayerRoundStatus = .active
    @Published var isMyTurn: Bool = false
    @Published var roundResults: [String: RoundResult]?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private let roomCode: String
    private let myUserId: String
    private let onlineService: OnlineService
    private var gameStateListener: ListenerRegistration?
    private var dealerTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(roomCode: String, myUserId: String) {
        self.roomCode = roomCode
        self.myUserId = myUserId
        self.onlineService = OnlineService.shared
        startListeningToGameState()
    }
    
    deinit {
        gameStateListener?.remove()
        dealerTask?.cancel()
    }
    
    // MARK: - Game State Listening
    
    private func startListeningToGameState() {
        gameStateListener = onlineService.listenToFlip21GameState(roomCode: roomCode) { [weak self] result in
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
    
    private func processGameStateUpdate(_ newState: Flip21GameState) {
        let oldStatus = gameState?.roundStatus
        gameState = newState
        
        // Update my hand
        myHand = newState.playerHands[myUserId] ?? []
        
        // Update dealer hand
        dealerHand = newState.dealerHand
        
        // Update my status
        myStatus = newState.playerStatuses[myUserId] ?? .active
        
        // Update turn status
        isMyTurn = (newState.currentPlayerId == myUserId && newState.roundStatus == .playerTurns)
        
        // Update round results
        roundResults = newState.roundResults
        
        // Handle dealer turn automatically if it's my turn to trigger it (current player or host)
        if newState.roundStatus == .dealerTurn && oldStatus != .dealerTurn {
            Task {
                await processDealerTurn()
            }
        }
    }
    
    // MARK: - Game Actions
    
    func hit() async {
        guard isMyTurn, var gameState = gameState, gameState.roundStatus == .playerTurns else {
            errorMessage = "Not your turn"
            return
        }
        
        guard myStatus == .active else {
            errorMessage = "You've already locked or busted"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Draw a card from deck
            if gameState.deck.isEmpty {
                // Reshuffle if needed (shouldn't happen with 52 cards, but safety check)
                reshuffleDeck(in: &gameState)
            }
            
            guard !gameState.deck.isEmpty else {
                throw NSError(domain: "Flip21", code: -1, userInfo: [NSLocalizedDescriptionKey: "Deck is empty"])
            }
            
            // Draw card and add to player's hand (revealed)
            var drawnCard = gameState.deck.removeFirst()
            drawnCard.isRevealed = true
            
            var myHand = gameState.playerHands[myUserId] ?? []
            myHand.append(drawnCard)
            gameState.playerHands[myUserId] = myHand
            
            // Check if player busted
            if myHand.isBusted() {
                gameState.playerStatuses[myUserId] = .busted
                myStatus = .busted
                
                // Move to next player
                if gameState.allPlayersFinished {
                    gameState.roundStatus = .dealerTurn
                } else {
                    advanceToNextActivePlayer(in: &gameState)
                }
            } else {
                // Still active, but stay on same player (they can hit again or lock)
                // Don't advance turn yet
            }
            
            // Update game state
            try await onlineService.updateFlip21GameState(roomCode: roomCode, gameState: gameState)
            
        } catch {
            errorMessage = "Failed to hit: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func lock() async {
        guard isMyTurn, var gameState = gameState, gameState.roundStatus == .playerTurns else {
            errorMessage = "Not your turn"
            return
        }
        
        guard myStatus == .active else {
            errorMessage = "You've already locked or busted"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Lock the player's hand
            gameState.playerStatuses[myUserId] = .locked
            myStatus = .locked
            
            // Move to next player
            if gameState.allPlayersFinished {
                gameState.roundStatus = .dealerTurn
            } else {
                advanceToNextActivePlayer(in: &gameState)
            }
            
            // Update game state
            try await onlineService.updateFlip21GameState(roomCode: roomCode, gameState: gameState)
            
        } catch {
            errorMessage = "Failed to lock: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Dealer Logic
    
    private func processDealerTurn() async {
        guard var gameState = gameState, gameState.roundStatus == .dealerTurn else {
            return
        }
        
        // Reveal dealer's face-down card
        if gameState.dealerHand.count >= 1 {
            gameState.dealerHand[0].isRevealed = true
        }
        
        // Dealer draws until reaching at least 17
        while gameState.dealerHand.calculateValue() < 17 {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay between draws
            
            if gameState.deck.isEmpty {
                reshuffleDeck(in: &gameState)
            }
            
            guard !gameState.deck.isEmpty else {
                break
            }
            
            var drawnCard = gameState.deck.removeFirst()
            drawnCard.isRevealed = true
            gameState.dealerHand.append(drawnCard)
            
            // Update after each draw
            try? await onlineService.updateFlip21GameState(roomCode: roomCode, gameState: gameState)
        }
        
        // Resolve round
        resolveRound(gameState: &gameState)
        
        // Update final state
        do {
            try await onlineService.updateFlip21GameState(roomCode: roomCode, gameState: gameState)
        } catch {
            errorMessage = "Failed to resolve round: \(error.localizedDescription)"
        }
    }
    
    private func resolveRound(gameState: inout Flip21GameState) {
        gameState.roundStatus = .resolving
        
        let dealerValue = gameState.dealerHand.calculateValue()
        let dealerBusted = gameState.dealerHand.isBusted()
        
        var roundResults: [String: RoundResult] = [:]
        
        for playerId in gameState.playerOrder {
            let hand = gameState.playerHands[playerId] ?? []
            let playerValue = hand.calculateValue()
            let playerBusted = hand.isBusted()
            let status = gameState.playerStatuses[playerId] ?? .active
            
            // Only evaluate locked players (busted players automatically lose)
            if status == .locked {
                if playerBusted {
                    roundResults[playerId] = .loss
                } else if dealerBusted {
                    roundResults[playerId] = .win
                    gameState.scores[playerId] = (gameState.scores[playerId] ?? 0) + 1
                } else if playerValue > dealerValue {
                    roundResults[playerId] = .win
                    gameState.scores[playerId] = (gameState.scores[playerId] ?? 0) + 1
                } else if playerValue == dealerValue {
                    roundResults[playerId] = .push
                } else {
                    roundResults[playerId] = .loss
                }
            } else if status == .busted {
                roundResults[playerId] = .loss
            }
        }
        
        gameState.roundResults = roundResults
        
        // Mark round as finished
        gameState.roundStatus = .finished
    }
    
    func startNextRound() async {
        guard var gameState = gameState, gameState.roundStatus == .finished,
              let roundResults = gameState.roundResults else {
            return
        }
        
        // Only winners can start next round (check if current user won)
        guard roundResults[myUserId] == .win else {
            errorMessage = "Only winners can advance to the next round"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Eliminate losers (and pushes - only winners advance)
            var eliminatedPlayers: Set<String> = []
            for (playerId, result) in roundResults {
                if result != .win {
                    eliminatedPlayers.insert(playerId)
                }
            }
            
            // Filter out eliminated players from player order
            gameState.playerOrder = gameState.playerOrder.filter { !eliminatedPlayers.contains($0) }
            
            // Check if game is over (only one or zero players left)
            guard gameState.playerOrder.count > 1 else {
                errorMessage = "Game Over - Winner!"
                isLoading = false
                return
            }
            
            // Reset for next round
            gameState.roundNumber += 1
            gameState.roundStatus = .dealing
            gameState.currentPlayerIndex = 0
            gameState.roundResults = nil
            
            // Clear hands for remaining players only
            gameState.dealerHand = []
            for playerId in gameState.playerOrder {
                gameState.playerHands[playerId] = []
                gameState.playerStatuses[playerId] = .active
            }
            
            // Deal initial cards
            dealInitialCards(to: &gameState)
            
            // Update game state
            try await onlineService.updateFlip21GameState(roomCode: roomCode, gameState: gameState)
            
        } catch {
            errorMessage = "Failed to start next round: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func didPlayerWinRound() -> Bool {
        guard let gameState = gameState, let roundResults = gameState.roundResults else {
            return false
        }
        return roundResults[myUserId] == .win
    }
    
    // MARK: - Helper Methods
    
    private func advanceToNextActivePlayer(in gameState: inout Flip21GameState) {
        let startIndex = gameState.currentPlayerIndex
        var attempts = 0
        
        repeat {
            gameState.advanceToNextPlayer()
            attempts += 1
            
            if let currentId = gameState.currentPlayerId {
                let status = gameState.playerStatuses[currentId] ?? .active
                if status == .active {
                    return // Found active player
                }
            }
        } while attempts < gameState.playerOrder.count && gameState.currentPlayerIndex != startIndex
    }
    
    private func dealInitialCards(to gameState: inout Flip21GameState) {
        // Ensure deck has enough cards
        if gameState.deck.count < (gameState.playerOrder.count * 1 + 1) {
            // Reshuffle if needed
            reshuffleDeck(in: &gameState)
        }
        
        // Deal 1 card to each player (revealed to themselves)
        for playerId in gameState.playerOrder {
            var hand: [Flip21Card] = []
            guard !gameState.deck.isEmpty else { break }
            var card = gameState.deck.removeFirst()
            card.isRevealed = true // Players can see their own cards
            hand.append(card)
            gameState.playerHands[playerId] = hand
            gameState.playerStatuses[playerId] = .active
        }
        
        // Deal 1 face-up card to dealer
        if !gameState.deck.isEmpty {
            var dealerCard = gameState.deck.removeFirst()
            dealerCard.isRevealed = true
            gameState.dealerHand = [dealerCard]
        }
        
        // Start player turns
        gameState.roundStatus = .playerTurns
    }
    
    private func reshuffleDeck(in gameState: inout Flip21GameState) {
        // Collect all cards from player hands and dealer hand (except keep one dealer card face-up)
        var allCards: [Flip21Card] = []
        
        for (_, hand) in gameState.playerHands {
            allCards.append(contentsOf: hand)
        }
        
        // Keep one dealer card visible, shuffle the rest
        if let firstDealerCard = gameState.dealerHand.first {
            allCards.append(contentsOf: gameState.dealerHand.dropFirst())
            gameState.dealerHand = [firstDealerCard]
        } else {
            allCards.append(contentsOf: gameState.dealerHand)
            gameState.dealerHand = []
        }
        
        allCards.append(contentsOf: gameState.deck)
        
        // Reset all cards to face-down and reshuffle
        for i in 0..<allCards.count {
            allCards[i].isRevealed = false
        }
        
        gameState.deck = allCards.shuffled()
    }
    
    func stopListening() {
        gameStateListener?.remove()
        gameStateListener = nil
        dealerTask?.cancel()
    }
}

