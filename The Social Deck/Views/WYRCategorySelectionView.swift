//
//  WYRCategorySelectionView.swift
//  The Social Deck
//

import SwiftUI

struct WYRCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @EnvironmentObject private var subManager: SubscriptionManager

    private let plusCategories: Set<String> = ["Dirty", "Couples", "Weird"]

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
            WYRSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        WYRCategorySelectionView(deck: Deck(
            title: "Would You Rather",
            description: "Test",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "WYR artwork",
            type: .wouldYouRather,
            cards: [],
            availableCategories: ["Party", "Couples", "Social", "Dirty", "Friends", "Weird"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
