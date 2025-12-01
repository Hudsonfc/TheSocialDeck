//
//  NHIEPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct NHIEPlayView: View {
    @ObservedObject var manager: NHIEGameManager
    let deck: Deck
    let selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var cardRotation: Double = 0
    @State private var showEndView: Bool = false
    @State private var nextButtonOpacity: Double = 0
    @State private var nextButtonOffset: CGFloat = 20
    
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
                
                // "Never Have I Ever" label
                Text("Never Have I Ever")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .padding(.bottom, 32)
                
                // Card
                if let currentCard = manager.currentCard() {
                    ZStack {
                        // Card front - visible when rotation < 90
                        CardFrontView(text: currentCard.text)
                            .opacity(cardRotation < 90 ? 1 : 0)
                        
                        // Card back - visible when rotation >= 90, pre-rotated 180
                        CardBackView(text: currentCard.text)
                            .opacity(cardRotation >= 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                    .frame(width: 320, height: 480)
                    .rotation3DEffect(
                        .degrees(cardRotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .onTapGesture {
                        toggleCard()
                    }
                    .padding(.bottom, 32)
                }
                
                Spacer()
                
                // Next button
                if manager.isFlipped {
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
                destination: NHIEEndView(deck: deck, selectedCategories: selectedCategories),
                isActive: $showEndView
            ) {
                EmptyView()
            }
        )
        .onChange(of: manager.isFlipped) { oldValue, newValue in
            if newValue {
                // Show next button smoothly
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    nextButtonOpacity = 1.0
                    nextButtonOffset = 0
                }
            } else {
                // Hide next button smoothly
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    nextButtonOpacity = 0
                    nextButtonOffset = 20
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
            if manager.isFlipped {
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
        // Smooth transition: reset rotation and go back
        withAnimation(.easeOut(duration: 0.2)) {
            cardRotation = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Reset flip state before going back
            if manager.isFlipped {
                manager.flipCard()
            }
            manager.previousCard()
        }
    }
    
    private func nextCard() {
        // Smooth transition: fade out button and reset rotation
        withAnimation(.easeOut(duration: 0.2)) {
            nextButtonOpacity = 0
            nextButtonOffset = 20
            cardRotation = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Reset flip state before moving to next card
            if manager.isFlipped {
                manager.flipCard()
            }
            manager.nextCard()
        }
    }
}

struct CardFrontView: View {
    let text: String
    
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

struct CardBackView: View {
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Text("Never Have I Ever")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                
                Text(text)
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
        NHIEPlayView(
            manager: NHIEGameManager(
                deck: Deck(
                    title: "Never Have I Ever",
                    description: "Test",
                    numberOfCards: 3,
                    estimatedTime: "5-10 min",
                    imageName: "Art 1.4",
                    type: .neverHaveIEver,
                    cards: [
                        Card(text: "been skydiving", category: "Wild"),
                        Card(text: "lied about my age", category: "Party"),
                        Card(text: "kissed a stranger", category: "Wild")
                    ],
                    availableCategories: ["Party", "Wild"]
                ),
                selectedCategories: ["Party", "Wild"]
            ),
            deck: Deck(
                title: "Never Have I Ever",
                description: "Test",
                numberOfCards: 3,
                estimatedTime: "5-10 min",
                imageName: "Art 1.4",
                type: .neverHaveIEver,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

