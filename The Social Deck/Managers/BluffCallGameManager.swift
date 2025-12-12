//
//  BluffCallGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI

class BluffCallGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var players: [String] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var isFinished: Bool = false
    
    // Game state
    @Published var gamePhase: GamePhase = .playerTurn
    @Published var playerAnswer: String? = nil // "A", "B", or "Yes"/"No" for questions
    @Published var groupDecision: GroupDecision? = nil // .believe or .callBluff
    @Published var revealedAnswer: String? = nil // The actual answer
    @Published var playerVotes: [String: GroupDecision] = [:] // Individual player votes when 3+ players
    
    enum GamePhase {
        case playerTurn // Player sees prompt, chooses answer, and convinces group
        case groupDeciding // Group is deciding whether to believe or call bluff
        case reveal // Revealing the truth and consequences
        case passingPhone // Passing to next player
    }
    
    enum GroupDecision {
        case believe
        case callBluff
    }
    
    init(deck: Deck, selectedCategories: [String], cardCount: Int = 0, players: [String] = []) {
        // Initialize players - if empty, use default
        if players.isEmpty {
            self.players = ["Player 1", "Player 2", "Player 3", "Player 4"]
        } else {
            self.players = players
        }
        
        // Filter and shuffle cards
        if cardCount == 0 {
            let filteredCards = deck.cards.filter { card in
                selectedCategories.contains(card.category)
            }
            self.cards = filteredCards.shuffled()
        } else {
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
        
        // Start with passingPhone phase for the first player
        gamePhase = .passingPhone
        currentPlayerIndex = 0
        currentIndex = 0
    }
    
    var currentCard: Card? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    var currentPlayer: String {
        guard currentPlayerIndex < players.count else { return "" }
        return players[currentPlayerIndex]
    }
    
    var isLastCard: Bool {
        return currentIndex >= cards.count - 1
    }
    
    var isLastPlayer: Bool {
        return currentPlayerIndex >= players.count - 1
    }
    
    func startRound() {
        gamePhase = .playerTurn
        playerAnswer = nil
        groupDecision = nil
        revealedAnswer = nil
        playerVotes = [:] // Reset individual votes
    }
    
    func playerChoseAnswer(_ answer: String) {
        playerAnswer = answer
        // Stay in playerTurn phase - player can convince verbally, then tap continue
    }
    
    func finishPlayerTurn() {
        gamePhase = .groupDeciding
    }
    
    func groupMadeDecision(_ decision: GroupDecision) {
        groupDecision = decision
        // Determine the actual answer
        determineActualAnswer()
        gamePhase = .reveal
    }
    
    // Individual voting methods for 3+ players
    var votingPlayers: [String] {
        // All players except the current player
        return players.filter { $0 != currentPlayer }
    }
    
    var allPlayersVoted: Bool {
        // Check if all voting players have voted
        return votingPlayers.allSatisfy { playerVotes[$0] != nil }
    }
    
    func playerVoted(_ player: String, decision: GroupDecision) {
        playerVotes[player] = decision
        
        // If all players have voted, determine group decision by majority
        if allPlayersVoted {
            determineGroupDecisionFromVotes()
        }
    }
    
    func getPlayerVote(_ player: String) -> GroupDecision? {
        return playerVotes[player]
    }
    
    private func determineGroupDecisionFromVotes() {
        // Count votes
        var believeCount = 0
        var callBluffCount = 0
        
        for player in votingPlayers {
            if let vote = playerVotes[player] {
                if vote == .believe {
                    believeCount += 1
                } else {
                    callBluffCount += 1
                }
            }
        }
        
        // Majority wins (if tie, default to callBluff)
        let finalDecision: GroupDecision = believeCount > callBluffCount ? .believe : .callBluff
        groupMadeDecision(finalDecision)
    }
    
    private func determineActualAnswer() {
        guard let card = currentCard else { return }
        
        // For two-option cards, randomly determine the "truth"
        // For question cards, randomly determine Yes/No
        if let optionA = card.optionA, let optionB = card.optionB {
            // Two-option card - randomly pick one as "truth"
            revealedAnswer = Bool.random() ? "A" : "B"
        } else {
            // Question card - randomly determine I have/I haven't
            revealedAnswer = Bool.random() ? "I have" : "I haven't"
        }
    }
    
    func passToNextPlayer() {
        // Each player gets a different card, so move to next card
        currentIndex += 1
        
        // Check if we've run out of cards
        if currentIndex >= cards.count {
            isFinished = true
            return
        }
        
        // Move to next player (cycle through players)
        if isLastPlayer {
            // Reset to first player for next card
            currentPlayerIndex = 0
        } else {
            // Move to next player
            currentPlayerIndex += 1
        }
        
        gamePhase = .passingPhone
    }
    
    func getConsequenceText() -> String {
        guard let card = currentCard,
              let playerAnswer = playerAnswer,
              let groupDecision = groupDecision,
              let revealedAnswer = revealedAnswer else {
            return ""
        }
        
        // Check if player was telling the truth
        let playerToldTruth = (playerAnswer == revealedAnswer)
        
        if groupDecision == .callBluff {
            if playerToldTruth {
                // Group called bluff but player was telling truth
                return "\(currentPlayer) was telling the truth! Everyone who called the bluff drinks!"
            } else {
                // Group correctly called the bluff
                return "You caught \(currentPlayer) in a lie! \(currentPlayer) drinks extra!"
            }
        } else {
            // Group believed
            if playerToldTruth {
                // Player was telling truth, group believed correctly
                return "\(currentPlayer) was telling the truth and you believed them! No one drinks."
            } else {
                // Player was lying, group believed incorrectly
                return "\(currentPlayer) was lying and you believed them! Everyone who believed drinks!"
            }
        }
    }
    
    func getWhoDrinks() -> String {
        guard let card = currentCard,
              let playerAnswer = playerAnswer,
              let groupDecision = groupDecision,
              let revealedAnswer = revealedAnswer else {
            return ""
        }
        
        let playerToldTruth = (playerAnswer == revealedAnswer)
        
        if groupDecision == .callBluff {
            if playerToldTruth {
                return "Everyone drinks (except \(currentPlayer))"
            } else {
                return "\(currentPlayer) drinks extra"
            }
        } else {
            if playerToldTruth {
                return "No one drinks"
            } else {
                return "Everyone drinks (except \(currentPlayer))"
            }
        }
    }
    
    func didGroupGuessCorrectly() -> Bool? {
        guard let playerAnswer = playerAnswer,
              let groupDecision = groupDecision,
              let revealedAnswer = revealedAnswer else {
            return nil
        }
        
        let playerToldTruth = (playerAnswer == revealedAnswer)
        
        if groupDecision == .callBluff {
            // Group guessed correctly if they called bluff and player was lying
            return !playerToldTruth
        } else {
            // Group guessed correctly if they believed and player was telling truth
            return playerToldTruth
        }
    }
    
    // Get players who guessed wrong (for 3+ player games)
    func getPlayersWhoGuessedWrong() -> [String] {
        guard let playerAnswer = playerAnswer,
              let revealedAnswer = revealedAnswer else {
            return []
        }
        
        let playerToldTruth = (playerAnswer == revealedAnswer)
        var wrongPlayers: [String] = []
        
        for player in votingPlayers {
            if let vote = playerVotes[player] {
                // Player guessed wrong if:
                // - They called bluff but player was telling truth
                // - They believed but player was lying
                let guessedWrong = (vote == .callBluff && playerToldTruth) || (vote == .believe && !playerToldTruth)
                if guessedWrong {
                    wrongPlayers.append(player)
                }
            }
        }
        
        return wrongPlayers
    }
    
    // Check if a specific player guessed correctly
    func didPlayerGuessCorrectly(_ player: String) -> Bool? {
        guard let playerAnswer = playerAnswer,
              let revealedAnswer = revealedAnswer,
              let vote = playerVotes[player] else {
            return nil
        }
        
        let playerToldTruth = (playerAnswer == revealedAnswer)
        
        if vote == .callBluff {
            // Player guessed correctly if they called bluff and current player was lying
            return !playerToldTruth
        } else {
            // Player guessed correctly if they believed and current player was telling truth
            return playerToldTruth
        }
    }
    
    // Get formatted player's claimed answer
    func getPlayerClaimedAnswer() -> String {
        guard let card = currentCard,
              let playerAnswer = playerAnswer else {
            return ""
        }
        
        if let optionA = card.optionA, let optionB = card.optionB {
            // Two-option card
            return playerAnswer == "A" ? optionA : optionB
        } else {
            // Question card - show question with answer
            return "\(card.text) - \(playerAnswer)"
        }
    }
}

