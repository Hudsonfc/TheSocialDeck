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
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button at top left
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    }
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 32) {
                    // Game artwork
                    Image(deck.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipped()
                        .cornerRadius(100)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Difficulty Selection
                    VStack(spacing: 20) {
                        Text("Select Difficulty")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        VStack(spacing: 16) {
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
                    
                    // Start Game button
                    PrimaryButton(title: "Start Game") {
                        navigateToPlay = true
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: MemoryMasterLoadingView(
                    deck: deck,
                    difficulty: selectedDifficulty
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
                    Spacer()
                VStack(alignment: .center, spacing: 4) {
                    Text(difficulty.displayName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? .white : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Text("\(difficulty.numberOfPairs * 2) cards")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(isSelected ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
            .cornerRadius(16)
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

