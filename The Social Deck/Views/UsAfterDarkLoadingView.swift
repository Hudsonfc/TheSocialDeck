//
//  UsAfterDarkLoadingView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI

struct UsAfterDarkLoadingView: View {
    let deck: Deck
    let selectedCategories: [String]
    let cardCount: Int
    
    @State private var navigateToPlay: Bool = false
    @State private var progress: Double = 0
    @State private var hasStartedLoading: Bool = false
    @State private var isDismissing: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Game artwork
                Image(deck.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 275)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.cardShadowColor, radius: 15, x: 0, y: 8)
                
                // Loading text
                VStack(spacing: 12) {
                    Text("Get Ready!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    
                    Text("Preparing your game...")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                
                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.tertiaryBackground)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.buttonBackground)
                        .frame(width: 200 * progress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
                .frame(width: 200)
                
                Spacer()
            }
            
            // X button to exit
            VStack {
                HStack {
                    Button(action: {
                        isDismissing = true
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
                .padding(.horizontal, 40)
                .padding(.top, 20)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Only start loading if we haven't started yet and we're not dismissing
            if !hasStartedLoading && !isDismissing {
                hasStartedLoading = true
                startLoading()
            }
        }
        .onDisappear {
            // Cancel navigation if we're dismissing
            if isDismissing {
                navigateToPlay = false
            }
        }
        .background(
            NavigationLink(
                destination: UsAfterDarkPlayView(
                    manager: UsAfterDarkGameManager(deck: deck, selectedCategories: selectedCategories, cardCount: cardCount),
                    deck: deck,
                    selectedCategories: selectedCategories
                ),
                isActive: $navigateToPlay
            ) {
                EmptyView()
            }
        )
    }
    
    private func startLoading() {
        // Animate progress bar
        withAnimation(.easeInOut(duration: 0.5)) {
            progress = 0.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.4)) {
                progress = 0.6
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 0.3)) {
                progress = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            // Only navigate if we're not dismissing
            if !isDismissing {
                navigateToPlay = true
            }
        }
    }
}

#Preview {
    NavigationView {
        UsAfterDarkLoadingView(
            deck: Deck(
                title: "Us After Dark",
                description: "Test",
                numberOfCards: 150,
                estimatedTime: "30-45 min",
                imageName: "us after dark",
                type: .usAfterDark,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: [],
            cardCount: 0
        )
    }
}

