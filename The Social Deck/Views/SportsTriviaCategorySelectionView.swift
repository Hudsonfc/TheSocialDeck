//
//  SportsTriviaCategorySelectionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct SportsTriviaCategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategory: String? = nil
    @State private var navigateToSetup: Bool = false
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
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.top, 20)
                            .padding(.bottom, 32)
                        
                        // Title
                        Text("Select Difficulty")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .padding(.bottom, 8)
                        
                        Text("Choose your challenge level")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
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
                destination: SportsTriviaSetupView(deck: deck, selectedCategories: selectedCategory != nil ? [selectedCategory!] : []),
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
                        .foregroundColor(isSelected ? .white : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
                Spacer()
            }
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 10 : 5, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

