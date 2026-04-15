//
//  CategoryClashCategorySelectionView.swift
//  The Social Deck
//

import SwiftUI

struct CategoryClashCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @EnvironmentObject private var subManager: SubscriptionManager

    private let plusCategories: Set<String> = ["Pop Culture", "Food & Beverages"]

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
            CategoryClashSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        CategoryClashCategorySelectionView(deck: Deck(
            title: "Category Clash",
            description: "Test",
            numberOfCards: 250,
            estimatedTime: "15-20 min",
            imageName: "CC artwork",
            type: .categoryClash,
            cards: [],
            availableCategories: ["Food & Beverages", "Pop Culture", "General", "Sports & Activities", "Animals & Nature"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
