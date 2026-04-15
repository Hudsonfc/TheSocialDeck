//
//  QuickfireCouplesCategorySelectionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI

struct QuickfireCouplesCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @EnvironmentObject private var subManager: SubscriptionManager

    private let plusCategories: Set<String> = ["Personality", "Relationship"]

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
            QuickfireCouplesSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        QuickfireCouplesCategorySelectionView(deck: Deck(
            title: "Quickfire Couples",
            description: "Test",
            numberOfCards: 150,
            estimatedTime: "15-25 min",
            imageName: "Quickfire Couples",
            type: .quickfireCouples,
            cards: [],
            availableCategories: ["Light & Fun", "Preferences", "Personality", "Relationship"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
