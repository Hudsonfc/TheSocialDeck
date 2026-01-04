//
//  RateUsView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI
import StoreKit

struct RateUsView: View {
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
            
            // Rate Us Card
            VStack(spacing: 0) {
                // Content
                VStack(spacing: 28) {
                    // Bearded man icon
                    Image("bearded man")
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top, 36)
                    
                    // Title
                    Text("Love The Social Deck?")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Description
                    VStack(spacing: 16) {
                        Text("Your feedback helps us improve! Please take a moment to rate us on the App Store.")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x5A/255.0, green: 0x5A/255.0, blue: 0x5A/255.0))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 40)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Rate Us Button
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            requestReview()
                            dismissView()
                        }) {
                            Text("Rate Us")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .cornerRadius(16)
                        }
                        
                        // Maybe Later Button
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            dismissView()
                        }) {
                            Text("Maybe Later")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 36)
                }
            }
            .frame(width: 340)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
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
    
    private func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    RateUsView(isPresented: .constant(true))
}

