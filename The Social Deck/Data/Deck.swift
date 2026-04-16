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
    /// Online-first party game (same `rawValue` as legacy `OnlineGameEntry.gameType`).
    case whatWouldYouDo
    case other

    /// Games that support online multiplayer (e.g. Play Offline vs Create Room in Play2).
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

    /// Marketing pill on the Play / home grid (bottom-leading). Only set for decks that should show a tag.
    var playGridMarketingBadge: (label: String, systemImage: String)? {
        switch self {
        case .neverHaveIEver:
            return ("Must Play", "sparkles")
        case .riddleMeThis:
            return ("Fan Favorite", "star.fill")
        case .actItOut:
            return ("Most Played", "flame.fill")
        case .actNatural:
            return ("Just like imposter", "theatermasks.fill")
        case .mostLikelyTo:
            return ("Crowd Pleaser", "face.smiling.fill")
        case .takeItPersonally:
            return ("Our Pick", "heart.fill")
        case .quickfireCouples:
            return ("Date Night", "moon.stars.fill")
        case .closerThanEver:
            return ("Go Deep", "heart.circle.fill")
        default:
            return nil
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

    /// Minimal deck for cover-only UI (online placeholders, loading, synthetic contexts).
    static func coverOnly(type: DeckType, catalogImageName: String = "") -> Deck {
        Deck(
            title: "",
            description: "",
            numberOfCards: 0,
            estimatedTime: "",
            imageName: catalogImageName,
            type: type,
            cards: [],
            availableCategories: []
        )
    }
}

extension Deck {
    /// When true, UI uses programmatic cover (`DeckCoverArtView`) instead of `Image(imageName)`.
    var usesProgrammaticCoverArt: Bool {
        type.usesProgrammaticClassicCoverArt
            || type == .spillTheEx
            || type == .takeItPersonally
            || type == .rhymeTime
            || type == .tapDuel
            || type == .whatsMySecret
            || type == .riddleMeThis
            || type == .actItOut
            || type == .actNatural
            || type == .categoryClash
            || type == .storyChain
            || type == .memoryMaster
            || type == .bluffCall
            || type == .spinTheBottle
            || type == .twoTruthsAndALie
            || type == .hotPotato
            || type == .colorClash
            || type == .flip21
            || type == .quickfireCouples
            || type == .closerThanEver
            || type == .usAfterDark
            || type == .whatWouldYouDo
    }
}
