//
//  Flip21GameState.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Round Status

enum Flip21RoundStatus: String, Codable, Equatable {
    case dealing = "dealing"          // Cards are being dealt
    case playerTurns = "playerTurns"  // Players are taking turns
    case dealerTurn = "dealerTurn"    // Dealer is drawing cards
    case resolving = "resolving"      // Round is resolving results
    case finished = "finished"        // Round finished, ready for next
}

// MARK: - Player Status

enum PlayerRoundStatus: String, Codable, Equatable {
    case active = "active"    // Player's turn
    case locked = "locked"    // Player locked their hand
    case busted = "busted"    // Player went over 21
}

// MARK: - Flip 21 Game State

struct Flip21GameState: Codable, Equatable {
    var deck: [Flip21Card]
    var dealerHand: [Flip21Card]
    var playerHands: [String: [Flip21Card]] // Player ID -> Hand
    var playerStatuses: [String: PlayerRoundStatus] // Player ID -> Status
    var playerOrder: [String] // Order of players for turns
    var currentPlayerIndex: Int // Index in playerOrder for current turn
    var roundStatus: Flip21RoundStatus
    var roundNumber: Int
    var scores: [String: Int] // Player ID -> Total wins
    var roundResults: [String: RoundResult]? // Player ID -> Round result (nil = no result yet)
    
    init(
        deck: [Flip21Card] = [],
        dealerHand: [Flip21Card] = [],
        playerHands: [String: [Flip21Card]] = [:],
        playerStatuses: [String: PlayerRoundStatus] = [:],
        playerOrder: [String] = [],
        currentPlayerIndex: Int = 0,
        roundStatus: Flip21RoundStatus = .dealing,
        roundNumber: Int = 1,
        scores: [String: Int] = [:],
        roundResults: [String: RoundResult]? = nil
    ) {
        self.deck = deck
        self.dealerHand = dealerHand
        self.playerHands = playerHands
        self.playerStatuses = playerStatuses
        self.playerOrder = playerOrder
        self.currentPlayerIndex = currentPlayerIndex
        self.roundStatus = roundStatus
        self.roundNumber = roundNumber
        self.scores = scores
        self.roundResults = roundResults
    }
    
    /// Get current player ID
    var currentPlayerId: String? {
        guard currentPlayerIndex < playerOrder.count else { return nil }
        return playerOrder[currentPlayerIndex]
    }
    
    /// Check if all players have finished (locked or busted)
    var allPlayersFinished: Bool {
        guard !playerOrder.isEmpty else { return false }
        return playerOrder.allSatisfy { playerId in
            let status = playerStatuses[playerId] ?? .active
            return status == .locked || status == .busted
        }
    }
    
    /// Get the next player ID
    func nextPlayerId() -> String? {
        guard !playerOrder.isEmpty else { return nil }
        let nextIndex = (currentPlayerIndex + 1) % playerOrder.count
        return playerOrder[nextIndex]
    }
    
    /// Move to next player
    mutating func advanceToNextPlayer() {
        guard !playerOrder.isEmpty else { return }
        currentPlayerIndex = (currentPlayerIndex + 1) % playerOrder.count
    }
}

// MARK: - Round Result

enum RoundResult: String, Codable, Equatable {
    case win = "win"
    case loss = "loss"
    case push = "push" // Tie with dealer
}

