//
//  ActItOutEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 12/31/24.
//

import SwiftUI

struct ActItOutEndView: View {
    let deck: Deck
    let selectedCategories: [String]
    let roundsPlayed: Int
    let players: [String]
    let playerScores: [String: Int]
    @State private var navigateToHome: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    @State private var navigateToNewPlayers: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(deck: Deck, selectedCategories: [String], roundsPlayed: Int = 0, players: [String] = [], playerScores: [String: Int] = [:]) {
        self.deck = deck
        self.selectedCategories = selectedCategories
        self.roundsPlayed = roundsPlayed
        self.players = players
        self.playerScores = playerScores
    }

    private var playersSortedByPoints: [String] {
        players.sorted {
            let a = playerScores[$0, default: 0]
            let b = playerScores[$1, default: 0]
            if a != b { return a > b }
            return $0 < $1
        }
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
                    DeckCoverArtView(deck: deck)
                        .scaledToFit()
                        .frame(width: 160, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.cardShadowColor, radius: 15, x: 0, y: 8)
                    
                    VStack(spacing: 12) {
                        Text("Great Game!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        
                        Text("Most guess points wins!")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }

                    // Game summary
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Rounds")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondaryText)
                            Spacer()
                            Text("\(roundsPlayed)")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                        }
                        .padding(.bottom, 14)

                        if !players.isEmpty {
                            Divider()
                                .opacity(0.35)
                                .padding(.bottom, 10)

                            ForEach(Array(playersSortedByPoints.enumerated()), id: \.element) { index, name in
                                HStack {
                                    Text(name)
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    Spacer()
                                    Text("\(playerScores[name, default: 0])")
                                        .font(.system(size: 15, weight: .medium, design: .rounded).monospacedDigit())
                                        .foregroundColor(.secondaryText)
                                }
                                .padding(.vertical, 10)

                                if index < playersSortedByPoints.count - 1 {
                                    Divider()
                                        .opacity(0.25)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                destination: ActItOutSetupView(deck: deck, selectedCategories: selectedCategories, existingPlayers: players),
                isActive: $navigateToPlayAgain
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: ActItOutCategorySelectionView(deck: deck),
                isActive: $navigateToNewPlayers
            ) {
                EmptyView()
            }
        )
    }
}

#Preview {
    NavigationView {
        ActItOutEndView(
            deck: Deck(
                title: "Act It Out",
                description: "Players take turns acting out a word or idea without speaking while everyone else tries to guess. No talking—just gestures and movement. When someone guesses correctly, give them a point; whoever has the most points when the game ends wins.",
                numberOfCards: 300,
                estimatedTime: "15-30 min",
                imageName: "AIO 2.0",
                type: .actItOut,
                cards: allActItOutCards,
                availableCategories: ["Actions & Verbs", "Animals"]
            ),
            selectedCategories: ["Actions & Verbs", "Animals"],
            roundsPlayed: 15
        )
    }
}
