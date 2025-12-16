//
//  TapDuelSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import UIKit

struct TapDuelSetupView: View {
    let deck: Deck
    @State private var player1Name: String = ""
    @State private var player2Name: String = ""
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
                            .padding(.bottom, 32)
                        
                        // Players section
                        VStack(spacing: 24) {
                            VStack(spacing: 8) {
                                Text("Enter Player Names")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                
                                Text("Two players will share the phone. Enter both names to start.")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Player 1 input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Player 1 (Left Side)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                
                                TextField("Enter name", text: $player1Name)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                    .cornerRadius(12)
                                    .autocapitalization(.words)
                                    .disableAutocorrection(true)
                            }
                            
                            // Player 2 input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Player 2 (Right Side)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                
                                TextField("Enter name", text: $player2Name)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                    .cornerRadius(12)
                                    .autocapitalization(.words)
                                    .disableAutocorrection(true)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 32)
                        
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
                        .padding(.top, 20)
                        .disabled(player1Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || player2Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity((player1Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || player2Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1.0)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: TapDuelLoadingView(
                    deck: deck,
                    player1Name: player1Name.trimmingCharacters(in: .whitespacesAndNewlines),
                    player2Name: player2Name.trimmingCharacters(in: .whitespacesAndNewlines)
                ),
                isActive: $navigateToPlay
            ) {
                EmptyView()
            }
        )
    }
}

#Preview {
    NavigationView {
        TapDuelSetupView(
            deck: Deck(
                title: "Tap Duel",
                description: "Fast head-to-head reaction game",
                numberOfCards: 0,
                estimatedTime: "2-5 min",
                imageName: "TD artwork",
                type: .tapDuel,
                cards: [],
                availableCategories: []
            )
        )
    }
}

