//
//  ActNaturalRevealView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI

struct ActNaturalRevealView: View {
    @ObservedObject var manager: ActNaturalGameManager
    let deck: Deck
    @State private var showingRole: Bool = false
    @State private var navigateToDiscussion: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.white
                .ignoresSafeArea()
            
            if let currentPlayer = manager.currentPlayer {
                if showingRole {
                    // Role reveal screen
                    roleRevealView(for: currentPlayer)
                } else {
                    // Pass device screen
                    passDeviceView(for: currentPlayer)
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: ActNaturalDiscussionView(manager: manager, deck: deck),
                isActive: $navigateToDiscussion
            ) {
                EmptyView()
            }
        )
    }
    
    // MARK: - Pass Device View
    private func passDeviceView(for player: ActNaturalPlayer) -> some View {
        VStack(spacing: 0) {
            // Header with progress
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
                
                Spacer()
                
                Text("\(manager.currentPlayerIndex + 1) of \(manager.players.count)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Game artwork
            Image(deck.imageName)
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .frame(width: 160, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
            
            // Pass instruction
            VStack(spacing: 16) {
                Text("Pass to")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                
                Text(player.name)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text("Make sure no one else can see the screen")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Ready button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingRole = true
                }
                HapticManager.shared.mediumImpact()
            }) {
                Text("I'm \(player.name) — Show My Role")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Role Reveal View
    private func roleRevealView(for player: ActNaturalPlayer) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                
                Text("\(manager.currentPlayerIndex + 1) of \(manager.players.count)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            if player.isUnknown {
                // Unknown player view
                unknownRoleView(for: player)
            } else {
                // Regular player with word
                regularRoleView(for: player)
            }
            
            Spacer()
            
            // Continue button
            Button(action: continueToNext) {
                Text(manager.currentPlayerIndex == manager.players.count - 1 ? "Start Discussion" : "Got It — Pass Device")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Unknown Role View
    private func unknownRoleView(for player: ActNaturalPlayer) -> some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "questionmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
            }
            
            VStack(spacing: 12) {
                Text("Act Natural")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                
                Text("You are the Unknown")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            }
            
            // Card with instructions
            VStack(spacing: 16) {
                Text("You do NOT know the word")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text("Listen carefully to others and try to figure out what the word is. Blend in and act like you know it!")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(24)
            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
            .cornerRadius(20)
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Regular Role View
    private func regularRoleView(for player: ActNaturalPlayer) -> some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
            }
            
            VStack(spacing: 12) {
                Text("You Know the Word")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text("The secret word is:")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
            
            // Word card
            VStack(spacing: 8) {
                Text(manager.secretWord?.word ?? "???")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                if let category = manager.secretWord?.category {
                    Text(category)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .cornerRadius(20)
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
            .cornerRadius(20)
            .padding(.horizontal, 24)
            
            // Hint
            Text("Try to identify the unknown player(s)!")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
        }
    }
    
    private func continueToNext() {
        manager.markCurrentPlayerViewed()
        
        if manager.currentPlayerIndex == manager.players.count - 1 {
            // Last player, go to discussion
            manager.gamePhase = .discussion
            navigateToDiscussion = true
        } else {
            // Move to next player
            manager.moveToNextPlayer()
            withAnimation(.easeInOut(duration: 0.3)) {
                showingRole = false
            }
        }
        HapticManager.shared.mediumImpact()
    }
}

#Preview {
    NavigationView {
        ActNaturalRevealView(
            manager: {
                let manager = ActNaturalGameManager()
                manager.addPlayer(name: "Alice")
                manager.addPlayer(name: "Bob")
                manager.addPlayer(name: "Charlie")
                manager.startGame()
                return manager
            }(),
            deck: Deck(
                title: "Act Natural",
                description: "Blend in or get caught!",
                numberOfCards: 150,
                estimatedTime: "10-20 min",
                imageName: "AN 2.0",
                type: .other,
                cards: [],
                availableCategories: []
            )
        )
    }
}

