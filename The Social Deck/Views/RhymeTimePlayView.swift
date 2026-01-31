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
            Text("Ready to start?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
            
            Text("Say a word that rhymes with the base word before time runs out!")
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

// Active game view
struct RhymeTimeActiveGameView: View {
    @ObservedObject var manager: RhymeTimeGameManager
    @State private var rhymeInput: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            // Base word display
            VStack(spacing: 16) {
                Text("Rhyme with:")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                
                Text(manager.baseWord.uppercased())
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
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
            
            // Used rhymes display
            if !manager.usedRhymes.isEmpty {
                VStack(spacing: 8) {
                    Text("Used Rhymes")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(manager.usedRhymes, id: \.self) { rhyme in
                                Text(rhyme.capitalized)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.tertiaryBackground)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
            
            // Rhyme input (optional - for tracking)
            VStack(spacing: 12) {
                Text("What did you say? (Optional)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                
                TextField("Enter your rhyme", text: $rhymeInput)
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
            
            // Action buttons
            VStack(spacing: 16) {
                Button(action: {
                    submitRhyme()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                        Text("I Said a Rhyme")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                    .cornerRadius(12)
                    .shadow(color: Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 40)
        }
        .onChange(of: manager.currentPlayerIndex) { _, _ in
            // Clear input when player changes
            rhymeInput = ""
            isTextFieldFocused = false
        }
    }
    
    private func submitRhyme() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // If player entered a word, check for duplicates
        if !rhymeInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            manager.addUsedRhyme(rhymeInput)
            // If addUsedRhyme detected a duplicate, it will handle the loss
            // Otherwise, continue with submission
            if manager.gamePhase == .active {
                manager.submitRhyme()
                rhymeInput = ""
            }
        } else {
            // Player didn't enter a word - just confirm they said something
            // Group can enforce rules manually
            manager.submitRhyme()
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
                
                Text("Everyone found a rhyme!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
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

// Timer expired view
struct RhymeTimeTimerExpiredView: View {
    @ObservedObject var manager: RhymeTimeGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            // Friendly visual
            ZStack {
                Circle()
                    .fill(Color.buttonBackground.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "timer")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(Color.buttonBackground)
            }
            
            VStack(spacing: 16) {
                Text("Time's Up!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                
                if let loser = manager.loser {
                    Text("\(loser) was holding the phone!")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
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

