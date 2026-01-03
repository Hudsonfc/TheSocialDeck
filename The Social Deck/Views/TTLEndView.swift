//
//  TTLEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct TTLEndView: View {
    let deck: Deck
    let selectedCategories: [String]
    let cardsPlayed: Int
    @State private var navigateToHome: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(deck: Deck, selectedCategories: [String], cardsPlayed: Int = 0) {
        self.deck = deck
        self.selectedCategories = selectedCategories
        self.cardsPlayed = cardsPlayed
    }
    
    var body: some View {
        ZStack {
            // White background
            Color.white
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
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
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
                        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
                    
                    VStack(spacing: 12) {
                        Text("Great Game!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("Did you spot all the lies?")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    }
                    
                    // Game summary
                    VStack(spacing: 16) {
                        summaryRow(label: "Cards Played", value: "\(cardsPlayed)")
                        summaryRow(label: "Categories", value: "\(selectedCategories.count)")
                    }
                    .padding(20)
                    .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
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
                        Text("Play Again")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        navigateToHome = true
                    }) {
                        Text("Home")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
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
                destination: TTLCategorySelectionView(deck: deck),
                isActive: $navigateToPlayAgain
            ) {
                EmptyView()
            }
        )
    }
    
    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
        }
    }
}

#Preview {
    NavigationView {
        TTLEndView(
            deck: Deck(
                title: "Two Truths and a Lie",
                description: "Test",
                numberOfCards: 50,
                estimatedTime: "5-10 min",
                imageName: "Art 1.4",
                type: .twoTruthsAndALie,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"],
            cardsPlayed: 10
        )
    }
}
