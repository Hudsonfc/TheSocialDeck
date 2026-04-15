//
//  BluffCallCategorySelectionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct BluffCallCategorySelectionView: View {
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
            BluffCallSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        BluffCallCategorySelectionView(deck: Deck(
            title: "Bluff Call",
            description: "Test",
            numberOfCards: 300,
            estimatedTime: "15-20 min",
            imageName: "Art 1.4",
            type: .bluffCall,
            cards: [],
            availableCategories: ["Party", "Wild", "Couples", "Social", "Dirty", "Friends"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
