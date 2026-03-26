//
//  TORGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI

class TORGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var isFlipped: Bool = false
    @Published var isFinished: Bool = false
    @Published var hasSeenType: Bool = false
    @Published var hasAccepted: Bool = false
    
    // Track the original card and its paired opposite for switching
    private var originalCardIndex: Int = 0
    private var switchedCardIndex: Int? = nil
    
    init(deck: Deck, selectedCategories: [String], cardCount: Int = 0, deterministicRoomCode: String? = nil) {
        // If cardCount is 0, use all available cards
        if cardCount == 0 {
        let filteredCards = deck.cards.filter { card in
            selectedCategories.contains(card.category)
        }
            self.cards = shuffledCardsForOnlinePlay(filteredCards, deterministicRoomCode: deterministicRoomCode, useRandomShuffle: true)
            self.originalCardIndex = 0
            return
        }

        // Group cards by category and shuffle each category
        var cardsByCategory: [String: [Card]] = [:]
        for category in selectedCategories {
            let categoryCards = deck.cards.filter { $0.category == category }
            cardsByCategory[category] = shuffledCardsForOnlinePlay(categoryCards, deterministicRoomCode: deterministicRoomCode, useRandomShuffle: true)
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
        self.originalCardIndex = 0
    }
    
    func currentCard() -> Card? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    func flipCard() {
        isFlipped.toggle()
        if isFlipped {
            hasSeenType = true
            // When first flipping a card, set it as the original
            if switchedCardIndex == nil {
                originalCardIndex = currentIndex
            }
        }
    }
    
    func acceptCard() {
        hasAccepted = true
    }
    
    func switchToOppositeType() {
        guard let currentCard = currentCard(),
              let currentType = currentCard.cardType else { return }
        
        // If we're viewing the switched card, switch back to original
        if let switchedIndex = switchedCardIndex, currentIndex == switchedIndex {
            currentIndex = originalCardIndex
            hasSeenType = true // We've already seen this card
            hasAccepted = false
            isFlipped = true // Keep it flipped since we're switching between already-seen cards
            return
        }
        
        // If we're viewing the original, switch to the paired opposite
        if currentIndex == originalCardIndex {
            // If we already have a paired card, use it instead of finding a new one
            if let existingSwitchedIndex = switchedCardIndex {
                currentIndex = existingSwitchedIndex
                hasSeenType = true
                hasAccepted = false
                isFlipped = true
                return
            }
            
            // Otherwise, find and pair a new card of opposite type
            let currentCategory = currentCard.category
            let oppositeType: CardType = currentType == .truth ? .dare : .truth
            
            // Find a card of opposite type from the same category
            let availableCards = cards.filter { card in
                card.category == currentCategory && card.cardType == oppositeType
            }
            
            // Deterministic pick (first in deck order) so all devices agree in online play — never randomElement here.
            if let switchedIndex = cards.firstIndex(where: { $0.category == currentCategory && $0.cardType == oppositeType }) {
                switchedCardIndex = switchedIndex
                currentIndex = switchedIndex
                hasSeenType = true
                hasAccepted = false
                isFlipped = true
            }
        }
    }
    
    func nextCard() {
        if isFlipped {
            isFlipped = false
        }
        hasSeenType = false
        hasAccepted = false
        
        // Reset switching state for next card
        switchedCardIndex = nil
        
        // Always increment from originalCardIndex, not currentIndex (which might be a switched card)
        originalCardIndex += 1
        currentIndex = originalCardIndex
        
        if originalCardIndex >= cards.count {
            isFinished = true
        }
    }
    
    func previousCard() {
        if originalCardIndex > 0 {
            if isFlipped {
                isFlipped = false
            }
            hasSeenType = false
            hasAccepted = false
            
            // Reset switching state when going back
            switchedCardIndex = nil
            originalCardIndex -= 1
            currentIndex = originalCardIndex
            
            isFinished = false
        }
    }
    
    var canGoBack: Bool {
        return originalCardIndex > 0
    }
    
    // Game position for counter (based on original card, not current index which changes when switching)
    var gamePosition: Int {
        return originalCardIndex
    }
    
    /// Jump directly to a specific card index (used for online non-host sync).
    /// If index equals cards.count the host has finished, so mark this player finished too.
    func goToIndex(_ index: Int) {
        if index == cards.count {
            isFlipped = false
            hasSeenType = false
            hasAccepted = false
            switchedCardIndex = nil
            isFinished = true
            return
        }
        guard index >= 0 && index < cards.count else { return }
        isFlipped = false
        hasSeenType = false
        hasAccepted = false
        switchedCardIndex = nil
        originalCardIndex = index
        currentIndex = index
        isFinished = false
    }

    /// Apply Firestore snapshot for online Truth or Dare (game position, optional switched card index, flip, accept).
    func applyOnlineSyncState(gamePosition: Int, displayIndex: Int, isFlipped: Bool, hasAccepted: Bool) {
        if gamePosition >= cards.count {
            isFinished = true
            self.isFlipped = false
            hasSeenType = false
            self.hasAccepted = false
            switchedCardIndex = nil
            if !cards.isEmpty {
                originalCardIndex = cards.count - 1
                currentIndex = originalCardIndex
            }
            return
        }

        isFinished = false
        originalCardIndex = gamePosition
        currentIndex = displayIndex
        if displayIndex == gamePosition {
            switchedCardIndex = nil
        } else {
            switchedCardIndex = displayIndex
        }
        self.isFlipped = isFlipped
        self.hasAccepted = hasAccepted
        hasSeenType = isFlipped
    }

    var canSwitch: Bool {
        guard let currentCard = currentCard(),
              let currentType = currentCard.cardType else { return false }
        
        let currentCategory = currentCard.category
        let oppositeType: CardType = currentType == .truth ? .dare : .truth
        return cards.contains { card in
            card.category == currentCategory && card.cardType == oppositeType
        }
    }
}

