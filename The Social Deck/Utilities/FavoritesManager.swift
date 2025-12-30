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
        // Load favorites from UserDefaults
        if let saved = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            self.favoriteGameTypes = Set(saved)
        } else {
            self.favoriteGameTypes = []
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteGameTypes), forKey: favoritesKey)
    }
    
    func isFavorite(_ gameType: DeckType) -> Bool {
        return favoriteGameTypes.contains(gameType.rawValue)
    }
    
    func toggleFavorite(_ gameType: DeckType) {
        if favoriteGameTypes.contains(gameType.rawValue) {
            favoriteGameTypes.remove(gameType.rawValue)
        } else {
            favoriteGameTypes.insert(gameType.rawValue)
        }
        HapticManager.shared.lightImpact()
    }
    
    func addFavorite(_ gameType: DeckType) {
        favoriteGameTypes.insert(gameType.rawValue)
    }
    
    func removeFavorite(_ gameType: DeckType) {
        favoriteGameTypes.remove(gameType.rawValue)
    }
}

