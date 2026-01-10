//
//  SportsTriviaPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct SportsTriviaPlayView: View {
    @ObservedObject var manager: SportsTriviaGameManager
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var showEndView: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showHomeAlert: Bool = false
    @State private var nextButtonOpacity: Double = 0
    @State private var nextButtonOffset: CGFloat = 20
    @State private var cardOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, back button, score, and progress
                HStack {
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
                            .fixedSize()
                        }
                        .padding(.leading, 12)
                    }
                    
                    Spacer()
                    
                    // Progress indicator and Score
                    VStack(spacing: 4) {
                        // Progress indicator
                        if let _ = manager.currentCard() {
                            Text("\(manager.currentIndex + 1) / \(manager.cards.count)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                        }
                    
                    // Score
                    VStack(spacing: 2) {
                        Text("Score")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        Text("\(manager.score)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color.buttonBackground)
                        }
                    }
                    .padding(.trailing, 12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                Spacer()
                
                if let currentCard = manager.currentCard() {
                    VStack(spacing: 32) {
                        // Question Card
                        VStack(spacing: 16) {
                            Text("Question")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            
                            Text(currentCard.text)
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 40)
                        
                        // Multiple Choice Options
                        VStack(spacing: 16) {
                            if let optionA = currentCard.optionA {
                                AnswerButton(
                                    label: "A",
                                    text: optionA,
                                    isSelected: manager.selectedAnswer == "A",
                                    isCorrect: manager.showAnswer && currentCard.correctAnswer == "A",
                                    isIncorrect: manager.showAnswer && manager.selectedAnswer == "A" && currentCard.correctAnswer != "A",
                                    isDisabled: manager.showAnswer,
                                    action: {
                                        if !manager.showAnswer {
                                            manager.selectAnswer("A")
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                nextButtonOpacity = 1.0
                                                nextButtonOffset = 0
                                            }
                                        }
                                    }
                                )
                            }
                            
                            if let optionB = currentCard.optionB {
                                AnswerButton(
                                    label: "B",
                                    text: optionB,
                                    isSelected: manager.selectedAnswer == "B",
                                    isCorrect: manager.showAnswer && currentCard.correctAnswer == "B",
                                    isIncorrect: manager.showAnswer && manager.selectedAnswer == "B" && currentCard.correctAnswer != "B",
                                    isDisabled: manager.showAnswer,
                                    action: {
                                        if !manager.showAnswer {
                                            manager.selectAnswer("B")
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                nextButtonOpacity = 1.0
                                                nextButtonOffset = 0
                                            }
                                        }
                                    }
                                )
                            }
                            
                            if let optionC = currentCard.optionC {
                                AnswerButton(
                                    label: "C",
                                    text: optionC,
                                    isSelected: manager.selectedAnswer == "C",
                                    isCorrect: manager.showAnswer && currentCard.correctAnswer == "C",
                                    isIncorrect: manager.showAnswer && manager.selectedAnswer == "C" && currentCard.correctAnswer != "C",
                                    isDisabled: manager.showAnswer,
                                    action: {
                                        if !manager.showAnswer {
                                            manager.selectAnswer("C")
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                nextButtonOpacity = 1.0
                                                nextButtonOffset = 0
                                            }
                                        }
                                    }
                                )
                            }
                            
                            if let optionD = currentCard.optionD {
                                AnswerButton(
                                    label: "D",
                                    text: optionD,
                                    isSelected: manager.selectedAnswer == "D",
                                    isCorrect: manager.showAnswer && currentCard.correctAnswer == "D",
                                    isIncorrect: manager.showAnswer && manager.selectedAnswer == "D" && currentCard.correctAnswer != "D",
                                    isDisabled: manager.showAnswer,
                                    action: {
                                        if !manager.showAnswer {
                                            manager.selectAnswer("D")
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                nextButtonOpacity = 1.0
                                                nextButtonOffset = 0
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .offset(x: cardOffset)
                    .id(currentCard.id)
                }
                
                Spacer()
                
                // Next button
                if manager.showAnswer {
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
                    destination: SportsTriviaEndView(manager: manager, deck: deck, selectedCategories: selectedCategories),
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
        .onChange(of: manager.showAnswer) { oldValue, newValue in
            if newValue {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    nextButtonOpacity = 1.0
                    nextButtonOffset = 0
                }
            }
        }
        .onChange(of: manager.isFinished) { oldValue, newValue in
            if newValue && manager.showAnswer {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showEndView = true
                }
            }
        }
        .onAppear {
            if manager.showAnswer {
                nextButtonOpacity = 1.0
                nextButtonOffset = 0
            }
        }
    }
    
    private func previousCard() {
        isTransitioning = true
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = 500
            nextButtonOpacity = 0
            nextButtonOffset = 20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) {
                cardOffset = -500
            }
            
            manager.previousCard()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    cardOffset = 0
                }
                
                if manager.showAnswer {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        nextButtonOpacity = 1.0
                        nextButtonOffset = 0
                    }
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
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            cardOffset = -500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
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

fileprivate struct AnswerButton: View {
    let label: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Label circle
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 44, height: 44)
                    
                    Text(label)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                }
                
                // Answer text
                Text(text)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Checkmark or X
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                } else if isIncorrect {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(buttonBackgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: isSelected ? 3 : 0)
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled && !isSelected && !isCorrect ? 0.5 : 1.0)
    }
    
    private var backgroundColor: Color {
        if isCorrect {
            return .green.opacity(0.2)
        } else if isIncorrect {
            return .red.opacity(0.2)
        } else if isSelected {
            return Color.buttonBackground
        } else {
            return Color.tertiaryBackground
        }
    }
    
    private var buttonBackgroundColor: Color {
        if isCorrect {
            return .green.opacity(0.1)
        } else if isIncorrect {
            return .red.opacity(0.1)
        } else if isSelected {
            return Color.buttonBackground.opacity(0.1)
        } else {
            return Color.tertiaryBackground
        }
    }
    
    private var textColor: Color {
        if isCorrect {
            return .green
        } else if isIncorrect {
            return .red
        } else if isSelected {
            return Color.buttonBackground
        } else {
            return .primaryText
        }
    }
    
    private var borderColor: Color {
        if isCorrect {
            return .green
        } else if isIncorrect {
            return .red
        } else {
            return Color.buttonBackground
        }
    }
}
