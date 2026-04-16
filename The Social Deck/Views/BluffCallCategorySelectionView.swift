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
    @EnvironmentObject private var subManager: SubscriptionManager

    /// Four of six packs require Plus (free: Party, Friends).
    private let plusCategories: Set<String> = ["Wild", "Couples", "Social", "Dirty"]

    private var freeCategories: Set<String> {
        Set(deck.availableCategories.filter { !plusCategories.contains($0) })
    }

    private func categoryIsLocked(_ category: String) -> Bool {
        plusCategories.contains(category) && !subManager.isPlus
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
