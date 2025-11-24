//
//  SplashView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct SplashView: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.5
    @State private var logoRotation: Double = -180
    @State private var logoBounce: CGFloat = 0
    @State private var showAgeCheck: Bool = false
    @State private var ageCheckOpacity: Double = 0
    
    let words = ["The", "Social", "Deck"]
    @State private var wordOpacities: [Double] = [0, 0, 0]
    @State private var wordScales: [CGFloat] = [0.3, 0.3, 0.3]
    @State private var wordOffsets: [CGFloat] = [50, 50, 50]
    
    var body: some View {
        ZStack {
            // Splash screen content
            ZStack {
                // Red background
                Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
                    .ignoresSafeArea()
                
                // Logo and text
                VStack(spacing: 20) {
                    // Logo from Assets with enhanced animation
                    Image("TheSocialDeckLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .opacity(logoOpacity)
                        .scaleEffect(logoScale)
                        .rotationEffect(.degrees(logoRotation))
                        .offset(y: logoBounce)
                    
                    // Text under logo - word by word animation
                    HStack(spacing: 8) {
                        ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                            Text(word)
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.black)
                                .opacity(wordOpacities[index])
                                .scaleEffect(wordScales[index])
                                .offset(y: wordOffsets[index])
                        }
                    }
                }
            }
            .opacity(showAgeCheck ? 0 : 1)
            
            // AgeCheckView overlay
            if showAgeCheck {
                AgeCheckView()
                    .opacity(ageCheckOpacity)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Logo animation: rotate, scale, fade in, and bounce
            withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                logoOpacity = 1.0
                logoScale = 1.0
                logoRotation = 0
            }
            
            // Bounce effect for logo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.4)) {
                    logoBounce = -10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.4)) {
                        logoBounce = 0
                    }
                }
            }
            
            // Animate words one by one
            for index in 0..<words.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2 + Double(index) * 0.15) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                        wordOpacities[index] = 1.0
                        wordScales[index] = 1.0
                        wordOffsets[index] = 0
                    }
                }
            }
            
            // Fade out and navigate after 4.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                // Fade out splash screen
                withAnimation(.easeIn(duration: 0.5)) {
                    showAgeCheck = true
                }
                
                // Fade in AgeCheckView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        ageCheckOpacity = 1.0
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}

