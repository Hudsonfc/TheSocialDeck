//
//  StoryChainEndView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct StoryChainEndView: View {
    let deck: Deck
    let storySentences: [StorySentence]
    @State private var navigateToHome: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        navigateToHome = true
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                // Title
                Text("Story Complete!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                
                // Full story display with author labels - takes up most of the screen
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(storySentences.enumerated()), id: \.element.id) { index, sentence in
                            VStack(alignment: .leading, spacing: 6) {
                                // Author label (if not starting sentence)
                                if let author = sentence.author {
                                    Text(author)
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                        .textCase(.uppercase)
                                } else {
                                    Text("Starting Line")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                        .textCase(.uppercase)
                                }
                                
                                // Sentence text
                                Text(sentence.text)
                                    .font(.system(size: 18, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                    .lineSpacing(6)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(sentence.author != nil ? Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0) : Color(red: 0xF0/255.0, green: 0xF0/255.0, blue: 0xF0/255.0))
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
                .padding(.horizontal, 40)
                
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
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 16)
                
                // Back to Home button
                Button(action: {
                    HapticManager.shared.lightImpact()
                    navigateToHome = true
                }) {
                    Text("Home")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: 2)
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHome
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: StoryChainSetupView(deck: deck),
                isActive: $navigateToPlayAgain
            ) {
                EmptyView()
            }
        )
    }
}

#Preview {
    NavigationView {
        StoryChainEndView(
            deck: Deck(
                title: "Story Chain",
                description: "Add one sentence to continue the story. Pass the phone and watch the chaos unfold.",
                numberOfCards: 145,
                estimatedTime: "15-25 min",
                imageName: "SC artwork",
                type: .storyChain,
                cards: [],
                availableCategories: []
            ),
            storySentences: [
                StorySentence(text: "Once upon a time, a penguin found a key in the middle of the desert.", author: nil),
                StorySentence(text: "The key was glowing with an otherworldly light.", author: "Alice"),
                StorySentence(text: "Suddenly, the ground began to shake.", author: "Bob")
            ]
        )
    }
}

