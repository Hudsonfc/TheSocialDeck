//
//  FavoritesManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 12/30/25.
//

import SwiftUI

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    private let favoritesKey = "favoriteGameTypes"
    
    @Published var favoriteGameTypes: Set<String> {
        didSet {
            saveFavorites()
        }
    }
    
    private init() {
        if let saved = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            self.favoriteGameTypes = Set(saved)
        } else {
            self.favoriteGameTypes = []
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteGameTypes), forKey: favoritesKey)
    }
    
    /// Favorites keyed by `DeckType.rawValue` or online-only `OnlineGameEntry.gameType` (e.g. `whatWouldYouDo`).
    func isFavoriteRawGameType(_ rawValue: String) -> Bool {
        favoriteGameTypes.contains(rawValue)
    }

    func toggleFavoriteRawGameType(_ rawValue: String) {
        if favoriteGameTypes.contains(rawValue) {
            favoriteGameTypes.remove(rawValue)
        } else {
            favoriteGameTypes.insert(rawValue)
        }
        HapticManager.shared.lightImpact()
        let snapshot = favoriteGameTypes
        Task {
            await AuthManager.shared.saveFavoritesToFirestore(snapshot)
        }
    }

    func isFavorite(_ gameType: DeckType) -> Bool {
        isFavoriteRawGameType(gameType.rawValue)
    }

    func toggleFavorite(_ gameType: DeckType) {
        toggleFavoriteRawGameType(gameType.rawValue)
    }
    
    func addFavorite(_ gameType: DeckType) {
        favoriteGameTypes.insert(gameType.rawValue)
    }

    func removeFavorite(_ gameType: DeckType) {
        favoriteGameTypes.remove(gameType.rawValue)
    }
}

