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
    @AppStorage("totalCardsFlipped") private var totalCardsFlipped: Int = 0
    @State private var showHomeAlert: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showEndView: Bool = false
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, home, and back button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    
                    // Home button
                    Button(action: {
                        showHomeAlert = true
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 12)
                    
                    Spacer()
                    
                    // Progress indicator
                    if !manager.isFinished && manager.cards.count > 0 {
                        Text("Round \(manager.roundNumber) of \(manager.cards.count)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                    }
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Game content based on phase
                Group {
                    switch manager.gamePhase {
                    case .playersTurn:
                        PlayersTurnView(manager: manager)
                            .transition(.opacity.combined(with: .offset(y: 16)))
                    case .showingSecret:
                        ShowingSecretView(manager: manager)
                            .transition(.opacity.combined(with: .offset(y: 16)))
                    case .timerRunning:
                        TimerRunningView(manager: manager)
                            .transition(.opacity.combined(with: .offset(y: 16)))
                    case .guessing:
                        GuessingView(manager: manager)
                            .transition(.opacity.combined(with: .offset(y: 16)))
                    case .result:
                        ResultView(manager: manager, showEndView: $showEndView)
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    }
                }
                .animation(.spring(response: 0.52, dampingFraction: 0.9), value: manager.gamePhase)
                
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
                        totalRounds: manager.roundNumber - 1,
                        players: manager.players,
                        playerScores: manager.playerScores
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
                        .fill(Color.buttonBackground.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundColor(Color.buttonBackground)
                }
                
                VStack(spacing: 12) {
                    Text("Player's Turn")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    
                    Text("\(manager.currentPlayer)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color.buttonBackground)
                    
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
    @AppStorage("totalCardsFlipped") private var totalCardsFlipped: Int = 0
    @State private var cardRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 32) {
            if let secret = manager.currentSecret {
                VStack(spacing: 24) {
                    // Player's turn text
                    Text("\(manager.currentPlayer)'s turn")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
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
                    .frame(width: ResponsiveSize.cardWidth, height: ResponsiveSize.bluffCallCardHeight)
                    .rotation3DEffect(
                        .degrees(cardRotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .onTapGesture {
                        if !manager.isCardFlipped {
                            // Flip to show secret
                            totalCardsFlipped += 1
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
                .fill(Color.cardBackground)

            VStack(spacing: 0) {
                ProgrammaticWhatsMySecretCoverArtView()
                    .environment(\.playGridAdaptiveSocialDeckCovers, true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Text("Tap to reveal")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .padding(.bottom, 24)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

// Secret Card Front View (shows the secret)
struct SecretCardFrontView: View {
    let secret: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.cardBackground)

            VStack(spacing: 20) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.secondaryText)

                Text(secret)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)
                
                Text("Help the group figure it out—without saying it outright!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.vertical, 40)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
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
                    .foregroundColor(.primaryText)
                
                Text("\(manager.currentPlayer) knows the secret—help them get the group there, or be the one who guesses it for a point!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Timer display
            VStack(spacing: 12) {
                Text(formatTime(manager.timeRemaining))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(manager.timeRemaining <= 30 ? Color.buttonBackground : .primaryText)
                    .monospacedDigit()
                    .animation(.easeInOut(duration: 0.3), value: manager.timeRemaining <= 30)
                
                Text(manager.timeRemaining <= 30 ? "Time running out!" : "time remaining")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(manager.timeRemaining <= 30 ? Color.buttonBackground : .secondaryText)
                    .animation(.easeInOut(duration: 0.3), value: manager.timeRemaining <= 30)
            }
            
            // Circular progress indicator
            ZStack {
                Circle()
                    .stroke(Color.tertiaryBackground, lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(max(0, manager.timeRemaining / 120.0)))
                    .stroke(
                        manager.timeRemaining <= 30 ? Color.buttonBackground : Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: manager.timeRemaining)
            }
            .frame(width: ResponsiveSize.timerSize, height: ResponsiveSize.timerSize)
            
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
                    .foregroundColor(Color.buttonBackground)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.tertiaryBackground)
                    .cornerRadius(20)
                }
                
                // Someone guessed during the timer
                Button(action: {
                    manager.someoneGuessedIt()
                }) {
                    Text("Someone guessed it")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.buttonBackground)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.tertiaryBackground)
                        .cornerRadius(20)
                }
            }
            .padding(.top, 8)
        }
    }
}

// Guessing View - Group makes final guess (timer ended) or awards a point (early guess)
struct GuessingView: View {
    @ObservedObject var manager: WhatsMySecretGameManager

    var body: some View {
        VStack(spacing: 32) {
            Text(manager.isResolvingEarlyGuess ? "Someone guessed it!" : "Time's Up!")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)

            if let secret = manager.currentSecret {
                VStack(spacing: 24) {
                    Text("The secret was:")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))

                    // Secret card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0xF8/255.0, green: 0xF9/255.0, blue: 0xFA/255.0))
                            .shadow(color: Color.shadowColor, radius: 20, x: 0, y: 10)

                        Text(secret)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(32)
                    }
                    .frame(width: ResponsiveSize.cardWidth, height: ResponsiveSize.categoryCardHeight)

                    if manager.isResolvingEarlyGuess {
                        Text("Tap the player who guessed it to give them a point.")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    } else {
                        Text("Did the group guess correctly?")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }

            if manager.isResolvingEarlyGuess {
                if manager.guessablePlayers.isEmpty {
                    Text("Add another player to award guess points.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(manager.guessablePlayers, id: \.self) { name in
                            Button(action: {
                                manager.awardGuessPoint(to: name)
                            }) {
                                Text(name)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                                    .cornerRadius(12)
                                    .shadow(color: Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 40)
                }
            } else {
                HStack(spacing: 16) {
                    Button(action: {
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
                        .background(Color.buttonBackground)
                        .cornerRadius(12)
                        .shadow(color: Color.buttonBackground.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

// Result View - Show result and move to next round
struct ResultView: View {
    @ObservedObject var manager: WhatsMySecretGameManager
    @Binding var showEndView: Bool

    private let winGreen = Color(red: 0x34 / 255.0, green: 0xC7 / 255.0, blue: 0x59 / 255.0)

    private var playersSortedByPoints: [String] {
        manager.players.sorted {
            let a = manager.playerScores[$0, default: 0]
            let b = manager.playerScores[$1, default: 0]
            if a != b { return a > b }
            return $0 < $1
        }
    }

    private var minimalistStandings: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(playersSortedByPoints.enumerated()), id: \.element) { index, name in
                HStack {
                    Text(name)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.primaryText)
                    Spacer()
                    Text("\(manager.playerScores[name, default: 0])")
                        .font(.system(size: 15, weight: .medium, design: .rounded).monospacedDigit())
                        .foregroundColor(.secondaryText)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 4)

                if index < playersSortedByPoints.count - 1 {
                    Divider()
                        .opacity(0.35)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    var body: some View {
        VStack(spacing: 32) {
            if let wasCorrect = manager.groupGuessedCorrectly {
                if wasCorrect, let guesser = manager.lastRoundGuessWinner {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(winGreen)

                        VStack(spacing: 4) {
                            Text(guesser)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primaryText)
                            Text("+1")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                        }

                        if !manager.players.isEmpty {
                            minimalistStandings
                        }
                    }
                    .padding(.horizontal, 24)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundColor(wasCorrect ? winGreen : Color.buttonBackground)

                        VStack(spacing: 6) {
                            Text(wasCorrect ? "Got it" : "Round over")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primaryText)

                            Text(wasCorrect ? "The group guessed the secret." : "No one guessed it this round.")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 28)

                        if !manager.players.isEmpty {
                            minimalistStandings
                        }
                    }
                    .padding(.horizontal, 24)
                }
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
                    imageName: "WMS artwork",
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
                imageName: "WMS artwork",
                type: .whatsMySecret,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party"]
        )
    }
}
