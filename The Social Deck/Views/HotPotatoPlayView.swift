//
//  HotPotatoPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct HotPotatoPlayView: View {
    @ObservedObject var manager: HotPotatoGameManager
    let deck: Deck
    @Environment(\.dismiss) private var dismiss
    @State private var showHomeAlert: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var pulseSpeed: Double = 1.0 // Animation speed multiplier
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit and home button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                    
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
                    .padding(.leading, 12)
                    
                    Spacer()
                    
                    // Round indicator
                    Text("Round \(manager.roundNumber)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Game content based on phase
                Group {
                    switch manager.gamePhase {
                    case .waitingToStart:
                        WaitingToStartView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    case .active:
                        ActiveGameView(manager: manager, pulseScale: $pulseScale, glowOpacity: $glowOpacity)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
                                removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.95))
                            ))
                    case .choosingPlayer:
                        ChoosePlayerView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                            ))
                    case .expired:
                        TimerExpiredView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: manager.gamePhase)
                
                Spacer()
            }
            
            // Perk alert overlay - positioned on top
            if let perk = manager.activePerk, manager.showPerkAlert, !manager.perkAccepted {
                ZStack {
                    // Backdrop blur
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Prevent dismissing by tapping outside
                        }
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 24) {
                            // Icon with animated background
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                perk.iconColor.opacity(0.2),
                                                perk.iconColor.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: perk.icon)
                                    .font(.system(size: 44, weight: .medium))
                                    .foregroundColor(perk.iconColor)
                            }
                            .padding(.top, 8)
                            
                            VStack(spacing: 8) {
                                Text(perk.rawValue)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                
                                Text(perk.description)
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 8)
                            
                            // Accept button - modern style
                            Button(action: {
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    manager.acceptPerk()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text("Accept")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            perk.iconColor,
                                            perk.iconColor.opacity(0.8)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(color: perk.iconColor.opacity(0.4), radius: 12, x: 0, y: 6)
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 32)
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal, 32)
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                        
                        Spacer()
                    }
                }
                .zIndex(1000)
            }
        }
        .navigationBarHidden(true)
        .alert("Go to Home?", isPresented: $showHomeAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Go Home", role: .destructive) {
                navigateToHome = true
            }
        } message: {
            Text("Are you sure you want to go back to the home screen? Your progress will be lost.")
        }
        .background(
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHome
            ) {
                EmptyView()
            }
        )
        .onChange(of: manager.gamePhase) { oldValue, newValue in
            if newValue == .active {
                // Start the pulse animation when game becomes active
                updatePulseAnimation()
            } else {
                // Reset animation when game is not active
                withAnimation(.easeInOut(duration: 0.3)) {
                    pulseScale = 1.0
                    glowOpacity = 0.3
                    pulseSpeed = 1.0
                }
            }
        }
        .onChange(of: manager.heatLevel) { oldValue, newValue in
            if manager.gamePhase == .active {
                // Update animation speed and intensity based on heat level
                updatePulseAnimation()
            }
        }
    }
    
    private func updatePulseAnimation() {
        // Faster pulse as heat increases (0.5s to 0.2s duration)
        let baseDuration = 1.0
        let minDuration = 0.2
        let duration = baseDuration - (baseDuration - minDuration) * manager.heatLevel
        
        // More intense glow as heat increases
        let baseOpacity = 0.3
        let maxOpacity = 0.9
        let targetOpacity = baseOpacity + (maxOpacity - baseOpacity) * manager.heatLevel
        
        // Larger scale as heat increases
        let baseScale: CGFloat = 1.0
        let maxScale: CGFloat = 1.25
        let targetScale = baseScale + (maxScale - baseScale) * CGFloat(manager.heatLevel)
        
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            pulseScale = targetScale
            glowOpacity = targetOpacity
            pulseSpeed = 1.0 / duration
        }
    }
}

// Choose Player View
struct ChoosePlayerView: View {
    @ObservedObject var manager: HotPotatoGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Choose Who to Pass To")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Text("\(manager.currentPlayer), pick someone!")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Player selection buttons
            VStack(spacing: 16) {
                ForEach(Array(manager.players.enumerated()), id: \.offset) { index, player in
                    // Don't show current player as an option
                    if index != manager.currentPlayerIndex {
                        Button(action: {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            manager.choosePlayer(index)
                        }) {
                            Text(player)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .cornerRadius(12)
                                .shadow(color: Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

// Waiting to start view
struct WaitingToStartView: View {
    @ObservedObject var manager: HotPotatoGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Ready to start?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            
            Text("Pass the phone quickly when the round starts!")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            PrimaryButton(title: "Start Round") {
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                // Smooth fade out animation
                withAnimation(.easeOut(duration: 0.3)) {
                    // Start round after animation begins
                }
                
                // Small delay for smoother transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        manager.startRound()
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

// Active game view with animated hot indicator
struct ActiveGameView: View {
    @ObservedObject var manager: HotPotatoGameManager
    @Binding var pulseScale: CGFloat
    @Binding var glowOpacity: Double
    @State private var showPassAnimation: Bool = false
    @State private var shakeOffsetX: CGFloat = 0
    @State private var shakeOffsetY: CGFloat = 0
    @State private var shakeTimer: Timer?
    
    var body: some View {
        VStack(spacing: 30) {
            // Heat level indicator
            VStack(spacing: 8) {
                Text(manager.heatLevelText)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(manager.heatColor)
                    .animation(.easeInOut(duration: 0.3), value: manager.heatLevelText)
                
                // Heat progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .frame(height: 12)
                        
                        // Heat fill
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0xFF/255.0, green: 0x8C/255.0, blue: 0x42/255.0),
                                        Color(red: 0xFF/255.0, green: 0x45/255.0, blue: 0x00/255.0),
                                        Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(manager.heatLevel), height: 12)
                            .animation(.linear(duration: 0.1), value: manager.heatLevel)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal, 40)
            }
            
            // Animated "HOT" indicator
            ZStack {
                // Glow effect with dynamic color
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                manager.heatColor.opacity(glowOpacity),
                                manager.heatColor.opacity(0)
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(pulseScale)
                
                // Main hot circle with dynamic color
                ZStack {
                    Circle()
                        .fill(manager.heatColor)
                        .frame(width: 200, height: 200)
                        .shadow(color: manager.heatColor.opacity(0.6), radius: 25, x: 0, y: 0)
                    
                    // HP Icon with heat-based animation
                    Image("HP icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(manager.heatLevel * 360)) // Full rotation as heat increases
                        .scaleEffect(1.0 + CGFloat(manager.heatLevel) * 0.5) // Scale up more as heat increases (1.0 to 1.5)
                        .offset(x: shakeOffsetX, y: shakeOffsetY) // Shake animation
                        .animation(.linear(duration: 0.1), value: manager.heatLevel)
                        .onAppear {
                            startShakeAnimation()
                        }
                        .onDisappear {
                            stopShakeAnimation()
                        }
                        .onChange(of: manager.heatLevel) { oldValue, newValue in
                            // Update shake intensity based on heat
                            updateShakeIntensity()
                        }
                }
                .scaleEffect(pulseScale)
                
                // Pass animation overlay
                if showPassAnimation {
                    ZStack {
                        Circle()
                            .stroke(manager.heatColor, lineWidth: 4)
                            .frame(width: 220, height: 220)
                            .scaleEffect(1.3)
                            .opacity(0)
                        
                        Text("✓")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.green)
                            .scaleEffect(1.2)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Current player indicator
            VStack(spacing: 12) {
                Text("Pass the phone to:")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                
                Text(manager.currentPlayer)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .transition(.scale.combined(with: .opacity))
                
                // Pass counter
                if manager.passCount > 0 {
                    Text("\(manager.passCount) pass\(manager.passCount == 1 ? "" : "es")")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                }
            }
            
            // Close call indicator
            if manager.wasCloseCall {
                Text("🔥 Close call!")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0xFF/255.0, green: 0x45/255.0, blue: 0x00/255.0))
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Pass phone button - disabled if perk needs to be accepted
            Button(action: {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                manager.passPhone()
                
                // Show pass animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showPassAnimation = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showPassAnimation = false
                    }
                }
            }) {
                Text("Pass Phone")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(manager.heatColor)
                    .cornerRadius(12)
                    .shadow(color: manager.heatColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 40)
            .disabled(manager.activePerk != nil && !manager.perkAccepted)
            .opacity((manager.activePerk != nil && !manager.perkAccepted) ? 0.5 : 1.0)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: manager.currentPlayer)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: manager.passCount)
    }
    
    private func startShakeAnimation() {
        updateShakeIntensity()
        shakeTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            // Update shake position - no weak self needed for structs
            self.updateShakePosition()
        }
    }
    
    private func stopShakeAnimation() {
        shakeTimer?.invalidate()
        shakeTimer = nil
        shakeOffsetX = 0
        shakeOffsetY = 0
    }
    
    private func updateShakeIntensity() {
        // Shake intensity increases with heat level (0 to max 15 pixels)
        // Only shake if heat level is above 0.3 (30%)
        if manager.heatLevel > 0.3 {
            // Shake intensity scales from 0 to 15 pixels as heat goes from 0.3 to 1.0
            let intensity = CGFloat((manager.heatLevel - 0.3) / 0.7) * 15.0
            // Update will be handled by timer
        }
    }
    
    private func updateShakePosition() {
        // Only shake if heat level is significant
        guard manager.heatLevel > 0.3 else {
            shakeOffsetX = 0
            shakeOffsetY = 0
            return
        }
        
        // Calculate shake intensity based on heat (0.3 to 1.0 maps to 0 to 15 pixels)
        let intensity = CGFloat((manager.heatLevel - 0.3) / 0.7) * 15.0
        
        // Random shake offset
        shakeOffsetX = CGFloat.random(in: -intensity...intensity)
        shakeOffsetY = CGFloat.random(in: -intensity...intensity)
    }
}

// Timer expired view
struct TimerExpiredView: View {
    @ObservedObject var manager: HotPotatoGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            // Friendly visual with animation
            ZStack {
                Circle()
                    .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "timer")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
            }
            .scaleEffect(1.0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    // Animation handled by scaleEffect
                }
            }
            
            VStack(spacing: 16) {
                Text("Time's Up!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                if let loser = manager.loser {
                    Text("\(loser) was holding the phone!")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Round stats
                if manager.passCount > 0 {
                    VStack(spacing: 8) {
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text("Round Stats")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("\(manager.passCount)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                Text("Passes")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            }
                            
                            if manager.wasCloseCall {
                                VStack(spacing: 4) {
                                    Text("🔥")
                                        .font(.system(size: 24))
                                    Text("Close Call!")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(red: 0xFF/255.0, green: 0x45/255.0, blue: 0x00/255.0))
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            
            // Next round button
            PrimaryButton(title: "Next Round") {
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                // Small delay for smoother transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    manager.nextRound()
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    NavigationView {
        HotPotatoPlayView(
            manager: HotPotatoGameManager(players: ["Alice", "Bob", "Charlie"]),
            deck: Deck(
                title: "Hot Potato",
                description: "Pass the phone quickly!",
                numberOfCards: 50,
                estimatedTime: "10-15 min",
                imageName: "Art 1.4",
                type: .hotPotato,
                cards: [],
                availableCategories: []
            )
        )
    }
}

