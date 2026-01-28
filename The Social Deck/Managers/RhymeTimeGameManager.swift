//
//  RhymeTimeGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI

class RhymeTimeGameManager: ObservableObject {
    @Published var players: [String] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var isGameActive: Bool = false
    @Published var timerExpired: Bool = false
    @Published var roundNumber: Int = 1
    @Published var loser: String? = nil
    @Published var baseWord: String = ""
    @Published var usedRhymes: [String] = []
    @Published var timeRemaining: Double = 0.0
    @Published var roundComplete: Bool = false
    
    private var timer: Timer?
    private var turnDuration: TimeInterval = 10.0 // Default 10 seconds per turn
    private var cards: [Card] = []
    private var currentCardIndex: Int = 0
    
    enum GamePhase {
        case waitingToStart // Before round starts
        case active // Timer is running, player must say a rhyme
        case roundComplete // Round completed successfully
        case expired // Timer expired or player lost
    }
    
    @Published var gamePhase: GamePhase = .waitingToStart
    
    init(deck: Deck, players: [String], timerDuration: Int = 10) {
        // Randomize player order
        if players.isEmpty {
            self.players = ["Player 1"]
        } else {
            self.players = players.shuffled()
        }
        
        // Set timer duration
        self.turnDuration = TimeInterval(timerDuration)
        
        // Get cards from deck
        self.cards = deck.cards.isEmpty ? [] : deck.cards.shuffled()
    }
    
    var currentPlayer: String {
        guard currentPlayerIndex < players.count else { return "" }
        return players[currentPlayerIndex]
    }
    
    func startRound() {
        // Reset state
        timerExpired = false
        loser = nil
        gamePhase = .active
        isGameActive = true
        usedRhymes = []
        roundComplete = false
        currentPlayerIndex = 0
        
        // Get new base word
        if cards.isEmpty {
            // Fallback if no cards available
            baseWord = "cat"
        } else if currentCardIndex < cards.count {
            baseWord = cards[currentCardIndex].text
            currentCardIndex += 1
        } else {
            // Reuse cards if we run out
            currentCardIndex = 0
            cards = cards.shuffled()
            baseWord = cards[currentCardIndex].text
            currentCardIndex += 1
        }
        
        // Start timer for first player
        startTurnTimer()
    }
    
    private func startTurnTimer() {
        timeRemaining = turnDuration
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.timeRemaining -= 0.1
            
            if self.timeRemaining <= 0 {
                self.handleTimerExpired()
                timer.invalidate()
            }
        }
    }
    
    func submitRhyme() {
        guard isGameActive && !timerExpired, !players.isEmpty else { return }
        
        // Player confirmed they said a rhyme out loud
        // Note: We can't validate the actual word, so we rely on group honesty
        // The app tracks that a player responded, but can't check if it actually rhymed
        
        // Move to next player
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        
        // If we've gone through all players, round is complete
        if currentPlayerIndex == 0 {
            // All players completed the round
            completeRound()
        } else {
            // Continue to next player - restart timer
            startTurnTimer()
        }
    }
    
    // Method to add a used rhyme and check for duplicates
    func addUsedRhyme(_ rhyme: String) {
        let trimmedRhyme = rhyme.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if rhyme was already used
        if usedRhymes.contains(trimmedRhyme) {
            // Player repeated a rhyme - they lose
            handlePlayerLost(reason: "repeated rhyme")
            return
        }
        
        // Add to used rhymes
        usedRhymes.append(trimmedRhyme)
    }
    
    func passWithoutRhyme() {
        // Player passes without saying a rhyme - they lose
        handlePlayerLost(reason: "no rhyme")
    }
    
    private func handleTimerExpired() {
        timer?.invalidate()
        timer = nil
        timerExpired = true
        isGameActive = false
        loser = currentPlayer
        gamePhase = .expired
    }
    
    private func handlePlayerLost(reason: String) {
        timer?.invalidate()
        timer = nil
        timerExpired = true
        isGameActive = false
        loser = currentPlayer
        gamePhase = .expired
    }
    
    private func completeRound() {
        timer?.invalidate()
        timer = nil
        roundComplete = true
        gamePhase = .roundComplete
        isGameActive = false
    }
    
    func nextRound() {
        roundNumber += 1
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count // Start with next player
        gamePhase = .waitingToStart
        roundComplete = false
    }
    
    func resetGame() {
        roundNumber = 1
        currentPlayerIndex = 0
        gamePhase = .waitingToStart
        timerExpired = false
        loser = nil
        usedRhymes = []
        roundComplete = false
        timer?.invalidate()
        timer = nil
        currentCardIndex = 0
    }
    
    deinit {
        timer?.invalidate()
    }
}

