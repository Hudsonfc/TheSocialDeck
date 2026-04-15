//
//  UsAfterDarkCategorySelectionView.swift
//  The Social Deck
//

import SwiftUI

struct UsAfterDarkCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @EnvironmentObject private var subManager: SubscriptionManager

    private let plusCategories: Set<String> = ["Desires", "Intimacy"]

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
            UsAfterDarkSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        UsAfterDarkCategorySelectionView(deck: Deck(
            title: "Us After Dark",
            description: "Test",
            numberOfCards: 100,
            estimatedTime: "30-45 min",
            imageName: "us after dark",
            type: .usAfterDark,
            cards: [],
            availableCategories: ["Memories", "Connection", "Desires", "Intimacy"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
