//
//  CloserThanEverCategorySelectionView.swift
//  The Social Deck
//

import SwiftUI

struct CloserThanEverCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @EnvironmentObject private var subManager: SubscriptionManager

    private let plusCategories: Set<String> = ["Vulnerability", "Intimacy"]

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
            CloserThanEverSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        CloserThanEverCategorySelectionView(deck: Deck(
            title: "Closer Than Ever",
            description: "Test",
            numberOfCards: 100,
            estimatedTime: "30-45 min",
            imageName: "Closer than ever",
            type: .closerThanEver,
            cards: [],
            availableCategories: ["Love Languages", "Memories", "Vulnerability", "Intimacy"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
