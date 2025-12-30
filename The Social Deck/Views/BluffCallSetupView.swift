//
//  BluffCallSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct BluffCallSetupView: View {
    let deck: Deck
    let selectedCategories: [String]
    @State private var navigateToPlay: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // Player management
    @State private var players: [String] = []
    @State private var newPlayerName: String = ""
    
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
                
                ScrollView {
                    VStack(spacing: 32) {
                            // Game artwork - regular card image
                        Image(deck.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.top, 20)
                    
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
                        
                        // Players section
                        VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Add Players")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Text("Enter each player's name and tap the + button to add them to the game.")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 20)
                        }
                        
                        // Player list
                        if players.isEmpty {
                            Text("No players added yet")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                                    HStack {
                                        Text(player)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            players.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                    .cornerRadius(12)
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                        
                        // Add player input
                        HStack(spacing: 12) {
                            TextField("Player name", text: $newPlayerName)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                .cornerRadius(12)
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .onSubmit {
                                    addPlayer()
                                }
                            
                            Button(action: {
                                addPlayer()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            }
                        }
                        }
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
                        .padding(.horizontal, 40)
                        
                        // Start Game button
                        PrimaryButton(title: "Start Game") {
                            navigateToPlay = true
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        .disabled(players.isEmpty)
                        .opacity(players.isEmpty ? 0.5 : 1.0)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            updateInitialCardCount()
        }
        .background(
            NavigationLink(
                destination: BluffCallLoadingView(
                    deck: deck,
                    selectedCategories: selectedCategories,
                    cardCount: Int(selectedCardCount),
                    players: players
                ),
                isActive: $navigateToPlay
            ) {
                EmptyView()
            }
        )
    }
    
    private func addPlayer() {
        let trimmedName = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        // Validate: not empty, not duplicate, and reasonable length
        if !trimmedName.isEmpty 
            && !players.contains(trimmedName) 
            && trimmedName.count <= 30 {
            players.append(trimmedName)
            newPlayerName = ""
        }
    }
}

#Preview {
    NavigationView {
        BluffCallSetupView(
            deck: Deck(
                title: "Bluff Call",
                description: "Convince the group your answer is true, or call their bluff!",
                numberOfCards: 300,
                estimatedTime: "15-20 min",
                imageName: "Art 1.4",
                type: .bluffCall,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

