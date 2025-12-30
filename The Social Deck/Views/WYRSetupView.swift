//
//  WYRSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct WYRSetupView: View {
    let deck: Deck
    let selectedCategories: [String]
    @State private var navigateToPlay: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // Calculate max cards available from selected categories
    private var maxCardsAvailable: Int {
        // Group cards by category to find minimum per category
        var cardsByCategory: [String: [Card]] = [:]
        for category in selectedCategories {
            let categoryCards = deck.cards.filter { $0.category == category }
            cardsByCategory[category] = categoryCards
        }
        
        // Find minimum cards per category
        let minCardsPerCategory = cardsByCategory.values.map { $0.count }.min() ?? 0
        
        // Total available = minCardsPerCategory * number of categories
        return minCardsPerCategory * selectedCategories.count
    }
    
    private var minCards: Int {
        return min(10, maxCardsAvailable)
    }
    
    private var maxCards: Int {
        return max(maxCardsAvailable, 10)
    }
    
    // Initialize selectedCardCount based on available cards
    private var initialCardCount: Double {
        let max = maxCardsAvailable
        if max == 0 {
            return 10
        }
        return Double(min(30, max))
    }
    
    @State private var selectedCardCount: Double = 30
    
    // Update selectedCardCount when view appears if needed
    private func updateInitialCardCount() {
        if selectedCardCount > Double(maxCardsAvailable) {
            selectedCardCount = Double(initialCardCount)
        }
    }
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button at top left
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
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
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Selected categories chips
                    VStack(spacing: 12) {
                        Text("Selected Categories")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        
                        if selectedCategories.count <= 3 {
                            // Center when 3 or fewer categories
                            HStack(spacing: 12) {
                                ForEach(selectedCategories, id: \.self) { category in
                                    Text(category)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                        .cornerRadius(24)
                                }
                            }
                        } else {
                            // Scrollable when more than 3 categories
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(selectedCategories, id: \.self) { category in
                                        Text(category)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                            .cornerRadius(24)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Description
                    Text(deck.description)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                    
                    // Card Count Selector
                    VStack(spacing: 12) {
                        Text("Number of Cards")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        
                        VStack(spacing: 8) {
                            Text("\(Int(selectedCardCount)) cards")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Slider(value: $selectedCardCount, in: Double(minCards)...Double(maxCards), step: 1)
                                .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            
                            HStack {
                                Text("\(minCards)")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                Spacer()
                                Text("\(maxCards)")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
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
        .onAppear {
            updateInitialCardCount()
        }
        .background(
            NavigationLink(
                destination: WYRLoadingView(
                    deck: deck,
                    selectedCategories: selectedCategories,
                    cardCount: Int(selectedCardCount)
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
        WYRSetupView(
            deck: Deck(
                title: "Would You Rather",
                description: "Make tough choices and discover what your friends prefer",
                numberOfCards: 330,
                estimatedTime: "30-45 min",
                imageName: "WYR artwork",
                type: .wouldYouRather,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

