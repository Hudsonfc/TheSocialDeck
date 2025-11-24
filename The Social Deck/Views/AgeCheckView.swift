//
//  AgeCheckView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct AgeCheckView: View {
    @State private var titleOpacity: Double = 0
    @State private var button1Offset: CGFloat = 50
    @State private var button2Offset: CGFloat = 50
    @State private var button1Opacity: Double = 0
    @State private var button2Opacity: Double = 0
    @State private var showAlert: Bool = false
    @State private var navigateToOnboarding: Bool = false
    
    // Floating animation states
    @State private var button1Float: CGFloat = 0
    @State private var button2Float: CGFloat = 0
    
    // Press states
    @State private var button1Pressed: Bool = false
    @State private var button2Pressed: Bool = false
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            // AgeCheckView content
            if !navigateToOnboarding {
                // Centered VStack
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Title
                    Text("Are you 18 or older?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .opacity(titleOpacity)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Circular buttons in HStack
                    HStack(spacing: 40) {
                    // Button 1: Yes
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            button1Pressed = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                navigateToOnboarding = true
                            }
                        }
                    }) {
                        Text("Yes")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .clipShape(Circle())
                    }
                    .scaleEffect(button1Pressed ? 0.85 : 1.0)
                    .opacity(button1Pressed ? 0.7 : 1.0)
                    .offset(y: button1Offset + button1Float)
                    .opacity(button1Opacity)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !button1Pressed {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                        button1Pressed = true
                                    }
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    button1Pressed = false
                                }
                            }
                    )
                    
                    // Button 2: No
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            button2Pressed = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showAlert = true
                            button2Pressed = false
                        }
                    }) {
                        Text("No")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 100, height: 100)
                            .background(Color.white)
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0), lineWidth: 3)
                            )
                            .clipShape(Circle())
                    }
                    .scaleEffect(button2Pressed ? 0.85 : 1.0)
                    .opacity(button2Pressed ? 0.7 : 1.0)
                    .offset(y: button2Offset + button2Float)
                    .opacity(button2Opacity)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !button2Pressed {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                        button2Pressed = true
                                    }
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    button2Pressed = false
                                }
                            }
                    )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                .transition(.move(edge: .leading))
            }
            
            // OnboardingView overlay
            if navigateToOnboarding {
                OnboardingView()
                    .transition(.move(edge: .trailing))
            }
        }
        .onAppear {
            // Title fade in animation
            withAnimation(.easeIn(duration: 0.6)) {
                titleOpacity = 1.0
            }
            
            // Buttons slide up animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    button1Offset = 0
                    button1Opacity = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    button2Offset = 0
                    button2Opacity = 1.0
                }
            }
            
            // Start floating animations
            startFloatingAnimation()
        }
        .alert("You must be 18+ to use The Social Deck.", isPresented: $showAlert) {
            Button("Close App", role: .destructive) {
                // Terminate the app
                exit(0)
            }
        }
    }
    
    private func startFloatingAnimation() {
        // Button 1 floating animation - starts after buttons appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                button1Float = -8
            }
        }
        
        // Button 2 floating animation (slightly offset for variety)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                button2Float = -8
            }
        }
    }
}

#Preview {
    AgeCheckView()
}

