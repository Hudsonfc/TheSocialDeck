//
//  WhatsMySecretPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import UIKit

struct WhatsMySecretPlayView: View {
    @ObservedObject var manager: WhatsMySecretGameManager
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var showHomeAlert: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showEndView: Bool = false
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, home, and back button
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
                    
                    // Progress indicator
                    if !manager.isFinished && manager.cards.count > 0 {
                        Text("Round \(manager.roundNumber) of \(manager.cards.count)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Game content based on phase
                Group {
                    switch manager.gamePhase {
                    case .playersTurn:
                        PlayersTurnView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    case .showingSecret:
                        ShowingSecretView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    case .timerRunning:
                        TimerRunningView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    case .guessing:
                        GuessingView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    case .result:
                        ResultView(manager: manager, showEndView: $showEndView)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.95).combined(with: .opacity),
                                removal: .scale(scale: 0.95).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.85), value: manager.gamePhase)
                
                Spacer()
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
            Group {
                NavigationLink(
                    destination: HomeView(),
                    isActive: $navigateToHome
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: WhatsMySecretEndView(
                        deck: deck,
                        selectedCategories: selectedCategories,
                        groupWins: manager.groupWins,
                        secretPlayerWins: manager.secretPlayerWins,
                        totalRounds: manager.roundNumber - 1
                    ),
                    isActive: $showEndView
                ) {
                    EmptyView()
                }
            }
        )
        .onAppear {
            // Ensure round is started if needed
            if (manager.gamePhase == .playersTurn || manager.gamePhase == .showingSecret) && manager.currentSecret == nil && !manager.cards.isEmpty {
                manager.startRound()
            }
        }
    }
    
}

// Players Turn View - Shows whose turn it is
struct PlayersTurnView: View {
    @ObservedObject var manager: WhatsMySecretGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                }
                
                VStack(spacing: 12) {
                    Text("Player's Turn")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Text("\(manager.currentPlayer)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    
                    Text("Everyone else, look away!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                }
            }
            
            PrimaryButton(title: "Ready to View Secret") {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                manager.proceedToSecret()
            }
            .padding(.horizontal, 40)
        }
    }
}

// Showing Secret View - Card back shown first, can flip to see secret
struct ShowingSecretView: View {
    @ObservedObject var manager: WhatsMySecretGameManager
    @State private var cardRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 32) {
            if let secret = manager.currentSecret {
                VStack(spacing: 24) {
                    // Instruction text
                    Text("Tap the card to reveal your secret")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Flippable card
                    ZStack {
                        // Card front (back of card) - visible when rotation < 90
                        SecretCardBackView()
                            .opacity(cardRotation < 90 ? 1 : 0)
                        
                        // Card back (front with secret) - visible when rotation >= 90
                        SecretCardFrontView(secret: secret)
                            .opacity(cardRotation >= 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                    .frame(width: 320, height: 400)
                    .rotation3DEffect(
                        .degrees(cardRotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .onTapGesture {
                        if !manager.isCardFlipped {
                            // Flip to show secret
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                cardRotation = 180
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                manager.flipCard()
                            }
                        } else {
                            // Flip back
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                cardRotation = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                manager.flipCard()
                            }
                        }
                    }
                    .onChange(of: manager.currentCardIndex) { oldValue, newValue in
                        // Reset card flip state when moving to new card
                        if oldValue != newValue {
                            withAnimation(.none) {
                                cardRotation = 0
                            }
                        }
                    }
                    .onChange(of: manager.gamePhase) { oldValue, newValue in
                        // Reset card rotation only if coming from a different phase (not timerRunning)
                        // If coming from timerRunning, keep the card flipped
                        if newValue == .showingSecret && oldValue != .showingSecret && oldValue != .timerRunning {
                            withAnimation(.none) {
                                cardRotation = 0
                            }
                        } else if newValue == .showingSecret && oldValue == .timerRunning {
                            // Coming from timer - ensure card shows secret (flipped)
                            if manager.isCardFlipped && cardRotation < 90 {
                                withAnimation(.none) {
                                    cardRotation = 180
                                }
                            }
                        }
                    }
                }
                
                // Show button based on context
                if manager.isCardFlipped {
                    // If coming from timer (paused), show "Resume Timer" button
                    if manager.isTimerPaused {
                        PrimaryButton(title: "Resume Timer") {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            manager.resumeTimer()
                        }
                        .padding(.horizontal, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        // First time viewing secret
                        PrimaryButton(title: "Got It! Put Phone Down") {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            manager.secretViewed()
                        }
                        .padding(.horizontal, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: manager.isCardFlipped)
    }
}

// Secret Card Back View (shows "What's My Secret?")
struct SecretCardBackView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 20) {
                Text("What's My Secret?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .multilineTextAlignment(.center)
                
                Text("Tap to reveal")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
        }
    }
}

// Secret Card Front View (shows the secret)
struct SecretCardFrontView: View {
    let secret: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0xF8/255.0, green: 0xF9/255.0, blue: 0xFA/255.0))
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 20) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                
                Text(secret)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("Follow this rule without revealing it!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.vertical, 40)
        }
    }
}

// Timer Running View - Group interacts while timer counts down
struct TimerRunningView: View {
    @ObservedObject var manager: WhatsMySecretGameManager
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Group Interaction Time")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text("\(manager.currentPlayer) is following a secret rule. Try to figure it out!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Timer display
            VStack(spacing: 12) {
                Text(formatTime(manager.timeRemaining))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(manager.timeRemaining <= 30 ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .monospacedDigit()
                    .animation(.easeInOut(duration: 0.3), value: manager.timeRemaining <= 30)
                
                Text(manager.timeRemaining <= 30 ? "Time running out!" : "time remaining")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(manager.timeRemaining <= 30 ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .animation(.easeInOut(duration: 0.3), value: manager.timeRemaining <= 30)
            }
            
            // Circular progress indicator
            ZStack {
                Circle()
                    .stroke(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(max(0, manager.timeRemaining / 120.0)))
                    .stroke(
                        manager.timeRemaining <= 30 ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: manager.timeRemaining)
            }
            .frame(width: 120, height: 120)
            
            // Action buttons
            VStack(spacing: 12) {
                // View secret again button
                Button(action: {
                    manager.viewSecretAgain()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("View Secret Again")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                    .cornerRadius(20)
                }
                
                // Skip timer button
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    manager.skipTimer()
                }) {
                    Text("Group Ready - Skip Timer")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .cornerRadius(20)
                }
            }
            .padding(.top, 8)
        }
    }
}

// Guessing View - Group makes final guess
struct GuessingView: View {
    @ObservedObject var manager: WhatsMySecretGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Time's Up!")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            
            if let secret = manager.currentSecret {
                VStack(spacing: 24) {
                    Text("The Secret Was:")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    
                    // Secret card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0xF8/255.0, green: 0xF9/255.0, blue: 0xFA/255.0))
                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        
                        Text(secret)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .multilineTextAlignment(.center)
                            .padding(32)
                    }
                    .frame(width: 320, height: 300)
                    
                    Text("Did the group guess correctly?")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            
            // Guess buttons
            HStack(spacing: 16) {
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    manager.submitGuess(wasCorrect: true)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                        Text("Yes")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                    .cornerRadius(12)
                    .shadow(color: Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    manager.submitGuess(wasCorrect: false)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                        Text("No")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(12)
                    .shadow(color: Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

// Result View - Show result and move to next round
struct ResultView: View {
    @ObservedObject var manager: WhatsMySecretGameManager
    @Binding var showEndView: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            if let wasCorrect = manager.groupGuessedCorrectly {
                // Result visual
                ZStack {
                    Circle()
                        .fill(wasCorrect ? Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.1) : Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                        .frame(width: 200, height: 200)
                    
                    Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(wasCorrect ? Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0) : Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                }
                
                VStack(spacing: 16) {
                    Text(wasCorrect ? "Group Wins!" : "\(manager.currentPlayer) Wins!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Text(wasCorrect ? "The group correctly guessed the secret!" : "The group couldn't figure out the secret!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Score summary
                VStack(spacing: 12) {
                    Text("Score")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    
                    HStack(spacing: 30) {
                        VStack(spacing: 4) {
                            Text("Group")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            Text("\(manager.groupWins)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                        }
                        
                        Text("—")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        
                        VStack(spacing: 4) {
                            Text("Players")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            Text("\(manager.secretPlayerWins)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        }
                    }
                }
                .padding(.top, 8)
            }
            
            // Next round button
            if !manager.isFinished {
                VStack(spacing: 16) {
                    PrimaryButton(title: manager.roundNumber >= manager.cards.count ? "Final Round Next" : "Next Round") {
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            manager.nextRound()
                        }
                    }
                    
                    // Show progress indicator
                    if manager.cards.count > 0 {
                        Text("Round \(manager.roundNumber) of \(manager.cards.count)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    }
                }
                .padding(.horizontal, 40)
            } else {
                PrimaryButton(title: "View Final Results") {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        manager.isFinished = true
                        showEndView = true
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    NavigationView {
        WhatsMySecretPlayView(
            manager: WhatsMySecretGameManager(
                deck: Deck(
                    title: "What's My Secret?",
                    description: "Test",
                    numberOfCards: 50,
                    estimatedTime: "5-10 min",
                    imageName: "Art 1.4",
                    type: .whatsMySecret,
                    cards: [],
                    availableCategories: []
                ),
                selectedCategories: ["Party"],
                cardCount: 10,
                players: ["Alice", "Bob", "Charlie"]
            ),
            deck: Deck(
                title: "What's My Secret?",
                description: "Test",
                numberOfCards: 50,
                estimatedTime: "5-10 min",
                imageName: "Art 1.4",
                type: .whatsMySecret,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party"]
        )
    }
}
