//
//  TIPCategorySelectionView.swift
//  The Social Deck
//
//  Created for Take It Personally game
//

import SwiftUI

struct TIPCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @EnvironmentObject private var subManager: SubscriptionManager

    private let plusCategories: Set<String> = ["Wild", "Couples"]

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
            TIPSetupView(deck: deck, selectedCategories: Array(selectedCategories))
        }
    }
}

#Preview {
    NavigationView {
        TIPCategorySelectionView(deck: Deck(
            title: "Take It Personally",
            description: "Test",
            numberOfCards: 60,
            estimatedTime: "20-30 min",
            imageName: "take it personally",
            type: .takeItPersonally,
            cards: [],
            availableCategories: ["Party", "Wild", "Friends", "Couples"]
        ))
        .environmentObject(SubscriptionManager.shared)
    }
}
