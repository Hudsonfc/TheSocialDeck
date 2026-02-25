//
//  SpillTheExSetupView.swift
//  The Social Deck
//

import SwiftUI

struct SpillTheExSetupView: View {
    let deck: Deck
    let selectedCategories: [String]
    @State private var navigateToPlay: Bool = false
    @Environment(\.dismiss) private var dismiss

    private var maxCardsAvailable: Int {
        deck.cards.filter { selectedCategories.contains($0.category) }.count
    }

    private var minCards: Int {
        min(10, maxCardsAvailable)
    }

    private var maxCards: Int {
        max(maxCardsAvailable, 10)
    }

    private var initialCardCount: Double {
        let max = maxCardsAvailable
        if max == 0 { return 10 }
        return Double(min(30, max))
    }

    @State private var selectedCardCount: Double = 30

    private func updateInitialCardCount() {
        if selectedCardCount > Double(maxCardsAvailable) {
            selectedCardCount = initialCardCount
        }
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
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 32) {
                            Image(deck.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: ResponsiveSize.setupArtworkWidth, height: ResponsiveSize.setupArtworkHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                                .padding(.top, 20)

                            VStack(spacing: 12) {
                                Text("Selected Categories")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondaryText)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(selectedCategories, id: \.self) { category in
                                            Text(category)
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                                .foregroundColor(Color.primaryAccent)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.primaryAccent.opacity(0.1))
                                                .cornerRadius(16)
                                        }
                                    }
                                    .padding(.horizontal, 40)
                                }
                            }
                            .padding(.bottom, 20)

                            VStack(spacing: 12) {
                                Text("Number of Cards")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondaryText)

                                VStack(spacing: 8) {
                                    Text("\(Int(selectedCardCount)) cards")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)

                                    Slider(value: $selectedCardCount, in: Double(minCards)...Double(maxCards), step: 1)
                                        .tint(Color.primaryAccent)

                                    HStack {
                                        Text("\(minCards)")
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundColor(.secondaryText)
                                        Spacer()
                                        Text("\(maxCards)")
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundColor(.secondaryText)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 32)
                        }
                        .padding(.horizontal, 40)
                    }

                    PrimaryButton(title: "Start Game") {
                        navigateToPlay = true
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            updateInitialCardCount()
        }
        .background(
            NavigationLink(
                destination: SpillTheExPlayView(
                    manager: SpillTheExGameManager(
                        deck: deck,
                        selectedCategories: selectedCategories,
                        cardCount: Int(selectedCardCount)
                    ),
                    deck: deck,
                    selectedCategories: selectedCategories
                ),
                isActive: $navigateToPlay
            ) {
                EmptyView()
            }
        )
    }
}

#Preview {
    NavigationView {
        SpillTheExSetupView(
            deck: Deck(
                title: "Spill the Ex",
                description: "Hot takes about past relationships.",
                numberOfCards: 100,
                estimatedTime: "20-30 min",
                imageName: "Spill the Ex",
                type: .spillTheEx,
                cards: allSpillTheExCards,
                availableCategories: ["Confessions", "Situationship", "The Breakup", "Wild Side"]
            ),
            selectedCategories: ["Confessions", "Situationship"]
        )
    }
}
