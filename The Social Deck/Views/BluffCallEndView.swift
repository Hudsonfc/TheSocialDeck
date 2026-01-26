//
//  BluffCallEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct BluffCallEndView: View {
    let deck: Deck
    let selectedCategories: [String]
    let roundsPlayed: Int
    let players: [String]
    @State private var navigateToHome: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    @State private var navigateToNewPlayers: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(deck: Deck, selectedCategories: [String], roundsPlayed: Int = 0, players: [String] = []) {
        self.deck = deck
        self.selectedCategories = selectedCategories
        self.roundsPlayed = roundsPlayed
        self.players = players
    }
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    Button(action: {
                        navigateToHome = true
                    }) {
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
                
                // End content
                VStack(spacing: 32) {
                    // Game artwork
                    Image(deck.imageName)
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFit()
                        .frame(width: 160, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.cardShadowColor, radius: 15, x: 0, y: 8)
                    
                    VStack(spacing: 12) {
                        Text("Great Game!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        
                        Text("Who was the best bluffer?")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                    
                    // Game summary
                    VStack(spacing: 16) {
                        summaryRow(label: "Rounds Played", value: "\(roundsPlayed)")
                        summaryRow(label: "Categories", value: "\(selectedCategories.count)")
                    }
                    .padding(20)
                    .background(Color.secondaryBackground)
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        navigateToPlayAgain = true
                    }) {
                        Text("Play Again with Same Players")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.buttonBackground)
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        navigateToNewPlayers = true
                    }) {
                        Text("New Players")
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
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHome
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: BluffCallSetupView(deck: deck, selectedCategories: selectedCategories, existingPlayers: players),
                isActive: $navigateToPlayAgain
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: BluffCallCategorySelectionView(deck: deck),
                isActive: $navigateToNewPlayers
            ) {
                EmptyView()
            }
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
        BluffCallEndView(
            deck: Deck(
                title: "Bluff Call",
                description: "Test",
                numberOfCards: 300,
                estimatedTime: "15-20 min",
                imageName: "Art 1.4",
                type: .bluffCall,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"],
            roundsPlayed: 12
        )
    }
}
