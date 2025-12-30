//
//  PopCultureTriviaEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct PopCultureTriviaEndView: View {
    @ObservedObject var manager: PopCultureTriviaGameManager
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti: Bool = false
    @State private var navigateToHomeView: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    
    private var scorePercentage: Int {
        guard manager.cards.count > 0 else { return 0 }
        return Int((Double(manager.score) / Double(manager.cards.count)) * 100)
    }
    
    private var scoreMessage: String {
        let percentage = scorePercentage
        if percentage >= 90 {
            return "Outstanding!"
        } else if percentage >= 75 {
            return "Great Job!"
        } else if percentage >= 60 {
            return "Good Work!"
        } else if percentage >= 50 {
            return "Not Bad!"
        } else {
            return "Keep Trying!"
        }
    }
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Score icon
                if showConfetti {
                    VStack(spacing: 24) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 120))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        
                        // Score display
                        VStack(spacing: 12) {
                            Text(scoreMessage)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Text("\(manager.score) / \(manager.cards.count)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            
                            Text("\(scorePercentage)%")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        }
                    }
                    .padding(.bottom, 40)
                }
                
                Spacer()
                
                // Play Again button
                Button(action: {
                    HapticManager.shared.lightImpact()
                    navigateToPlayAgain = true
                }) {
                    Text("Play Again")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 16)
                
                // Home button
                Button(action: {
                    HapticManager.shared.lightImpact()
                    navigateToHomeView = true
                }) {
                    Text("Home")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: 2)
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHomeView
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: PopCultureTriviaCategorySelectionView(deck: deck),
                isActive: $navigateToPlayAgain
            ) {
                EmptyView()
            }
        )
        .onAppear {
            withAnimation {
                showConfetti = true
            }
        }
    }
}

