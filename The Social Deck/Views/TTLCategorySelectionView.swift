//
//  TTLCategorySelectionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct TTLCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false

    private var freeCategories: Set<String> {
        Set(deck.availableCategories)
    }

    private func categoryIsLocked(_ category: String) -> Bool {
        false
    }

    var body: some View {
        ClassicCategorySelectionRoot(
            deck: deck,
            selectedCategories: $selectedCategories,
            freeCategories: freeCategories,
            navigateToSetup: $navigateToSetup,
            isLocked: categoryIsLocked
        ) {
            TTLSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        TTLCategorySelectionView(deck: Deck(
            title: "Two Truths and a Lie",
            description: "Test",
            numberOfCards: 50,
            estimatedTime: "5-10 min",
            imageName: "Art 1.4",
            type: .twoTruthsAndALie,
            cards: [],
            availableCategories: ["Party", "Wild", "Couples", "Social", "Dirty", "Friends"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
