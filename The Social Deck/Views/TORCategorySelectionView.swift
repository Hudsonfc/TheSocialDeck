//
//  TORCategorySelectionView.swift
//  The Social Deck
//

import SwiftUI

struct TORCategorySelectionView: View {
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
            TORSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        TORCategorySelectionView(deck: Deck(
            title: "Truth or Dare",
            description: "Test",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "TOD artwork",
            type: .truthOrDare,
            cards: [],
            availableCategories: ["Party", "Wild", "Couples", "Social", "Dirty", "Friends"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
