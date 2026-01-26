//
//  WhatsMySecretEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct WhatsMySecretEndView: View {
    let deck: Deck
    let selectedCategories: [String]
    let groupWins: Int
    let secretPlayerWins: Int
    let totalRounds: Int
    let players: [String]
    @State private var navigateToHome: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    @State private var navigateToNewPlayers: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(deck: Deck, selectedCategories: [String], groupWins: Int, secretPlayerWins: Int, totalRounds: Int, players: [String] = []) {
        self.deck = deck
        self.selectedCategories = selectedCategories
        self.groupWins = groupWins
        self.secretPlayerWins = secretPlayerWins
        self.totalRounds = totalRounds
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
                        
                        Text("Secrets revealed!")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                    
                    // Game summary
                    VStack(spacing: 16) {
                        summaryRow(label: "Rounds Played", value: "\(totalRounds)")
                        summaryRow(label: "Group Wins", value: "\(groupWins)")
                        summaryRow(label: "Secret Player Wins", value: "\(secretPlayerWins)")
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
                destination: WhatsMySecretSetupView(deck: deck, existingPlayers: players),
                isActive: $navigateToPlayAgain
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: WhatsMySecretSetupView(deck: deck, existingPlayers: nil),
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
        WhatsMySecretEndView(
            deck: Deck(
                title: "What's My Secret?",
                description: "Test",
                numberOfCards: 50,
                estimatedTime: "5-10 min",
                imageName: "WMS artwork",
                type: .whatsMySecret,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: [],
            groupWins: 5,
            secretPlayerWins: 3,
            totalRounds: 8,
            players: []
        )
    }
}
