//
//  LoadingDot.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct LoadingDot: View {
    @Binding var scale: CGFloat
    let delay: Double
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0),
                        Color(red: 0xFF/255.0, green: 0x6B/255.0, blue: 0x6B/255.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 16, height: 16)
            .scaleEffect(scale)
            .shadow(color: Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.4), radius: 6)
    }
}

