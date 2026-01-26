//
//  RiddleMeThisSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import UIKit

struct RiddleMeThisSetupView: View {
    let deck: Deck
    @State private var navigateToPlay: Bool = false
    @State private var timerEnabled: Bool = false
    @State private var timerDuration: Double = 30
    @Environment(\.dismiss) private var dismiss
    
    private let minCards: Int = 1
    private let maxCards: Int = 50
    
    @State private var selectedCardCount: Double = 10
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button at top left
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
                            // Game artwork - regular card image
                            Image(deck.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                                .padding(.top, 20)
                                .padding(.bottom, 32)
                            
                            // Card Count Selector
                            VStack(spacing: 12) {
                                Text("Number of Riddles")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondaryText)
                                
                                VStack(spacing: 8) {
                                    Text("\(Int(selectedCardCount)) riddle\(Int(selectedCardCount) == 1 ? "" : "s")")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    
                                    Slider(value: $selectedCardCount, in: Double(minCards)...Double(min(maxCards, deck.numberOfCards)), step: 1)
                                        .tint(Color.primaryAccent)
                                    
                                    HStack {
                                        Text("\(minCards)")
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundColor(.secondaryText)
                                        Spacer()
                                        Text("\(min(maxCards, deck.numberOfCards))")
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundColor(.secondaryText)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                            
                            // Timer Toggle Section
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Timer")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primaryText)
                                        
                                        Text("Add urgency with a countdown timer")
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundColor(.secondaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $timerEnabled)
                                        .tint(Color.primaryAccent)
                                }
                                
                                if timerEnabled {
                                    VStack(spacing: 8) {
                                        Text(formatTimerDuration(Int(timerDuration)))
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color.primaryAccent)
                                        
                                        Slider(value: $timerDuration, in: 15...180, step: 5)
                                            .tint(Color.primaryAccent)
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.secondaryBackground)
                            .cornerRadius(16)
                            .animation(.easeInOut(duration: 0.2), value: timerEnabled)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 32)
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
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: RiddleMeThisPlayView(
                    manager: RiddleMeThisGameManager(deck: deck, cardCount: Int(selectedCardCount), timerEnabled: timerEnabled, timerDuration: Int(timerDuration)),
                    deck: deck
                ),
                isActive: $navigateToPlay
            ) {
                EmptyView()
            }
        )
    }
    
    private func formatTimerDuration(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds) seconds per riddle"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds == 0 {
                return "\(minutes) minute\(minutes == 1 ? "" : "s") per riddle"
            } else {
                return "\(minutes)m \(remainingSeconds)s per riddle"
            }
        }
    }
}

#Preview {
    NavigationView {
        RiddleMeThisSetupView(
            deck: Deck(
                title: "Riddle Me This",
                description: "Solve riddles to progress.",
                numberOfCards: 50,
                estimatedTime: "5-10 min",
                imageName: "RMT artwork",
                type: .riddleMeThis,
                cards: allRiddleMeThisCards,
                availableCategories: []
            )
        )
    }
}
