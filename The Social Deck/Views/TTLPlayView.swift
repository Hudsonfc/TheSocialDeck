//
//  TTLPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct TTLPlayView: View {
    @ObservedObject var manager: TTLGameManager
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
    @State private var cardOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var selectedStatement: Int? = nil // 1, 2, or 3
    @State private var dragOffset: CGFloat = 0
    
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
                            previousCard()
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
                        }
                        .padding(.leading, 12)
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    if let currentCard = manager.currentCard() {
                        Text("\(manager.currentIndex + 1) / \(manager.cards.count)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                // "Two Truths and a Lie" label
                Text("Two Truths and a Lie")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.buttonBackground)
                    .padding(.bottom, 32)
                
                // Card
                if let currentCard = manager.currentCard() {
                    ZStack {
                        // Card front - visible when rotation < 90
                        TTLCardFrontView()
                            .opacity(cardRotation < 90 ? 1 : 0)
                        
                        // Card back - visible when rotation >= 90, pre-rotated 180
                        TTLCardBackView(
                            statement1: currentCard.text,
                            statement2: currentCard.optionA ?? "",
                            statement3: currentCard.optionB ?? "",
                            selectedStatement: $selectedStatement
                        )
                            .opacity(cardRotation >= 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                    .frame(width: ResponsiveSize.cardWidth, height: ResponsiveSize.cardHeight)
                    .rotation3DEffect(
                        .degrees(cardRotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .offset(x: cardOffset + dragOffset)
                    .id(currentCard.id)
                    .onTapGesture {
                        if !isTransitioning && !manager.isFlipped {
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
                                    } else if value.translation.width < -swipeThreshold && !manager.isFinished && selectedStatement != nil {
                                        // Swipe left - go to next (only if statement selected)
                                        nextCard()
                                    }
                                    dragOffset = 0
                                }
                            } : nil
                    )
                    .padding(.bottom, 32)
                }
                
                Spacer()
                
                // Next button or swipe instruction - only show when a statement is selected
                if manager.isFlipped && selectedStatement != nil {
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
                                .background(Color.buttonBackground)
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
                    destination: TTLEndView(deck: deck, selectedCategories: selectedCategories, cardsPlayed: manager.cards.count),
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
            if !newValue {
                selectedStatement = nil
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    nextButtonOpacity = 0
                    nextButtonOffset = 20
                }
            }
        }
        .onChange(of: selectedStatement) { oldValue, newValue in
            if newValue != nil && manager.isFlipped {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    nextButtonOpacity = 1.0
                    nextButtonOffset = 0
                }
            }
        }
        .onChange(of: manager.isFinished) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showEndView = true
                }
            }
        }
        .onAppear {
            if manager.isFlipped && selectedStatement != nil {
                nextButtonOpacity = 1.0
                nextButtonOffset = 0
            }
        }
    }
    
    private func toggleCard() {
        if manager.isFlipped {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
            }
        } else {
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
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            cardRotation = 0
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = 500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if manager.isFlipped {
                manager.flipCard()
            }
            selectedStatement = nil
            
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                cardOffset = -500
            }
            
            manager.previousCard()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
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
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            nextButtonOpacity = 0
            nextButtonOffset = 20
            cardRotation = 0
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = -500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if manager.isFlipped {
                manager.flipCard()
            }
            selectedStatement = nil
            
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                cardOffset = 500
            }
            
            manager.nextCard()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
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

struct TTLCardFrontView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.appBackground)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.buttonBackground)
                    .padding(.bottom, 20)
                
                Text("Tap to reveal")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
        }
    }
}

struct TTLCardBackView: View {
    let statement1: String
    let statement2: String
    let statement3: String
    @Binding var selectedStatement: Int?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.appBackground)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            ScrollView {
                VStack(spacing: 16) {
                    Text("Two Truths and a Lie")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.buttonBackground)
                        .padding(.top, 24)
                    
                    Text("Tap the statement you think is a LIE")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 12) {
                        // Statement 1
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedStatement = 1
                            }
                        }) {
                            HStack {
                                Text("1.")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                
                                Text(statement1)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if selectedStatement == 1 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color.buttonBackground)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(selectedStatement == 1 ? Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0) : Color.tertiaryBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedStatement == 1 ? Color.buttonBackground : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Statement 2
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedStatement = 2
                            }
                        }) {
                            HStack {
                                Text("2.")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                
                                Text(statement2)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if selectedStatement == 2 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color.buttonBackground)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(selectedStatement == 2 ? Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0) : Color.tertiaryBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedStatement == 2 ? Color.buttonBackground : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Statement 3
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedStatement = 3
                            }
                        }) {
                            HStack {
                                Text("3.")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                
                                Text(statement3)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if selectedStatement == 3 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color.buttonBackground)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(selectedStatement == 3 ? Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0) : Color.tertiaryBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedStatement == 3 ? Color.buttonBackground : Color.clear, lineWidth: 2)
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
}

#Preview {
    NavigationView {
        TTLPlayView(
            manager: TTLGameManager(
                deck: Deck(
                    title: "Two Truths and a Lie",
                    description: "Test",
                    numberOfCards: 3,
                    estimatedTime: "5-10 min",
                    imageName: "Art 1.4",
                    type: .twoTruthsAndALie,
                    cards: [
                        Card(text: "I once danced on a table", category: "Party", cardType: nil, optionA: "I've never been to 50+ parties", optionB: "I've been to 50+ parties"),
                        Card(text: "I stayed at a party until sunrise", category: "Party", cardType: nil, optionA: "I've never played a party game", optionB: "I've kissed 10 strangers")
                    ],
                    availableCategories: ["Party"]
                ),
                selectedCategories: ["Party"]
            ),
            deck: Deck(
                title: "Two Truths and a Lie",
                description: "Test",
                numberOfCards: 3,
                estimatedTime: "5-10 min",
                imageName: "Art 1.4",
                type: .twoTruthsAndALie,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party"]
        )
    }
}

