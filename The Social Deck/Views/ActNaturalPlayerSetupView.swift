//
//  ActNaturalPlayerSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI

struct ActNaturalPlayerSetupView: View {
    let deck: Deck
    @StateObject private var manager = ActNaturalGameManager()
    @State private var currentName: String = ""
    @State private var showError: Bool = false
    @State private var navigateToReveal: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    private let minPlayers = 3
    private let maxPlayers = 12
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("\(manager.players.count)/\(maxPlayers) Players")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
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
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.top, 20)
                
                // Title
                Text("Add Players")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .padding(.top, 20)
                
                Text("Minimum \(minPlayers) players required")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .padding(.top, 4)
                
                // Name input
                HStack(spacing: 12) {
                    TextField("Enter player name", text: $currentName)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(showError ? Color.red : Color.clear, lineWidth: 1)
                        )
                    
                    Button(action: addPlayer) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                manager.players.count < maxPlayers && !currentName.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
                                    : Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(manager.players.count >= maxPlayers || currentName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Players list
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(manager.players.enumerated()), id: \.element.id) { index, player in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                    .frame(width: 30, alignment: .leading)
                                
                                Text(player.name)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        manager.removePlayer(at: index)
                                    }
                                    HapticManager.shared.lightImpact()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 16)
                
                Spacer()
                
                // Unknown count info
                if manager.players.count >= minPlayers {
                    Text(manager.players.count >= 6 ? "2 unknowns will be chosen" : "1 unknown will be chosen")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .padding(.bottom, 8)
                }
                
                // Start button
                Button(action: startGame) {
                    Text("Start Game")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            manager.players.count >= minPlayers
                                ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
                                : Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0)
                        )
                        .cornerRadius(16)
                }
                .disabled(manager.players.count < minPlayers)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: ActNaturalRevealView(manager: manager, deck: deck),
                isActive: $navigateToReveal
            ) {
                EmptyView()
            }
        )
    }
    
    private func addPlayer() {
        let trimmedName = currentName.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty else {
            showError = true
            return
        }
        
        guard manager.players.count < maxPlayers else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            manager.addPlayer(name: trimmedName)
        }
        currentName = ""
        showError = false
        HapticManager.shared.lightImpact()
    }
    
    private func startGame() {
        manager.startGame()
        navigateToReveal = true
        HapticManager.shared.mediumImpact()
    }
}

#Preview {
    NavigationView {
        ActNaturalPlayerSetupView(
            deck: Deck(
                title: "Act Natural",
                description: "Blend in or get caught!",
                numberOfCards: 150,
                estimatedTime: "10-20 min",
                imageName: "AN 2.0",
                type: .other,
                cards: [],
                availableCategories: []
            )
        )
    }
}

