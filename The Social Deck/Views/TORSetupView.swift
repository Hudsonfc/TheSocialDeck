//
//  TORSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct TORSetupView: View {
    let deck: Deck
    let selectedCategories: [String]
    @State private var navigateToPlay: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // Calculate max cards available from selected categories
    private var maxCardsAvailable: Int {
        let filteredCards = deck.cards.filter { selectedCategories.contains($0.category) }
        return filteredCards.count
    }
    
    private var minCards: Int {
        return min(10, maxCardsAvailable)
    }
    
    private var maxCards: Int {
        return max(maxCardsAvailable, 10)
    }
    
    // Initialize selectedCardCount based on available cards
    private var initialCardCount: Double {
        let max = maxCardsAvailable
        if max == 0 {
            return 10
        }
        return Double(min(30, max))
    }
    
    @State private var selectedCardCount: Double = 30
    
    // Update selectedCardCount when view appears if needed
    private func updateInitialCardCount() {
        if selectedCardCount > Double(maxCardsAvailable) {
            selectedCardCount = Double(initialCardCount)
        }
    }
    
    var body: some View {
        ZStack {
            // Adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button at top left
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
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
                            // Game artwork - regular card image
                            Image(deck.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                                .padding(.top, 20)
                            
                            // Selected categories chips
                            VStack(spacing: 12) {
                                Text("Selected Categories")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondaryText)
                                
                                // Chips in scrollable layout
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
                            
                            // Card Count Selector
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
                    
                    // Start Game button - anchored at bottom
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
                destination: TORPlayView(
                    manager: TORGameManager(deck: deck, selectedCategories: selectedCategories, cardCount: Int(selectedCardCount)),
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
        TORSetupView(
            deck: Deck(
                title: "Truth or Dare",
                description: "Choose truth or dare and see where the night takes you",
                numberOfCards: 330,
                estimatedTime: "30-45 min",
                imageName: "TOD artwork",
                type: .truthOrDare,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

