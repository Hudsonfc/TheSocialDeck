//
//  OnlineColorClashPlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct OnlineColorClashPlayView: View {
    @StateObject private var manager: OnlineColorClashGameManager
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
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
    
    let roomCode: String
    
    init(roomCode: String, myUserId: String) {
        self.roomCode = roomCode
        _manager = StateObject(wrappedValue: OnlineColorClashGameManager(roomCode: roomCode, myUserId: myUserId))
    }
    
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
            
            if manager.winnerId != nil || showWinnerView {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
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
        .sheet(isPresented: $manager.showWildColorSelection) {
            WildColorSelectionModal { color in
                Task {
                    await manager.selectWildColor(color)
                }
            }
        }
        .sheet(isPresented: $showCardInfo) {
            ColorClashCardInfoView()
        }
        .onAppear {
            // Trigger initial deal animation
            if isInitialDeal && !manager.myHand.isEmpty {
                // Start with cards hidden
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Animate cards appearing one by one
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isInitialDeal = false
                    }
                }
            }
            previousTopCardId = manager.topCard?.id
        }
        .onChange(of: manager.myHand.count) { count in
            // Reset initial deal if hand becomes empty and then gets cards again
            if count > 0 && isInitialDeal {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isInitialDeal = false
                    }
                }
            }
        }
        .onChange(of: manager.topCard?.id) { newCardId in
            // Check if card was played by another player (not by us)
            if let newId = newCardId, newId != previousTopCardId, previousTopCardId != nil {
                // Check if it was played by another player
                if let gameState = manager.gameState,
                   let lastPlayer = gameState.lastActionPlayer,
                   lastPlayer != authManager.userProfile?.userId {
                    triggerCardFlipAnimation()
                }
            }
            previousTopCardId = newCardId
        }
        .onChange(of: manager.winnerId) { winnerId in
            if winnerId != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showWinnerView = true
                }
            }
        }
        .onChange(of: manager.isMyTurn) { isMyTurn in
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
                    if manager.isMyTurn {
                        HStack(spacing: 12) {
                            if !hasDrawnThisTurn {
                                drawCardButton
                            }
                            
                            // Skip Turn button - always visible when it's your turn
                            Button(action: {
                                HapticManager.shared.mediumImpact()
                                selectedCardIds.removeAll()
                                Task {
                                    await manager.skipTurn()
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
                            .disabled(manager.isLoading)
                            .opacity(manager.isLoading ? 0.6 : 1.0)
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
                if let gameState = manager.gameState {
                    playerProfilesLayout(gameState: gameState)
                }
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            Text(roomCode)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                .cornerRadius(8)
            
            Spacer()
            
            // Timer - centered to avoid overlap with player avatars on right
            if manager.isMyTurn {
                turnTimer
            }
        }
        .padding(.horizontal, 40)
        .padding(.trailing, 140) // Extra padding to avoid overlap with player avatars (100px + 40px margin)
        .padding(.bottom, 16)
    }
    
    private var turnTimer: some View {
        let progress = manager.turnTimeRemaining / 30.0
        let timerColor = manager.turnTimeRemaining < 10 ? 
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
                        gradient: Gradient(colors: manager.turnTimeRemaining < 10 ? 
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
            
            Text("\(Int(manager.turnTimeRemaining))")
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
        .scaleEffect(manager.turnTimeRemaining < 5 ? 1.1 : 1.0)
        .animation(
            manager.turnTimeRemaining < 5 ? 
                .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : 
                .default,
            value: manager.turnTimeRemaining < 5
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
        .disabled(manager.isLoading)
        .opacity(manager.isLoading ? 0.6 : 1.0)
    }
    
    private var centerGameArea: some View {
        VStack(spacing: 0) {
            // Discard Pile Card
            if let topCard = manager.topCard {
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
    
    private func playerProfilesLayout(gameState: ColorClashGameState) -> some View {
        let playerIds = gameState.playerOrder
        
        return GeometryReader { geometry in
            let centerY = geometry.size.height / 2 - 140 // Move up by 140 pixels
            let slotSpacing: CGFloat = 90 // Fixed spacing between slot centers (reduced to bring top/bottom closer to middle)
            let rightColumnX = geometry.size.width - 116 // 100 width + 16 padding
            let leftColumnX: CGFloat = 16 // 16 padding
            
            ZStack {
                // Right column - 3 fixed slots
                // Top slot (index 0)
                playerSlotView(
                    playerId: playerIds.count > 0 ? playerIds[0] : nil,
                    gameState: gameState,
                    slotIndex: 0,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: rightColumnX + 50, y: centerY - slotSpacing)
                
                // Middle slot (index 1)
                playerSlotView(
                    playerId: playerIds.count > 1 ? playerIds[1] : nil,
                    gameState: gameState,
                    slotIndex: 1,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: rightColumnX + 50, y: centerY)
                
                // Bottom slot (index 2)
                playerSlotView(
                    playerId: playerIds.count > 2 ? playerIds[2] : nil,
                    gameState: gameState,
                    slotIndex: 2,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: rightColumnX + 50, y: centerY + slotSpacing)
                
                // Left column - 3 fixed slots
                // Top slot (index 3)
                playerSlotView(
                    playerId: playerIds.count > 3 ? playerIds[3] : nil,
                    gameState: gameState,
                    slotIndex: 3,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: leftColumnX + 50, y: centerY - slotSpacing)
                
                // Middle slot (index 4)
                playerSlotView(
                    playerId: playerIds.count > 4 ? playerIds[4] : nil,
                    gameState: gameState,
                    slotIndex: 4,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: leftColumnX + 50, y: centerY)
                
                // Bottom slot (index 5)
                playerSlotView(
                    playerId: playerIds.count > 5 ? playerIds[5] : nil,
                    gameState: gameState,
                    slotIndex: 5,
                    centerY: centerY,
                    slotSpacing: slotSpacing
                )
                .position(x: leftColumnX + 50, y: centerY + slotSpacing)
            }
        }
    }
    
    private func playerSlotView(
        playerId: String?,
        gameState: ColorClashGameState,
        slotIndex: Int,
        centerY: CGFloat,
        slotSpacing: CGFloat
    ) -> some View {
        Group {
            if let playerId = playerId,
               let player = onlineManager.currentRoom?.players.first(where: { $0.id == playerId }) {
                let isCurrentPlayer = gameState.currentPlayerId == playerId
                let isMe = playerId == authManager.userProfile?.userId
                let handCount = gameState.handCount(for: playerId)
                let playedThisCard = gameState.lastActionPlayer == playerId
                
                playerAvatarView(
                    player: player,
                    isMe: isMe,
                    isCurrentPlayer: isCurrentPlayer,
                    handCount: handCount,
                    playedThisCard: playedThisCard
                )
            } else {
                // Empty slot - invisible placeholder to maintain position
                Color.clear
                    .frame(width: 100, height: 90)
            }
        }
    }
    
    private func playerAvatarsList(gameState: ColorClashGameState) -> some View {
        VStack(spacing: 16) {
            ForEach(gameState.playerOrder, id: \.self) { playerId in
                if let player = onlineManager.currentRoom?.players.first(where: { $0.id == playerId }) {
                    let isCurrentPlayer = gameState.currentPlayerId == playerId
                    let isMe = playerId == authManager.userProfile?.userId
                    let handCount = gameState.handCount(for: playerId)
                    let playedThisCard = gameState.lastActionPlayer == playerId
                    
                    playerAvatarView(
                        player: player,
                        isMe: isMe,
                        isCurrentPlayer: isCurrentPlayer,
                        handCount: handCount,
                        playedThisCard: playedThisCard
                    )
                }
            }
        }
    }
    
    private func playerAvatarView(
        player: RoomPlayer,
        isMe: Bool,
        isCurrentPlayer: Bool,
        handCount: Int,
        playedThisCard: Bool
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
            
            if playedThisCard {
                Text("Played")
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
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: playedThisCard)
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
                    ForEach(Array(manager.myHand.enumerated()), id: \.element.id) { index, card in
                        let isSelected = selectedCardIds.contains(card.id)
                        
                        ColorClashCardView(
                            card: card,
                            size: .small,
                            isHighlighted: isSelected
                        ) {
                            if manager.isMyTurn {
                                HapticManager.shared.lightImpact()
                                toggleCardSelection(card)
                            }
                        }
                        .opacity(manager.isMyTurn ? 1.0 : 0.5)
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
            if manager.isMyTurn {
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
                        .disabled(manager.isLoading)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCardIds.count)
                        .opacity(manager.isLoading ? 0.6 : 1.0)
                        .padding(.horizontal, 40)
                    }
                    
                    HStack(spacing: 12) {
                        // Last Card Button
                        if manager.myHand.count == 1 {
                            Button(action: {
                                HapticManager.shared.lightImpact()
                                Task {
                                    await manager.declareLastCard()
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
                            .disabled(manager.isLoading)
                            .opacity(manager.isLoading ? 0.6 : 1.0)
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
    }
    
    private var winnerView: some View {
        VStack(spacing: 24) {
            if let winnerId = manager.winnerId,
               let winner = onlineManager.currentRoom?.players.first(where: { $0.id == winnerId }) {
                AvatarView(
                    avatarType: winner.avatarType,
                    avatarColor: winner.avatarColor,
                    size: 100
                )
                
                Text("\(winner.username) Wins!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            }
            
            PrimaryButton(title: "Back to Room") {
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
            // Check if we can add this card (must match existing selection if any)
            if selectedCardIds.isEmpty {
                selectedCardIds.insert(card.id)
            } else {
                // Check if this card matches the existing selection
                let existingCards = manager.myHand.filter { selectedCardIds.contains($0.id) }
                if let firstCard = existingCards.first {
                    let canAdd = (card.type == firstCard.type) && 
                                ((card.type == .wild || card.type == .wildDrawFour) || (card.color == firstCard.color))
                    if canAdd {
                        selectedCardIds.insert(card.id)
                    } else {
                        // Clear and start new selection
                        selectedCardIds = [card.id]
                    }
                }
            }
        }
    }
    
    private func playSelectedCards() async {
        let cardsToPlay = manager.myHand.filter { selectedCardIds.contains($0.id) }
        guard !cardsToPlay.isEmpty else { return }
        
        // Play cards sequentially
        for card in cardsToPlay {
            await playCardWithAnimation(card)
            if cardsToPlay.count > 1 {
                try? await Task.sleep(nanoseconds: 250_000_000) // 0.25 seconds between cards
            }
        }
        
        selectedCardIds.removeAll()
    }
    
    private func playCardWithAnimation(_ card: ColorClashCard) async {
        // Start animation from card position
        flyingCard = card
        flyingCardOpacity = 1.0
        
        guard let cardIndex = manager.myHand.firstIndex(where: { $0.id == card.id }) else { return }
        let startOffset = CGSize(width: CGFloat(cardIndex - manager.myHand.count / 2) * 20, height: 400)
        flyingCardOffset = startOffset
        
        // Animate to center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            withAnimation(.easeInOut(duration: 0.5)) {
                flyingCardOffset = CGSize(width: 0, height: -50)
            }
        }
        
        // Play card after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) {
            Task {
                await manager.playCard(card)
                
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
        let previousHandCount = manager.myHand.count
        await manager.drawCard()
        
        if let newCard = manager.myHand.last, manager.myHand.count > previousHandCount {
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
