//
//  SpillTheExCategorySelectionView.swift
//  The Social Deck
//

import SwiftUI

struct SpillTheExCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @EnvironmentObject private var subManager: SubscriptionManager

    private let plusCategories: Set<String> = ["The Breakup", "Wild Side"]

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
            SpillTheExSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        SpillTheExCategorySelectionView(deck: Deck(
            title: "Spill the Ex",
            description: "Hot takes about past relationships.",
            numberOfCards: 100,
            estimatedTime: "20-30 min",
            imageName: "Spill the Ex",
            type: .spillTheEx,
            cards: allSpillTheExCards,
            availableCategories: ["Confessions", "Situationship", "The Breakup", "Wild Side"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
