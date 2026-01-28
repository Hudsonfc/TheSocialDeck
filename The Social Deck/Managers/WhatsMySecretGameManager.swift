//
//  WhatsMySecretGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI
import UIKit

class WhatsMySecretGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var players: [String] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var roundNumber: Int = 1
    @Published var currentCardIndex: Int = 0
    @Published var timeRemaining: Double = 0.0
    @Published var groupGuessedCorrectly: Bool? = nil
    @Published var isFinished: Bool = false
    @Published var isCardFlipped: Bool = false
    @Published var groupWins: Int = 0
    @Published var secretPlayerWins: Int = 0
    @Published var isTimerPaused: Bool = false
    
    private var timer: Timer?
    private var pausedTimeRemaining: TimeInterval = 0
    private var roundDuration: TimeInterval = 120.0 // 2 minutes per round (configurable)
    
    enum GamePhase {
        case playersTurn // Show "Player's Turn" screen
        case showingSecret // Secret player views their secret (card back shown, can flip)
        case timerRunning // Timer running, group interacts
        case guessing // Group makes final guess
        case result // Showing result
    }
    
    @Published var gamePhase: GamePhase = .playersTurn
    
    init(deck: Deck, selectedCategories: [String], cardCount: Int, players: [String], timerDuration: TimeInterval = 120.0) {
        // Initialize players - randomize order
        if players.isEmpty {
            self.players = ["Player 1"]
        } else {
            self.players = players.shuffled()
        }
        
        // Set timer duration
        self.roundDuration = timerDuration
        
        // Get cards - use all categories (combine all)
        let categoriesToUse = selectedCategories.isEmpty ? deck.availableCategories : selectedCategories
        
        if cardCount == 0 {
            let filteredCards = deck.cards.filter { card in
                categoriesToUse.contains(card.category)
            }
            self.cards = filteredCards.shuffled()
        } else {
            // Group cards by category and shuffle each category
            var cardsByCategory: [String: [Card]] = [:]
            for category in categoriesToUse {
                let categoryCards = deck.cards.filter { $0.category == category }
                cardsByCategory[category] = categoryCards.shuffled()
            }
            
            // Calculate how many cards per category
            let cardsPerCategory = (cardCount + categoriesToUse.count - 1) / categoriesToUse.count
            
            // Take equal number of cards from each selected category
            var distributedCards: [Card] = []
            for category in categoriesToUse {
                if let categoryCards = cardsByCategory[category] {
                    let cardsToTake = min(cardsPerCategory, categoryCards.count)
                    distributedCards.append(contentsOf: categoryCards.prefix(cardsToTake))
                }
            }
            
            // Shuffle the final result
            distributedCards = distributedCards.shuffled()
            
            // Trim to exact cardCount if needed
            if distributedCards.count > cardCount {
                self.cards = Array(distributedCards.prefix(cardCount))
            } else {
                self.cards = distributedCards
            }
        }
        
        // Start the first round
        if !self.cards.isEmpty {
            startRound()
        }
    }
    
    var currentPlayer: String {
        guard currentPlayerIndex < players.count else { return "" }
        return players[currentPlayerIndex]
    }
    
    var currentSecret: String? {
        guard currentCardIndex < cards.count else { return nil }
        return cards[currentCardIndex].text
    }
    
    func startRound() {
        // Check if we have cards left
        guard currentCardIndex < cards.count else {
            isFinished = true
            return
        }
        
        gamePhase = .playersTurn
        timeRemaining = roundDuration
        groupGuessedCorrectly = nil
        isCardFlipped = false
    }
    
    func proceedToSecret() {
        // Move from "Player's Turn" to showing secret card
        gamePhase = .showingSecret
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func flipCard() {
        isCardFlipped.toggle()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func secretViewed() {
        // Move to timer phase (after player has seen the secret)
        gamePhase = .timerRunning
        isTimerPaused = false
        startTimer()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func viewSecretAgain() {
        // Pause timer and switch to showing secret
        pauseTimer()
        isCardFlipped = true // Ensure card shows secret
        gamePhase = .showingSecret
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func resumeTimer() {
        // Resume from showing secret back to timer
        gamePhase = .timerRunning
        isTimerPaused = false
        resumeTimerFromPause()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func pauseTimer() {
        isTimerPaused = true
        pausedTimeRemaining = timeRemaining
        timer?.invalidate()
        timer = nil
    }
    
    private func resumeTimerFromPause() {
        timeRemaining = pausedTimeRemaining
        startTimer()
    }
    
    private var lastSecondForHaptic: Int = 0
    
    private func startTimer() {
        timer?.invalidate()
        lastSecondForHaptic = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, !self.isTimerPaused else {
                return
            }
            
            self.timeRemaining -= 0.1
            
            // Haptic feedback when timer is low (last 30 seconds, once per second)
            if self.timeRemaining <= 30 && self.timeRemaining > 0 {
                let currentSecond = Int(self.timeRemaining)
                if currentSecond != self.lastSecondForHaptic {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    self.lastSecondForHaptic = currentSecond
                }
            }
            
            if self.timeRemaining <= 0 {
                self.handleTimerExpired()
                timer.invalidate()
            }
        }
    }
    
    func skipTimer() {
        // Allow skipping timer if needed (for testing or if group is ready)
        timer?.invalidate()
        timeRemaining = 0
        handleTimerExpired()
    }
    
    private func handleTimerExpired() {
        timer?.invalidate()
        timer = nil
        gamePhase = .guessing
    }
    
    func submitGuess(wasCorrect: Bool) {
        groupGuessedCorrectly = wasCorrect
        gamePhase = .result
        
        // Update score tracking
        if wasCorrect {
            groupWins += 1
        } else {
            secretPlayerWins += 1
        }
        
        // Haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(wasCorrect ? .success : .error)
    }
    
    func nextRound() {
        // Move to next card
        currentCardIndex += 1
        
        // Move to next player (rotate)
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        
        // Check if game is finished
        if currentCardIndex >= cards.count {
            isFinished = true
            return
        }
        
        roundNumber += 1
        gamePhase = .playersTurn
        timeRemaining = roundDuration
        groupGuessedCorrectly = nil
        isCardFlipped = false
    }
    
    var canGoBack: Bool {
        return currentCardIndex > 0
    }
    
    func previousRound() {
        guard canGoBack, !players.isEmpty else { return }
        
        // Move to previous card
        currentCardIndex -= 1
        
        // Move to previous player (rotate backwards)
        if currentPlayerIndex == 0 {
            currentPlayerIndex = players.count - 1
        } else {
            currentPlayerIndex -= 1
        }
        
        roundNumber = max(1, roundNumber - 1)
        gamePhase = .playersTurn
        timeRemaining = roundDuration
        groupGuessedCorrectly = nil
        isCardFlipped = false
        
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }
}
