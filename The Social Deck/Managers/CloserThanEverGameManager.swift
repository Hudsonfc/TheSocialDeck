//
//  CloserThanEverGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import Foundation
import SwiftUI

class CloserThanEverGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var isFlipped: Bool = false
    @Published var isFinished: Bool = false
    
    // Check if shuffle is enabled in settings
    private var shouldShuffle: Bool {
        UserDefaults.standard.object(forKey: "shuffleCardsEnabled") as? Bool ?? true
    }
    
    init(deck: Deck, selectedCategories: [String], cardCount: Int = 0) {
        // If no categories selected, use all cards
        if selectedCategories.isEmpty {
            let allCards = shouldShuffle ? deck.cards.shuffled() : deck.cards
            if cardCount == 0 {
                self.cards = allCards
            } else {
                self.cards = Array(allCards.prefix(cardCount))
            }
            return
        }
        
        // Group cards by category and optionally shuffle each category
        var cardsByCategory: [String: [Card]] = [:]
        for category in selectedCategories {
            let categoryCards = deck.cards.filter { $0.category == category }
            cardsByCategory[category] = shouldShuffle ? categoryCards.shuffled() : categoryCards
        }
        
        // If cardCount is 0, use all available cards (equal from each category)
        if cardCount == 0 {
            // Find the minimum number of cards available in any selected category
            // This ensures we can take equal amounts from each category
            let cardsPerCategory = cardsByCategory.values.map { $0.count }.min() ?? 0
            
            var distributedCards: [Card] = []
            for category in selectedCategories {
                if let categoryCards = cardsByCategory[category] {
                    let cardsToTake = min(cardsPerCategory, categoryCards.count)
                    distributedCards.append(contentsOf: categoryCards.prefix(cardsToTake))
                }
            }
            self.cards = shouldShuffle ? distributedCards.shuffled() : distributedCards
            return
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
        
        // Optionally shuffle the final result to mix categories
        if shouldShuffle {
            distributedCards = distributedCards.shuffled()
        }
        
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

