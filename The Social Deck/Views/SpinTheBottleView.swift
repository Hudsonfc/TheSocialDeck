//
//  SpinTheBottleView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct SpinTheBottleView: View {
    @State private var rotationAngle: Double = 0
    @State private var isSpinning: Bool = false
    @State private var showSettings: Bool = false
    @State private var bottleScale: CGFloat = 1.0
    @State private var spinDuration: Double = 3.0 // Default 3.0 seconds
    @State private var navigateToHome: Bool = false
    @State private var showHomeAlert: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    let players = ["Player 1", "Player 2", "Player 3", "Player 4"]
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit and home buttons
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Spin the Bottle")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Spacer()
                    
                    // Home button
                    Button(action: {
                        showHomeAlert = true
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Bottle image - centered
                Image("STB bottle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(rotationAngle))
                    .scaleEffect(bottleScale)
                    .onTapGesture {
                        if !isSpinning {
                            spinBottle()
                        }
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: bottleScale)
                
                Spacer()
                
                // Instructions
                if !showSettings {
                    VStack(spacing: 12) {
                        Text("Tap the bottle to spin")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("Pass the phone around and take turns")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
                
                // Settings card
                if showSettings {
                    VStack(spacing: 20) {
                        Text("Spin Duration")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        VStack(spacing: 8) {
                            // Slider
                            Slider(value: $spinDuration, in: 2.0...15.0, step: 0.5)
                                .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            
                            // Duration display
                            Text("\(spinDuration, specifier: "%.1f") seconds")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 40)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    // Tap to spin again text
                    Text("Tap the bottle to spin again")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .padding(.bottom, 60)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Go to Home?", isPresented: $showHomeAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Go Home", role: .destructive) {
                navigateToHome = true
            }
        } message: {
            Text("Are you sure you want to go back to the home screen?")
        }
        .background(
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHome
            ) {
                EmptyView()
            }
        )
    }
    
    private func spinBottle() {
        // Hide settings if showing
        if showSettings {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showSettings = false
            }
        }
        
        // Scale up on tap for feedback
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            bottleScale = 1.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                bottleScale = 1.0
            }
        }
        
        // Start spinning
        isSpinning = true
        
        // Calculate random rotation: multiple full rotations + random angle
        // Scale rotation amount based on duration to maintain consistent spin speed
        let baseFullRotations = Double.random(in: 3...6) // 3-6 base rotations
        let randomAngle = Double.random(in: 0...360) // Random final angle
        
        // Scale rotations proportionally to duration to maintain constant angular velocity
        // Using 2.5 seconds as the baseline (normal speed)
        let rotationMultiplier = spinDuration / 2.5
        let fullRotations = baseFullRotations * rotationMultiplier * 360
        let totalRotation = fullRotations + randomAngle
        
        // Animate with easing (fast → slow → stop) using selected duration
        withAnimation(.easeOut(duration: spinDuration)) {
            rotationAngle += totalRotation
        }
        
        // Show settings card after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSettings = true
            }
            isSpinning = false
        }
    }
}

#Preview {
    NavigationView {
        SpinTheBottleView()
    }
}

