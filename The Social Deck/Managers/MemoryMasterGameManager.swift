//
//  MemoryMasterGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI

struct MemoryCard: Identifiable {
    let id = UUID()
    let pairId: Int // Cards with same pairId are matches
    var isFlipped: Bool = false
    var isMatched: Bool = false
    var isFlipping: Bool = false // To prevent multiple flips during animation
}

class MemoryMasterGameManager: ObservableObject {
    @Published var cards: [MemoryCard] = []
    @Published var flippedCardIndices: [Int] = [] // Track currently flipped cards (max 2)
    @Published var isGameComplete: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var moves: Int = 0
    @Published var isPreviewPhase: Bool = true // Show all cards at start
    
    private var timer: Timer?
    private let difficulty: MemoryMasterDifficulty
    
    init(difficulty: MemoryMasterDifficulty) {
        self.difficulty = difficulty
        setupGame()
        // Small delay to ensure cards are set before preview starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.startPreviewPhase()
        }
    }
    
    private func setupGame() {
        let numberOfPairs = difficulty.numberOfPairs
        var cardPairs: [MemoryCard] = []
        
        // Create pairs
        for pairId in 0..<numberOfPairs {
            // Create two cards with the same pairId, start them flipped for preview
            var card1 = MemoryCard(pairId: pairId)
            card1.isFlipped = true
            var card2 = MemoryCard(pairId: pairId)
            card2.isFlipped = true
            cardPairs.append(card1)
            cardPairs.append(card2)
        }
        
        // Shuffle the cards before setting them
        let shuffledCards = cardPairs.shuffled()
        // Set cards all at once to prevent visual glitches
        cards = shuffledCards
    }
    
    private func startPreviewPhase() {
        // Cards are already flipped from setup, no need to flip them again
        
        // After 2 seconds, flip all cards back with animation and start the game
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Use a transaction to batch the state changes for smooth animation
            var transaction = Transaction(animation: .spring(response: 0.5, dampingFraction: 0.75))
            withTransaction(transaction) {
                for index in 0..<self.cards.count {
                    self.cards[index].isFlipped = false
                }
            }
            
            // End preview phase and start timer after flip animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isPreviewPhase = false
                self.startTimer()
            }
        }
    }
    
    func flipCard(at index: Int) {
        // Prevent flipping during preview phase
        guard !isPreviewPhase else {
            return
        }
        
        // Prevent flipping if:
        // - Card is already flipped or matched
        // - Card is currently animating
        // - We already have 2 cards flipped
        guard index < cards.count,
              !cards[index].isFlipped,
              !cards[index].isMatched,
              !cards[index].isFlipping,
              flippedCardIndices.count < 2 else {
            return
        }
        
        // Mark card as flipping to prevent double-taps
        cards[index].isFlipping = true
        
        // Flip the card
        cards[index].isFlipped = true
        flippedCardIndices.append(index)
        
        // If we now have 2 cards flipped, check for match
        if flippedCardIndices.count == 2 {
            moves += 1
            checkForMatch()
        }
    }
    
    private func checkForMatch() {
        let index1 = flippedCardIndices[0]
        let index2 = flippedCardIndices[1]
        
        if cards[index1].pairId == cards[index2].pairId {
            // Match found!
            // Keep cards flipped for a moment to show the match
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Mark as matched after showing the match
                self.cards[index1].isMatched = true
                self.cards[index2].isMatched = true
                self.cards[index1].isFlipping = false
                self.cards[index2].isFlipping = false
                
                // Clear flipped cards
                self.flippedCardIndices.removeAll()
                self.checkGameComplete()
            }
        } else {
            // No match - flip cards back after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + difficulty.flipBackDelay) {
                self.cards[index1].isFlipped = false
                self.cards[index2].isFlipped = false
                self.cards[index1].isFlipping = false
                self.cards[index2].isFlipping = false
                self.flippedCardIndices.removeAll()
            }
        }
    }
    
    private func checkGameComplete() {
        let allMatched = cards.allSatisfy { $0.isMatched }
        if allMatched {
            isGameComplete = true
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 0.1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
}

enum MemoryMasterDifficulty {
    case easy
    case medium
    case hard
    case expert
    
    var numberOfPairs: Int {
        switch self {
        case .easy: return 6 // 12 cards total
        case .medium: return 10 // 20 cards total
        case .hard: return 15 // 30 cards total
        case .expert: return 24 // 48 cards total
        }
    }
    
    var flipBackDelay: TimeInterval {
        switch self {
        case .easy: return 1.0
        case .medium: return 0.7
        case .hard: return 0.5
        case .expert: return 0.4
        }
    }
    
    var animationSpeed: Double {
        switch self {
        case .easy: return 0.5
        case .medium: return 0.3
        case .hard: return 0.2
        case .expert: return 0.15
        }
    }
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }
}

