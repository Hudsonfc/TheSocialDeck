//
//  ActNaturalGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import Foundation
import SwiftUI

struct ActNaturalPlayer: Identifiable {
    let id = UUID()
    let name: String
    var isUnknown: Bool = false
    var hasViewed: Bool = false
}

class ActNaturalGameManager: ObservableObject {
    @Published var players: [ActNaturalPlayer] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var secretWord: ActNaturalWord?
    @Published var gamePhase: ActNaturalPhase = .setup
    @Published var unknownCount: Int = 1
    @Published var timerDuration: Int? = nil // nil means no timer, otherwise seconds
    @Published var timeRemaining: Int = 0
    var timer: Timer?
    
    enum ActNaturalPhase {
        case setup
        case revealing
        case discussion
        case ended
    }
    
    var currentPlayer: ActNaturalPlayer? {
        guard currentPlayerIndex < players.count else { return nil }
        return players[currentPlayerIndex]
    }
    
    var allPlayersViewed: Bool {
        players.allSatisfy { $0.hasViewed }
    }
    
    var unknownPlayers: [ActNaturalPlayer] {
        players.filter { $0.isUnknown }
    }
    
    var regularPlayers: [ActNaturalPlayer] {
        players.filter { !$0.isUnknown }
    }
    
    func addPlayer(name: String) {
        let player = ActNaturalPlayer(name: name)
        players.append(player)
    }
    
    func removePlayer(at index: Int) {
        guard index < players.count else { return }
        players.remove(at: index)
    }
    
    func startGame() {
        guard players.count >= 3 else { return }
        
        // Select random word
        secretWord = actNaturalWords.randomElement()
        
        // Unknown count is set before calling startGame() from the setup view
        // If not set, default to: 1 for 3-5 players, 2 for 6+ players
        if unknownCount == 0 {
            unknownCount = players.count >= 6 ? 2 : 1
        }
        
        // Shuffle players for random order
        players.shuffle()
        
        // Randomly assign unknowns - ensure we don't assign more than intended
        var availableIndices = Array(0..<players.count)
        availableIndices.shuffle()
        
        // Reset all players first
        for i in 0..<players.count {
            players[i].isUnknown = false
        }
        
        // Assign exactly unknownCount unknowns
        let actualUnknownCount = min(unknownCount, availableIndices.count)
        for i in 0..<actualUnknownCount {
            let unknownIndex = availableIndices[i]
            players[unknownIndex].isUnknown = true
        }
        
        // Update unknownCount to match actual assignment
        unknownCount = actualUnknownCount
        
        // Reset viewing state
        for i in 0..<players.count {
            players[i].hasViewed = false
        }
        
        currentPlayerIndex = 0
        gamePhase = .revealing
    }
    
    func markCurrentPlayerViewed() {
        guard currentPlayerIndex < players.count else { return }
        players[currentPlayerIndex].hasViewed = true
    }
    
    func moveToNextPlayer() {
        currentPlayerIndex += 1
        if currentPlayerIndex >= players.count {
            gamePhase = .discussion
            startTimer()
        }
    }
    
    func startTimer() {
        guard let duration = timerDuration else { return }
        timeRemaining = duration
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetGame() {
        stopTimer()
        players = []
        currentPlayerIndex = 0
        secretWord = nil
        gamePhase = .setup
        unknownCount = 1
        timerDuration = nil
        timeRemaining = 0
    }
    
    func playAgain() {
        stopTimer()
        // Keep players but reset game state
        for i in 0..<players.count {
            players[i].isUnknown = false
            players[i].hasViewed = false
        }
        currentPlayerIndex = 0
        secretWord = nil
        gamePhase = .setup
        timeRemaining = 0
    }
    
    deinit {
        timer?.invalidate()
    }
}

