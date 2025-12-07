//
//  Deck.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

enum DeckType {
    case neverHaveIEver
    case truthOrDare
    case wouldYouRather
    case mostLikelyTo
    case twoTruthsAndALie
    case popCultureTrivia
    case historyTrivia
    case scienceTrivia
    case sportsTrivia
    case movieTrivia
    case musicTrivia
    case truthOrDrink
    case categoryClash
    case other
}

struct Deck: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let numberOfCards: Int
    let estimatedTime: String
    let imageName: String
    let type: DeckType
    let cards: [Card]
    let availableCategories: [String] // e.g., ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
}
