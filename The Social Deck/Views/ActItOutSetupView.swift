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
    let existingPlayers: [String]?
    @State private var players: [String] = []
    @State private var newPlayerName: String = ""
    @State private var navigateToPlay: Bool = false
    @State private var timerEnabled: Bool = true
    @State private var timerDuration: Double = 60
    @State private var useDefaultPlayers: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    init(deck: Deck, selectedCategories: [String], existingPlayers: [String]? = nil) {
        self.deck = deck
        self.selectedCategories = selectedCategories
        self.existingPlayers = existingPlayers
    }
    
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
            // Dark adaptive background
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
                    
                    Text(useDefaultPlayers ? "Using Default Names" : "\(players.count)/12 Players")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Game artwork
                            Image(deck.imageName)
                                .resizable()
                                .interpolation(.high)
                                .antialiased(true)
                                .scaledToFit()
                                .frame(width: ResponsiveSize.setupArtworkWidth, height: ResponsiveSize.setupArtworkHeight)
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
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondaryText)
                                
                                // Chips in scrollable layout
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(selectedCategories, id: \.self) { category in
                                            Text(category)
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                                .foregroundColor(Color.primaryAccent)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.primaryAccent.opacity(0.1))
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
                                        .foregroundColor(.primaryText)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $timerEnabled)
                                        .tint(Color.primaryAccent)
                                }
                                .padding(.horizontal, 40)
                                
                                if timerEnabled {
                                    VStack(spacing: 8) {
                                        Text("\(Int(timerDuration)) seconds")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color.primaryAccent)
                                        
                                        Slider(value: $timerDuration, in: 30...90, step: 15)
                                            .tint(Color.primaryAccent)
                                            .padding(.horizontal, 40)
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                            
                            // Card count slider
                            VStack(spacing: 12) {
                                Text("Number of Rounds")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                
                                Text("\(Int(selectedCardCount)) rounds")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.primaryAccent)
                                
                                if maxCardsAvailable > 0 {
                                    Slider(value: $selectedCardCount, in: Double(minCards)...Double(maxCards), step: 1)
                                        .tint(Color.primaryAccent)
                                        .padding(.horizontal, 40)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            // Players section
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Players")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    
                                    Spacer()
                                    
                                    Toggle("Use default names", isOn: $useDefaultPlayers)
                                        .tint(Color.primaryAccent)
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                }
                                .padding(.horizontal, 40)
                                
                                if !useDefaultPlayers {
                                    VStack(spacing: 12) {
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
                                    .padding(.horizontal, 40)
                                } else {
                                    Text("Players will be assigned default names (Player 1, Player 2, etc.)")
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondaryText)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                        .padding(.vertical, 12)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            // Tips section
                            if !useDefaultPlayers && players.count >= 2 {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Tips")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    
                                    tipRow(icon: "theatermasks.fill", text: "Act out the word without speaking")
                                    tipRow(icon: "person.2.fill", text: "Others try to guess what you're acting")
                                    tipRow(icon: "timer", text: "Optional timer adds pressure")
                                }
                                .padding(16)
                                .background(Color.secondaryBackground)
                                .cornerRadius(12)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 32)
                            }
                        }
                    }
                    
                    // Start Game button - anchored at bottom
                    PrimaryButton(title: "Start Game") {
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        // Small delay for smoother transition
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            navigateToPlay = true
                        }
                    }
                    .disabled(!useDefaultPlayers && players.count < 2)
                    .opacity(((!useDefaultPlayers && players.count >= 2) || useDefaultPlayers) ? 1.0 : 0.5)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            updateInitialCardCount()
            // Load existing players if provided
            if let existing = existingPlayers {
                players = existing
                useDefaultPlayers = false
            }
        }
        .background(
            NavigationLink(
                destination: ActItOutPlayView(
                    manager: ActItOutGameManager(
                        deck: deck,
                        selectedCategories: selectedCategories,
                        players: useDefaultPlayers ? [] : players,
                        cardCount: Int(selectedCardCount),
                        timerEnabled: timerEnabled,
                        timerDuration: Int(timerDuration)
                    ),
                    deck: deck,
                    selectedCategories: selectedCategories
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

