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
    @State private var logoExitOffset: CGFloat = 0
    @State private var navigateToOnboarding: Bool = false
    @State private var navigateToHome: Bool = false
    
    let words = ["The", "Social", "Deck"]
    @State private var wordOpacities: [Double] = [0, 0, 0]
    @State private var wordScales: [CGFloat] = [0.3, 0.3, 0.3]
    @State private var wordOffsets: [CGFloat] = [50, 50, 50]
    @State private var wordExitOffsets: [CGFloat] = [0, 0, 0]
    
    var body: some View {
        ZStack {
            // Splash screen content
            ZStack {
                // White background
                Color.white
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
                        .offset(y: logoBounce + logoExitOffset)
                    
                    // Text under logo - word by word animation
                    HStack(spacing: 8) {
                        ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                            Text(word)
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.black)
                                .opacity(wordOpacities[index])
                                .scaleEffect(wordScales[index])
                                .offset(y: wordOffsets[index] + wordExitOffsets[index])
                        }
                    }
                }
            }
            .opacity(navigateToOnboarding || navigateToHome ? 0 : 1)
            
            // Navigate to OnboardingView if not completed
            if navigateToOnboarding {
                OnboardingView()
                    .transition(.opacity)
            }
            
            // Navigate to HomeView if onboarding already completed
            if navigateToHome {
                HomeView()
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
            
            // Start exit animations and navigate after 3.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                // Logo exit animation: scale down, rotate slightly, fade out, move up
                withAnimation(.easeIn(duration: 0.4)) {
                    logoScale = 0.3
                    logoRotation = 15
                    logoOpacity = 0
                    logoExitOffset = -30
                }
                
                // Text exit animation: scale down, fade out, move up (staggered in reverse)
                for index in (0..<words.count).reversed() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(words.count - 1 - index) * 0.08) {
                        withAnimation(.easeIn(duration: 0.4)) {
                            wordScales[index] = 0.2
                            wordOpacities[index] = 0
                            wordExitOffsets[index] = -20
                        }
                    }
                }
                
                // Navigate after exit animations
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Check if onboarding has been completed
                    if OnboardingManager.shared.hasCompletedOnboarding {
                        withAnimation(.easeIn(duration: 0.3)) {
                            navigateToHome = true
                        }
                    } else {
                        withAnimation(.easeIn(duration: 0.3)) {
                            navigateToOnboarding = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}

