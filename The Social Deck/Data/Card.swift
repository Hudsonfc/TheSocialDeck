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
}
