//
//  TORCategorySelectionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct TORCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
    @State private var navigateToSetup: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dark adaptive background
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
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Game artwork
                        Image(deck.imageName)
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .scaledToFit()
                            .frame(width: 160, height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                            .padding(.top, 20)
                            .padding(.bottom, 32)
                        
                        // Title
                        Text("Select Categories")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .padding(.bottom, 8)
                        
                        Text("Choose which types of prompts to include")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .padding(.bottom, 24)
                        
                        // Category buttons
                        VStack(spacing: 12) {
                            ForEach(deck.availableCategories, id: \.self) { category in
                                CategoryButton(
                                    title: category,
                                    isSelected: selectedCategories.contains(category),
                                    cardCount: deck.cards.filter { $0.category == category }.count
                                ) {
                                    if selectedCategories.contains(category) {
                                        selectedCategories.remove(category)
                                    } else {
                                        selectedCategories.insert(category)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)
                        
                        // Select All button
                        Button(action: {
                            if selectedCategories.count == deck.availableCategories.count {
                                selectedCategories.removeAll()
                            } else {
                                selectedCategories = Set(deck.availableCategories)
                            }
                        }) {
                            Text(selectedCategories.count == deck.availableCategories.count ? "Deselect All" : "Select All")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryAccent)
                        }
                        .padding(.bottom, 24)
                        
                        // Continue button
                        PrimaryButton(title: "Continue") {
                            HapticManager.shared.lightImpact()
                            navigateToSetup = true
                        }
                        .padding(.horizontal, 40)
                        .disabled(selectedCategories.isEmpty)
                        .opacity(selectedCategories.isEmpty ? 0.5 : 1.0)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: TORSetupView(deck: deck, selectedCategories: Array(selectedCategories)),
                isActive: $navigateToSetup
            ) {
                EmptyView()
            }
        )
    }
}

#Preview {
    NavigationView {
        TORCategorySelectionView(deck: Deck(
            title: "Truth or Dare",
            description: "Test",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "TOD artwork",
            type: .truthOrDare,
            cards: [],
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
        ))
    }
}

