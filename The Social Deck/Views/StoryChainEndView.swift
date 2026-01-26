//
//  StoryChainEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct StoryChainEndView: View {
    let deck: Deck
    let storySentences: [StorySentence]
    @State private var navigateToHome: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    @State private var navigateToNewPlayers: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // Store player names to pass back to setup
    private var playerNames: [String] {
        storySentences.compactMap { $0.author }
    }
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    Button(action: {
                        navigateToHome = true
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Title section with artwork
                HStack(spacing: 16) {
                    Image(deck.imageName)
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFit()
                        .frame(width: 80, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Great Game!")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        
                        Text("Your story is complete!")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                        
                        // Story stats
                        Text("\(storySentences.count) sentences")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color.buttonBackground)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.buttonBackground.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Full story display
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(storySentences.enumerated()), id: \.element.id) { index, sentence in
                            VStack(alignment: .leading, spacing: 6) {
                                // Author label
                                if let author = sentence.author {
                                    Text(author)
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color.buttonBackground)
                                        .textCase(.uppercase)
                                } else {
                                    Text("Starting Line")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(.secondaryText)
                                        .textCase(.uppercase)
                                }
                                
                                // Sentence text
                                Text(sentence.text)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondaryBackground)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        navigateToPlayAgain = true
                    }) {
                        Text("Play Again with Same Players")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.buttonBackground)
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        navigateToNewPlayers = true
                    }) {
                        Text("New Players")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color.buttonBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.secondaryBackground)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHome
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: StoryChainSetupView(deck: deck, existingPlayers: playerNames),
                isActive: $navigateToPlayAgain
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: StoryChainSetupView(deck: deck, existingPlayers: nil),
                isActive: $navigateToNewPlayers
            ) {
                EmptyView()
            }
        )
    }
}

#Preview {
    NavigationView {
        StoryChainEndView(
            deck: Deck(
                title: "Story Chain",
                description: "Add one sentence to continue the story. Pass the phone and watch the chaos unfold.",
                numberOfCards: 145,
                estimatedTime: "15-25 min",
                imageName: "SC artwork",
                type: .storyChain,
                cards: [],
                availableCategories: []
            ),
            storySentences: [
                StorySentence(text: "Once upon a time, a penguin found a key in the middle of the desert.", author: nil),
                StorySentence(text: "The key was glowing with an otherworldly light.", author: "Alice"),
                StorySentence(text: "Suddenly, the ground began to shake.", author: "Bob")
            ]
        )
    }
}
