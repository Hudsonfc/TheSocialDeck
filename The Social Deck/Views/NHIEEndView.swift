//
//  NHIEEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct NHIEEndView: View {
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti: Bool = false
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Confetti animation placeholder
                if showConfetti {
                    // TODO: Add Lottie confetti animation
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                }
                
                // Completion text
                Text("Deck Completed!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    NavigationLink(destination: NHIECategorySelectionView(deck: deck)) {
                        PrimaryButton(title: "Play Again") {
                            // Navigation handled by NavigationLink
                        }
                    }
                    
                    Button(action: {
                        // Pop to root
                        dismiss()
                    }) {
                        Text("Home")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation {
                showConfetti = true
            }
        }
    }
}

#Preview {
    NavigationView {
        NHIEEndView(
            deck: Deck(
                title: "Never Have I Ever",
                description: "Test",
                numberOfCards: 50,
                estimatedTime: "5-10 min",
                imageName: "Art 1.4",
                type: .neverHaveIEver,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

