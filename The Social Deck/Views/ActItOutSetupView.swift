//
//  ActItOutSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 12/31/24.
//

import SwiftUI
import UIKit

struct ActItOutSetupView: View {
    let deck: Deck
    let selectedCategories: [String]
    @State private var players: [String] = []
    @State private var newPlayerName: String = ""
    @State private var navigateToPlay: Bool = false
    @State private var timerEnabled: Bool = true
    @State private var timerDuration: Double = 60
    @State private var useDefaultPlayers: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    // Calculate max cards available from selected categories
    private var maxCardsAvailable: Int {
        var total = 0
        for category in selectedCategories {
            let categoryCards = deck.cards.filter { $0.category == category }
            total += categoryCards.count
        }
        return total
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
        return Double(min(20, max))
    }
    
    @State private var selectedCardCount: Double = 20
    
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
                    VStack(spacing: 0) {
                        // Game artwork - regular card image
                        Image(deck.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                        
                        // Selected categories chips
                        VStack(spacing: 12) {
                            Text("Selected Categories")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            
                            // Chips in scrollable layout
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(selectedCategories, id: \.self) { category in
                                        Text(category)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                                            .cornerRadius(16)
                                    }
                                }
                                .padding(.horizontal, 40)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Timer toggle
                        VStack(spacing: 12) {
                            HStack {
                                Text("Timer")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                
                                Spacer()
                                
                                Toggle("", isOn: $timerEnabled)
                                    .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            }
                            .padding(.horizontal, 40)
                            
                            if timerEnabled {
                                VStack(spacing: 8) {
                                    Text("\(Int(timerDuration)) seconds")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    
                                    Slider(value: $timerDuration, in: 30...90, step: 15)
                                        .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                        .padding(.horizontal, 40)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Card count slider
                        VStack(spacing: 12) {
                            Text("Number of Rounds")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Text("\(Int(selectedCardCount)) rounds")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            
                            if maxCardsAvailable > 0 {
                                Slider(value: $selectedCardCount, in: Double(minCards)...Double(maxCards), step: 1)
                                    .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Players section
                        VStack(spacing: 12) {
                            HStack {
                                Text("Players")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                
                                Spacer()
                                
                                Toggle("Use default names", isOn: $useDefaultPlayers)
                                    .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                            }
                            .padding(.horizontal, 40)
                            
                            if !useDefaultPlayers {
                                VStack(spacing: 12) {
                                    // Add player input
                                    HStack(spacing: 12) {
                                        TextField("Player name", text: $newPlayerName)
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 12)
                                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                            .cornerRadius(10)
                                            .autocapitalization(.words)
                                            .disableAutocorrection(true)
                                            .onSubmit {
                                                addPlayer()
                                            }
                                        
                                        Button(action: {
                                            addPlayer()
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                        }
                                    }
                                    
                                    // Player list
                                    if players.isEmpty {
                                        Text("Add at least 2 players")
                                            .font(.system(size: 13, weight: .regular, design: .rounded))
                                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                            .padding(.vertical, 12)
                                    } else {
                                        VStack(spacing: 8) {
                                            ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                                                HStack {
                                                    Text(player)
                                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                                    
                                                    Spacer()
                                                    
                                                    Button(action: {
                                                        players.remove(at: index)
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .font(.system(size: 18))
                                                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                                .cornerRadius(10)
                                            }
                                        }
                                        .frame(maxHeight: 120)
                                    }
                                }
                                .padding(.horizontal, 40)
                            } else {
                                Text("Players will be assigned default names (Player 1, Player 2, etc.)")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 12)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Start Game button
                        PrimaryButton(title: "Start Game") {
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            // Small delay for smoother transition
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                navigateToPlay = true
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 16)
                        .disabled(!useDefaultPlayers && players.count < 2)
                        .opacity((!useDefaultPlayers && players.count < 2) ? 0.5 : 1.0)
                        .padding(.bottom, 32)
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
                destination: ActItOutLoadingView(
                    deck: deck,
                    selectedCategories: selectedCategories,
                    players: useDefaultPlayers ? [] : players,
                    cardCount: Int(selectedCardCount),
                    timerEnabled: timerEnabled,
                    timerDuration: Int(timerDuration)
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
        ActItOutSetupView(
            deck: Deck(
                title: "Act It Out",
                description: "Act out prompts silently!",
                numberOfCards: 300,
                estimatedTime: "15-30 min",
                imageName: "AIO 2.0",
                type: .actItOut,
                cards: allActItOutCards,
                availableCategories: ["Actions & Verbs", "Animals", "Emotions & Expressions", "Daily Activities", "Sports & Activities", "Objects & Tools", "Food & Cooking", "Famous Concepts", "Movie Genres", "Nature & Weather"]
            ),
            selectedCategories: ["Actions & Verbs", "Animals"]
        )
    }
}

