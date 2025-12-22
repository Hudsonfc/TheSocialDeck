//
//  ColorClashGameState.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Game Status

enum GameStatus: String, Codable, Equatable {
    case waiting = "waiting"
    case playing = "playing"
    case finished = "finished"
}

// MARK: - Action Type

enum PlayerActionType: String, Codable, Equatable {
    case played = "played"
    case skipped = "skipped"
    case drew = "drew"
}

// MARK: - Color Clash Game State

struct ColorClashGameState: Codable, Equatable {
    var deck: [ColorClashCard]
    var discardPile: [ColorClashCard]
    var playerHands: [String: [ColorClashCard]] // Player ID -> Hand
    var currentPlayerId: String
    var playerOrder: [String]
    var turnDirection: Int // 1 for clockwise, -1 for counter-clockwise
    var currentColor: CardColor
    var burnedColor: CardColor?
    var turnStartedAt: Date?
    var turnDuration: TimeInterval // Duration of each turn (e.g., 30 seconds)
    var status: GameStatus
    var winnerId: String?
    var lastCardDeclared: [String: Bool] // Player ID -> has declared last card
    var pendingDrawCards: Int? // Number of cards to draw (from Draw Two/Four)
    var skipNextPlayer: Bool
    var lastActionPlayer: String? // Who performed the last action
    var lastActionType: PlayerActionType? // Type of last action (played, skipped, drew)
    
    init(
        deck: [ColorClashCard] = [],
        discardPile: [ColorClashCard] = [],
        playerHands: [String: [ColorClashCard]] = [:],
        currentPlayerId: String = "",
        playerOrder: [String] = [],
        turnDirection: Int = 1,
        currentColor: CardColor = .red,
        burnedColor: CardColor? = nil,
        turnStartedAt: Date? = nil,
        turnDuration: TimeInterval = 30.0,
        status: GameStatus = .waiting,
        winnerId: String? = nil,
        lastCardDeclared: [String: Bool] = [:],
        pendingDrawCards: Int? = nil,
        skipNextPlayer: Bool = false,
        lastActionPlayer: String? = nil,
        lastActionType: PlayerActionType? = nil
    ) {
        self.deck = deck
        self.discardPile = discardPile
        self.playerHands = playerHands
        self.currentPlayerId = currentPlayerId
        self.playerOrder = playerOrder
        self.turnDirection = turnDirection
        self.currentColor = currentColor
        self.burnedColor = burnedColor
        self.turnStartedAt = turnStartedAt
        self.turnDuration = turnDuration
        self.status = status
        self.winnerId = winnerId
        self.lastCardDeclared = lastCardDeclared
        self.pendingDrawCards = pendingDrawCards
        self.skipNextPlayer = skipNextPlayer
        self.lastActionPlayer = lastActionPlayer
        self.lastActionType = lastActionType
    }
    
    /// Get the top card from the discard pile
    var topCard: ColorClashCard? {
        return discardPile.last
    }
    
    /// Get hand count for a specific player
    func handCount(for playerId: String) -> Int {
        return playerHands[playerId]?.count ?? 0
    }
    
    /// Check if game is finished
    var isFinished: Bool {
        return status == .finished
    }
    
    /// Get the next player ID based on turn direction
    func nextPlayerId() -> String? {
        guard let currentIndex = playerOrder.firstIndex(of: currentPlayerId) else {
            return playerOrder.first
        }
        
        let nextIndex = (currentIndex + turnDirection + playerOrder.count) % playerOrder.count
        return playerOrder[nextIndex]
    }
}

