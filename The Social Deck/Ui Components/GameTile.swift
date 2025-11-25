//
//  GameTile.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct GameTile: View {
    let gameName: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Placeholder artwork
            Image("Art 1.4")
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipped()
                .cornerRadius(12)
            
            // Game name placeholder
            Text(gameName)
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
}

#Preview {
    GameTile(gameName: "Game Name")
        .padding()
}

