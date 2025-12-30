//
//  MLTEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct MLTEndView: View {
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti: Bool = false
    @State private var navigateToHomeView: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Checkmark icon
                if showConfetti {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .padding(.bottom, 40)
                }
                
                // Completion text
                VStack(spacing: 12) {
                    Text("Deck Completed!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Play Again button
                Button(action: {
                    HapticManager.shared.lightImpact()
                    navigateToPlayAgain = true
                }) {
                    Text("Play Again")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 16)
                
                // Home button
                Button(action: {
                    HapticManager.shared.lightImpact()
                    navigateToHomeView = true
                }) {
                    Text("Home")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: 2)
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHomeView
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: MLTCategorySelectionView(deck: deck),
                isActive: $navigateToPlayAgain
            ) {
                EmptyView()
            }
        )
        .onAppear {
            withAnimation {
                showConfetti = true
            }
        }
    }
}

#Preview {
    NavigationView {
        MLTEndView(
            deck: Deck(
                title: "Most Likely To",
                description: "Test",
                numberOfCards: 50,
                estimatedTime: "5-10 min",
                imageName: "MLT artwork",
                type: .mostLikelyTo,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

