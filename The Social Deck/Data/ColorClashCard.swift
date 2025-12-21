//
//  ColorClashCard.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

// MARK: - Card Color

enum CardColor: String, Codable, CaseIterable, Equatable {
    case red = "red"
    case blue = "blue"
    case yellow = "yellow"
    case green = "green"
}

// MARK: - Card Type

enum ColorClashCardType: String, Codable, Equatable {
    case number = "number"
    case skip = "skip"
    case reverse = "reverse"
    case drawTwo = "drawTwo"
    case wild = "wild"
    case wildDrawFour = "wildDrawFour"
}

// MARK: - Color Clash Card

struct ColorClashCard: Identifiable, Codable, Equatable {
    let id: String
    let color: CardColor?
    let number: Int? // 0-9 for number cards
    let type: ColorClashCardType
    var selectedColor: CardColor? // For wild cards, the color chosen by the player
    
    init(id: String = UUID().uuidString, color: CardColor?, number: Int? = nil, type: ColorClashCardType, selectedColor: CardColor? = nil) {
        self.id = id
        self.color = color
        self.number = number
        self.type = type
        self.selectedColor = selectedColor
    }
    
    /// Check if this card can be played on the current top card
    func canPlay(on topCard: ColorClashCard, currentColor: CardColor, burnedColor: CardColor?) -> Bool {
        // If this is a wild card, it can always be played
        if type == .wild || type == .wildDrawFour {
            return true
        }
        
        // Check if this card is the burned color
        if let burnedColor = burnedColor, let cardColor = color, cardColor == burnedColor {
            // Burned color cards can only be played as last card or action cards
            // For now, we'll allow action cards to be played
            return type != .number
        }
        
        // Match by color
        if let cardColor = color, cardColor == currentColor {
            return true
        }
        
        // Match by number (for number cards)
        if type == .number, let cardNumber = number, let topNumber = topCard.number, cardNumber == topNumber {
            return true
        }
        
        // Match by type (for action cards)
        if type != .number, type == topCard.type {
            return true
        }
        
        return false
    }
    
    /// Create a standard 108-card Color Clash deck
    static func createStandardDeck() -> [ColorClashCard] {
        var deck: [ColorClashCard] = []
        
        // Number cards: 0 (one per color), 1-9 (two per color)
        for color in CardColor.allCases {
            // One 0 card
            deck.append(ColorClashCard(color: color, number: 0, type: .number))
            
            // Two of each 1-9
            for number in 1...9 {
                deck.append(ColorClashCard(color: color, number: number, type: .number))
                deck.append(ColorClashCard(color: color, number: number, type: .number))
            }
            
            // Action cards: Skip, Reverse, Draw Two (two of each per color)
            for _ in 0..<2 {
                deck.append(ColorClashCard(color: color, type: .skip))
                deck.append(ColorClashCard(color: color, type: .reverse))
                deck.append(ColorClashCard(color: color, type: .drawTwo))
            }
        }
        
        // Wild cards: 4 Wild, 4 Wild Draw Four
        for _ in 0..<4 {
            deck.append(ColorClashCard(color: nil, type: .wild))
            deck.append(ColorClashCard(color: nil, type: .wildDrawFour))
        }
        
        return deck
    }
}

