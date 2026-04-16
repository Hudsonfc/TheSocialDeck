//
//  SpillTheExEndView.swift
//  The Social Deck
//

import SwiftUI

struct SpillTheExEndView: View {
    let deck: Deck
    let selectedCategories: [String]
    let cardsPlayed: Int
    @State private var navigateToHome: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    @Environment(\.dismiss) private var dismiss

    init(deck: Deck, selectedCategories: [String], cardsPlayed: Int = 0) {
        self.deck = deck
        self.selectedCategories = selectedCategories
        self.cardsPlayed = cardsPlayed
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { navigateToHome = true }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                VStack(spacing: 32) {
                    DeckCoverArtView(deck: deck)
                        .scaledToFit()
                        .frame(width: 160, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.cardShadowColor, radius: 15, x: 0, y: 8)

                    VStack(spacing: 12) {
                        Text("The Tea Has Been Spilled!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)

                        Text("Hope nobody's past is too traumatised 🫶")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 16) {
                        summaryRow(label: "Cards Played", value: "\(cardsPlayed)")
                        summaryRow(label: "Categories", value: "\(selectedCategories.count)")
                    }
                    .padding(20)
                    .background(Color.secondaryBackground)
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        navigateToPlayAgain = true
                    }) {
                        Text("Play Again")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.buttonBackground)
                            .cornerRadius(16)
                    }

                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        navigateToHome = true
                    }) {
                        Text("Home")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color.buttonBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.secondaryBackground)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(destination: HomeView(), isActive: $navigateToHome) { EmptyView() }
        )
        .background(
            NavigationLink(
                destination: SpillTheExCategorySelectionView(deck: deck),
                isActive: $navigateToPlayAgain
            ) { EmptyView() }
        )
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primaryText)
        }
    }
}

#Preview {
    NavigationView {
        SpillTheExEndView(
            deck: Deck(
                title: "Spill the Ex",
                description: "Hot takes about past relationships.",
                numberOfCards: 100,
                estimatedTime: "20-30 min",
                imageName: "Spill the Ex",
                type: .spillTheEx,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Confessions", "Situationship"],
            cardsPlayed: 20
        )
        .environmentObject(SubscriptionManager.shared)
    }
}
