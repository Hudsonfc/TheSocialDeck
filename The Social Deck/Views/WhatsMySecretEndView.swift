//
//  WhatsMySecretEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct WhatsMySecretEndView: View {
    let deck: Deck
    let selectedCategories: [String]
    let groupWins: Int
    let secretPlayerWins: Int
    let totalRounds: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti: Bool = false
    @State private var navigateToHomeView: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Trophy icon
                if showConfetti {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                            .frame(width: 150, height: 150)
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 70, weight: .medium))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    }
                    .padding(.bottom, 40)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Completion text
                VStack(spacing: 24) {
                    Text("Game Complete!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .multilineTextAlignment(.center)
                    
                    // Score summary
                    VStack(spacing: 16) {
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                Text("Group Wins")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                Text("\(groupWins)")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                            }
                            
                            Text("VS")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            
                            VStack(spacing: 8) {
                                Text("Secret Players")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                Text("\(secretPlayerWins)")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            }
                        }
                        
                        Text("\(totalRounds) \(totalRounds == 1 ? "round" : "rounds") played")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Play Again button
                PrimaryButton(title: "Play Again") {
                    HapticManager.shared.lightImpact()
                    navigateToPlayAgain = true
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
                destination: WhatsMySecretSetupView(deck: deck),
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

#Preview {
    NavigationView {
        WhatsMySecretEndView(
            deck: Deck(
                title: "What's My Secret?",
                description: "Test",
                numberOfCards: 50,
                estimatedTime: "5-10 min",
                imageName: "WMS artwork",
                type: .whatsMySecret,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: [],
            groupWins: 5,
            secretPlayerWins: 3,
            totalRounds: 8
        )
    }
}
