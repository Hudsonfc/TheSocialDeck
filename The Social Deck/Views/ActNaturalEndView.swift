//
//  ActNaturalEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI

struct ActNaturalEndView: View {
    @ObservedObject var manager: ActNaturalGameManager
    let deck: Deck
    @State private var navigateToSetup: Bool = false
    @State private var navigateToHome: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.white
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
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // End content
                VStack(spacing: 32) {
                    // Game artwork
                    Image(deck.imageName)
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFit()
                        .frame(width: 160, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
                    
                    VStack(spacing: 12) {
                        Text("Great Game!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("Did you guess the unknown player(s)?")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    }
                    
                    // Game summary
                    VStack(spacing: 16) {
                        summaryRow(label: "Players", value: "\(manager.players.count)")
                        summaryRow(label: "Unknowns", value: "\(manager.unknownCount)")
                        summaryRow(label: "Word", value: manager.secretWord?.word ?? "—")
                    }
                    .padding(20)
                    .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: playAgain) {
                        Text("Play Again")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    
                    Button(action: newGame) {
                        Text("New Players")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
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
                destination: ActNaturalPlayerSetupView(deck: deck),
                isActive: $navigateToSetup
            ) {
                EmptyView()
            }
        )
    }
    
    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
        }
    }
    
    private func playAgain() {
        HapticManager.shared.mediumImpact()
        manager.resetGame()
        navigateToSetup = true
    }
    
    private func newGame() {
        HapticManager.shared.mediumImpact()
        manager.resetGame()
        navigateToSetup = true
    }
}

#Preview {
    NavigationView {
        ActNaturalEndView(
            manager: {
                let manager = ActNaturalGameManager()
                manager.addPlayer(name: "Alice")
                manager.addPlayer(name: "Bob")
                manager.addPlayer(name: "Charlie")
                manager.startGame()
                return manager
            }(),
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

