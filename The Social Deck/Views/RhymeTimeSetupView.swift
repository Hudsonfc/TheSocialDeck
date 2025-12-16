//
//  RhymeTimeSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import UIKit

struct RhymeTimeSetupView: View {
    let deck: Deck
    @State private var players: [String] = []
    @State private var newPlayerName: String = ""
    @State private var navigateToPlay: Bool = false
    @Environment(\.dismiss) private var dismiss
    
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
                        // Game artwork
                        Image(deck.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipped()
                            .cornerRadius(100)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.top, 20)
                            .padding(.bottom, players.count > 3 ? 20 : 32)
                        
                        // Players section
                        VStack(spacing: players.count > 3 ? 12 : 16) {
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
                                ScrollView {
                                    VStack(spacing: players.count > 3 ? 8 : 12) {
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
                                            .padding(.vertical, players.count > 3 ? 12 : 14)
                                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .frame(maxHeight: players.count > 3 ? 180 : 200)
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
                        .padding(.bottom, players.count > 3 ? 20 : 32)
                        
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
                        .padding(.top, players.count > 3 ? 16 : 20)
                        .disabled(players.isEmpty)
                        .opacity(players.isEmpty ? 0.5 : 1.0)
                        .padding(.bottom, players.count > 3 ? 32 : 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: RhymeTimeLoadingView(
                    deck: deck,
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
        RhymeTimeSetupView(
            deck: Deck(
                title: "Rhyme Time",
                description: "Say words that rhyme!",
                numberOfCards: 40,
                estimatedTime: "10-15 min",
                imageName: "Art 1.4",
                type: .rhymeTime,
                cards: allRhymeTimeCards,
                availableCategories: []
            )
        )
    }
}

