//
//  Card.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

enum CardType {
    case truth
    case dare
}

struct Card: Identifiable {
    let id = UUID()
    let text: String // The prompt ONLY, NOT "never have I ever..." or "truth/dare"
    let category: String // e.g., "Party", "Wild", "Couples"
    let cardType: CardType? // nil for NHIE, .truth or .dare for Truth or Dare
    let optionA: String? // For Would You Rather cards or Multiple Choice
    let optionB: String? // For Would You Rather cards or Multiple Choice
    let optionC: String? // For Multiple Choice trivia
    let optionD: String? // For Multiple Choice trivia
    let correctAnswer: String? // For trivia: "A", "B", "C", or "D"
    
    init(text: String, category: String, cardType: CardType? = nil, optionA: String? = nil, optionB: String? = nil, optionC: String? = nil, optionD: String? = nil, correctAnswer: String? = nil) {
        self.text = text
        self.category = category
        self.cardType = cardType
        self.optionA = optionA
        self.optionB = optionB
        self.optionC = optionC
        self.optionD = optionD
        self.correctAnswer = correctAnswer
    }
}
