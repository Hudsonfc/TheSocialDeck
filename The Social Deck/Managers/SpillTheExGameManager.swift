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

    init(deck: Deck, selectedCategories: [String], cardCount: Int = 0, deterministicRoomCode: String? = nil) {
        if cardCount == 0 {
            let filteredCards = deck.cards.filter { selectedCategories.contains($0.category) }
            self.cards = shuffledCardsForOnlinePlay(filteredCards, deterministicRoomCode: deterministicRoomCode, useRandomShuffle: shouldShuffle)
            return
        }

        var cardsByCategory: [String: [Card]] = [:]
        for category in selectedCategories {
            let categoryCards = deck.cards.filter { $0.category == category }
            cardsByCategory[category] = shuffledCardsForOnlinePlay(categoryCards, deterministicRoomCode: deterministicRoomCode, useRandomShuffle: shouldShuffle)
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
            distributedCards = shuffledCardsForOnlinePlay(distributedCards, deterministicRoomCode: deterministicRoomCode, useRandomShuffle: true)
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

    // Used by online non-hosts to jump to the host's current card index.
    // Mirrors the classic games behavior where `index == cards.count` represents "finished".
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

    var canGoBack: Bool {
        return currentIndex > 0
    }
}
