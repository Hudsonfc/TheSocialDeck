//
//  WYRGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI

class WYRGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var isFlipped: Bool = false
    @Published var isFinished: Bool = false
    
    init(deck: Deck, selectedCategories: [String], cardCount: Int = 0, deterministicRoomCode: String? = nil) {
        // Group cards by category and shuffle each category
        var cardsByCategory: [String: [Card]] = [:]
        for category in selectedCategories {
            let categoryCards = deck.cards.filter { $0.category == category }
            cardsByCategory[category] = shuffledCardsForOnlinePlay(categoryCards, deterministicRoomCode: deterministicRoomCode, useRandomShuffle: true)
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
            self.cards = shuffledCardsForOnlinePlay(distributedCards, deterministicRoomCode: deterministicRoomCode, useRandomShuffle: true)
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
        
        // Shuffle the final result to mix categories
        distributedCards = shuffledCardsForOnlinePlay(distributedCards, deterministicRoomCode: deterministicRoomCode, useRandomShuffle: true)
        
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

    /// Jump directly to a specific card index (used for online non-host sync).
    /// If index equals cards.count the host has finished, so mark this player finished too.
    func goToIndex(_ index: Int) {
        if index == cards.count {
            isFlipped = false
            isFinished = true
            return
        }
        guard index >= 0 && index < cards.count else { return }
        isFlipped = false
        currentIndex = index
        isFinished = false
    }

    /// Apply Firestore snapshot for online Would You Rather (index + face up/down).
    func applyOnlineSyncState(cardIndex: Int, isFlipped flipped: Bool) {
        if cardIndex >= cards.count {
            isFlipped = false
            isFinished = true
            return
        }
        currentIndex = cardIndex
        isFinished = false
        isFlipped = flipped
    }
}

