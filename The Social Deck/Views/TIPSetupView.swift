//
//  TIPSetupView.swift
//  The Social Deck
//
//  Created for Take It Personally game
//

import SwiftUI

struct TIPSetupView: View {
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
                                .frame(width: ResponsiveSize.setupArtworkWidth, height: ResponsiveSize.setupArtworkHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                                .padding(.top, 20)
                            
                            // Selected categories chips (same as NHIE)
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
                            
                            // Card Count Selector (same as NHIE)
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
                    
                    // Play button fixed at bottom
                    PrimaryButton(title: "Start Game") {
                        HapticManager.shared.lightImpact()
                        navigateToPlay = true
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: TIPPlayView(
                    manager: TIPGameManager(deck: deck, selectedCategories: selectedCategories, cardCount: Int(selectedCardCount)),
                    deck: deck,
                    selectedCategories: selectedCategories
                ),
                isActive: $navigateToPlay
            ) {
                EmptyView()
            }
        )
        .onAppear {
            updateInitialCardCount()
        }
    }
}

#Preview {
    NavigationView {
        TIPSetupView(
            deck: Deck(
                title: "Take It Personally",
                description: "Bold statements about the group",
                numberOfCards: 60,
                estimatedTime: "20-30 min",
                imageName: "take it personally",
                type: .takeItPersonally,
                cards: allTIPCards,
                availableCategories: ["Party", "Wild", "Friends", "Couples"]
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}
