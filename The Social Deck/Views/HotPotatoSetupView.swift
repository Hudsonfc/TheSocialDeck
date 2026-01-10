//
//  HotPotatoSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import UIKit

struct HotPotatoSetupView: View {
    let deck: Deck
    @State private var players: [String] = []
    @State private var newPlayerName: String = ""
    @State private var navigateToPlay: Bool = false
    @State private var perksEnabled: Bool = true
    @State private var showPerksBreakdown: Bool = false
    @State private var numberOfRounds: Double = 5
    @Environment(\.dismiss) private var dismiss
    
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
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                        
                        // Number of rounds section
                        VStack(spacing: 12) {
                            Text("Number of Rounds")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                            
                            Text("\(Int(numberOfRounds)) rounds")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color.primaryAccent)
                            
                            Slider(value: $numberOfRounds, in: 1...15, step: 1)
                                .tint(Color.primaryAccent)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                        
                        // Perks toggle
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Perks")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    
                                    Text("Turn this on to play with perks")
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondaryText.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $perksEnabled)
                                    .tint(Color.primaryAccent)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(12)
                            
                            // Perks breakdown button
                            Button(action: {
                                showPerksBreakdown = true
                            }) {
                                HStack {
                                    Text("View All Perks")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color.primaryAccent)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color.primaryAccent)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(Color.tertiaryBackground)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 32)
                        
                        // Tips section
                        if players.count >= 2 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tips")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                
                                tipRow(icon: "timer", text: "Pass the phone before time runs out")
                                tipRow(icon: "flame.fill", text: "Heat increases as timer counts down")
                                tipRow(icon: "gift.fill", text: "Perks can help you survive")
                            }
                            .padding(16)
                            .background(Color.secondaryBackground)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)
                        }
                        
                        // Start Game button
                        Button(action: {
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            // Small delay for smoother transition
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                navigateToPlay = true
                            }
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
        .background(
            Group {
                NavigationLink(
                    destination: HotPotatoLoadingView(
                        deck: deck,
                        players: players,
                        perksEnabled: perksEnabled,
                        numberOfRounds: Int(numberOfRounds)
                    ),
                    isActive: $navigateToPlay
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: PerksBreakdownView(),
                    isActive: $showPerksBreakdown
                ) {
                    EmptyView()
                }
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
        HotPotatoSetupView(
            deck: Deck(
                title: "Hot Potato",
                description: "Pass the phone quickly before the timer runs out!",
                numberOfCards: 50,
                estimatedTime: "10-15 min",
                imageName: "Art 1.4",
                type: .hotPotato,
                cards: [],
                availableCategories: []
            )
        )
    }
}

