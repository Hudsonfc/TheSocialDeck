//
//  LoadingIndicator.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct LoadingIndicator: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Outer ring background (subtle gray)
            Circle()
                .stroke(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0), lineWidth: 5)
                .frame(width: 56, height: 56)
            
            // Rotating progress ring with gradient
            Circle()
                .trim(from: 0.0, to: 0.7)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0),
                            Color(red: 0xFF/255.0, green: 0x6B/255.0, blue: 0x6B/255.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 56, height: 56)
                .rotationEffect(.degrees(rotationAngle))
        }
        .onAppear {
            // Start continuous rotation
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}
