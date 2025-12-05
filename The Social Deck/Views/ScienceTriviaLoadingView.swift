//
//  ScienceTriviaLoadingView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ScienceTriviaLoadingView: View {
    let deck: Deck
    let selectedCategories: [String]
    let cardCount: Int
    @State private var navigateToPlay: Bool = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Game artwork with pulsing animation
                Image(deck.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipped()
                    .cornerRadius(100)
                    .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 5)
                    .scaleEffect(scale)
                
                // Loading text
                Text("Loading...")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                // Custom animated loading indicator
                LoadingIndicator()
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Start pulsing animation for artwork
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
            
            // Navigate after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                navigateToPlay = true
            }
        }
        .background(
            NavigationLink(
                destination: ScienceTriviaPlayView(
                    manager: ScienceTriviaGameManager(deck: deck, selectedCategories: selectedCategories, cardCount: cardCount),
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
