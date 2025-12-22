//
//  ColorClashLoadingScreen.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ColorClashLoadingScreen: View {
    @State private var currentTipIndex = 0
    @State private var logoScale: CGFloat = 1.0
    @State private var dot1Scale: CGFloat = 0.5
    @State private var dot2Scale: CGFloat = 0.7
    @State private var dot3Scale: CGFloat = 1.0
    
    private let tips: [String] = [
        "Match colors or numbers to play cards",
        "Wild cards can be played anytime",
        "Say 'Last Card' when you have one left!",
        "Draw Two makes the next player draw",
        "Reverse changes the turn direction",
        "Skip to skip the next player's turn"
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0xFA/255.0, green: 0xFA/255.0, blue: 0xFA/255.0),
                    Color.white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Game logo with animation
                Image("color clash artwork logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(logoScale)
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                // Loading indicator - Modern dot animation
                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .frame(width: 12, height: 12)
                            .scaleEffect(dot1Scale)
                        
                        Circle()
                            .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .frame(width: 12, height: 12)
                            .scaleEffect(dot2Scale)
                        
                        Circle()
                            .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .frame(width: 12, height: 12)
                            .scaleEffect(dot3Scale)
                    }
                    
                    Text("Preparing Game")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .tracking(0.5)
                }
                
                // Quick tip
                VStack(spacing: 12) {
                    Text("Quick Tip")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    Text(tips[currentTipIndex])
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .scale))
                        .id(currentTipIndex)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            // Start logo animation (subtle pulse)
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                logoScale = 1.08
            }
            
            // Start dot animations (staggered pulse effect)
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                dot1Scale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    dot2Scale = 1.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    dot3Scale = 1.0
                }
            }
            
            // Rotate tips every 3 seconds
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentTipIndex = (currentTipIndex + 1) % tips.count
                }
            }
        }
    }
}

#Preview {
    ColorClashLoadingScreen()
}
