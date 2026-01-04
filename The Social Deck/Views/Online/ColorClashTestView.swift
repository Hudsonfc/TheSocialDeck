//
//  ColorClashTestView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ColorClashTestView: View {
    @StateObject private var testManager = TestColorClashGameManager()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCardIds: Set<String> = []
    @State private var showWinnerView: Bool = false
    @State private var hasDrawnThisTurn: Bool = false
    @State private var flyingCard: ColorClashCard?
    @State private var flyingCardOffset: CGSize = .zero
    @State private var flyingCardOpacity: Double = 0
    @State private var newlyDrawnCardId: String?
    @State private var showCardInfo: Bool = false
    @State private var isInitialDeal: Bool = true
    @State private var previousTopCardId: String?
    @State private var showCardFlip: Bool = false
    @State private var cardFlipRotation: Double = 0
    @State private var showWalkthrough: Bool = false // Skip walkthrough for direct game testing
    @State private var showLoadingScreen: Bool = false
    @State private var hasShownLoading: Bool = false
    
    // Fake players for testing (4 players)
    private let fakePlayers: [RoomPlayer] = [
        RoomPlayer(id: "testUser123", username: "You", avatarType: "avatar 1", avatarColor: "blue", isReady: true, isHost: true),
        RoomPlayer(id: "player1", username: "Alex", avatarType: "avatar 2", avatarColor: "red", isReady: true),
        RoomPlayer(id: "player2", username: "Jordan", avatarType: "avatar 3", avatarColor: "green", isReady: true),
        RoomPlayer(id: "player3", username: "Sam", avatarType: "avatar 4", avatarColor: "purple", isReady: true)
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0xFA/255.0, green: 0xFA/255.0, blue: 0xFA/255.0),
                    Color.white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if testManager.winnerId != nil || showWinnerView {
                winnerView
            } else {
                gameView
            }
            
            // Flying card animation overlay
            if let flyingCard = flyingCard {
                GeometryReader { geometry in
                    ColorClashCardView(card: flyingCard, size: .small)
                        .position(
                            x: geometry.size.width / 2 + flyingCardOffset.width,
                            y: geometry.size.height / 2 + flyingCardOffset.height
                        )
                        .opacity(flyingCardOpacity)
                }
                .allowsHitTesting(false)
                .zIndex(1000)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(showWalkthrough ? .hidden : .visible)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
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
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    showCardInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0))
                }
            }
        }
        .sheet(isPresented: $testManager.showWildColorSelection) {
            WildColorSelectionModal { color in
                Task {
                    await testManager.selectWildColor(color)
                }
            }
        }
        .sheet(isPresented: $showCardInfo) {
            ColorClashCardInfoView()
        }
        .onAppear {
            // Trigger initial deal animation
            if isInitialDeal && !testManager.myHand.isEmpty {
                // Start with cards hidden
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Animate cards appearing one by one
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isInitialDeal = false
                    }
                }
            }
            previousTopCardId = testManager.topCard?.id
        }
        .onChange(of: testManager.myHand.count) { count in
            // Reset initial deal if hand becomes empty and then gets cards again
            if count > 0 && isInitialDeal {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isInitialDeal = false
                    }
                }
            }
        }
        .onChange(of: testManager.topCard?.id) { newCardId in
            // Check if card was played by another player (not by us)
            if let newId = newCardId, newId != previousTopCardId, previousTopCardId != nil {
                // Another player played a card - show flip animation
                if let lastPlayer = testManager.lastActionPlayer, lastPlayer != "testUser123" {
                    triggerCardFlipAnimation()
                }
            }
            previousTopCardId = newCardId
        }
        .onChange(of: testManager.winnerId) { winnerId in
            if winnerId != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showWinnerView = true
                }
            }
        }
        .onChange(of: testManager.isMyTurn) { isMyTurn in
            if isMyTurn {
                hasDrawnThisTurn = false
                selectedCardIds.removeAll()
            }
        }
    }
    
    private var gameView: some View {
        GeometryReader { geometry in
            ZStack {
                // Main game content - takes full width and stays centered
                VStack(spacing: 0) {
                    // Title at the top
                    Text("Color Clash")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    
                    // Top Bar
                    topBar
                    
                    // Flexible spacer to push content down
                    Spacer(minLength: 0)
                    
                    // Center Game Area
                    centerGameArea
                    
                    // Spacing between card and hand
                    Spacer()
                        .frame(height: 24)
                    
                    // Your Hand
                    yourHandArea
                    
                    // Flexible spacer to push content up
                    Spacer(minLength: 0)
                    
                    // Action buttons at the bottom
                    if testManager.isMyTurn {
                        HStack(spacing: 12) {
                            if !hasDrawnThisTurn {
                                drawCardButton
                            }
                            
                            // Skip Turn button - always visible when it's your turn
                            Button(action: {
                                HapticManager.shared.mediumImpact()
                                selectedCardIds.removeAll()
                                Task {
                                    await testManager.skipTurn()
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.forward.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                    Text("Skip")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0),
                                                    Color(red: 0x4A/255.0, green: 0x4A/255.0, blue: 0x4A/255.0)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                                )
                            }
                            .disabled(testManager.isLoading)
                            .opacity(testManager.isLoading ? 0.6 : 1.0)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                    } else {
                        Spacer()
                            .frame(height: geometry.safeAreaInsets.bottom + 16)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Player profiles - mirrored layout when more than 3 players
                playerProfilesLayout
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            Spacer()
            
            // Timer - centered to avoid overlap with player avatars on right
            if testManager.isMyTurn {
                turnTimer
            }
        }
        .padding(.horizontal, 40)
        .padding(.trailing, 140) // Extra padding to avoid overlap with player avatars (100px + 40px margin)
        .padding(.bottom, 16)
    }
    
    private var turnTimer: some View {
        let progress = testManager.turnTimeRemaining / 30.0
        let timerColor = testManager.turnTimeRemaining < 10 ? 
            Color(red: 0xFF/255.0, green: 0x3B/255.0, blue: 0x30/255.0) :
            Color(red: 0x4A/255.0, green: 0x90/255.0, blue: 0xE2/255.0)
        
        return ZStack {
            Circle()
                .stroke(Color(red: 0xE5/255.0, green: 0xE5/255.0, blue: 0xE5/255.0), lineWidth: 4)
                .frame(width: 44, height: 44)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: testManager.turnTimeRemaining < 10 ? 
                            [Color(red: 0xFF/255.0, green: 0x3B/255.0, blue: 0x30/255.0),
                             Color(red: 0xFF/255.0, green: 0x17/255.0, blue: 0x17/255.0)] :
                            [Color(red: 0x4A/255.0, green: 0x90/255.0, blue: 0xE2/255.0),
                             Color(red: 0x5A/255.0, green: 0xA0/255.0, blue: 0xF2/255.0)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: progress)
            
            Text("\(Int(testManager.turnTimeRemaining))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(timerColor)
        }
        .padding(6)
        .background(
            Circle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .scaleEffect(testManager.turnTimeRemaining < 5 ? 1.1 : 1.0)
        .animation(
            testManager.turnTimeRemaining < 5 ? 
                .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : 
                .default,
            value: testManager.turnTimeRemaining < 5
        )
    }
    
    private var drawCardButton: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            selectedCardIds.removeAll()
            Task {
                await drawCardWithAnimation()
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("Draw Card")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0),
                                Color(red: 0xC0/255.0, green: 0x2E/255.0, blue: 0x2E/255.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.3), radius: 6, x: 0, y: 3)
            )
        }
        .disabled(testManager.isLoading)
        .opacity(testManager.isLoading ? 0.6 : 1.0)
    }
    
    private var centerGameArea: some View {
        VStack(spacing: 0) {
            // Discard Pile Card
            if let topCard = testManager.topCard {
                Group {
                    if showCardFlip {
                        // Flipping card - show back or front based on rotation
                        ZStack {
                            // Card back (visible from 0-90 degrees)
                            if cardFlipRotation < 90 {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        Image("color clash artwork logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 0xE5/255.0, green: 0xE5/255.0, blue: 0xE5/255.0), lineWidth: 2)
                                    )
                                    .frame(width: 100, height: 150)
                            }
                            
                            // Card front (visible from 90-180 degrees)
                            if cardFlipRotation >= 90 {
                                ColorClashCardView(card: topCard, size: .medium)
                                    .rotation3DEffect(
                                        .degrees(180),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                            }
                        }
                        .rotation3DEffect(
                            .degrees(cardFlipRotation),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.8
                        )
                    } else {
                        // Normal card display (no flip)
                        ColorClashCardView(card: topCard, size: .medium)
                    }
                }
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                    .frame(width: 100, height: 150)
                    .overlay(ProgressView())
            }
        }
    }
    
    private var playerProfilesLayout: some View {
        GeometryReader { geometry in
            let centerY = geometry.size.height / 2 - 140 // Move up by 140 pixels
            let slotSpacing: CGFloat = 90 // Fixed spacing between slot centers (reduced to bring top/bottom closer to middle)
            let rightColumnX = geometry.size.width - 116 // 100 width + 16 padding
            let leftColumnX: CGFloat = 16 // 16 padding
            
            ZStack {
                // Right column - 3 fixed slots
                // Top slot (index 0)
                playerSlotView(
                    player: fakePlayers.count > 0 ? fakePlayers[0] : nil,
                    slotIndex: 0,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: rightColumnX + 50, y: centerY - slotSpacing)
                
                // Middle slot (index 1)
                playerSlotView(
                    player: fakePlayers.count > 1 ? fakePlayers[1] : nil,
                    slotIndex: 1,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: rightColumnX + 50, y: centerY)
                
                // Bottom slot (index 2)
                playerSlotView(
                    player: fakePlayers.count > 2 ? fakePlayers[2] : nil,
                    slotIndex: 2,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: rightColumnX + 50, y: centerY + slotSpacing)
                
                // Left column - 3 fixed slots
                // Top slot (index 3)
                playerSlotView(
                    player: fakePlayers.count > 3 ? fakePlayers[3] : nil,
                    slotIndex: 3,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: leftColumnX + 50, y: centerY - slotSpacing)
                
                // Middle slot (index 4)
                playerSlotView(
                    player: fakePlayers.count > 4 ? fakePlayers[4] : nil,
                    slotIndex: 4,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: leftColumnX + 50, y: centerY)
                
                // Bottom slot (index 5)
                playerSlotView(
                    player: fakePlayers.count > 5 ? fakePlayers[5] : nil,
                    slotIndex: 5,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: leftColumnX + 50, y: centerY + slotSpacing)
            }
        }
    }
    
    private func playerSlotView(
        player: RoomPlayer?,
        slotIndex: Int,
        centerY: CGFloat,
        slotSpacing: CGFloat
    ) -> some View {
        Group {
            if let player = player {
                let isCurrentPlayer = testManager.currentPlayerId == player.id
                let isMe = player.id == "testUser123"
                let handCount = testManager.getHandCount(for: player.id)
                let lastActionPlayer = testManager.lastActionPlayer == player.id ? testManager.lastActionPlayer : nil
                let lastActionType = lastActionPlayer != nil ? testManager.lastActionType : nil
                
                playerAvatarView(
                    player: player,
                    isMe: isMe,
                    isCurrentPlayer: isCurrentPlayer,
                    handCount: handCount,
                    lastActionType: lastActionType
                )
            } else {
                // Empty slot - invisible placeholder to maintain position
                Color.clear
                    .frame(width: 100, height: 90)
            }
        }
    }
    
    private var playerAvatarsList: some View {
        VStack(spacing: 16) {
            ForEach(fakePlayers) { player in
                let isCurrentPlayer = testManager.currentPlayerId == player.id
                let isMe = player.id == "testUser123"
                let handCount = testManager.getHandCount(for: player.id)
                let lastActionPlayer = testManager.lastActionPlayer == player.id ? testManager.lastActionPlayer : nil
                let lastActionType = lastActionPlayer != nil ? testManager.lastActionType : nil
                
                playerAvatarView(
                    player: player,
                    isMe: isMe,
                    isCurrentPlayer: isCurrentPlayer,
                    handCount: handCount,
                    lastActionType: lastActionType
                )
            }
        }
    }
    
    private func playerAvatarView(
        player: RoomPlayer,
        isMe: Bool,
        isCurrentPlayer: Bool,
        handCount: Int,
        lastActionType: PlayerActionType?
    ) -> some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white, Color(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isCurrentPlayer ? 56 : 50, height: isCurrentPlayer ? 56 : 50)
                        .shadow(color: isCurrentPlayer ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.3) : Color.black.opacity(0.15), 
                               radius: isCurrentPlayer ? 12 : 8, x: 0, y: isCurrentPlayer ? 6 : 4)
                    
                    AvatarView(
                        avatarType: player.avatarType,
                        avatarColor: player.avatarColor,
                        size: isCurrentPlayer ? 44 : 40
                    )
                    
                    if isCurrentPlayer {
                        Circle()
                            .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: 3)
                            .frame(width: 56, height: 56)
                    }
                }
                
                // Hand count badge
                Text("\(handCount)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: isCurrentPlayer ? [
                                Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0),
                                Color(red: 0xB8/255.0, green: 0x2E/255.0, blue: 0x2E/255.0)
                            ] : [
                                Color.gray,
                                Color(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(10)
                    .offset(x: 18, y: -8)
            }
            
            Text(isMe ? "You" : player.username)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .lineLimit(1)
                .frame(width: 80)
            
            if let actionType = lastActionType {
                Text(actionTypeText(actionType))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0),
                                Color(red: 0xB8/255.0, green: 0x2E/255.0, blue: 0x2E/255.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
            }
        }
        .scaleEffect(isCurrentPlayer ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCurrentPlayer)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: lastActionType)
    }
    
    private func actionTypeText(_ actionType: PlayerActionType) -> String {
        switch actionType {
        case .played:
            return "Played"
        case .skipped:
            return "Skipped"
        case .drew:
            return "Drew Card"
        }
    }
    
    private var yourHandArea: some View {
        VStack(spacing: 12) {
            // Your Cards Label
            HStack {
                Text("Your Cards")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Spacer()
            }
            .padding(.horizontal, 40)
            
            // Hand - always visible
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(testManager.myHand.enumerated()), id: \.element.id) { index, card in
                        let isSelected = selectedCardIds.contains(card.id)
                        
                        ColorClashCardView(
                            card: card,
                            size: .small,
                            isHighlighted: isSelected
                        ) {
                            if testManager.isMyTurn {
                                HapticManager.shared.lightImpact()
                                toggleCardSelection(card)
                            }
                        }
                        .opacity(testManager.isMyTurn ? 1.0 : 0.5)
                        .scaleEffect(isSelected ? 1.08 : (newlyDrawnCardId == card.id ? 1.2 : 1.0))
                        .offset(
                            x: newlyDrawnCardId == card.id ? 300 : (isInitialDeal ? -CGFloat(index) * 72 : 0),
                            y: newlyDrawnCardId == card.id ? -8 : (isSelected ? -4 : 0)
                        )
                        .rotationEffect(.degrees(newlyDrawnCardId == card.id ? 15 : 0))
                        .zIndex(isSelected ? 10 : (newlyDrawnCardId == card.id ? 5 : 1))
                        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isSelected)
                        .animation(.easeInOut(duration: 0.5), value: newlyDrawnCardId)
                        .animation(
                            isInitialDeal ? 
                                .spring(response: 0.6, dampingFraction: 0.75).delay(Double(index) * 0.08) :
                                .default,
                            value: isInitialDeal
                        )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
            }
            .frame(height: 120)
            
            // Action Buttons (when it's your turn)
            if testManager.isMyTurn {
                VStack(spacing: 12) {
                    // Play Selected Cards Button
                    if selectedCardIds.count > 0 {
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            Task {
                                await playSelectedCards()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(selectedCardIds.count == 1 ? "Play Card" : "Play \(selectedCardIds.count) Cards")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.blue,
                                                Color(red: 0x1E/255.0, green: 0x88/255.0, blue: 0xE5/255.0)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                            )
                        }
                        .disabled(testManager.isLoading)
                        .opacity(testManager.isLoading ? 0.6 : 1.0)
                        .padding(.horizontal, 40)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCardIds.count)
                    }
                    
                    HStack(spacing: 12) {
                        // Last Card Button
                        if testManager.myHand.count == 1 {
                            Button(action: {
                                HapticManager.shared.lightImpact()
                                Task {
                                    await testManager.declareLastCard()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "hand.raised.fill")
                                        .font(.system(size: 18))
                                    Text("Last Card!")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.green,
                                            Color(red: 0x2E/255.0, green: 0x7D/255.0, blue: 0x32/255.0)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(color: Color.green.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .disabled(testManager.isLoading)
                            .opacity(testManager.isLoading ? 0.6 : 1.0)
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
    }
    
    private var winnerView: some View {
        VStack(spacing: 24) {
            Text("You Win!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            
            PrimaryButton(title: "Back") {
                dismiss()
            }
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Helper Methods
    
    private func colorForCardColor(_ cardColor: CardColor) -> Color {
        switch cardColor {
        case .red:
            return Color(red: 0xE5/255.0, green: 0x39/255.0, blue: 0x46/255.0)
        case .blue:
            return Color(red: 0x21/255.0, green: 0x96/255.0, blue: 0xF3/255.0)
        case .yellow:
            return Color(red: 0xFF/255.0, green: 0xC1/255.0, blue: 0x07/255.0)
        case .green:
            return Color(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x50/255.0)
        }
    }
    
    private func toggleCardSelection(_ card: ColorClashCard) {
        if selectedCardIds.contains(card.id) {
            selectedCardIds.remove(card.id)
        } else {
            if selectedCardIds.isEmpty {
                selectedCardIds.insert(card.id)
            } else {
                let existingCards = testManager.myHand.filter { selectedCardIds.contains($0.id) }
                if let firstCard = existingCards.first {
                    let canAdd = (card.type == firstCard.type) && 
                                ((card.type == .wild || card.type == .wildDrawFour) || (card.color == firstCard.color))
                    if canAdd {
                        selectedCardIds.insert(card.id)
                    } else {
                        selectedCardIds = [card.id]
                    }
                }
            }
        }
    }
    
    private func playSelectedCards() async {
        let cardsToPlay = testManager.myHand.filter { selectedCardIds.contains($0.id) }
        guard !cardsToPlay.isEmpty else { return }
        
        for card in cardsToPlay {
            await playCardWithAnimation(card)
            if cardsToPlay.count > 1 {
                try? await Task.sleep(nanoseconds: 250_000_000)
            }
        }
        
        selectedCardIds.removeAll()
    }
    
    private func playCardWithAnimation(_ card: ColorClashCard) async {
        flyingCard = card
        flyingCardOpacity = 1.0
        
        guard let cardIndex = testManager.myHand.firstIndex(where: { $0.id == card.id }) else { return }
        let startOffset = CGSize(width: CGFloat(cardIndex - testManager.myHand.count / 2) * 20, height: 400)
        flyingCardOffset = startOffset
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            withAnimation(.easeInOut(duration: 0.5)) {
                flyingCardOffset = CGSize(width: 0, height: -50)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) {
            Task {
                await testManager.playCard(card)
                
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                    flyingCardOffset = .zero
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        flyingCardOpacity = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        flyingCard = nil
                        flyingCardOffset = .zero
                    }
                }
            }
        }
    }
    
    private func drawCardWithAnimation() async {
        let previousHandCount = testManager.myHand.count
        await testManager.drawCard()
        
        if let newCard = testManager.myHand.last, testManager.myHand.count > previousHandCount {
            newlyDrawnCardId = newCard.id
            hasDrawnThisTurn = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                newlyDrawnCardId = nil
            }
        }
    }
    
    private func triggerCardFlipAnimation() {
        showCardFlip = true
        cardFlipRotation = 0
        
        // Smooth flip animation with spring physics
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            cardFlipRotation = 90
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                cardFlipRotation = 180
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.easeOut(duration: 0.1)) {
                    cardFlipRotation = 0
                    showCardFlip = false
                }
            }
        }
    }
}

// MARK: - Test Game Manager

@MainActor
class TestColorClashGameManager: ObservableObject {
    @Published var myHand: [ColorClashCard] = []
    @Published var topCard: ColorClashCard?
    @Published var currentColor: CardColor = .red
    @Published var burnedColor: CardColor?
    @Published var isMyTurn: Bool = true
    @Published var turnTimeRemaining: TimeInterval = 30.0
    @Published var showWildColorSelection: Bool = false
    @Published var pendingWildCard: ColorClashCard?
    @Published var winnerId: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var currentPlayerId: String = "testUser123"
    @Published var lastActionPlayer: String? = nil
    @Published var lastActionType: PlayerActionType? = nil
    
    private var deck: [ColorClashCard] = []
    private var discardPile: [ColorClashCard] = []
    private var turnTimer: Timer?
    private var aiTimer: Timer?
    private var playerHands: [String: [ColorClashCard]] = [:]
    private var playerOrder: [String] = ["testUser123", "player1", "player2", "player3"]
    private var currentPlayerIndex: Int = 0
    
    init() {
        setupTestGame()
    }
    
    deinit {
        turnTimer?.invalidate()
        aiTimer?.invalidate()
    }
    
    private func setupTestGame() {
        // Create and shuffle deck
        deck = ColorClashCard.createStandardDeck()
        deck.shuffle()
        
        // Deal 7 cards to each player
        for playerId in playerOrder {
            let hand = Array(deck.prefix(7))
            deck.removeFirst(7)
            playerHands[playerId] = hand
        }
        
        myHand = playerHands["testUser123"] ?? []
        
        // Place first card on discard pile
        if let firstCardIndex = deck.firstIndex(where: { $0.type == .number && $0.number != nil }) {
            let card = deck.remove(at: firstCardIndex)
            discardPile.append(card)
            topCard = card
            currentColor = card.color ?? .red
        } else if !deck.isEmpty {
            let card = deck.removeFirst()
            discardPile.append(card)
            topCard = card
            currentColor = card.color ?? .red
        }
        
        burnedColor = CardColor.allCases.randomElement()
        
        currentPlayerId = playerOrder[0]
        isMyTurn = (currentPlayerId == "testUser123")
        
        if isMyTurn {
            startTurnTimer()
        } else {
            scheduleAITurn()
        }
    }
    
    func getHandCount(for playerId: String) -> Int {
        return playerHands[playerId]?.count ?? 0
    }
    
    private func startTurnTimer() {
        turnTimer?.invalidate()
        turnTimeRemaining = 30.0
        
        turnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                self.turnTimeRemaining -= 1.0
                if self.turnTimeRemaining <= 0 {
                    timer.invalidate()
                    await self.handleAutoDraw()
                }
            }
        }
    }
    
    func playCard(_ card: ColorClashCard, selectedColor: CardColor? = nil) async {
        guard isMyTurn else { return }
        guard let cardIndex = myHand.firstIndex(where: { $0.id == card.id }) else { return }
        guard let currentTopCard = topCard else { return }
        
        var cardToPlay = card
        if card.type == .wild || card.type == .wildDrawFour {
            if let selectedColor = selectedColor {
                cardToPlay.selectedColor = selectedColor
            } else {
                pendingWildCard = card
                showWildColorSelection = true
                return
            }
        }
        
        let isValid = cardToPlay.canPlay(on: currentTopCard, currentColor: currentColor, burnedColor: burnedColor)
        if !isValid && myHand.count > 1 {
            errorMessage = "Cannot play this card"
            return
        }
        
        isLoading = true
        myHand.remove(at: cardIndex)
        playerHands["testUser123"] = myHand
        
        discardPile.append(cardToPlay)
        topCard = cardToPlay
        lastActionPlayer = "testUser123"
        lastActionType = .played
        
        if let selectedColor = cardToPlay.selectedColor {
            currentColor = selectedColor
        } else if let cardColor = cardToPlay.color {
            currentColor = cardColor
        }
        
        // Process action card effects
        processActionCard(cardToPlay)
        
        if myHand.isEmpty {
            winnerId = "testUser123"
            turnTimer?.invalidate()
            aiTimer?.invalidate()
        } else {
            advanceTurn()
        }
        
        isLoading = false
    }
    
    private var skipNextPlayer: Bool = false
    private var pendingDrawCards: Int? = nil
    private var turnDirection: Int = 1
    
    private func processActionCard(_ card: ColorClashCard) {
        switch card.type {
        case .skip:
            skipNextPlayer = true
        case .reverse:
            turnDirection *= -1
            // If only 2 players, reverse acts like skip
            if playerOrder.count == 2 {
                skipNextPlayer = true
            }
        case .drawTwo:
            pendingDrawCards = (pendingDrawCards ?? 0) + 2
            skipNextPlayer = true
        case .wildDrawFour:
            pendingDrawCards = (pendingDrawCards ?? 0) + 4
            skipNextPlayer = true
        case .wild, .number:
            break
        }
    }
    
    func selectWildColor(_ color: CardColor) async {
        guard let card = pendingWildCard else { return }
        showWildColorSelection = false
        pendingWildCard = nil
        await playCard(card, selectedColor: color)
    }
    
    func drawCard() async {
        guard isMyTurn else { return }
        isLoading = true
        
        // Check if there are pending draw cards (from Draw Two/Four)
        if let pendingDraw = pendingDrawCards, pendingDraw > 0 {
            // Draw pending cards
            for _ in 0..<pendingDraw {
                if let card = drawCardFromDeck() {
                    myHand.append(card)
                }
            }
            pendingDrawCards = nil
        } else {
            // Draw one card
            if let card = drawCardFromDeck() {
                myHand.append(card)
            }
        }
        
        playerHands["testUser123"] = myHand
        lastActionPlayer = "testUser123"
        lastActionType = .drew
        advanceTurn()
        isLoading = false
    }
    
    func declareLastCard() async {
        // Just acknowledge in test mode
    }
    
    func skipTurn() async {
        guard isMyTurn else { return }
        isLoading = true
        lastActionPlayer = "testUser123"
        lastActionType = .skipped
        advanceTurn()
        isLoading = false
    }
    
    private func handleAutoDraw() async {
        await drawCard()
    }
    
    private func drawCardFromDeck() -> ColorClashCard? {
        if !deck.isEmpty {
            return deck.removeFirst()
        } else if discardPile.count > 1 {
            let top = discardPile.removeLast()
            let toShuffle = discardPile
            discardPile = [top]
            deck = toShuffle.shuffled()
            if !deck.isEmpty {
                return deck.removeFirst()
            }
        }
        return nil
    }
    
    private func advanceTurn() {
        turnTimer?.invalidate()
        
        // Handle skip - need to skip the next player
        if skipNextPlayer {
            skipNextPlayer = false
            // Move to next player first (this is the skipped player)
            currentPlayerIndex = (currentPlayerIndex + turnDirection + playerOrder.count) % playerOrder.count
            currentPlayerId = playerOrder[currentPlayerIndex]
            // Then move to the player after the skipped one
            currentPlayerIndex = (currentPlayerIndex + turnDirection + playerOrder.count) % playerOrder.count
            currentPlayerId = playerOrder[currentPlayerIndex]
        } else {
            // Normal turn advance
            currentPlayerIndex = (currentPlayerIndex + turnDirection + playerOrder.count) % playerOrder.count
            currentPlayerId = playerOrder[currentPlayerIndex]
        }
        
        isMyTurn = (currentPlayerId == "testUser123")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.lastActionPlayer = nil
            self?.lastActionType = nil
        }
        
        if isMyTurn {
            startTurnTimer()
        } else {
            scheduleAITurn()
        }
    }
    
    private func scheduleAITurn() {
        aiTimer?.invalidate()
        let delay = Double.random(in: 1.2...2.5)
        
        aiTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.playAITurn()
            }
        }
    }
    
    private func playAITurn() async {
        guard var hand = playerHands[currentPlayerId], let currentTopCard = topCard else {
            advanceTurn()
            return
        }
        
        let playerNames = ["player1": "Alex", "player2": "Jordan", "player3": "Sam"]
        let playerName = playerNames[currentPlayerId] ?? "Player"
        
        let playableCards = hand.filter { card in
            card.canPlay(on: currentTopCard, currentColor: currentColor, burnedColor: burnedColor)
        }
        
        if let cardToPlay = playableCards.randomElement() {
            var card = cardToPlay
            
            if card.type == .wild || card.type == .wildDrawFour {
                card.selectedColor = CardColor.allCases.randomElement()
            }
            
            if let index = hand.firstIndex(where: { $0.id == card.id }) {
                hand.remove(at: index)
                playerHands[currentPlayerId] = hand
                
                discardPile.append(card)
                topCard = card
                lastActionPlayer = currentPlayerId
                lastActionType = .played
                
                if let selectedColor = card.selectedColor {
                    currentColor = selectedColor
                } else if let cardColor = card.color {
                    currentColor = cardColor
                }
                
                // Process action card effects
                processActionCard(card)
                
                if hand.isEmpty {
                    winnerId = currentPlayerId
                    aiTimer?.invalidate()
                    turnTimer?.invalidate()
                    return
                }
            }
        } else {
            // Check if there are pending draw cards (from Draw Two/Four)
            if let pendingDraw = pendingDrawCards, pendingDraw > 0 {
                // Draw pending cards
                for _ in 0..<pendingDraw {
                    if let drawnCard = drawCardFromDeck() {
                        hand.append(drawnCard)
                    }
                }
                pendingDrawCards = nil
            } else {
                // Draw one card
                if let card = drawCardFromDeck() {
                    hand.append(card)
                }
            }
            playerHands[currentPlayerId] = hand
            lastActionPlayer = currentPlayerId
            lastActionType = .drew
        }
        
        advanceTurn()
    }
}
