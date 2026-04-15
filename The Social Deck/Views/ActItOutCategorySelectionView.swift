//
//  ActItOutCategorySelectionView.swift
//  The Social Deck
//

import SwiftUI

struct ActItOutCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @EnvironmentObject private var subManager: SubscriptionManager

    private let plusCategories: Set<String> = ["Famous Concepts", "Movie Genres", "Food & Cooking", "Animals"]

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
            ActItOutSetupView(
                deck: deck,
                selectedCategories: Array(selectedCategories)
            )
        }
    }
}

// MARK: - Category row (used by online lobby category sheet)

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    var isLocked: Bool = false
    let cardCount: Int
    let action: () -> Void

    private let soDeckRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .primaryText)

                Spacer()

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(soDeckRed)
                } else {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .primaryAccent)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                isLocked
                    ? Color.tertiaryBackground.opacity(0.6)
                    : (isSelected ? Color.primaryAccent : Color.tertiaryBackground)
            )
            .cornerRadius(12)
            .overlay {
                if isLocked {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(soDeckRed.opacity(0.82), lineWidth: 2)
                }
            }
            .opacity(isLocked ? 0.8 : 1.0)
        }
    }
}

#Preview {
    NavigationView {
        ActItOutCategorySelectionView(
            deck: Deck(
                title: "Act It Out",
                description: "Players take turns acting out a word or idea without speaking while everyone else tries to guess. No talking—just gestures and movement. When someone guesses correctly, give them a point; whoever has the most points when the game ends wins.",
                numberOfCards: 300,
                estimatedTime: "15-30 min",
                imageName: "AIO 2.0",
                type: .actItOut,
                cards: allActItOutCards,
                availableCategories: ["Actions & Verbs", "Animals", "Emotions & Expressions", "Daily Activities", "Sports & Activities", "Objects & Tools", "Food & Cooking", "Famous Concepts", "Movie Genres", "Nature & Weather"]
            )
        )
        .environmentObject(SubscriptionManager.shared)
    }
}
