//
//  MLTGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI

class MLTGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var isFlipped: Bool = false
    @Published var isFinished: Bool = false
    
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
    
    func flipCard() {
        isFlipped.toggle()
    }
    
    func nextCard() {
        if isFlipped {
            isFlipped = false
        }
        
        currentIndex += 1
        
        if currentIndex >= cards.count {
            isFinished = true
        }
    }
    
    func previousCard() {
        if currentIndex > 0 {
            if isFlipped {
                isFlipped = false
            }
            
            currentIndex -= 1
            isFinished = false
        }
    }
    
    var canGoBack: Bool {
        return currentIndex > 0
    }
}

