//
//  HistoryTriviaCategorySelectionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct HistoryTriviaCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategory: String? = nil
    @State private var navigateToSetup: Bool = false
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
                    }
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Game artwork
                        Image(deck.imageName)
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .scaledToFit()
                            .frame(width: 160, height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                            .padding(.top, 20)
                            .padding(.bottom, 32)
                        
                        // Title
                        Text("Select Difficulty")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .padding(.bottom, 8)
                        
                        Text("Choose your challenge level")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .padding(.bottom, 24)
                        
                        // Difficulty buttons
                        VStack(spacing: 12) {
                            ForEach(deck.availableCategories, id: \.self) { category in
                                DifficultyButton(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    onTap: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedCategory = category
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)
                        
                        // Continue button
                        PrimaryButton(title: "Continue") {
                            HapticManager.shared.lightImpact()
                            navigateToSetup = true
                        }
                        .padding(.horizontal, 40)
                        .disabled(selectedCategory == nil)
                        .opacity(selectedCategory == nil ? 0.5 : 1.0)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: HistoryTriviaSetupView(deck: deck, selectedCategories: selectedCategory != nil ? [selectedCategory!] : []),
                isActive: $navigateToSetup
            ) {
                EmptyView()
            }
        )
    }
}

fileprivate struct DifficultyButton: View {
    let category: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Text(category)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .white : .primaryText)
                }
                Spacer()
            }
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? .primaryAccent : Color.tertiaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0), lineWidth: 1)
            )
            .shadow(color: isSelected ? .primaryAccent.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 10 : 5, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

