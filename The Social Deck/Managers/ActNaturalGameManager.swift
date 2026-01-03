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
        
        // Determine number of unknowns (1 for 3-5 players, 2 for 6+ players)
        unknownCount = players.count >= 6 ? 2 : 1
        
        // Shuffle players for random order
        players.shuffle()
        
        // Randomly assign unknowns
        var availableIndices = Array(0..<players.count)
        availableIndices.shuffle()
        
        for i in 0..<unknownCount {
            let unknownIndex = availableIndices[i]
            players[unknownIndex].isUnknown = true
        }
        
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
        }
    }
    
    func resetGame() {
        players = []
        currentPlayerIndex = 0
        secretWord = nil
        gamePhase = .setup
        unknownCount = 1
    }
    
    func playAgain() {
        // Keep players but reset game state
        for i in 0..<players.count {
            players[i].isUnknown = false
            players[i].hasViewed = false
        }
        currentPlayerIndex = 0
        secretWord = nil
        gamePhase = .setup
    }
}

