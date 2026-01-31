//
//  MovieTriviaSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct MovieTriviaSetupView: View {
    let deck: Deck
    let selectedCategories: [String]
    @State private var navigateToPlay: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    private var maxCardsAvailable: Int {
        let filteredCards = deck.cards.filter { selectedCategories.contains($0.category) }
        return filteredCards.count
    }
    
    private var minCards: Int {
        return min(5, maxCardsAvailable)
    }
    
    private var maxCards: Int {
        return max(maxCardsAvailable, 5)
    }
    
    private var initialCardCount: Double {
        let max = maxCardsAvailable
        if max == 0 {
            return 5
        }
        return Double(min(15, max))
    }
    
    @State private var selectedCardCount: Double = 15
    
    private func updateInitialCardCount() {
        if selectedCardCount > Double(maxCardsAvailable) {
            selectedCardCount = Double(initialCardCount)
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                    // Game title
                    Text(deck.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Game artwork - regular card image
                    Image(deck.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: ResponsiveSize.setupArtworkWidth, height: ResponsiveSize.setupArtworkHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 12) {
                        Text("Selected Difficulties")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                        
                        if selectedCategories.count <= 3 {
                            HStack(spacing: 12) {
                                ForEach(selectedCategories, id: \.self) { category in
                                    Text(category)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.primaryAccent)
                                        .cornerRadius(24)
                                }
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(selectedCategories, id: \.self) { category in
                                        Text(category)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.primaryAccent)
                                            .cornerRadius(24)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    Text(deck.description)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 12) {
                        Text("Number of Questions")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                        
                        VStack(spacing: 8) {
                            Text("\(Int(selectedCardCount)) questions")
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
                destination: MovieTriviaPlayView(
                    manager: MovieTriviaGameManager(deck: deck, selectedCategories: selectedCategories, cardCount: Int(selectedCardCount)),
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

