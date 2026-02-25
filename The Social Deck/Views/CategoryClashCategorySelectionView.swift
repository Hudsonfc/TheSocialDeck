//
//  CategoryClashCategorySelectionView.swift
//  The Social Deck
//

import SwiftUI

struct CategoryClashCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @State private var showPlusPaywall = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subManager: SubscriptionManager

    private let plusCategories: Set<String> = ["Pop Culture", "Food & Beverages"]

    private var freeCategories: Set<String> {
        Set(deck.availableCategories.filter { !plusCategories.contains($0) })
    }

    private func isLocked(_ category: String) -> Bool {
        plusCategories.contains(category) && !subManager.isPlus
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                    }
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)

                ScrollView {
                    VStack(spacing: 0) {
                        Image(deck.imageName)
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .scaledToFit()
                            .frame(width: 160, height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                            .padding(.top, 20)
                            .padding(.bottom, 32)

                        Text("Select Categories")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .padding(.bottom, 8)

                        Text("Choose which types of prompts to include")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .padding(.bottom, 24)

                        VStack(spacing: 12) {
                            ForEach(deck.availableCategories, id: \.self) { category in
                                CategoryButton(
                                    title: category,
                                    isSelected: selectedCategories.contains(category),
                                    isLocked: isLocked(category),
                                    cardCount: deck.cards.filter { $0.category == category }.count
                                ) {
                                    if isLocked(category) {
                                        showPlusPaywall = true
                                    } else if selectedCategories.contains(category) {
                                        selectedCategories.remove(category)
                                    } else {
                                        selectedCategories.insert(category)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)

                        Button(action: {
                            let available = subManager.isPlus
                                ? Set(deck.availableCategories)
                                : freeCategories
                            if selectedCategories == available {
                                selectedCategories.removeAll()
                            } else {
                                selectedCategories = available
                            }
                        }) {
                            let available = subManager.isPlus
                                ? Set(deck.availableCategories)
                                : freeCategories
                            Text(selectedCategories == available ? "Deselect All" : "Select All")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryAccent)
                        }
                        .padding(.bottom, 24)

                        PrimaryButton(title: "Continue") {
                            HapticManager.shared.lightImpact()
                            navigateToSetup = true
                        }
                        .padding(.horizontal, 40)
                        .disabled(selectedCategories.isEmpty)
                        .opacity(selectedCategories.isEmpty ? 0.5 : 1.0)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPlusPaywall) {
            TheSocialDeckPlusPopUpView(onDismiss: { showPlusPaywall = false })
                .environmentObject(SubscriptionManager.shared)
        }
        .background(
            NavigationLink(
                destination: CategoryClashSetupView(deck: deck, selectedCategories: Array(selectedCategories)),
                isActive: $navigateToSetup
            ) {
                EmptyView()
            }
        )
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
