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
                            
                            VStack(spacing: 16) {
                                // Title
                                Text("Game Setup")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                
                                // Selected categories
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Selected Categories:")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(.secondaryText)
                                    
                                    Text(selectedCategories.joined(separator: ", "))
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.primaryText)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 40)
                            
                            VStack(spacing: 24) {
                                // Card count selection
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("Number of Cards:")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primaryText)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(selectedCardCount))")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(.primaryAccent)
                                    }
                                    
                                    Slider(value: $selectedCardCount, in: Double(minCards)...Double(maxCards), step: 1)
                                        .accentColor(.primaryAccent)
                                }
                                .padding(.horizontal, 40)
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 20)
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
