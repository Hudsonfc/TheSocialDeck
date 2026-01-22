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
                            Text("Enter Player Names")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primaryText)
                                .padding(.top, 20)
                            
                            Text("Two players required")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .padding(.top, 4)
                            
                            // Players section
                            VStack(spacing: 20) {
                                // Player 1 input
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Player 1 (Left Side)")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    
                                    TextField("Enter name", text: $player1Name)
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(.primaryText)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .background(Color.secondaryBackground)
                                        .cornerRadius(12)
                                        .autocapitalization(.words)
                                        .disableAutocorrection(true)
                                }
                                
                                // Player 2 input
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Player 2 (Right Side)")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    
                                    TextField("Enter name", text: $player2Name)
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(.primaryText)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .background(Color.secondaryBackground)
                                        .cornerRadius(12)
                                        .autocapitalization(.words)
                                        .disableAutocorrection(true)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                            .padding(.bottom, 24)
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
                    .disabled(player1Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || player2Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity((!player1Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !player2Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 1.0 : 0.5)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
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
                numberOfCards: 999,
                estimatedTime: "2-5 min",
                imageName: "TD artwork",
                type: .tapDuel,
                cards: [],
                availableCategories: []
            )
        )
    }
}

