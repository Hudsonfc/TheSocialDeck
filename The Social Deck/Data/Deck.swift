//
//  Deck.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

enum DeckType: String {
    case neverHaveIEver
    case truthOrDare
    case wouldYouRather
    case mostLikelyTo
    case twoTruthsAndALie
    case categoryClash
    case spinTheBottle
    case storyChain
    case memoryMaster
    case bluffCall
    case hotPotato
    case rhymeTime
    case tapDuel
    case whatsMySecret
    case riddleMeThis
    case actItOut
    case actNatural
    case colorClash
    case flip21
    case quickfireCouples
    case closerThanEver
    case usAfterDark
    case takeItPersonally
    case spillTheEx
    case other

    /// Games that support online multiplayer (e.g. Play Local vs Play Online in Play2).
    var supportsOnlineMultiplayer: Bool {
        switch self {
        case .neverHaveIEver, .truthOrDare, .wouldYouRather, .mostLikelyTo,
             .quickfireCouples, .closerThanEver, .usAfterDark, .spillTheEx,
             .takeItPersonally, .riddleMeThis, .actNatural, .storyChain, .twoTruthsAndALie,
             .colorClash, .flip21:
            return true
        default:
            return false
        }
    }
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
    let availableCategories: [String] // e.g., ["Party", "Wild", "Couples", "Social", "Dirty", "Friends"]
}
