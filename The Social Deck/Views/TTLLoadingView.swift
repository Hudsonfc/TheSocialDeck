//
//  TTLLoadingView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct TTLLoadingView: View {
    let deck: Deck
    let selectedCategories: [String]
    let cardCount: Int
    @State private var navigateToPlay: Bool = false
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.7
    @State private var logoRotation: Double = 0
    @State private var logoBounce: CGFloat = 0
    @State private var hasNavigated: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // The Social Deck Logo with bouncy animations
                Image("TheSocialDeckLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)
                    .rotationEffect(.degrees(logoRotation))
                    .offset(y: logoBounce)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // If we've already navigated (meaning we came back from PlayView), dismiss immediately
            if hasNavigated {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    dismiss()
                }
                return
            }
            
            // Logo animation: fade in with bouncy scale up
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                logoOpacity = 1.0
                logoScale = 1.1
            }
            
            // Bounce back after initial scale
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) {
                    logoScale = 1.0
                }
            }
            
            // Continuous bouncy scale animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                    logoScale = 1.15
                }
            }
            
            // Bouncy vertical movement
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                    logoBounce = -8
                }
            }
            
            // Slow continuous rotation animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                    logoRotation = 360
                }
            }
            
            // Navigate after short delay (1.5 seconds total)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                hasNavigated = true
                navigateToPlay = true
            }
        }
        .background(
            NavigationLink(
                destination: TTLPlayView(
                    manager: TTLGameManager(deck: deck, selectedCategories: selectedCategories, cardCount: cardCount),
                    deck: deck,
                    selectedCategories: selectedCategories
                ),
                isActive: $navigateToPlay
            ) {
                EmptyView()
            }
        )
    }
}

