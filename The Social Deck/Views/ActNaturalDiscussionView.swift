//
//  ActNaturalDiscussionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI

struct ActNaturalDiscussionView: View {
    @ObservedObject var manager: ActNaturalGameManager
    let deck: Deck
    @State private var showReveal: Bool = false
    @State private var navigateToEnd: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            if showReveal {
                revealView
            } else {
                discussionView
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: ActNaturalEndView(manager: manager, deck: deck),
                isActive: $navigateToEnd
            ) {
                EmptyView()
            }
        )
    }
    
    // MARK: - Discussion View
    private var discussionView: some View {
        VStack(spacing: 0) {
            // Header
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
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Discussion content
            VStack(spacing: 32) {
                // Icon
                ZStack {
                Circle()
                    .fill(Color.buttonBackground.opacity(0.1))
                    .frame(width: 100, height: 100)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(Color.buttonBackground)
                }
                
                VStack(spacing: 16) {
                    Text("Discussion Time!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    
                    Text("Talk about the word without saying it directly. The unknown player(s) will try to blend in!")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }
                
                // Tips card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tips for Discussion")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    
                    tipRow(icon: "lightbulb.fill", text: "Give clues without being too obvious")
                    tipRow(icon: "eye.fill", text: "Watch for suspicious reactions")
                    tipRow(icon: "hand.raised.fill", text: "Ask each player to describe the word")
                    tipRow(icon: "clock.fill", text: "Take your time — no rush!")
                }
                .padding(20)
                .background(Color.secondaryBackground)
                .cornerRadius(20)
                .padding(.horizontal, 24)
                
                // Player count reminder
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.buttonBackground)
                    
                    Text("\(manager.unknownCount) unknown player\(manager.unknownCount > 1 ? "s" : "") among \(manager.players.count) players")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            // Reveal button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showReveal = true
                }
                HapticManager.shared.mediumImpact()
            }) {
                Text("Reveal the Truth")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.buttonBackground)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Reveal View
    private var revealView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 32) {
                // Word reveal
                VStack(spacing: 16) {
                    Text("The Word Was")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                    
                    Text(manager.secretWord?.word ?? "???")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    
                    if let category = manager.secretWord?.category {
                        Text(category)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.buttonBackground)
                            .cornerRadius(20)
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(Color.secondaryBackground)
                .cornerRadius(24)
                .padding(.horizontal, 24)
                
                // Unknown players reveal
                VStack(spacing: 16) {
                    Text("The Unknown\(manager.unknownCount > 1 ? "s Were" : " Was")")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                    
                    ForEach(manager.unknownPlayers) { player in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.buttonBackground)
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "questionmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(player.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.primaryText)
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color.buttonBackground.opacity(0.1))
                .cornerRadius(24)
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Play again button
            VStack(spacing: 12) {
                Button(action: {
                    navigateToEnd = true
                    HapticManager.shared.mediumImpact()
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color.buttonBackground)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
        }
    }
}

#Preview {
    NavigationView {
        ActNaturalDiscussionView(
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

