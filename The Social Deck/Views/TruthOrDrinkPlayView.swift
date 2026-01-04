//
//  TruthOrDrinkPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct TruthOrDrinkPlayView: View {
    @ObservedObject var manager: TruthOrDrinkGameManager
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @AppStorage("swipeNavigationEnabled") private var swipeNavigationEnabled = false
    @State private var cardRotation: Double = 0
    @State private var showEndView: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showHomeAlert: Bool = false
    @State private var nextButtonOpacity: Double = 0
    @State private var nextButtonOffset: CGFloat = 20
    @State private var answerDrinkButtonsOpacity: Double = 0
    @State private var answerDrinkButtonsOffset: CGFloat = 20
    @State private var cardOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, back button, and progress
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                    
                    // Home button
                    Button(action: {
                        showHomeAlert = true
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 12)
                    
                    // Back button
                    if manager.canGoBack {
                        Button(action: {
                            previousCard()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Previous")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .cornerRadius(20)
                        }
                        .padding(.leading, 12)
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    Text("\(manager.gamePosition + 1) / \(manager.cards.count)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // Card
                if let currentCard = manager.currentCard() {
                    ZStack {
                        // Card front - visible when rotation < 90
                        TruthOrDrinkCardFrontView(card: currentCard)
                            .opacity(cardRotation < 90 ? 1 : 0)
                        
                        // Card back - visible when rotation >= 90, pre-rotated 180
                        TruthOrDrinkCardBackView(card: currentCard)
                            .opacity(cardRotation >= 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                    .frame(width: 320, height: 480)
                    .rotation3DEffect(
                        .degrees(cardRotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .offset(x: cardOffset + dragOffset)
                    .id(currentCard.id) // Force SwiftUI to treat each card as unique
                    .onTapGesture {
                        if !isTransitioning {
                            toggleCard()
                        }
                    }
                    .gesture(
                        swipeNavigationEnabled ? DragGesture()
                            .onChanged { value in
                                if !isTransitioning {
                                    dragOffset = value.translation.width
                                }
                            }
                            .onEnded { value in
                                if !isTransitioning {
                                    let swipeThreshold: CGFloat = 100
                                    if value.translation.width > swipeThreshold && manager.canGoBack {
                                        // Swipe right - go to previous
                                        previousCard()
                                    } else if value.translation.width < -swipeThreshold && !manager.isFinished {
                                        // Swipe left - go to next (only if answered)
                                        if manager.hasAnswered {
                                            nextCard()
                                        }
                                    }
                                    dragOffset = 0
                                }
                            } : nil
                    )
                    .padding(.bottom, 32)
                }
                
                Spacer()
                
                // Answer/Drink buttons (shown when card content is revealed but not answered)
                if manager.isFlipped && !manager.hasAnswered {
                    HStack(spacing: 12) {
                        // Answer button
                        Button(action: {
                            answerCard()
                        }) {
                            Text("Answer")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .cornerRadius(12)
                        }
                        
                        // Drink button
                        Button(action: {
                            drinkCard()
                        }) {
                            Text("Drink")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: 2)
                                )
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .opacity(answerDrinkButtonsOpacity)
                    .offset(y: answerDrinkButtonsOffset)
                }
                
                // Next button or swipe instruction (shown when card is answered)
                if manager.hasAnswered {
                    if swipeNavigationEnabled {
                        // Swipe instruction text
                        Text("Swipe right to go to next card or left to go to previous card")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                    } else {
                        // Next button
                        Button(action: {
                            if manager.isFinished {
                                showEndView = true
                            } else {
                                nextCard()
                            }
                        }) {
                            Text(manager.isFinished ? "Finish" : "Next")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                        .opacity(nextButtonOpacity)
                        .offset(y: nextButtonOffset)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                    }
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: manager.isFlipped)
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
                    destination: TruthOrDrinkEndView(deck: deck, selectedCategories: selectedCategories, cardsPlayed: manager.cards.count),
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
        .onChange(of: manager.isFlipped) { oldValue, newValue in
            if newValue && !manager.hasAnswered {
                // Show Answer/Drink buttons when card content is revealed
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    answerDrinkButtonsOpacity = 1.0
                    answerDrinkButtonsOffset = 0
                }
            } else if !newValue || manager.hasAnswered {
                // Hide Answer/Drink buttons
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    answerDrinkButtonsOpacity = 0
                    answerDrinkButtonsOffset = 20
                }
            }
        }
        .onChange(of: manager.hasAnswered) { oldValue, newValue in
            if newValue {
                // Hide Answer/Drink buttons
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    answerDrinkButtonsOpacity = 0
                    answerDrinkButtonsOffset = 20
                }
                // Show Next button after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        nextButtonOpacity = 1.0
                        nextButtonOffset = 0
                    }
                }
            } else {
                // Hide Next button when card is unanswered
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    nextButtonOpacity = 0
                    nextButtonOffset = 20
                }
            }
        }
        .onChange(of: manager.isFinished) { oldValue, newValue in
            if newValue {
                // Automatically navigate to end view when game is finished
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showEndView = true
                }
            }
        }
        .onAppear {
            // Initialize button state
            if manager.isFlipped && !manager.hasAnswered {
                answerDrinkButtonsOpacity = 1.0
                answerDrinkButtonsOffset = 0
            } else if manager.hasAnswered {
                nextButtonOpacity = 1.0
                nextButtonOffset = 0
            }
        }
    }
    
    private func toggleCard() {
        if manager.isFlipped {
            // Flip back to front
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
            }
        } else {
            // Flip to back to show question
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
            }
        }
    }
    
    private func answerCard() {
        manager.answerCard()
    }
    
    private func drinkCard() {
        manager.drinkCard()
    }
    
    private func previousCard() {
        isTransitioning = true
        
        // Reset rotation and hide buttons
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            cardRotation = 0
            answerDrinkButtonsOpacity = 0
            nextButtonOpacity = 0
        }
        
        // Slide current card right out of screen
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = 500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // Reset flip state before going back
            if manager.isFlipped {
                manager.flipCard()
            }
            
            // Position new card off screen to the left BEFORE changing the card
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                cardOffset = -500
            }
            
            // Now change the card
            manager.previousCard()
            
            // Small delay to ensure the card view has updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                // Slide previous card in from left
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    cardOffset = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTransitioning = false
                }
            }
        }
    }
    
    private func nextCard() {
        isTransitioning = true
        
        // Fade out button and reset rotation
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            nextButtonOpacity = 0
            nextButtonOffset = 20
            cardRotation = 0
        }
        
        // Slide current card left out of screen
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = -500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // Reset flip state before moving to next card
            if manager.isFlipped {
                manager.flipCard()
            }
            
            // Position new card off screen to the right BEFORE changing the card
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                cardOffset = 500
            }
            
            // Now change the card
            manager.nextCard()
            
            // Small delay to ensure the card view has updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                // Slide new card in from right
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    cardOffset = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTransitioning = false
                }
            }
        }
    }
}

struct TruthOrDrinkCardFrontView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .padding(.bottom, 20)
                
                Text("Tap to reveal")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
        }
    }
}

struct TruthOrDrinkCardBackView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            // Show question text
            VStack(spacing: 16) {
                Text(card.text)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}

#Preview {
    NavigationView {
        TruthOrDrinkPlayView(
            manager: TruthOrDrinkGameManager(
                deck: Deck(
                    title: "Truth or Drink",
                    description: "Test",
                    numberOfCards: 3,
                    estimatedTime: "5-10 min",
                    imageName: "TOD artwork 2",
                    type: .truthOrDrink,
                    cards: [
                        Card(text: "What's your biggest secret?", category: "Party", cardType: nil),
                        Card(text: "Have you ever cheated?", category: "Wild", cardType: nil),
                        Card(text: "What's the most embarrassing thing you've done?", category: "Party", cardType: nil)
                    ],
                    availableCategories: ["Party", "Wild"]
                ),
                selectedCategories: ["Party", "Wild"]
            ),
            deck: Deck(
                title: "Truth or Drink",
                description: "Test",
                numberOfCards: 3,
                estimatedTime: "5-10 min",
                imageName: "TOD artwork 2",
                type: .truthOrDrink,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

