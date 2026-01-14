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
    @Environment(\.dismiss) private var dismiss
    
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
        .background(
            NavigationLink(
                destination: QuickfireCouplesLoadingView(
                    deck: deck,
                    selectedCategories: selectedCategories,
                    cardCount: 0
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

