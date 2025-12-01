//
//  WYRPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct WYRPlayView: View {
    @ObservedObject var manager: WYRGameManager
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var cardRotation: Double = 0
    @State private var showEndView: Bool = false
    @State private var nextButtonOpacity: Double = 0
    @State private var nextButtonOffset: CGFloat = 20
    @State private var cardOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var selectedOption: String? = nil // "A" or "B"
    
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
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                    
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
                    if let currentCard = manager.currentCard() {
                        Text("\(manager.currentIndex + 1) / \(manager.cards.count)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // "Would You Rather" label
                Text("Would You Rather")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .padding(.bottom, 32)
                
                // Card
                if let currentCard = manager.currentCard() {
                    ZStack {
                        // Card front - visible when rotation < 90
                        WYRCardFrontView()
                            .opacity(cardRotation < 90 ? 1 : 0)
                        
                        // Card back - visible when rotation >= 90, pre-rotated 180
                        WYRCardBackView(
                            optionA: currentCard.optionA ?? "",
                            optionB: currentCard.optionB ?? "",
                            selectedOption: $selectedOption
                        )
                            .opacity(cardRotation >= 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                    .frame(width: 320, height: 480)
                    .rotation3DEffect(
                        .degrees(cardRotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .offset(x: cardOffset)
                    .id(currentCard.id) // Force SwiftUI to treat each card as unique
                    .onTapGesture {
                        if !isTransitioning && !manager.isFlipped {
                            toggleCard()
                        }
                    }
                    .padding(.bottom, 32)
                }
                
                Spacer()
                
                // Next button - only show when an option is selected
                if manager.isFlipped && selectedOption != nil {
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
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: manager.isFlipped)
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: WYREndView(deck: deck, selectedCategories: selectedCategories),
                isActive: $showEndView
            ) {
                EmptyView()
            }
        )
        .onChange(of: manager.isFlipped) { oldValue, newValue in
            if !newValue {
                // Reset selection when card flips back
                selectedOption = nil
                // Hide next button smoothly
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    nextButtonOpacity = 0
                    nextButtonOffset = 20
                }
            }
        }
        .onChange(of: selectedOption) { oldValue, newValue in
            if newValue != nil && manager.isFlipped {
                // Show next button smoothly when option is selected
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    nextButtonOpacity = 1.0
                    nextButtonOffset = 0
                }
            }
        }
        .onChange(of: manager.isFinished) { oldValue, newValue in
            if newValue && manager.isFlipped {
                // Automatically navigate to end view when game is finished
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showEndView = true
                }
            }
        }
        .onAppear {
            // Initialize button state
            if manager.isFlipped && selectedOption != nil {
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
            // Flip to back
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
            }
        }
    }
    
    private func previousCard() {
        isTransitioning = true
        
        // Reset rotation
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            cardRotation = 0
        }
        
        // Slide current card right out of screen
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = 500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // Reset flip state and selection before going back
            if manager.isFlipped {
                manager.flipCard()
            }
            selectedOption = nil
            
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
            // Reset flip state and selection before moving to next card
            if manager.isFlipped {
                manager.flipCard()
            }
            selectedOption = nil
            
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

struct WYRCardFrontView: View {
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

struct WYRCardBackView: View {
    let optionA: String
    let optionB: String
    @Binding var selectedOption: String?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 24) {
                Text("Would You Rather")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .padding(.top, 24)
                
                VStack(spacing: 20) {
                    // Option A - Tappable
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedOption = "A"
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text("Option A")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            
                            Text(optionA)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            
                            if selectedOption == "A" {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    .padding(.top, 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(selectedOption == "A" ? Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0) : Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedOption == "A" ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .frame(height: 2)
                            .frame(width: 40)
                        
                        Text("OR")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .padding(.horizontal, 12)
                        
                        Rectangle()
                            .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .frame(height: 2)
                            .frame(width: 40)
                    }
                    
                    // Option B - Tappable
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedOption = "B"
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text("Option B")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            
                            Text(optionB)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            
                            if selectedOption == "B" {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    .padding(.top, 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(selectedOption == "B" ? Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0) : Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedOption == "B" ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    NavigationView {
        WYRPlayView(
            manager: WYRGameManager(
                deck: Deck(
                    title: "Would You Rather",
                    description: "Test",
                    numberOfCards: 3,
                    estimatedTime: "5-10 min",
                    imageName: "Art 1.4",
                    type: .wouldYouRather,
                    cards: [
                        Card(text: "", category: "Party", optionA: "Dance on a table", optionB: "Sing karaoke"),
                        Card(text: "", category: "Party", optionA: "Take a shot", optionB: "Play beer pong"),
                        Card(text: "", category: "Wild", optionA: "Skydive", optionB: "Bungee jump")
                    ],
                    availableCategories: ["Party", "Wild"]
                ),
                selectedCategories: ["Party", "Wild"]
            ),
            deck: Deck(
                title: "Would You Rather",
                description: "Test",
                numberOfCards: 3,
                estimatedTime: "5-10 min",
                imageName: "Art 1.4",
                type: .wouldYouRather,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

