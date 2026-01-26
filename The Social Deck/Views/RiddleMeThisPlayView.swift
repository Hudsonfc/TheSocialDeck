//
//  RiddleMeThisPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import UIKit

struct RiddleMeThisPlayView: View {
    @ObservedObject var manager: RiddleMeThisGameManager
    let deck: Deck
    @Environment(\.dismiss) private var dismiss
    @State private var cardRotation: Double = 0
    @State private var showEndView: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showHomeAlert: Bool = false
    @State private var cardOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var isCardFlipped: Bool = false
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit and home button
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
                    
                    // Timer indicator (if enabled, started, and in riddle phase)
                    if manager.timerEnabled && manager.timerStarted && manager.gamePhase == .showingRiddle {
                        HStack(spacing: 6) {
                            Image(systemName: "timer")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(manager.timeRemaining <= 10 ? .buttonBackground : .buttonBackground)
                            Text(formatCountdownTime(manager.timeRemaining))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(manager.timeRemaining <= 10 ? .buttonBackground : .buttonBackground)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(manager.timeRemaining <= 10 ? Color.buttonBackground.opacity(0.25) : Color.buttonBackground.opacity(0.15))
                        .cornerRadius(20)
                        .padding(.trailing, 8)
                        .animation(.easeInOut(duration: 0.3), value: manager.timeRemaining <= 10)
                    }
                    
                    // Round indicator
                    Text("Round \(manager.roundNumber)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Game content based on phase
                Group {
                    switch manager.gamePhase {
                    case .showingRiddle:
                        RiddleView(manager: manager, cardRotation: $cardRotation, isCardFlipped: $isCardFlipped, isTransitioning: $isTransitioning)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    case .showingSolution:
                        SolutionView(manager: manager, cardRotation: $cardRotation, isCardFlipped: $isCardFlipped, isTransitioning: $isTransitioning, showEndView: $showEndView)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.85), value: manager.gamePhase)
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
        .background(
            NavigationLink(
                destination: RiddleMeThisEndView(
                    deck: deck,
                    totalRounds: manager.roundNumber - 1
                ),
                isActive: $showEndView
            ) {
                EmptyView()
            }
        )
        .onChange(of: manager.currentCardIndex) { oldValue, newValue in
            // Reset card flip state when moving to new card
            if oldValue != newValue {
                withAnimation(.none) {
                    cardRotation = 0
                    isCardFlipped = false
                }
            }
        }
    }
    
    private func formatTimerDuration(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds == 0 {
                return "\(minutes)m"
            } else {
                return "\(minutes)m \(remainingSeconds)s"
            }
        }
    }
    
    private func formatCountdownTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        } else {
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// Riddle View - Shows riddle card and answer buttons
struct RiddleView: View {
    @ObservedObject var manager: RiddleMeThisGameManager
    @Binding var cardRotation: Double
    @Binding var isCardFlipped: Bool
    @Binding var isTransitioning: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Timer indicator (prominent display when timer is enabled and started)
            if manager.timerEnabled && manager.timerStarted && manager.gamePhase == .showingRiddle {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(manager.timeRemaining <= 10 ? .buttonBackground : .buttonBackground)
                        Text(formatCountdownTime(manager.timeRemaining))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(manager.timeRemaining <= 10 ? .buttonBackground : .buttonBackground)
                    }
                    
                    if manager.timeRemaining <= 10 {
                        Text("Time running out!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.buttonBackground)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(manager.timeRemaining <= 10 ? Color.buttonBackground.opacity(0.3) : Color.buttonBackground.opacity(0.2))
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(manager.timeRemaining <= 10 ? Color.buttonBackground : Color.buttonBackground.opacity(0.5), lineWidth: manager.timeRemaining <= 10 ? 3 : 2)
                )
                .scaleEffect(manager.timeRemaining <= 5 ? 1.05 : 1.0)
                .padding(.bottom, 24)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: manager.timeRemaining <= 10)
            }
            
            // Card
            if let riddle = manager.currentRiddle {
                ZStack {
                    // Card back (initial) - "Riddle Me This" text - visible when rotation < 90
                    RiddleCardBackView(text: "Riddle Me This")
                        .opacity(cardRotation < 90 ? 1 : 0)
                    
                    // Card front (after flip) - showing riddle text - visible when rotation >= 90
                    RiddleCardFrontView(text: riddle.text)
                        .opacity(cardRotation >= 90 ? 1 : 0)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
                .frame(width: 320, height: 480)
                .rotation3DEffect(
                    .degrees(cardRotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .id(riddle.id)
                .onTapGesture {
                    if !isTransitioning {
                        toggleCard()
                    }
                }
            }
            
            // Placeholder text when timer is enabled but card hasn't been flipped yet
            if manager.timerEnabled && !manager.timerStarted && !isCardFlipped {
                Text("Tap the card to flip and start the timer")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 24)
                    .transition(.opacity)
            }
            
            Spacer()
            
            // Show answer button (only when card is flipped to show riddle)
            if isCardFlipped {
                PrimaryButton(title: "Show Answer") {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    manager.showAnswer()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isCardFlipped)
    }
    
    private func formatTimerDuration(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds) seconds"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds == 0 {
                return "\(minutes) minute\(minutes == 1 ? "" : "s")"
            } else {
                return "\(minutes)m \(remainingSeconds)s"
            }
        }
    }
    
    private func formatCountdownTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        } else {
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func toggleCard() {
        if isCardFlipped {
            // Flip back to front
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isCardFlipped = false
                // Timer continues running even when card is flipped back
            }
        } else {
            // Flip to back (show riddle)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isCardFlipped = true
                // Start timer when card is first flipped to show riddle (only starts once)
                if manager.timerEnabled {
                    manager.startTimer()
                }
            }
        }
    }
}

// Solution View - Shows answer and winner/no winner
struct SolutionView: View {
    @ObservedObject var manager: RiddleMeThisGameManager
    @Binding var cardRotation: Double
    @Binding var isCardFlipped: Bool
    @Binding var isTransitioning: Bool
    @Binding var showEndView: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Winner or no winner
            if manager.winner != nil {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.1))
                            .frame(width: 150, height: 150)
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                    }
                    
                    Text("Correct Answer!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                }
                .padding(.bottom, 24)
            } else {
                Text("Answer Revealed")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .padding(.bottom, 24)
            }
            
            // Card showing answer
            if let riddle = manager.currentRiddle {
                RiddleCardAnswerView(text: riddle.text, answer: manager.currentAnswer)
                    .frame(width: 320, height: 480)
            }
            
            Spacer()
            
            // Next round button
            PrimaryButton(title: manager.canGoToNextRound ? "Next Round" : "Finish") {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                if manager.canGoToNextRound {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        manager.nextRound()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        showEndView = true
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// Card Front View (showing riddle)
struct RiddleCardFrontView: View {
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Text(text)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}

// Card Back View (showing "Riddle Me This" text)
struct RiddleCardBackView: View {
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 20) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text(text)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
            }
        }
    }
}

// Card Answer View (showing answer in solution phase)
struct RiddleCardAnswerView: View {
    let text: String
    let answer: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 0) {
                // Answer section
                VStack(spacing: 16) {
                    Text("Answer")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                        .padding(.top, 40)
                    
                    Text(answer)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Divider with spacing
                Divider()
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                
                // Riddle section
                VStack(spacing: 8) {
                    Text("Riddle")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    
                    Text(text)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        RiddleMeThisPlayView(
            manager: RiddleMeThisGameManager(
                deck: Deck(
                    title: "Riddle Me This",
                    description: "Solve riddles",
                    numberOfCards: 71,
                    estimatedTime: "5-10 min",
                    imageName: "RMT artwork",
                    type: .riddleMeThis,
                    cards: allRiddleMeThisCards,
                    availableCategories: []
                ),
                cardCount: 5
            ),
            deck: Deck(
                title: "Riddle Me This",
                description: "Solve riddles",
                numberOfCards: 71,
                estimatedTime: "5-10 min",
                imageName: "RMT artwork",
                type: .riddleMeThis,
                cards: allRiddleMeThisCards,
                availableCategories: []
            )
        )
    }
}
