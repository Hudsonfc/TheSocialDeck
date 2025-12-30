//
//  ScienceTriviaEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ScienceTriviaEndView: View {
    @ObservedObject var manager: ScienceTriviaGameManager
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti: Bool = false
    @State private var navigateToHomeView: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    
    var scorePercentage: Int {
        guard manager.cards.count > 0 else { return 0 }
        return Int((Double(manager.score) / Double(manager.cards.count)) * 100)
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Score display
                if showConfetti {
                    VStack(spacing: 24) {
                        Text("\(manager.score)/\(manager.cards.count)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        
                        Text("\(scorePercentage)%")
                            .font(.system(size: 36, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        
                        Text("Quiz Complete!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
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
                destination: ScienceTriviaCategorySelectionView(deck: deck),
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

