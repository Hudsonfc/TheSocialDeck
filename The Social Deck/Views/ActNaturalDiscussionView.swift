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
        .onDisappear {
            manager.stopTimer()
        }
    }
    
    // MARK: - Discussion View
    private var discussionView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Discussion content with timer front and center
            VStack(spacing: 32) {
                // Timer display if enabled - front and center
                if let duration = manager.timerDuration {
                    VStack(spacing: 12) {
                        // Circular timer
                        ZStack {
                            Circle()
                                .stroke(Color.tertiaryBackground, lineWidth: 12)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(manager.timeRemaining) / CGFloat(duration))
                                .stroke(
                                    manager.timeRemaining < 60 ? Color.red : Color.buttonBackground,
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 0.1), value: manager.timeRemaining)
                            
                            Text(timeString)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(manager.timeRemaining < 60 ? Color.red : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        }
                    }
                }
                
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
                // Secret Word Card
                VStack(spacing: 16) {
                    Text("The Secret Word")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    Text(manager.secretWord?.word ?? "???")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    if let category = manager.secretWord?.category {
                        Text(category)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.buttonBackground)
                            )
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 24)
                
                // Unknown Players Card
                VStack(spacing: 16) {
                    Text("The Unknown\(manager.unknownCount > 1 ? "s" : "")")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    VStack(spacing: 12) {
                        ForEach(manager.unknownPlayers.prefix(manager.unknownCount)) { player in
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.buttonBackground)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color.buttonBackground.opacity(0.15))
                                    )
                                
                                Text(player.name)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Continue button
            Button(action: {
                navigateToEnd = true
                HapticManager.shared.mediumImpact()
            }) {
                Text("Continue")
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
    
    private var timeString: String {
        let minutes = manager.timeRemaining / 60
        let seconds = manager.timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
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

