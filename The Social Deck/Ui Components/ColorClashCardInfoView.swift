//
//  ColorClashCardInfoView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ColorClashCardInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    Text("Card Guide")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 8)
                    
                    // Number Cards
                    cardTypeSection(
                        title: "Number Cards (0-9)",
                        description: "Standard play cards. Match the color or number of the current card.",
                        icon: "number",
                        color: Color(red: 0x4A/255.0, green: 0x90/255.0, blue: 0xE2/255.0)
                    )
                    
                    // Skip Card
                    cardTypeSection(
                        title: "Skip",
                        description: "Skips the next player's turn. They cannot play or draw.",
                        icon: "arrow.right.circle.fill",
                        color: Color(red: 0xE5/255.0, green: 0x39/255.0, blue: 0x46/255.0)
                    )
                    
                    // Reverse Card
                    cardTypeSection(
                        title: "Reverse",
                        description: "Reverses the direction of play. Clockwise becomes counter-clockwise and vice versa.",
                        icon: "arrow.uturn.backward.circle.fill",
                        color: Color(red: 0xFF/255.0, green: 0xC1/255.0, blue: 0x07/255.0)
                    )
                    
                    // Draw Two Card
                    cardTypeSection(
                        title: "Draw Two",
                        description: "The next player must draw 2 cards and skip their turn.",
                        icon: "+2",
                        color: Color(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x50/255.0)
                    )
                    
                    // Wild Card
                    cardTypeSection(
                        title: "Wild",
                        description: "Can be played on any card. Choose the color that becomes active.",
                        icon: "paintbrush.fill",
                        color: Color(red: 0x9C/255.0, green: 0x27/255.0, blue: 0xB0/255.0)
                    )
                    
                    // Wild Draw Four Card
                    cardTypeSection(
                        title: "Wild Draw Four",
                        description: "Choose the active color. The next player must draw 4 cards and skip their turn.",
                        icon: "plus.circle.fill",
                        color: Color(red: 0x1E/255.0, green: 0x1E/255.0, blue: 0x1E/255.0)
                    )
                    
                    // Game Rules Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Game Rules")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        ruleItem("Match the color or number of the current card")
                        ruleItem("If you can't play, draw a card")
                        ruleItem("First to empty your hand wins")
                        ruleItem("Declare 'Last Card' when you have one card left")
                        ruleItem("Wild cards can be played anytime")
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0xFA/255.0, green: 0xFA/255.0, blue: 0xFA/255.0),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 32, height: 32)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    private func cardTypeSection(title: String, description: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Simple black icon
            Group {
                if icon == "+2" || icon == "+4" {
                    Text(icon)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.black)
                }
            }
            .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text(description)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func ruleItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x50/255.0))
            
            Text(text)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            
            Spacer()
        }
    }
}

#Preview {
    ColorClashCardInfoView()
}

