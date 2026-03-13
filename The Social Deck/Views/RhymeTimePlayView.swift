//
//  RhymeTimePlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import UIKit

struct RhymeTimePlayView: View {
    @ObservedObject var manager: RhymeTimeGameManager
    let deck: Deck
    @Environment(\.dismiss) private var dismiss
    @State private var showHomeAlert: Bool = false
    @State private var navigateToHome: Bool = false
    
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
                    
                    // Round indicator
                    Text("Round \(manager.roundNumber)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Game content based on phase
                Group {
                    switch manager.gamePhase {
                    case .waitingToStart:
                        RhymeTimeWaitingToStartView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    case .active:
                        RhymeTimeActiveGameView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
                                removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.95))
                            ))
                    case .roundComplete:
                        RhymeTimeRoundCompleteView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                    case .expired:
                        RhymeTimeTimerExpiredView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                    case .gameOver:
                        RhymeTimeGameOverView(manager: manager)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: manager.gamePhase)
                
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
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHome
            ) {
                EmptyView()
            }
        )
    }
}

// Waiting to start view
struct RhymeTimeWaitingToStartView: View {
    @ObservedObject var manager: RhymeTimeGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Round \(manager.roundNumber)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))

            VStack(spacing: 8) {
                Text("\(manager.currentPlayer)'s turn")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)

                Text("Type a word that rhymes with the base word before time runs out!")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

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

// Active game view
struct RhymeTimeActiveGameView: View {
    @ObservedObject var manager: RhymeTimeGameManager
    @State private var rhymeInput: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var showCorrectOverlay: Bool = false

    private let green = Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0)

    var body: some View {
        ZStack {
        VStack(spacing: 40) {
            // Base word display
            VStack(spacing: 16) {
                Text("Rhyme with:")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                
                Text(manager.baseWord.uppercased())
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .padding(.horizontal, 24)
            }
            
            // Timer display
            VStack(spacing: 12) {
                Text("\(manager.currentPlayer)'s turn")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
                
                // Circular timer
                ZStack {
                    Circle()
                        .stroke(Color.tertiaryBackground, lineWidth: 12)
                        .frame(width: ResponsiveSize.timerSize, height: ResponsiveSize.timerSize)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(manager.timeRemaining / 10.0))
                        .stroke(
                            manager.timeRemaining < 3.0 ? Color.red : Color.buttonBackground,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: ResponsiveSize.timerSize, height: ResponsiveSize.timerSize)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: manager.timeRemaining)
                    
                    Text("\(Int(manager.timeRemaining) + 1)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(manager.timeRemaining < 3.0 ? Color.red : Color.primaryText)
                }
            }
            
            // Live score strip
            RhymeTimeLiveScores(manager: manager)

            // Rhyme input — required
            VStack(spacing: 12) {
                Text("Type your rhyme")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))

                TextField("Enter a rhyming word", text: $rhymeInput)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.primaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.tertiaryBackground)
                    .cornerRadius(12)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        submitRhyme()
                    }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 8)

            // Submit button — disabled until a word is entered
            let canSubmit = !rhymeInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            VStack(spacing: 16) {
                Button(action: {
                    submitRhyme()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Submit Rhyme")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        canSubmit
                            ? Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0)
                            : Color.gray.opacity(0.4)
                    )
                    .cornerRadius(12)
                    .shadow(
                        color: canSubmit
                            ? Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.3)
                            : Color.clear,
                        radius: 8, x: 0, y: 4
                    )
                }
                .disabled(!canSubmit)
            }
            .padding(.horizontal, 40)
        }

            // Correct confirmation overlay
            if manager.lastSubmitCorrect {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(green.opacity(0.2))
                            .frame(width: 88, height: 88)
                        Circle()
                            .fill(green.opacity(0.35))
                            .frame(width: 72, height: 72)
                        Image(systemName: "checkmark")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    VStack(spacing: 4) {
                        Text("Correct!")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        Text("Nice rhyme!")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x5A/255.0, green: 0x5A/255.0, blue: 0x5A/255.0))
                    }
                }
                .padding(.horizontal, 44)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.tertiaryBackground)
                        .shadow(color: green.opacity(0.35), radius: 20, x: 0, y: 8)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(green.opacity(0.5), lineWidth: 2)
                )
                .transition(.scale(scale: 0.85).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.72), value: manager.lastSubmitCorrect)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isTextFieldFocused = true
            }
        }
        .onChange(of: manager.lastSubmitCorrect) { _, isCorrect in
            if isCorrect {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                // After the overlay is visible, advance to the next player (or end round)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    rhymeInput = ""
                    manager.advanceAfterSuccess()
                }
            }
        }
        .onChange(of: manager.currentPlayerIndex) { _, _ in
            rhymeInput = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
    }

    private func submitRhyme() {
        let trimmed = rhymeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        manager.submitRhyme(rhyme: trimmed)

        if manager.gamePhase == .active {
            rhymeInput = ""
        }
    }
}

// Round complete view
struct RhymeTimeRoundCompleteView: View {
    @ObservedObject var manager: RhymeTimeGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            // Success visual
            ZStack {
                Circle()
                    .fill(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
            }
            
            VStack(spacing: 16) {
                Text("Round Complete!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)

                Text("Everyone had their turn. Here's how it went!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            RhymeTimeScoreboard(manager: manager)

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

// Timer expired / wrong rhyme view
struct RhymeTimeTimerExpiredView: View {
    @ObservedObject var manager: RhymeTimeGameManager

    private var icon: String {
        switch manager.lossReason {
        case .timerExpired:   return "timer"
        case .badRhyme:       return "xmark.circle.fill"
        case .repeatedRhyme:  return "arrow.2.circlepath"
        case .notARealWord:   return "questionmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch manager.lossReason {
        case .timerExpired:  return Color.buttonBackground
        case .badRhyme:      return Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
        case .repeatedRhyme: return Color.orange
        case .notARealWord:  return Color.purple
        }
    }

    private var headline: String {
        switch manager.lossReason {
        case .timerExpired:  return "Time's Up!"
        case .badRhyme:      return "Doesn't Rhyme!"
        case .repeatedRhyme: return "Already Used!"
        case .notARealWord:  return "Not a Real Word!"
        }
    }

    private var subline: String {
        guard let loser = manager.loser else { return "" }
        switch manager.lossReason {
        case .timerExpired:
            return "\(loser) ran out of time."
        case .badRhyme:
            return "\(loser)'s word doesn't rhyme with \"\(manager.baseWord)\"."
        case .repeatedRhyme:
            return "\(loser) repeated a word that was already used."
        case .notARealWord:
            return "\(loser) entered a word that isn't in the dictionary."
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 200, height: 200)

                Image(systemName: icon)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(iconColor)
            }

            VStack(spacing: 16) {
                Text(headline)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)

                Text(subline)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
            }

            RhymeTimeScoreboard(manager: manager)

            let buttonTitle = manager.hasMorePlayersThisRound ? "Next Player" : "Next Round"
            PrimaryButton(title: buttonTitle) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if manager.hasMorePlayersThisRound {
                        manager.advanceAfterFailure()
                    } else {
                        manager.nextRound()
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Live score strip (shown during active play)
struct RhymeTimeLiveScores: View {
    @ObservedObject var manager: RhymeTimeGameManager

    private let green = Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0)

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(manager.players.enumerated()), id: \.element) { _, player in
                let isActive = player == manager.currentPlayer
                let score = manager.scores[player] ?? 0

                VStack(spacing: 4) {
                    Text(player)
                        .font(.system(size: 12, weight: isActive ? .bold : .regular, design: .rounded))
                        .foregroundColor(isActive ? .primaryText : Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("\(score)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isActive ? green : .primaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isActive ? green.opacity(0.1) : Color.clear)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isActive ? green : Color.clear),
                    alignment: .bottom
                )
            }
        }
        .background(Color.tertiaryBackground)
        .cornerRadius(12)
        .padding(.horizontal, 40)
    }
}

// MARK: - Scoreboard (shown after round ends)
struct RhymeTimeScoreboard: View {
    @ObservedObject var manager: RhymeTimeGameManager

    private let green  = Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0)
    private let red    = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    /// Returns -1 if player failed this round, +1 if they succeeded, nil if they haven't gone yet.
    private func delta(for player: String) -> Int? {
        if manager.failedThisRound[player] != nil { return -1 }
        // At end-of-round everyone who didn't fail earned +1
        if manager.roundComplete { return 1 }
        return nil
    }

    private func rank(_ index: Int) -> String {
        switch index {
        case 0: return "1st"
        case 1: return "2nd"
        case 2: return "3rd"
        default: return "\(index + 1)th"
        }
    }

    var body: some View {
        let sorted = manager.players.sorted { (manager.scores[$0] ?? 0) > (manager.scores[$1] ?? 0) }

        VStack(spacing: 0) {
            Text("SCOREBOARD")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                .kerning(1.2)
                .padding(.bottom, 10)

            VStack(spacing: 2) {
                ForEach(Array(sorted.enumerated()), id: \.element) { idx, player in
                    let pts    = manager.scores[player] ?? 0
                    let d      = delta(for: player)
                    let failed = manager.failedThisRound[player] != nil

                    HStack(spacing: 12) {
                        Text(rank(idx))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .frame(width: 30, alignment: .leading)

                        Text(player)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .lineLimit(1)

                        Spacer()

                        // Only show the delta badge if we know the outcome for this player
                        if let d = d {
                            Text(d > 0 ? "+1" : "-1")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(d > 0 ? green : red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background((d > 0 ? green : red).opacity(0.12))
                                .cornerRadius(6)
                        }

                        Text("\(pts) pt\(pts == 1 ? "" : "s")")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .frame(width: 52, alignment: .trailing)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(failed ? red.opacity(0.06) : (idx == 0 ? green.opacity(0.06) : Color.tertiaryBackground))
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Game Over / Winner screen
struct RhymeTimeGameOverView: View {
    @ObservedObject var manager: RhymeTimeGameManager
    @Environment(\.dismiss) private var dismiss

    private let gold   = Color(red: 0xFF/255.0, green: 0xCC/255.0, blue: 0x00/255.0)
    private let gray   = Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0)

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            // Trophy + winner headline
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(gold.opacity(0.12))
                        .frame(width: 110, height: 110)
                    Circle()
                        .fill(gold.opacity(0.22))
                        .frame(width: 86, height: 86)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(gold)
                }

                VStack(spacing: 6) {
                    Text("We Have a Winner!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)

                    if let winner = manager.gameWinner {
                        Text("\(winner) reached \(manager.winningScore) points!")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(gray)
                            .multilineTextAlignment(.center)
                    }
                }
            }

            Spacer()

            // Final scores card
            VStack(spacing: 0) {
                HStack {
                    Text("FINAL SCORES")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(gray)
                        .kerning(1.4)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                let sorted = manager.players.sorted { (manager.scores[$0] ?? 0) > (manager.scores[$1] ?? 0) }

                VStack(spacing: 2) {
                    ForEach(Array(sorted.enumerated()), id: \.element) { idx, player in
                        let pts      = manager.scores[player] ?? 0
                        let isWinner = player == manager.gameWinner

                        HStack(spacing: 14) {
                            // Rank badge
                            ZStack {
                                Circle()
                                    .fill(isWinner ? gold.opacity(0.18) : Color.appBackground)
                                    .frame(width: 32, height: 32)
                                if isWinner {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(gold)
                                } else {
                                    Text("\(idx + 1)")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(gray)
                                }
                            }

                            Text(player)
                                .font(.system(size: 16, weight: isWinner ? .bold : .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                                .lineLimit(1)

                            Spacer()

                            Text("\(pts) pt\(pts == 1 ? "" : "s")")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(isWinner ? gold : .primaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isWinner ? gold.opacity(0.08) : Color.tertiaryBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isWinner ? gold.opacity(0.30) : Color.clear, lineWidth: 1.5)
                                )
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.secondaryBackground)
            )
            .padding(.horizontal, 24)

            Spacer()

            // Action buttons
            VStack(spacing: 10) {
                PrimaryButton(title: "Play Again") {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    manager.resetGame()
                }
                .padding(.horizontal, 24)

                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    dismiss()
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .padding(.horizontal, 24)
            }

            Spacer(minLength: 8)
        }
    }
}

#Preview {
    NavigationView {
        RhymeTimePlayView(
            manager: RhymeTimeGameManager(
                deck: Deck(
                    title: "Rhyme Time",
                    description: "Say words that rhyme!",
                    numberOfCards: 40,
                    estimatedTime: "10-15 min",
                    imageName: "Art 1.4",
                    type: .rhymeTime,
                    cards: allRhymeTimeCards,
                    availableCategories: []
                ),
                players: ["Alice", "Bob", "Charlie"]
            ),
            deck: Deck(
                title: "Rhyme Time",
                description: "Say words that rhyme!",
                numberOfCards: 40,
                estimatedTime: "10-15 min",
                imageName: "Art 1.4",
                type: .rhymeTime,
                cards: allRhymeTimeCards,
                availableCategories: []
            )
        )
    }
}

