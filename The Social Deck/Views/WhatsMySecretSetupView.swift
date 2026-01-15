//
//  WhatsMySecretSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import UIKit

struct WhatsMySecretSetupView: View {
    let deck: Deck
    @State private var selectedCategories: [String] = []
    @State private var players: [String] = []
    @State private var newPlayerName: String = ""
    @State private var navigateToPlay: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    private let minCards: Int = 1
    private let maxCards: Int = 15
    
    @State private var selectedCardCount: Double = 5
    
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
                    
                    Text("\(players.count)/12 Players")
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
                                Text("Number of Secrets")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondaryText)
                                
                            VStack(spacing: 8) {
                                Text("\(Int(selectedCardCount)) secret\(Int(selectedCardCount) == 1 ? "" : "s")")
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
                            .padding(.bottom, 32)
                            
                            // Tips section
                            if players.count >= 2 {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Tips")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    
                                    tipRow(icon: "person.2.fill", text: "Each player gets a secret rule to follow")
                                    tipRow(icon: "eye.slash.fill", text: "Don't reveal your secret until the end")
                                    tipRow(icon: "bubble.left.and.bubble.right.fill", text: "Try to guess others' secrets")
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
                    .disabled(players.count < 2)
                    .opacity(players.count >= 2 ? 1.0 : 0.5)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Initialize selectedCategories with all available categories
            if selectedCategories.isEmpty {
                selectedCategories = deck.availableCategories
            }
        }
        .background(
            NavigationLink(
                destination: WhatsMySecretLoadingView(
                    deck: deck,
                    selectedCategories: deck.availableCategories,
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
        WhatsMySecretSetupView(
            deck: Deck(
                title: "What's My Secret?",
                description: "Test",
                numberOfCards: 50,
                estimatedTime: "5-10 min",
                imageName: "WMS artwork",
                type: .whatsMySecret,
                cards: [],
                availableCategories: ["Party", "Wild"]
            )
        )
    }
}
