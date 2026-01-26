//
//  StoryChainSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct StoryChainSetupView: View {
    let deck: Deck
    let existingPlayers: [String]?
    @State private var players: [String] = []
    @State private var newPlayerName: String = ""
    @State private var navigateToPlay: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(deck: Deck, existingPlayers: [String]? = nil) {
        self.deck = deck
        self.existingPlayers = existingPlayers
    }
    
    private let minPlayers = 2
    private let maxPlayers = 12
    
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
                    
                    Text("\(players.count)/\(maxPlayers) Players")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
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
                
                Text("Minimum \(minPlayers) players required")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .padding(.top, 4)
                
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
                                players.count < maxPlayers && !newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color.primaryAccent
                                    : Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(players.count >= maxPlayers || newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
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
                
                Spacer()
                
                // Start button
                Button(action: startGame) {
                    Text("Start Game")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            players.count >= minPlayers
                                ? Color.primaryAccent
                                : Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0)
                        )
                        .cornerRadius(16)
                }
                .disabled(players.count < minPlayers)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Load existing players if provided
            if let existing = existingPlayers {
                players = existing
            }
        }
        .background(
            NavigationLink(
                destination: StoryChainPlayView(
                    manager: StoryChainGameManager(deck: deck, players: players),
                    deck: deck
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
            && players.count < maxPlayers {
            players.append(trimmedName)
            newPlayerName = ""
        }
    }
    
    private func startGame() {
        navigateToPlay = true
    }
}

#Preview {
    NavigationView {
        StoryChainSetupView(
            deck: Deck(
                title: "Story Chain",
                description: "Add one sentence to continue the story. Pass the phone and watch the chaos unfold.",
                numberOfCards: 145,
                estimatedTime: "15-25 min",
                imageName: "SC artwork",
                type: .storyChain,
                cards: allStoryChainCards,
                availableCategories: []
            ),
            existingPlayers: nil
        )
    }
}
