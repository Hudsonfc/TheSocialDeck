//
//  NHIEGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI

class NHIEGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var isFlipped: Bool = false
    @Published var isFinished: Bool = false
    
    init(deck: Deck, selectedCategories: [String]) {
        // Filter cards by selected categories
        let filteredCards = deck.cards.filter { card in
            selectedCategories.contains(card.category)
        }
        
        // Shuffle the result
        self.cards = filteredCards.shuffled()
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

