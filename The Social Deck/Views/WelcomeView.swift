//
//  WelcomeView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool
    @State private var backgroundOpacity: Double = 0
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissView()
                }
            
            // Welcome Card
            VStack(spacing: 0) {
                // Content
                VStack(spacing: 28) {
                    // Blue man icon representing playing
                    Image("Blue man")
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top, 36)
                    
                    // Title
                    Text("Ready to Play?")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    
                    // Description
                    VStack(spacing: 16) {
                        Text("Browse our collection of card games, pick your favorites, and start playing with friends!")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 40)
                    }
                    
                    // Get Started Button
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        dismissView()
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.buttonBackground)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 36)
                }
            }
            .frame(width: 340)
            .background(Color.cardBackground)
            .cornerRadius(24)
            .shadow(color: Color.cardShadowColor, radius: 20, x: 0, y: 10)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
        }
        .onAppear {
            // Smooth fade-in animation
            withAnimation(.easeOut(duration: 0.3)) {
                backgroundOpacity = 0.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    cardScale = 1.0
                    cardOpacity = 1.0
                }
            }
        }
    }
    
    private func dismissView() {
        withAnimation(.easeIn(duration: 0.25)) {
            cardScale = 0.8
            cardOpacity = 0
            backgroundOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
        }
    }
}

#Preview {
    WelcomeView(isPresented: .constant(true))
}

