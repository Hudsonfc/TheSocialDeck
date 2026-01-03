//
//  CategoryClashGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI

class CategoryClashGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var isFinished: Bool = false
    @Published var currentRound: Int = 1
    @Published var timerEnabled: Bool = false
    @Published var timerDuration: Int = 30
    @Published var timeRemaining: Double = 30.0
    @Published var isTimerExpired: Bool = false
    
    private var timer: Timer?
    
    init(deck: Deck, selectedCategories: [String], cardCount: Int = 0, timerEnabled: Bool = false, timerDuration: Int = 30) {
        self.timerEnabled = timerEnabled
        self.timerDuration = timerDuration
        self.timeRemaining = Double(timerDuration)
        // If cardCount is 0, use all available cards
        if cardCount == 0 {
            let filteredCards = deck.cards.filter { card in
                selectedCategories.contains(card.category)
            }
            self.cards = filteredCards.shuffled()
            return
        }
        
        // Group cards by category and shuffle each category
        var cardsByCategory: [String: [Card]] = [:]
        for category in selectedCategories {
            let categoryCards = deck.cards.filter { $0.category == category }
            cardsByCategory[category] = categoryCards.shuffled()
        }
        
        // Calculate how many cards per category (round up to ensure we have enough)
        let cardsPerCategory = (cardCount + selectedCategories.count - 1) / selectedCategories.count
        
        // Take equal number of cards from each selected category
        var distributedCards: [Card] = []
        for category in selectedCategories {
            if let categoryCards = cardsByCategory[category] {
                let cardsToTake = min(cardsPerCategory, categoryCards.count)
                distributedCards.append(contentsOf: categoryCards.prefix(cardsToTake))
            }
        }
        
        // Shuffle the final result to mix categories
        distributedCards = distributedCards.shuffled()
        
        // Trim to exact cardCount if we have more than requested
        if distributedCards.count > cardCount {
            self.cards = Array(distributedCards.prefix(cardCount))
        } else {
            self.cards = distributedCards
        }
    }
    
    func currentCard() -> Card? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    func nextCategory() {
        currentIndex += 1
        
        if currentIndex >= cards.count {
            isFinished = true
        }
        
        // Update round based on current index
        currentRound = (currentIndex / 5) + 1
    }
    
    func previousCategory() {
        if currentIndex > 0 {
            currentIndex -= 1
            isFinished = false
            
            // Update round based on current index
            currentRound = (currentIndex / 5) + 1
        }
    }
    
    var canGoBack: Bool {
        return currentIndex > 0
    }
    
    var gamePosition: Int {
        return currentIndex
    }
    
    // Calculate suggested time limit based on round (gets faster each round)
    var suggestedTimeLimit: Int {
        // Start with 30 seconds, reduce by 5 seconds each round
        // Round 1 (index 0-4): 30s, Round 2 (index 5-9): 25s, Round 3 (index 10-14): 20s, etc.
        return max(10, 30 - (currentRound - 1) * 5)
    }
    
    // Timer methods
    func startTimer() {
        guard timerEnabled else { return }
        
        timeRemaining = Double(timerDuration)
        isTimerExpired = false
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.timeRemaining -= 0.1
            
            if self.timeRemaining <= 0 {
                self.timeRemaining = 0
                self.isTimerExpired = true
                timer.invalidate()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        timeRemaining = Double(timerDuration)
        isTimerExpired = false
    }
    
    deinit {
        timer?.invalidate()
    }
}

