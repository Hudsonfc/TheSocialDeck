//
//  Card.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

struct Card: Identifiable {
    let id = UUID()
    let text: String // The prompt ONLY, NOT "never have I ever..."
    let category: String // e.g., "Party", "Wild", "Couples"
}
