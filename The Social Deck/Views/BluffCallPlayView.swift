//
//  BluffCallPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct BluffCallPlayView: View {
    @ObservedObject var manager: BluffCallGameManager
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var showEndView: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showHomeAlert: Bool = false
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, home button, and progress
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
                    if let currentCard = manager.currentCard {
                        Text("Card \(manager.currentIndex + 1) / \(manager.cards.count)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Game content based on phase
                if let currentCard = manager.currentCard {
                    Group {
                        switch manager.gamePhase {
                        case .playerTurn:
                            PlayerTurnView(card: currentCard, manager: manager)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        case .groupDeciding:
                            GroupDecisionView(manager: manager, card: currentCard)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        case .reveal:
                            RevealView(manager: manager, card: currentCard)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                                    removal: .scale(scale: 0.8).combined(with: .opacity)
                                ))
                        case .passingPhone:
                            PassPhoneView(manager: manager)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: manager.gamePhase)
                }
                
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
                    destination: BluffCallEndView(deck: deck, selectedCategories: selectedCategories, roundsPlayed: manager.cards.count, players: manager.players),
                    isActive: $showEndView
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: HomeView(),
                    isActive: $navigateToHome
                ) {
                    EmptyView()
                }
            }
        )
        .onAppear {
            // Don't start round immediately - wait for pass phone screen
            // The pass phone screen will call startRound() when ready
        }
        .onChange(of: manager.isFinished) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showEndView = true
                }
            }
        }
    }
}

// Player turn view - combines prompt and choice
struct PlayerTurnView: View {
    let card: Card
    @ObservedObject var manager: BluffCallGameManager
    
    var body: some View {
        VStack(spacing: 24) {
            Text("\(manager.currentPlayer), look at this secretly")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.buttonBackground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 20) {
                    if let optionA = card.optionA, let optionB = card.optionB {
                        // Two-option card
                        Text("Which is true for you?")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .padding(.top, 24)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    manager.playerChoseAnswer("A")
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Text("Option A")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                    
                                    Text(optionA)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color.black)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 24)
                                    
                                    if manager.playerAnswer == "A" {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(Color.buttonBackground)
                                            .padding(.top, 4)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(manager.playerAnswer == "A" ? Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0) : Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(manager.playerAnswer == "A" ? Color.buttonBackground : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text("OR")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color.buttonBackground)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    manager.playerChoseAnswer("B")
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Text("Option B")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                    
                                    Text(optionB)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color.black)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 24)
                                    
                                    if manager.playerAnswer == "B" {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(Color.buttonBackground)
                                            .padding(.top, 4)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(manager.playerAnswer == "B" ? Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0) : Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(manager.playerAnswer == "B" ? Color.buttonBackground : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    } else {
                        // Question card
                        VStack(spacing: 20) {
                            Text(card.text)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.black)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        manager.playerChoseAnswer("I have")
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Text("I have")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(manager.playerAnswer == "I have" ? .white : Color.black)
                                        
                                        if manager.playerAnswer == "I have" {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(manager.playerAnswer == "I have" ? Color.buttonBackground : Color.white)
                                    .cornerRadius(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        manager.playerChoseAnswer("I haven't")
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Text("I haven't")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(manager.playerAnswer == "I haven't" ? .white : Color.black)
                                        
                                        if manager.playerAnswer == "I haven't" {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(manager.playerAnswer == "I haven't" ? Color.buttonBackground : Color.white)
                                    .cornerRadius(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .frame(width: 320, height: 400)
            
            if manager.playerAnswer != nil {
                VStack(spacing: 12) {
                    Text("Convince the group your answer is true!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    PrimaryButton(title: "Ready for Group Decision") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            manager.finishPlayerTurn()
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: manager.playerAnswer)
    }
}

// Group decision view
struct GroupDecisionView: View {
    @ObservedObject var manager: BluffCallGameManager
    let card: Card
    
    var hasMultipleVoters: Bool {
        return manager.players.count > 2
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(hasMultipleVoters ? "Each player, decide:" : "Group, decide:")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.buttonBackground)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Show the prompt they're deciding about
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.tertiaryBackground)
                    
                    VStack(spacing: 12) {
                        if let optionA = card.optionA, let optionB = card.optionB {
                            // Two-option card
                            VStack(spacing: 8) {
                                Text("\(manager.currentPlayer) said:")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                
                                if manager.playerAnswer == "A" {
                                    Text(optionA)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text(optionB)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        } else {
                            // Question card
                            VStack(spacing: 8) {
                                Text("\(manager.currentPlayer) said:")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                
                                Text(card.text)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .multilineTextAlignment(.center)
                                
                                Text(manager.playerAnswer ?? "")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.buttonBackground)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                if hasMultipleVoters {
                    // Individual voting for 3+ players
                    VStack(spacing: 16) {
                        Text("Do you believe \(manager.currentPlayer)?")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // List of voting players
                        ForEach(manager.votingPlayers, id: \.self) { player in
                            PlayerVoteCard(
                                player: player,
                                manager: manager
                            )
                        }
                        .padding(.horizontal, 40)
                    }
                } else {
                    // Simple group decision for 2 players
                    VStack(spacing: 16) {
                        Text("Do you believe \(manager.currentPlayer)?")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    manager.groupMadeDecision(.believe)
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Text("Believe")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color.buttonBackground)
                                .cornerRadius(16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    manager.groupMadeDecision(.callBluff)
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Text("Call Bluff")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color.buttonBackground)
                                .cornerRadius(16)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 40)
                    }
                }
                
                // Show voting progress if multiple voters
                if hasMultipleVoters {
                    let votedCount = manager.votingPlayers.filter { manager.getPlayerVote($0) != nil }.count
                    let totalCount = manager.votingPlayers.count
                    
                    if votedCount < totalCount {
                        Text("\(votedCount) of \(totalCount) players have voted")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .padding(.top, 8)
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
    }
}

// Individual player vote card
struct PlayerVoteCard: View {
    let player: String
    @ObservedObject var manager: BluffCallGameManager
    
    var hasVoted: Bool {
        return manager.getPlayerVote(player) != nil
    }
    
    var currentVote: BluffCallGameManager.GroupDecision? {
        return manager.getPlayerVote(player)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(player)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
            
            if hasVoted {
                // Show their vote
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.buttonBackground)
                    
                    Text(currentVote == .believe ? "Believed" : "Called Bluff")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0))
                .cornerRadius(16)
            } else {
                // Show voting buttons
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            manager.playerVoted(player, decision: .believe)
                        }
                    }) {
                        Text("Believe")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.buttonBackground)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            manager.playerVoted(player, decision: .callBluff)
                        }
                    }) {
                        Text("Call Bluff")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.buttonBackground)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.appBackground)
        .cornerRadius(16)
        .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
    }
}

// Reveal view - combines truth and consequences
struct RevealView: View {
    @ObservedObject var manager: BluffCallGameManager
    let card: Card
    
    var hasMultipleVoters: Bool {
        return manager.players.count > 2
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("The Truth:")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color.buttonBackground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Truth Section
                        VStack(spacing: 12) {
                            Text("The Answer Was:")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            
                            if let optionA = card.optionA, let optionB = card.optionB {
                                // Two-option card
                                Text(manager.revealedAnswer == "A" ? optionA : optionB)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.buttonBackground)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            } else {
                                // Question card
                                VStack(spacing: 8) {
                                    Text(card.text)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 24)
                                    
                                    Text(manager.revealedAnswer ?? "")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.buttonBackground)
                                }
                            }
                        }
                        .padding(.top, 24)
                        
                        Divider()
                            .padding(.horizontal, 24)
                        
                        // Player's Choice Section
                        VStack(spacing: 8) {
                            Text("\(manager.currentPlayer) Claimed:")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            
                            if let optionA = card.optionA, let optionB = card.optionB {
                                Text(manager.playerAnswer == "A" ? optionA : optionB)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            } else {
                                // For question cards, show the full claim
                                VStack(spacing: 4) {
                                    Text(card.text)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 24)
                                    
                                    Text(manager.playerAnswer ?? "")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal, 24)
                        
                        if hasMultipleVoters {
                            // Individual Player Guesses Section (for 3+ players)
                            VStack(spacing: 12) {
                                Text("Player Guesses:")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                
                                ForEach(manager.votingPlayers, id: \.self) { player in
                                    if let vote = manager.getPlayerVote(player),
                                       let guessedCorrectly = manager.didPlayerGuessCorrectly(player) {
                                        HStack(spacing: 12) {
                                            Text(player)
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundColor(.primaryText)
                                            
                                            Spacer()
                                            
                                            Text(vote == .believe ? "Believed" : "Called Bluff")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(guessedCorrectly ? Color.green : Color.red)
                                            
                                            Image(systemName: guessedCorrectly ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(guessedCorrectly ? Color.green : Color.red)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(guessedCorrectly ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            Divider()
                                .padding(.horizontal, 24)
                        } else {
                            // Group Decision Section (for 2 players)
                            if let groupDecision = manager.groupDecision {
                                VStack(spacing: 8) {
                                    Text("Group Decision:")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                    
                                    Text(groupDecision == .callBluff ? "Called Bluff" : "Believed")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.buttonBackground)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 24)
                            
                            // Visual indication if group guessed correctly (only for 2 players)
                            if let guessedCorrectly = manager.didGroupGuessCorrectly() {
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        Image(systemName: guessedCorrectly ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(guessedCorrectly ? Color.green : Color.red)
                                        
                                        Text(guessedCorrectly ? "You Guessed Correctly!" : "You Guessed Wrong!")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(guessedCorrectly ? Color.green : Color.red)
                                    }
                                }
                                
                                Divider()
                                    .padding(.horizontal, 24)
                            }
                        }
                        
                        // Consequences Section
                        VStack(spacing: 12) {
                            Text("Results")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color.buttonBackground)
                            
                            if hasMultipleVoters {
                                // For 3+ players, show specific players who got it wrong
                                let wrongPlayers = manager.getPlayersWhoGuessedWrong()
                                let playerToldTruth = manager.playerAnswer == manager.revealedAnswer
                                
                                if wrongPlayers.isEmpty {
                                    // No one got it wrong
                                    if playerToldTruth {
                                        // Player told truth and everyone believed correctly
                                        Text("Everyone guessed right!")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(Color.buttonBackground)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 24)
                                    } else {
                                        // Player lied and everyone called bluff correctly
                                        Text("\(manager.currentPlayer) got caught!")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(Color.buttonBackground)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 24)
                                    }
                                } else {
                                    // Show players who got it wrong
                                    Text("\(wrongPlayers.joined(separator: ", ")) got fooled!")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.buttonBackground)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 24)
                                    
                                    // If player lied and everyone called bluff, player also loses
                                    if !playerToldTruth {
                                        let allCalledBluff = manager.votingPlayers.allSatisfy { 
                                            manager.getPlayerVote($0) == .callBluff 
                                        }
                                        if allCalledBluff {
                                            Text("\(manager.currentPlayer) got exposed!")
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundColor(Color.buttonBackground)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 24)
                                                .padding(.top, 8)
                                        }
                                    }
                                }
                            } else {
                                // For 2 players, use the original text
                                Text(manager.getConsequenceText())
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                
                                Text(manager.getWhoLoses())
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.buttonBackground)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .frame(width: 320, height: 400)
            
            PrimaryButton(title: "Next Round") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    manager.passToNextPlayer()
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

// Pass phone view
struct PassPhoneView: View {
    @ObservedObject var manager: BluffCallGameManager
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Pass the phone to")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                
                Text(manager.currentPlayer)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color.buttonBackground)
                    .scaleEffect(pulseScale)
            }
            
            PrimaryButton(title: "Ready") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    manager.startRound()
                }
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
    }
}

#Preview {
    NavigationView {
        BluffCallPlayView(
            manager: BluffCallGameManager(
                deck: Deck(
                    title: "Bluff Call",
                    description: "Test",
                    numberOfCards: 3,
                    estimatedTime: "5-10 min",
                    imageName: "Art 1.4",
                    type: .bluffCall,
                    cards: [
                        Card(text: "I've never been to a party", category: "Party"),
                        Card(text: "", category: "Party", optionA: "Option A", optionB: "Option B")
                    ],
                    availableCategories: ["Party"]
                ),
                selectedCategories: ["Party"],
                cardCount: 2,
                players: ["Player 1", "Player 2"]
            ),
            deck: Deck(
                title: "Bluff Call",
                description: "Test",
                numberOfCards: 3,
                estimatedTime: "5-10 min",
                imageName: "Art 1.4",
                type: .bluffCall,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party"]
        )
    }
}

