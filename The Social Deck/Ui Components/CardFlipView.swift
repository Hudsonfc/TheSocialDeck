//
//  CardFlipView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct CardFlipView: View {
    let deck: Deck
    @Binding var expandedDeck: Deck?
    
    init(deck: Deck, expandedDeck: Binding<Deck?>) {
        self.deck = deck
        self._expandedDeck = expandedDeck
    }
    
    var body: some View {
        // Card view
        frontSide
            .frame(width: 140, height: 180)
            .onTapGesture {
                expandCard()
            }
    }
    
    // Front side - DeckTile
    private var frontSide: some View {
        VStack(spacing: 8) {
            // Placeholder artwork
            Image(deck.imageName)
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipped()
                .cornerRadius(12)
            
            // Deck title
            Text(deck.title)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 140)
        }
        .frame(width: 140, height: 180)
        .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
        .cornerRadius(16)
    }
    
    private func expandCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            expandedDeck = deck
        }
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var expandedDeck: Deck? = nil
        
        var body: some View {
            HStack {
                CardFlipView(
                    deck: Deck(
                        title: "Never Have I Ever",
                        description: "Reveal your wildest experiences and learn about your friends.",
                        numberOfCards: 50,
                        estimatedTime: "5-10 min",
                        imageName: "NHIE artwork",
                        type: .neverHaveIEver,
                        cards: [],
                        availableCategories: ["Party", "Wild"]
                    ),
                    expandedDeck: $expandedDeck
                )
                
                CardFlipView(
                    deck: Deck(
                        title: "Truth or Dare",
                        description: "Choose truth or dare and see where the night takes you.",
                        numberOfCards: 75,
                        estimatedTime: "10-15 min",
                        imageName: "Art 1.4",
                        type: .other,
                        cards: [],
                        availableCategories: []
                    ),
                    expandedDeck: $expandedDeck
                )
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
    }
    
    return PreviewWrapper()
}

