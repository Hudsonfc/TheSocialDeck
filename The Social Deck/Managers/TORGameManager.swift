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
    
    init(deck: Deck, selectedCategories: [String]) {
        // Filter cards by selected categories
        let filteredCards = deck.cards.filter { card in
            selectedCategories.contains(card.category)
        }
        
        // Shuffle the result
        self.cards = filteredCards.shuffled()
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
            
            if let switchedCard = availableCards.randomElement() {
                // Find the index of the switched card and store it
                if let switchedIndex = cards.firstIndex(where: { $0.id == switchedCard.id }) {
                    switchedCardIndex = switchedIndex
                    currentIndex = switchedIndex
                    hasSeenType = true // We're switching to a new card, but it's part of the same decision
                    hasAccepted = false
                    isFlipped = true // Keep it flipped
                }
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

