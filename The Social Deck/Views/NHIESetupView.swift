//
//  NHIESetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct NHIESetupView: View {
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
                    }
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 32) {
                    // Game artwork - regular card image
                    Image(deck.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                    
                    // Selected categories chips
                    VStack(spacing: 12) {
                        Text("Selected Categories")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                        
                        if selectedCategories.count <= 3 {
                            // Center when 3 or fewer categories
                            HStack(spacing: 12) {
                                ForEach(selectedCategories, id: \.self) { category in
                                    Text(category)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.buttonBackground)
                                        .cornerRadius(24)
                                }
                            }
                        } else {
                            // Scrollable when more than 3 categories
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(selectedCategories, id: \.self) { category in
                                        Text(category)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.buttonBackground)
                                            .cornerRadius(24)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
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
                    
                    // Start Game button
                    PrimaryButton(title: "Start Game") {
                        navigateToPlay = true
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            updateInitialCardCount()
        }
        .background(
            NavigationLink(
                destination: NHIELoadingView(
                    deck: deck,
                    selectedCategories: selectedCategories,
                    cardCount: Int(selectedCardCount)
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
        NHIESetupView(
            deck: Deck(
                title: "Never Have I Ever",
                description: "Reveal your wildest experiences",
                numberOfCards: 50,
                estimatedTime: "5-10 min",
                imageName: "NHIE artwork",
                type: .neverHaveIEver,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

