//
//  SpillTheExGameManager.swift
//  The Social Deck
//

import Foundation
import SwiftUI

class SpillTheExGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var isFlipped: Bool = false
    @Published var isFinished: Bool = false

    private var shouldShuffle: Bool {
        UserDefaults.standard.object(forKey: "shuffleCardsEnabled") as? Bool ?? true
    }

    init(deck: Deck, selectedCategories: [String], cardCount: Int = 0) {
        if cardCount == 0 {
            let filteredCards = deck.cards.filter { selectedCategories.contains($0.category) }
            self.cards = shouldShuffle ? filteredCards.shuffled() : filteredCards
            return
        }

        var cardsByCategory: [String: [Card]] = [:]
        for category in selectedCategories {
            let categoryCards = deck.cards.filter { $0.category == category }
            cardsByCategory[category] = shouldShuffle ? categoryCards.shuffled() : categoryCards
        }

        let cardsPerCategory = (cardCount + selectedCategories.count - 1) / selectedCategories.count

        var distributedCards: [Card] = []
        for category in selectedCategories {
            if let categoryCards = cardsByCategory[category] {
                let cardsToTake = min(cardsPerCategory, categoryCards.count)
                distributedCards.append(contentsOf: categoryCards.prefix(cardsToTake))
            }
        }

        if shouldShuffle {
            distributedCards = distributedCards.shuffled()
        }

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
        if isFlipped { isFlipped = false }
        currentIndex += 1
        if currentIndex >= cards.count {
            isFinished = true
        }
    }

    func previousCard() {
        if currentIndex > 0 {
            if isFlipped { isFlipped = false }
            currentIndex -= 1
            isFinished = false
        }
    }

    var canGoBack: Bool {
        return currentIndex > 0
    }
}
