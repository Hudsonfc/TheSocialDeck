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
    @State private var cardRotation: Double = 0
    
    private var isFlipped: Bool { cardRotation >= 90 }
    
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
                
                // Category display with flip-to-reveal
                if let currentCard = manager.currentCard() {
                    VStack(spacing: 32) {
                        Text(deck.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.buttonBackground)
                            .padding(.horizontal, 40)
                        
                        // Timer (only when flipped and enabled)
                        if manager.timerEnabled && isFlipped {
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
                        
                        // Flippable category card
                        ZStack {
                            CategoryClashCardFrontView()
                                .opacity(cardRotation < 90 ? 1 : 0)
                            
                            CategoryClashCardBackView(categoryText: currentCard.text)
                                .opacity(cardRotation >= 90 ? 1 : 0)
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        }
                        .frame(width: 320, height: 220)
                        .rotation3DEffect(
                            .degrees(cardRotation),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                        .onTapGesture {
                            if !isTransitioning {
                                flipCard()
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        if isFlipped {
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
    
    private func flipCard() {
        HapticManager.shared.lightImpact()
        
        if isFlipped {
            // Flip back to front
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 0
            }
        } else {
            // Flip to back
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if manager.timerEnabled {
                    manager.startTimer()
                }
            }
        }
    }
    
    private func previousCategory() {
        isTransitioning = true
        manager.stopTimer()
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            cardRotation = 0
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            categoryOffset = 500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                categoryOffset = -500
                cardRotation = 0
            }
            manager.previousCategory()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
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
        manager.stopTimer()
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            cardRotation = 0
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            categoryOffset = -500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                categoryOffset = 500
                cardRotation = 0
            }
            manager.nextCategory()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
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

// MARK: - Category Clash Card Views

private struct CategoryClashCardFrontView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
            Text("Tap to reveal category")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.cardShadowColor, radius: 15, x: 0, y: 8)
        )
    }
}

private struct CategoryClashCardBackView: View {
    let categoryText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(categoryText)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.cardShadowColor, radius: 15, x: 0, y: 8)
        )
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

