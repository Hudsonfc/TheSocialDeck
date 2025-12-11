//
//  MemoryMasterPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct MemoryMasterPlayView: View {
    @ObservedObject var manager: MemoryMasterGameManager
    let deck: Deck
    @Environment(\.dismiss) private var dismiss
    @State private var showEndView: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showHomeAlert: Bool = false
    
    // Calculate grid layout based on number of cards
    private var columns: [GridItem] {
        let cardCount = manager.cards.count
        let cols: Int
        if cardCount <= 12 {
            cols = 3 // Easy: 3x4 grid
        } else if cardCount <= 20 {
            cols = 5 // Medium: 5x4 grid
        } else {
            cols = 6 // Hard and Expert: 6 columns (Hard: 6x5, Expert: 6x7)
        }
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: cols)
    }
    
    // Calculate card size based on difficulty
    private var cardSize: (width: CGFloat, height: CGFloat) {
        let cardCount = manager.cards.count
        if cardCount <= 12 {
            return (80, 100) // Easy
        } else if cardCount <= 20 {
            return (70, 90) // Medium
        } else {
            return (55, 70) // Hard and Expert - same size, just more rows
        }
    }
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, home button, timer, and moves
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
                    
                    Spacer()
                    
                    // Timer and moves
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 14, weight: .medium))
                            Text(formatTime(manager.elapsedTime))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 14, weight: .medium))
                            Text("\(manager.moves) moves")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Game title
                Text("Memory Master")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .padding(.bottom, 8)
                
                // Preview phase message
                if manager.isPreviewPhase {
                    Text("Memorize the cards...")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: manager.isPreviewPhase)
                }
                
                // Card grid - centered for easy and medium
                if manager.cards.count <= 20 {
                    // Center the grid for easy (3x4) and medium (5x4)
                    Spacer()
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(manager.cards.indices, id: \.self) { index in
                            MemoryCardView(
                                manager: manager,
                                cardIndex: index,
                                cardSize: cardSize,
                                onTap: {
                                    manager.flipCard(at: index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                } else {
                    // Scrollable for hard and expert
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(manager.cards.indices, id: \.self) { index in
                                MemoryCardView(
                                    manager: manager,
                                    cardIndex: index,
                                    cardSize: cardSize,
                                    onTap: {
                                        manager.flipCard(at: index)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
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
                    destination: MemoryMasterEndView(
                        deck: deck,
                        elapsedTime: manager.elapsedTime,
                        moves: manager.moves
                    ),
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
        .onChange(of: manager.isGameComplete) { oldValue, newValue in
            if newValue {
                // Game complete - navigate to end view after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showEndView = true
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MemoryCardView: View {
    @ObservedObject var manager: MemoryMasterGameManager
    let cardIndex: Int
    let cardSize: (width: CGFloat, height: CGFloat)
    let onTap: () -> Void
    @State private var showMatchAnimation: Bool = false
    @State private var matchScale: CGFloat = 1.0
    
    private var card: MemoryCard {
        guard cardIndex < manager.cards.count else {
            return MemoryCard(pairId: 0)
        }
        return manager.cards[cardIndex]
    }
    
    @State private var cardRotation: Double = 0
    @State private var hasAppeared: Bool = false
    
    var body: some View {
        ZStack {
            // Card front - visible when rotation < 90
            MemoryCardFrontView(cardSize: cardSize)
                .opacity(cardRotation < 90 ? 1 : 0)
            
            // Card back - visible when rotation >= 90, pre-rotated 180
            MemoryCardBackView(pairId: card.pairId, cardSize: cardSize)
                .opacity(cardRotation >= 90 ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            
            // Match indicator overlay
            if card.isMatched {
                ZStack {
                    // Green glow background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.3))
                    
                    // Checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: cardSize.width * 0.5))
                        .foregroundColor(.green)
                }
                .scaleEffect(matchScale)
            }
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .rotation3DEffect(
            .degrees(cardRotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        .opacity(card.isMatched ? 0.7 : 1.0) // Slightly dim matched cards
        .onChange(of: card.isFlipped) { oldValue, newValue in
            // Only animate if the view has appeared (prevents initial glitch)
            if hasAppeared {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    cardRotation = newValue ? 180 : 0
                }
            } else {
                // Set without animation on first appearance
                cardRotation = newValue ? 180 : 0
            }
        }
        .onAppear {
            // Set initial rotation state without animation immediately
            cardRotation = card.isFlipped ? 180 : 0
            // Mark as appeared after a tiny delay to allow initial state to set
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                hasAppeared = true
            }
        }
        .id(card.id) // Use card ID to prevent view recycling issues
        .disabled(card.isMatched || manager.isPreviewPhase) // Disable during preview or if matched
        .onTapGesture {
            if !manager.isPreviewPhase && !card.isFlipped && !card.isMatched && !card.isFlipping {
                onTap()
            }
        }
        .onChange(of: card.isMatched) { oldValue, newValue in
            if newValue && !oldValue {
                // Card just matched - show animation
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    matchScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        matchScale = 1.0
                    }
                }
            }
        }
    }
}

struct MemoryCardFrontView: View {
    let cardSize: (width: CGFloat, height: CGFloat)?
    
    init(cardSize: (width: CGFloat, height: CGFloat)? = nil) {
        self.cardSize = cardSize
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            let fontSize = cardSize?.width ?? 80
            Image(systemName: "questionmark")
                .font(.system(size: fontSize * 0.35, weight: .semibold))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
        }
    }
}

struct MemoryCardBackView: View {
    let pairId: Int
    let cardSize: (width: CGFloat, height: CGFloat)?
    
    init(pairId: Int, cardSize: (width: CGFloat, height: CGFloat)? = nil) {
        self.pairId = pairId
        self.cardSize = cardSize
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Display a symbol or number based on pairId
            // Using emoji for visual variety
            let symbols = ["🎯", "⭐", "❤️", "🔥", "💎", "🌟", "🎨", "🚀", "🎪", "🎭", "🎬", "🎸", "🎮", "🏆", "🎁"]
            let symbol = symbols[pairId % symbols.count]
            
            let fontSize = cardSize?.width ?? 80
            Text(symbol)
                .font(.system(size: fontSize * 0.4))
        }
    }
}

#Preview {
    NavigationView {
        MemoryMasterPlayView(
            manager: MemoryMasterGameManager(difficulty: .easy),
            deck: Deck(
                title: "Memory Master",
                description: "Test your memory",
                numberOfCards: 12,
                estimatedTime: "5 min",
                imageName: "Art 1.4",
                type: .memoryMaster,
                cards: [],
                availableCategories: []
            )
        )
    }
}

