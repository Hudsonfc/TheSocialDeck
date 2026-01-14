//
//  StoryChainPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct StoryChainPlayView: View {
    @ObservedObject var manager: StoryChainGameManager
    let deck: Deck
    @Environment(\.dismiss) private var dismiss
    @State private var showEndView: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showHomeAlert: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit and home buttons
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
                    
                    // Home button
                    Button(action: {
                        showHomeAlert = true
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 12)
                    
                    Spacer()
                    
                    // Current player indicator with visual highlight
                    if !manager.isFinished {
                        VStack(spacing: 8) {
                            Text("It's Your Turn!")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                .textCase(.uppercase)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.buttonBackground)
                                
                                Text(manager.currentPlayer)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primaryText)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0xFF/255.0, green: 0xF4/255.0, blue: 0xF4/255.0))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.buttonBackground, lineWidth: 2)
                                    )
                            )
                            
                            Text("\(manager.currentPlayerIndex + 1) / \(manager.players.count)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                // Game title
                if !manager.isFinished {
                    Text(deck.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color.buttonBackground)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)
                }
                
                // Previous sentence card - only show the most recent sentence (not starting sentence after first turn)
                if !manager.isFinished {
                    if manager.currentPlayerIndex == 0 {
                        // First player sees the starting sentence
                        VStack(spacing: 8) {
                            Text("Starting Line")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                .textCase(.uppercase)
                            
                            Text(manager.startingSentence)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.primaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(Color.secondaryBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    } else if let lastSentence = manager.storySentences.last {
                        // Subsequent players only see the previous player's sentence
                        VStack(spacing: 8) {
                            Text("Previous Sentence")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                .textCase(.uppercase)
                            
                            Text(lastSentence.text)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.primaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(Color.secondaryBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    }
                }
                
                // Story accumulation area - hidden during gameplay, only shown at end
                if manager.isFinished {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(manager.storySentences) { storySentence in
                                Text(storySentence.text)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .lineSpacing(6)
                                    .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    // Spacer to push input to bottom during gameplay
                    Spacer()
                }
                
                // Text input and submit (only show if not finished)
                if !manager.isFinished {
                    VStack(spacing: 16) {
                        Text("Add your sentence")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Continue the story...", text: $manager.currentSentence, axis: .vertical)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.primaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(12)
                            .focused($isTextFieldFocused)
                            .lineLimit(3...6)
                            .autocapitalization(.sentences)
                            .disableAutocorrection(false)
                        
                        Button(action: {
                            manager.submitSentence()
                            isTextFieldFocused = false
                        }) {
                            HStack(spacing: 8) {
                                Text("Submit & Pass Phone")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                manager.currentSentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.gray
                                : Color.buttonBackground
                            )
                            .cornerRadius(12)
                        }
                        .disabled(manager.currentSentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                } else {
                    // Finish button when all players have gone
                    Button(action: {
                        showEndView = true
                    }) {
                        HStack(spacing: 8) {
                            Text("View Complete Story")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.buttonBackground)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Focus text field when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .alert("Go to Home?", isPresented: $showHomeAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Go Home", role: .destructive) {
                navigateToHome = true
            }
        } message: {
            Text("Are you sure you want to go back to the home screen? Your progress will be lost.")
        }
        .background(
            Group {
                NavigationLink(
                    destination: StoryChainEndView(deck: deck, storySentences: manager.storySentences),
                    isActive: $showEndView
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: HomeView(),
                    isActive: $navigateToHome
                ) {
                    EmptyView()
                }
            }
        )
        .onChange(of: manager.isFinished) { oldValue, newValue in
            if newValue {
                isTextFieldFocused = false
            }
        }
    }
}

#Preview {
    NavigationView {
        StoryChainPlayView(
            manager: StoryChainGameManager(
                deck: Deck(
                    title: "Story Chain",
                    description: "Add one sentence to continue the story. Pass the phone and watch the chaos unfold.",
                    numberOfCards: 145,
                    estimatedTime: "15-25 min",
                    imageName: "SC artwork",
                    type: .storyChain,
                    cards: allStoryChainCards,
                    availableCategories: []
                ),
                players: ["Alice", "Bob", "Charlie"]
            ),
            deck: Deck(
                title: "Story Chain",
                description: "Add one sentence to continue the story. Pass the phone and watch the chaos unfold.",
                numberOfCards: 125,
                estimatedTime: "15-25 min",
                imageName: "Art 1.4",
                type: .storyChain,
                cards: [],
                availableCategories: []
            )
        )
    }
}

