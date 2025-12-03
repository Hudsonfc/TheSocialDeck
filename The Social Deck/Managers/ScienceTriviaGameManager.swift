//
//  ScienceTriviaGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI

class ScienceTriviaGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var isFinished: Bool = false
    @Published var score: Int = 0
    @Published var selectedAnswer: String? = nil
    @Published var showAnswer: Bool = false
    @Published var userAnswers: [Int: String] = [:] // Track answers by card index
    @Published var correctAnswers: [Int: Bool] = [:] // Track if user got it right
    
    init(deck: Deck, selectedCategories: [String], cardCount: Int = 0) {
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
    
    func selectAnswer(_ answer: String) {
        guard !showAnswer, let card = currentCard() else { return }
        
        selectedAnswer = answer
        showAnswer = true
        userAnswers[currentIndex] = answer
        
        // Check if answer is correct
        if answer == card.correctAnswer {
            score += 1
            correctAnswers[currentIndex] = true
        } else {
            correctAnswers[currentIndex] = false
        }
    }
    
    func nextCard() {
        // Reset for next card
        selectedAnswer = nil
        showAnswer = false
        
        currentIndex += 1
        
        // Load previous answer if user is revisiting
        if let previousAnswer = userAnswers[currentIndex] {
            selectedAnswer = previousAnswer
            showAnswer = true
        }
        
        if currentIndex >= cards.count {
            isFinished = true
        }
    }
    
    func previousCard() {
        if currentIndex > 0 {
            // Reset current state
            selectedAnswer = nil
            showAnswer = false
            
            currentIndex -= 1
            isFinished = false
            
            // Load previous answer if exists
            if let previousAnswer = userAnswers[currentIndex] {
                selectedAnswer = previousAnswer
                showAnswer = true
            }
        }
    }
    
    var canGoBack: Bool {
        return currentIndex > 0
    }
    
    var isAnswerCorrect: Bool {
        guard let card = currentCard(), let selected = selectedAnswer else { return false }
        return selected == card.correctAnswer
    }
    
    var hasAnswered: Bool {
        return userAnswers[currentIndex] != nil
    }
}

