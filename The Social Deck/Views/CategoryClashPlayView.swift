//
//  CategoryClashPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct CategoryClashPlayView: View {
    @ObservedObject var manager: CategoryClashGameManager
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var showEndView: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showHomeAlert: Bool = false
    @State private var categoryOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, back button, and progress
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
                    
                    // Back button
                    if manager.canGoBack {
                        Button(action: {
                            previousCategory()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Previous")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.primaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.tertiaryBackground)
                            .cornerRadius(20)
                            .fixedSize()
                        }
                        .padding(.leading, 12)
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    Text("\(manager.gamePosition + 1) / \(manager.cards.count)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Category display
                if let currentCard = manager.currentCard() {
                    VStack(spacing: 32) {
                        // Game title
                        Text(deck.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .padding(.horizontal, 40)
                        
                        // Timer display (if enabled)
                        if manager.timerEnabled {
                            ZStack {
                                Circle()
                                    .stroke(Color.tertiaryBackground, lineWidth: 8)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: manager.timeRemaining / Double(manager.timerDuration))
                                    .stroke(
                                        manager.timeRemaining <= 5 ? Color.red : Color.buttonBackground,
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 0.1), value: manager.timeRemaining)
                                
                                Text("\(Int(manager.timeRemaining))")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(manager.timeRemaining <= 5 ? .red : .primaryText)
                            }
                            
                            if manager.isTimerExpired {
                                Text("Time's Up!")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Category card - large and prominent
                        VStack(spacing: 20) {
                            Text(currentCard.text)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 180)
                        .padding(.vertical, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(color: Color.cardShadowColor, radius: 15, x: 0, y: 8)
                        )
                        .padding(.horizontal, 40)
                        
                        // Instructions - simplified for one phone
                        VStack(spacing: 12) {
                            Text("Pass the phone around")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                            
                            Text("Take turns naming items. Hesitate, repeat, or freeze? You're out!")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                    }
                    .offset(x: categoryOffset)
                    .id(currentCard.id)
                }
                
                Spacer()
                
                // Next Category button
                Button(action: {
                    if manager.isFinished {
                        showEndView = true
                    } else {
                        nextCategory()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(manager.isFinished ? "Finish Game" : "Next Category")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        if !manager.isFinished {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
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
        .navigationBarHidden(true)
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
                    destination: CategoryClashEndView(deck: deck, selectedCategories: selectedCategories, roundsPlayed: manager.cards.count),
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
        .onAppear {
            // Start timer for first category if enabled
            if manager.timerEnabled {
                manager.startTimer()
            }
        }
        .onDisappear {
            manager.stopTimer()
        }
        .onChange(of: manager.isFinished) { oldValue, newValue in
            if newValue {
                manager.stopTimer()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showEndView = true
                }
            }
        }
    }
    
    private func previousCategory() {
        isTransitioning = true
        
        // Slide current category right out of screen
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            categoryOffset = 500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // Position new category off screen to the left BEFORE changing
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                categoryOffset = -500
            }
            
            // Now change the category
            manager.previousCategory()
            
            // Small delay to ensure the view has updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                // Slide previous category in from left
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    categoryOffset = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTransitioning = false
                }
            }
        }
    }
    
    private func nextCategory() {
        isTransitioning = true
        
        // Stop timer before transition
        manager.stopTimer()
        
        // Slide current category left out of screen
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            categoryOffset = -500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // Position new category off screen to the right BEFORE changing
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                categoryOffset = 500
            }
            
            // Now change the category
            manager.nextCategory()
            
            // Reset and start timer for new category
            if manager.timerEnabled && !manager.isFinished {
                manager.resetTimer()
                manager.startTimer()
            }
            
            // Small delay to ensure the view has updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                // Slide new category in from right
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    categoryOffset = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTransitioning = false
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        CategoryClashPlayView(
            manager: CategoryClashGameManager(
                deck: Deck(
                    title: "Category Clash",
                    description: "Test",
                    numberOfCards: 3,
                    estimatedTime: "15-20 min",
                    imageName: "CC artwork",
                    type: .categoryClash,
                    cards: [
                        Card(text: "Types of beers", category: "Food & Drink", cardType: nil),
                        Card(text: "Things that are red", category: "Food & Drink", cardType: nil),
                        Card(text: "Types of pizza toppings", category: "Food & Drink", cardType: nil)
                    ],
                    availableCategories: ["Food & Drink"]
                ),
                selectedCategories: ["Food & Drink"]
            ),
            deck: Deck(
                title: "Category Clash",
                description: "Test",
                numberOfCards: 3,
                estimatedTime: "15-20 min",
                imageName: "CC artwork",
                type: .categoryClash,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Food & Drink"]
        )
    }
}

