//
//  MLTCategorySelectionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct MLTCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @EnvironmentObject private var subManager: SubscriptionManager

    private let plusCategories: Set<String> = ["Dirty", "Couples", "Wild"]

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
            MLTSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        MLTCategorySelectionView(deck: Deck(
            title: "Most Likely To",
            description: "Test",
            numberOfCards: 50,
            estimatedTime: "5-10 min",
            imageName: "MLT artwork",
            type: .mostLikelyTo,
            cards: [],
            availableCategories: ["Party", "Wild", "Couples", "Social", "Dirty", "Friends"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
