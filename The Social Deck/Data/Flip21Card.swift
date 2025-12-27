//
//  Flip21Card.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

// MARK: - Card Suit

enum CardSuit: String, Codable, CaseIterable, Equatable {
    case spades = "spades"
    case hearts = "hearts"
    case diamonds = "diamonds"
    case clubs = "clubs"
}

// MARK: - Card Rank

enum CardRank: String, Codable, Equatable {
    case ace = "ace"
    case two = "two"
    case three = "three"
    case four = "four"
    case five = "five"
    case six = "six"
    case seven = "seven"
    case eight = "eight"
    case nine = "nine"
    case ten = "ten"
    case jack = "jack"
    case queen = "queen"
    case king = "king"
    
    /// Returns the numeric value of the rank (Ace = 1, face cards = 10)
    var value: Int {
        switch self {
        case .ace: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten, .jack, .queen, .king: return 10
        }
    }
    
    /// Display name for the rank
    var displayName: String {
        switch self {
        case .ace: return "A"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        default: return String(value)
        }
    }
}

// MARK: - Flip 21 Card

struct Flip21Card: Identifiable, Codable, Equatable {
    let id: String
    let suit: CardSuit
    let rank: CardRank
    var isRevealed: Bool // Whether the card is face-up or face-down
    
    init(id: String = UUID().uuidString, suit: CardSuit, rank: CardRank, isRevealed: Bool = false) {
        self.id = id
        self.suit = suit
        self.rank = rank
        self.isRevealed = isRevealed
    }
    
    /// Create a standard 52-card deck
    static func createStandardDeck() -> [Flip21Card] {
        var deck: [Flip21Card] = []
        for suit in CardSuit.allCases {
            for rank in [CardRank.ace, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king] {
                deck.append(Flip21Card(suit: suit, rank: rank))
            }
        }
        return deck
    }
}

// MARK: - Hand Value Calculation

extension Array where Element == Flip21Card {
    /// Calculate the best possible hand value (Ace can be 1 or 11)
    func calculateValue() -> Int {
        var value = 0
        var aceCount = 0
        
        for card in self where card.isRevealed {
            if card.rank == .ace {
                aceCount += 1
            } else {
                value += card.rank.value
            }
        }
        
        // Add aces optimally
        for _ in 0..<aceCount {
            if value + 11 <= 21 {
                value += 11
            } else {
                value += 1
            }
        }
        
        return value
    }
    
    /// Check if the hand is busted (over 21)
    func isBusted() -> Bool {
        return calculateValue() > 21
    }
    
    /// Check if the hand is blackjack (21 with exactly 2 cards)
    func isBlackjack() -> Bool {
        return count == 2 && calculateValue() == 21
    }
}

