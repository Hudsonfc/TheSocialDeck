//
//  NHIECategorySelectionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct NHIECategorySelectionView: View {
    let deck: Deck
    @State private var selectedCategories: Set<String> = []
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
                        Text("Select Categories")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("Choose one or more categories")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 8)
                }
                
                Spacer()
                
                // Category grid
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(deck.availableCategories, id: \.self) { category in
                            CategoryTile(
                                category: category,
                                isSelected: selectedCategories.contains(category),
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if selectedCategories.contains(category) {
                                            selectedCategories.remove(category)
                                        } else {
                                            selectedCategories.insert(category)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                }
                
                // Continue button at bottom
                VStack(spacing: 12) {
                    if !selectedCategories.isEmpty {
                        Text("\(selectedCategories.count) \(selectedCategories.count == 1 ? "category" : "categories") selected")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    }
                    
                    PrimaryButton(title: "Continue") {
                        if !selectedCategories.isEmpty {
                            navigateToSetup = true
                        }
                    }
                    .disabled(selectedCategories.isEmpty)
                    .opacity(selectedCategories.isEmpty ? 0.5 : 1.0)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: NHIESetupView(deck: deck, selectedCategories: Array(selectedCategories)),
                isActive: $navigateToSetup
            ) {
                EmptyView()
            }
        )
    }
}

struct CategoryTile: View {
    let category: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(category)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0xE5/255.0, green: 0xE5/255.0, blue: 0xE5/255.0), lineWidth: isSelected ? 2 : 1)
            )
            )
            .shadow(color: isSelected ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.15) : Color.black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        NHIECategorySelectionView(deck: Deck(
            title: "Never Have I Ever",
            description: "Test",
            numberOfCards: 50,
            estimatedTime: "5-10 min",
            imageName: "NHIE artwork",
            type: .neverHaveIEver,
            cards: [],
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
        ))
    }
}

