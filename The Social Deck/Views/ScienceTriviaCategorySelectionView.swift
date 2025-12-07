//
//  ScienceTriviaCategorySelectionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ScienceTriviaCategorySelectionView: View {
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
                // Top section with back button and title
                VStack(spacing: 20) {
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
                    
                    VStack(spacing: 8) {
                        Text("Select Difficulty")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("Choose one difficulty level")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 8)
                }
                
                Spacer()
                
                // Difficulty buttons - take up majority of space
                VStack(spacing: 20) {
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
                
                Spacer()
                
                // Continue button at bottom
                PrimaryButton(title: "Continue") {
                    if selectedCategory != nil {
                        navigateToSetup = true
                    }
                }
                .disabled(selectedCategory == nil)
                .opacity(selectedCategory == nil ? 0.5 : 1.0)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: ScienceTriviaSetupView(deck: deck, selectedCategories: selectedCategory != nil ? [selectedCategory!] : []),
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

