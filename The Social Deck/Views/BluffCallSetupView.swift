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
            // Adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
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
                    
                    Text("\(players.count)/12 Players")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 32) {
                            // Game artwork
                        Image(deck.imageName)
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .scaledToFit()
                            .frame(width: 120, height: 165)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                            .padding(.top, 20)
                        
                        // Title
                        Text("Add Players")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .padding(.top, 20)
                        
                        Text("Minimum 2 players required")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .padding(.top, 4)
                        
                        // Selected categories chips
                        VStack(spacing: 12) {
                            Text("Selected Categories")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.secondaryText)
                        
                        if selectedCategories.count <= 3 {
                            // Center when 3 or fewer categories
                            HStack(spacing: 12) {
                                ForEach(selectedCategories, id: \.self) { category in
                                    Text(category)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.buttonBackground)
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
                                            .background(Color.buttonBackground)
                                            .cornerRadius(24)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        }
                        
                        // Players section
                        VStack(spacing: 0) {
                            // Name input
                            HStack(spacing: 12) {
                                TextField("Enter player name", text: $newPlayerName)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color.secondaryBackground)
                                    .cornerRadius(12)
                                    .autocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .onSubmit {
                                        addPlayer()
                                    }
                                
                                Button(action: {
                                    addPlayer()
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            players.count < 12 && !newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty
                                                ? Color.primaryAccent
                                                : Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0)
                                        )
                                        .cornerRadius(12)
                                }
                                .disabled(players.count >= 12 || newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            
                            // Players list
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                                        HStack {
                                            Text("\(index + 1).")
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundColor(.secondaryText)
                                                .frame(width: 30, alignment: .leading)
                                            
                                            Text(player)
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                                .foregroundColor(.primaryText)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                players.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0))
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.secondaryBackground)
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 16)
                        }
                        
                        // Card Count Selector
                        VStack(spacing: 12) {
                        Text("Number of Cards")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                        
                        VStack(spacing: 8) {
                            Text("\(Int(selectedCardCount)) cards")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                            
                            Slider(value: $selectedCardCount, in: Double(minCards)...Double(maxCards), step: 1)
                                .tint(Color.primaryAccent)
                            
                            HStack {
                                Text("\(minCards)")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondaryText)
                                Spacer()
                                Text("\(maxCards)")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondaryText)
                            }
                        }
                        .padding(.horizontal, 20)
                        }
                        .padding(.horizontal, 40)
                        
                        // Tips section
                        if players.count >= 2 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tips")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                
                                tipRow(icon: "questionmark.circle.fill", text: "Answer truthfully or bluff")
                                tipRow(icon: "hand.raised.fill", text: "Group votes on whether to believe you")
                                tipRow(icon: "trophy.fill", text: "Score points for successful bluffs")
                            }
                            .padding(16)
                            .background(Color.secondaryBackground)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)
                        }
                        
                        // Start Game button
                        Button(action: {
                            navigateToPlay = true
                        }) {
                            Text("Start Game")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    players.count >= 2
                                        ? Color.primaryAccent
                                        : Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0)
                                )
                                .cornerRadius(16)
                        }
                        .disabled(players.count < 2)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                        
                        // Tips section
                        if players.count >= 2 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tips")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                
                                tipRow(icon: "questionmark.circle.fill", text: "Answer truthfully or bluff")
                                tipRow(icon: "hand.raised.fill", text: "Group votes on whether to believe you")
                                tipRow(icon: "trophy.fill", text: "Score points for successful bluffs")
                            }
                            .padding(16)
                            .background(Color.secondaryBackground)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)
                        }
                        
                        // Start Game button
                        Button(action: {
                            navigateToPlay = true
                        }) {
                            Text("Start Game")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    players.count >= 2
                                        ? Color.primaryAccent
                                        : Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0)
                                )
                                .cornerRadius(16)
                        }
                        .disabled(players.count < 2)
                        .padding(.horizontal, 24)
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
            && trimmedName.count <= 30
            && players.count < 12 {
            players.append(trimmedName)
            newPlayerName = ""
        }
    }
    
    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color.primaryAccent)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
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

