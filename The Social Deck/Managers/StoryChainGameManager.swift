//
//  StoryChainGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI

// Structure to track story sentences with their authors
struct StorySentence: Identifiable {
    let id = UUID()
    let text: String
    let author: String? // nil for starting sentence
}

class StoryChainGameManager: ObservableObject {
    @Published var players: [String] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var startingSentence: String = ""
    @Published var storySentences: [StorySentence] = [] // Array of sentences with authors
    @Published var isFinished: Bool = false
    @Published var currentSentence: String = "" // Current player's input
    
    init(deck: Deck, players: [String]) {
        // Ensure we have at least one player
        self.players = players.isEmpty ? ["Player 1"] : players
        // Get a random starting sentence
        if let randomCard = deck.cards.randomElement() {
            self.startingSentence = randomCard.text
        } else {
            self.startingSentence = "Once upon a time, something strange happened."
        }
        // Initialize story with starting sentence (no author)
        self.storySentences = [StorySentence(text: startingSentence, author: nil)]
    }
    
    var currentPlayer: String {
        guard currentPlayerIndex < players.count else { return "" }
        return players[currentPlayerIndex]
    }
    
    var isLastPlayer: Bool {
        return currentPlayerIndex >= players.count - 1
    }
    
    func submitSentence() {
        guard !currentSentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedSentence = currentSentence.trimmingCharacters(in: .whitespacesAndNewlines)
        let playerName = currentPlayer
        
        // Add the sentence to the story with the player's name
        storySentences.append(StorySentence(text: trimmedSentence, author: playerName))
        
        // Clear the input
        currentSentence = ""
        
        // Move to next player
        currentPlayerIndex += 1
        
        // Check if all players have gone
        if currentPlayerIndex >= players.count {
            isFinished = true
        }
    }
    
    var fullStory: String {
        return storySentences.map { $0.text }.joined(separator: " ")
    }
}

