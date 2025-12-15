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
                                insertion: .scale(scale: 0.95).combined(with: .opacity),
                                removal: .scale(scale: 0.95).combined(with: .opacity)
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
                    players: manager.players,
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
}

// Riddle View - Shows riddle card, timer, and player buttons
struct RiddleView: View {
    @ObservedObject var manager: RiddleMeThisGameManager
    @Binding var cardRotation: Double
    @Binding var isCardFlipped: Bool
    @Binding var isTransitioning: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Timer
            VStack(spacing: 8) {
                Text(manager.formatTime(manager.timeRemaining))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(manager.timeRemaining <= 10 ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .animation(.easeInOut(duration: 0.3), value: manager.timeRemaining)
                
                if manager.timeRemaining <= 10 {
                    Text("Time running out!")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .transition(.opacity)
                }
            }
            .padding(.top, 20)
            
            // Card
            if let riddle = manager.currentRiddle {
                ZStack {
                    // Card front - visible when rotation < 90
                    RiddleCardFrontView(text: riddle.text)
                        .opacity(cardRotation < 90 ? 1 : 0)
                    
                    // Card back - visible when rotation >= 90 (showing answer)
                    RiddleCardBackView(text: riddle.text, answer: manager.currentAnswer)
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
                .padding(.vertical, 20)
            }
            
            Spacer()
            
            // Locked out players
            if !manager.lockedOutPlayers.isEmpty {
                VStack(spacing: 8) {
                    Text("Locked Out")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(manager.lockedOutPlayers), id: \.self) { player in
                                Text(player)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 8)
            }
            
            // Player buttons
            VStack(spacing: 12) {
                Text("Who gave the answer?")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .padding(.bottom, 4)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(manager.players, id: \.self) { player in
                            if !manager.lockedOutPlayers.contains(player) {
                                HStack(spacing: 12) {
                                    // Correct answer button
                                    Button(action: {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                        manager.submitCorrectAnswer(winnerName: player)
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18, weight: .medium))
                                            Text("\(player) - Correct")
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                                        .cornerRadius(12)
                                    }
                                    
                                    // Wrong answer button
                                    Button(action: {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                        manager.submitIncorrectAnswer(playerName: player)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                            .frame(width: 50, height: 50)
                                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 32)
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
            }
        } else {
            // Flip to back (show answer)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isCardFlipped = true
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
        VStack(spacing: 32) {
            // Winner or no winner
            if let winner = manager.winner {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.1))
                            .frame(width: 150, height: 150)
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                    }
                    
                    Text("Winner!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Text(winner)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                }
                .padding(.top, 20)
            } else {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0).opacity(0.1))
                            .frame(width: 150, height: 150)
                        
                        Image(systemName: "clock.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    }
                    
                    Text("Time's Up!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Text("No winner this round")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                }
                .padding(.top, 20)
            }
            
            // Card showing riddle and answer
            if let riddle = manager.currentRiddle {
                ZStack {
                    RiddleCardBackView(text: riddle.text, answer: manager.currentAnswer)
                }
                .frame(width: 320, height: 480)
                .rotation3DEffect(
                    .degrees(cardRotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .id(riddle.id)
                .onAppear {
                    // Auto-flip to show answer
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                        cardRotation = 180
                        isCardFlipped = true
                    }
                }
                .padding(.vertical, 20)
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

// Card Front View
struct RiddleCardFrontView: View {
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 20) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                
                Text("Riddle Me This")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                
                Text(text)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }
        }
    }
}

// Card Back View (showing answer)
struct RiddleCardBackView: View {
    let text: String
    let answer: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 24) {
                Text("Answer")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                
                Text(answer)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Divider()
                    .padding(.horizontal, 32)
                
                Text(text)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.vertical, 32)
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
                    imageName: "Art 1.4",
                    type: .riddleMeThis,
                    cards: allRiddleMeThisCards,
                    availableCategories: []
                ),
                cardCount: 5,
                players: ["Player 1", "Player 2"]
            ),
            deck: Deck(
                title: "Riddle Me This",
                description: "Solve riddles",
                numberOfCards: 71,
                estimatedTime: "5-10 min",
                imageName: "Art 1.4",
                type: .riddleMeThis,
                cards: allRiddleMeThisCards,
                availableCategories: []
            )
        )
    }
}
