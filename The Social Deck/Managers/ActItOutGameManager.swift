//
//  ActItOutGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 12/31/24.
//

import Foundation
import SwiftUI

class ActItOutGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentCardIndex: Int = 0
    @Published var roundNumber: Int = 1
    @Published var isFlipped: Bool = false
    @Published var isFinished: Bool = false
    @Published var hasRevealed: Bool = false
    @Published var skipsRemaining: Int = 3
    
    // Timer properties
    @Published var timerEnabled: Bool = false
    @Published var timerDuration: Int = 60
    @Published var timeRemaining: Int = 60
    @Published var isTimerRunning: Bool = false
    
    private var timer: Timer?
    
    // Players
    @Published var players: [String] = []
    @Published var currentPlayerIndex: Int = 0
    
    var canGoBack: Bool {
        return currentCardIndex > 0
    }
    
    var currentPlayer: String {
        guard currentPlayerIndex < players.count else { return "" }
        return players[currentPlayerIndex]
    }
    
    init(deck: Deck, selectedCategories: [String], players: [String], cardCount: Int, timerEnabled: Bool, timerDuration: Int) {
        // Default to 2 players if none provided
        self.players = players.isEmpty ? ["Player 1", "Player 2"] : players.shuffled()
        self.timerEnabled = timerEnabled
        self.timerDuration = timerDuration
        self.timeRemaining = timerDuration
        
        // Filter cards by selected categories
        var filteredCards: [Card] = []
        for category in selectedCategories {
            let categoryCards = deck.cards.filter { $0.category == category }
            filteredCards.append(contentsOf: categoryCards)
        }
        
        // Shuffle and limit to cardCount
        filteredCards.shuffle()
        if cardCount > 0 && cardCount < filteredCards.count {
            self.cards = Array(filteredCards.prefix(cardCount))
        } else {
            self.cards = filteredCards
        }
    }
    
    func currentCard() -> Card? {
        guard currentCardIndex < cards.count else { return nil }
        return cards[currentCardIndex]
    }
    
    func flipCard() {
        isFlipped.toggle()
        if isFlipped && timerEnabled {
            startTimer()
        }
    }
    
    func revealAnswer() {
        hasRevealed = true
        stopTimer()
    }
    
    func skipCard() {
        guard skipsRemaining > 0 else { return }
        skipsRemaining -= 1
        stopTimer()
        nextCard()
    }
    
    func markCorrect() {
        stopTimer()
        hasRevealed = true
    }
    
    func nextCard() {
        stopTimer()
        
        if currentCardIndex < cards.count - 1 {
            currentCardIndex += 1
            roundNumber += 1
            isFlipped = false
            hasRevealed = false
            timeRemaining = timerDuration
            
            // Move to next player
            currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        } else {
            isFinished = true
        }
    }
    
    func previousCard() {
        stopTimer()
        
        if currentCardIndex > 0 {
            currentCardIndex -= 1
            roundNumber -= 1
            isFlipped = false
            hasRevealed = false
            timeRemaining = timerDuration
            
            // Move to previous player
            currentPlayerIndex = (currentPlayerIndex - 1 + players.count) % players.count
        }
    }
    
    // MARK: - Timer Functions
    
    private func startTimer() {
        guard timerEnabled else { return }
        isTimerRunning = true
        timeRemaining = timerDuration
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                self.revealAnswer()
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
}

