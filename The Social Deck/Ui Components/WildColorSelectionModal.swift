//
//  WildColorSelectionModal.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct WildColorSelectionModal: View {
    let onSelect: (CardColor) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Color")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .padding(.top, 24)
            
            HStack(spacing: 20) {
                ForEach(CardColor.allCases, id: \.self) { color in
                    Button(action: {
                        onSelect(color)
                    }) {
                        Circle()
                            .fill(colorForCardColor(color))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .shadow(color: colorForCardColor(color).opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private func colorForCardColor(_ cardColor: CardColor) -> Color {
        switch cardColor {
        case .red:
            return Color(red: 0xE5/255.0, green: 0x39/255.0, blue: 0x46/255.0)
        case .blue:
            return Color(red: 0x21/255.0, green: 0x96/255.0, blue: 0xF3/255.0)
        case .yellow:
            return Color(red: 0xFF/255.0, green: 0xC1/255.0, blue: 0x07/255.0)
        case .green:
            return Color(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x50/255.0)
        }
    }
}

