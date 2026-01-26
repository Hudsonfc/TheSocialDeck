//
//  MemoryMasterSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct MemoryMasterSetupView: View {
    let deck: Deck
    @State private var navigateToPlay: Bool = false
    @State private var selectedDifficulty: MemoryMasterDifficulty = .easy
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button at top left
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
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Game artwork - regular card image
                            Image(deck.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                                .padding(.top, 20)
                            
                            // Difficulty Selection
                            VStack(spacing: 12) {
                                Text("Select Difficulty")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondaryText)
                                
                                VStack(spacing: 12) {
                                    DifficultyButton(
                                        difficulty: .easy,
                                        isSelected: selectedDifficulty == .easy,
                                        onTap: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedDifficulty = .easy
                                            }
                                        }
                                    )
                                    
                                    DifficultyButton(
                                        difficulty: .medium,
                                        isSelected: selectedDifficulty == .medium,
                                        onTap: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedDifficulty = .medium
                                            }
                                        }
                                    )
                                    
                                    DifficultyButton(
                                        difficulty: .hard,
                                        isSelected: selectedDifficulty == .hard,
                                        onTap: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedDifficulty = .hard
                                            }
                                        }
                                    )
                                    
                                    DifficultyButton(
                                        difficulty: .expert,
                                        isSelected: selectedDifficulty == .expert,
                                        onTap: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedDifficulty = .expert
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 32)
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    // Start Game button - anchored at bottom
                    PrimaryButton(title: "Start Game") {
                        navigateToPlay = true
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: MemoryMasterPlayView(
                    manager: MemoryMasterGameManager(difficulty: selectedDifficulty),
                    deck: deck
                ),
                isActive: $navigateToPlay
            ) {
                EmptyView()
            }
        )
    }
}

fileprivate struct DifficultyButton: View {
    let difficulty: MemoryMasterDifficulty
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.displayName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? .white : .primaryText)
                    
                    Text("\(difficulty.numberOfPairs * 2) cards")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondaryText)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .primaryAccent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(isSelected ? .primaryAccent : Color.tertiaryBackground)
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationView {
        MemoryMasterSetupView(
            deck: Deck(
                title: "Memory Master",
                description: "Test your memory with escalating challenges.",
                numberOfCards: 55,
                estimatedTime: "20-30 min",
                imageName: "Art 1.4",
                type: .memoryMaster,
                cards: [],
                availableCategories: []
            )
        )
    }
}

