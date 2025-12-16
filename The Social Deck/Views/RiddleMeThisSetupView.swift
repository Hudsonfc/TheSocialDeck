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
    @Environment(\.dismiss) private var dismiss
    
    private let minCards: Int = 1
    private let maxCards: Int = 50
    
    @State private var selectedCardCount: Double = 10
    
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
                
                VStack(spacing: 0) {
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
                            
                            // Game description
                            VStack(spacing: 16) {
                                Text("How to Play")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                
                                VStack(spacing: 12) {
                                    Text("Read the riddle out loud to the group. Players race to say the correct answer. Tap 'Show Answer' when ready to reveal the solution.")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(4)
                                    
                                    // Tips section
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Tips")
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                        
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("•")
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                            Text("Tap the card to flip it and reveal the riddle")
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                        }
                                        
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("•")
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                            Text("You can flip the card back and forth as many times as needed")
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                        }
                                        
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("•")
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                            Text("Take your time - there's no timer!")
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 32)
                            
                            // Card Count Selector
                            VStack(spacing: 12) {
                                Text("Number of Riddles")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                
                                VStack(spacing: 8) {
                                    Text("\(Int(selectedCardCount)) riddle\(Int(selectedCardCount) == 1 ? "" : "s")")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                    
                                    Slider(value: $selectedCardCount, in: Double(minCards)...Double(min(maxCards, deck.numberOfCards)), step: 1)
                                        .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    
                                    HStack {
                                        Text("\(minCards)")
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                        Spacer()
                                        Text("\(min(maxCards, deck.numberOfCards))")
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 32)
                        }
                    }
                    
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
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: RiddleMeThisPlayView(
                    manager: RiddleMeThisGameManager(deck: deck, cardCount: Int(selectedCardCount)),
                    deck: deck
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
        RiddleMeThisSetupView(
            deck: Deck(
                title: "Riddle Me This",
                description: "Solve riddles to progress.",
                numberOfCards: 50,
                estimatedTime: "5-10 min",
                imageName: "Art 1.4",
                type: .riddleMeThis,
                cards: allRiddleMeThisCards,
                availableCategories: []
            )
        )
    }
}
