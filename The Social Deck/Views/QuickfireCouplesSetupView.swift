//
//  QuickfireCouplesSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI

struct QuickfireCouplesSetupView: View {
    let deck: Deck
    let selectedCategories: [String]
    @State private var navigateToPlay: Bool = false
    @State private var selectedCardCount: Double = 50
    @Environment(\.dismiss) private var dismiss
    
    private let minCards: Int = 10
    private var maxCards: Int {
        return deck.numberOfCards
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
                            
                            // Card Count Selector
                            VStack(spacing: 12) {
                                Text("Number of Cards")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondaryText)
                                
                                VStack(spacing: 8) {
                                    Text("\(Int(selectedCardCount)) cards")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    
                                    Slider(value: $selectedCardCount, in: Double(minCards)...Double(maxCards), step: 10)
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
                            .padding(.horizontal, 40)
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
        .background(
            NavigationLink(
                destination: QuickfireCouplesPlayView(
                    manager: QuickfireCouplesGameManager(deck: deck, selectedCategories: selectedCategories, cardCount: Int(selectedCardCount)),
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
        QuickfireCouplesSetupView(
            deck: Deck(
                title: "Quickfire Couples",
                description: "Test",
                numberOfCards: 150,
                estimatedTime: "15-25 min",
                imageName: "Quickfire Couples",
                type: .quickfireCouples,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Light & Fun", "Preferences"]
        )
    }
}

