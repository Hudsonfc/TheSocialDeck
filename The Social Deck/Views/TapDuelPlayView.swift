//
//  TapDuelPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import UIKit

struct TapDuelPlayView: View {
    @ObservedObject var manager: TapDuelGameManager
    let deck: Deck
    @Environment(\.dismiss) private var dismiss
    @State private var showHomeAlert: Bool = false
    @State private var navigateToHome: Bool = false
    
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
                    case .ready:
                        ReadyView(manager: manager)
                            .transition(.opacity)
                    case .countdown, .goSignal:
                        GameView(manager: manager)
                            .transition(.opacity)
                    case .finished:
                        FinishedView(manager: manager)
                            .transition(.scale.combined(with: .opacity))
                    case .falseStart:
                        FalseStartView(manager: manager)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: manager.gamePhase)
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

// Ready View - Shows before round starts
struct ReadyView: View {
    @ObservedObject var manager: TapDuelGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            // Scores
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text(manager.currentPlayer1Side)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    Text("\(manager.leftSideScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
                
                Text("VS")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                
                VStack(spacing: 4) {
                    Text(manager.currentPlayer2Side)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    Text("\(manager.rightSideScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
            }
            .padding(.top, 40)
            
            Text("Get Ready!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            
            Text("Place your finger on your side of the screen. Wait for GO!")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            PrimaryButton(title: "Start Round") {
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                // Small delay for smoother transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    manager.startRound()
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

// Game View - Split screen during countdown and GO signal
struct GameView: View {
    @ObservedObject var manager: TapDuelGameManager
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side (Player 1)
                ZStack {
                    Color(red: 0xF8/255.0, green: 0xF9/255.0, blue: 0xFA/255.0)
                    
                    VStack(spacing: 16) {
                        Text(manager.currentPlayer1Side)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("\(manager.leftSideScore)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    }
                }
                .frame(width: geometry.size.width / 2)
                .contentShape(Rectangle())
                .onTapGesture {
                    manager.handleTap(isLeftSide: true)
                }
                
                // Divider
                Rectangle()
                    .fill(Color(red: 0xE5/255.0, green: 0xE5/255.0, blue: 0xE5/255.0))
                    .frame(width: 2)
                
                // Right side (Player 2)
                ZStack {
                    Color(red: 0xF8/255.0, green: 0xF9/255.0, blue: 0xFA/255.0)
                    
                    VStack(spacing: 16) {
                        Text(manager.currentPlayer2Side)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("\(manager.rightSideScore)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    }
                }
                .frame(width: geometry.size.width / 2)
                .contentShape(Rectangle())
                .onTapGesture {
                    manager.handleTap(isLeftSide: false)
                }
            }
            
            // GO Signal overlay (centered)
            if manager.gamePhase == .goSignal {
                ZStack {
                    // Flash effect background
                    Color.white
                        .opacity(manager.goSignalOpacity * 0.9)
                        .ignoresSafeArea()
                    
                    Text("GO!")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                        .opacity(manager.goSignalOpacity)
                        .shadow(color: Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.5), radius: 20, x: 0, y: 0)
                }
                .allowsHitTesting(false) // Don't block taps
            }
        }
    }
}

// Finished View - Shows winner
struct FinishedView: View {
    @ObservedObject var manager: TapDuelGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            // Winner visual
            ZStack {
                Circle()
                    .fill(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
            }
            
            VStack(spacing: 16) {
                Text("Winner!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                if let winner = manager.winner {
                    Text(winner)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                }
            }
            
            // Scores
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text(manager.currentPlayer1Side)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    Text("\(manager.leftSideScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
                
                Text("VS")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                
                VStack(spacing: 4) {
                    Text(manager.currentPlayer2Side)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    Text("\(manager.rightSideScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
            }
            .padding(.top, 8)
            
            // Action buttons
            VStack(spacing: 16) {
                PrimaryButton(title: "Rematch") {
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        manager.rematch()
                    }
                }
                
                Button(action: {
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        manager.swapSides()
                    }
                }) {
                    Text("Swap Sides & Rematch")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
    }
}

// False Start View - Shows when someone tapped too early
struct FalseStartView: View {
    @ObservedObject var manager: TapDuelGameManager
    
    var body: some View {
        VStack(spacing: 32) {
            // False start visual
            ZStack {
                Circle()
                    .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
            }
            
            VStack(spacing: 16) {
                Text("False Start!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                if let falseStartPlayer = manager.falseStartPlayer {
                    Text("\(falseStartPlayer) tapped too early!")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Determine winner (the other player)
                    if falseStartPlayer == manager.currentPlayer1Side {
                        Text("\(manager.currentPlayer2Side) wins!")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                            .padding(.top, 8)
                    } else {
                        Text("\(manager.currentPlayer1Side) wins!")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                            .padding(.top, 8)
                    }
                }
            }
            
            // Scores
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text(manager.currentPlayer1Side)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    Text("\(manager.leftSideScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
                
                Text("VS")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                
                VStack(spacing: 4) {
                    Text(manager.currentPlayer2Side)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    Text("\(manager.rightSideScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
            }
            .padding(.top, 8)
            
            // Action buttons
            VStack(spacing: 16) {
                PrimaryButton(title: "Rematch") {
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        manager.rematch()
                    }
                }
                
                Button(action: {
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        manager.swapSides()
                    }
                }) {
                    Text("Swap Sides & Rematch")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    NavigationView {
        TapDuelPlayView(
            manager: TapDuelGameManager(player1Name: "Player 1", player2Name: "Player 2"),
            deck: Deck(
                title: "Tap Duel",
                description: "Fast reaction game",
                numberOfCards: 0,
                estimatedTime: "2-5 min",
                imageName: "Art 1.4",
                type: .tapDuel,
                cards: [],
                availableCategories: []
            )
        )
    }
}

