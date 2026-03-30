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
    var roomId: String? = nil
    var isHost: Bool = false
    var players: [RoomPlayer]? = nil
    var currentUserId: String? = nil
    @ObservedObject private var syncService = SyncService.shared
    @Environment(\.dismiss) private var dismiss
    @AppStorage("swipeNavigationEnabled") private var swipeNavigationEnabled = false
    @AppStorage("totalCardsFlipped") private var totalCardsFlipped: Int = 0
    @State private var cardRotation: Double = 0
    @State private var showEndView: Bool = false
    @State private var showOnlineGuestLeave = false
    @State private var showOnlineHostEveryone = false
    @State private var showOnlineHostMulti = false
    @State private var nextButtonOpacity: Double = 0
    @State private var nextButtonOffset: CGFloat = 20
    @State private var cardOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false
    @State private var selectedOption: String? = nil // "A" or "B"
    @State private var dragOffset: CGFloat = 0
    @State private var suppressWyrSelectionPush = false

    private var isMyClassicTurn: Bool {
        guard roomId != nil, let uid = currentUserId else { return true }
        if !syncService.remoteClassicTurnsEnabled { return isHost }
        let tid = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
        if tid.isEmpty { return isHost }
        return tid == uid
    }

    private var waitingForActivePlayerLine: String {
        if !syncService.remoteClassicTurnsEnabled { return "Waiting for host…" }
        let tid = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let pl = players, !pl.isEmpty, !tid.isEmpty,
              let name = pl.first(where: { $0.id == tid })?.username else {
            return "Waiting for the current player…"
        }
        return "Waiting for \(name)…"
    }

    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with exit, back button, and progress
                HStack {
                    Button(action: { handleOnlineOrOfflineBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }

                    if manager.canGoBack && roomId == nil {
                        ClassicGameCompactPreviousButton(action: { previousCard() })
                            .padding(.leading, 8)
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    if let currentCard = manager.currentCard() {
                        Text("\(manager.currentIndex + 1) / \(manager.cards.count)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                    }
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Online: player avatars + host/you indication (compact single line)
                if let players = players, !players.isEmpty, roomId != nil {
                    OnlinePlayerStripView(
                        players: players,
                        currentUserId: currentUserId,
                        activeTurnPlayerId: syncService.remoteTurnPlayerId
                    )
                    .padding(.bottom, 8)
                }

                // Card area fills remaining space so top bar and bottom hint stay visible
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    // "Would You Rather" label
                    Text("Would You Rather")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.buttonBackground)
                        .padding(.bottom, 32)
                    // Card
                    if let currentCard = manager.currentCard() {
                        ZStack {
                            WYRCardFrontView()
                                .opacity(cardRotation < 90 ? 1 : 0)
                            WYRCardBackView(
                                optionA: currentCard.optionA ?? "",
                                optionB: currentCard.optionB ?? "",
                                selectedOption: $selectedOption,
                                allowSelection: roomId == nil || isMyClassicTurn
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
                            if roomId != nil && !isMyClassicTurn { return }
                            if !isTransitioning && !manager.isFlipped { toggleCard() }
                        }
                        .gesture(
                            (swipeNavigationEnabled && (roomId == nil || isMyClassicTurn)) ? DragGesture()
                                .onChanged { value in
                                    if !isTransitioning { dragOffset = value.translation.width }
                                }
                                .onEnded { value in
                                    if !isTransitioning {
                                        let swipeThreshold: CGFloat = 100
                                        if value.translation.width > swipeThreshold && manager.canGoBack {
                                            previousCard()
                                        } else if value.translation.width < -swipeThreshold && !manager.isFinished && selectedOption != nil {
                                            nextCard()
                                        }
                                        dragOffset = 0
                                    }
                                } : nil
                        )
                        .padding(.bottom, 32)
                    }
                    if roomId != nil && !manager.isFlipped && !isMyClassicTurn {
                        Text(waitingForActivePlayerLine + " to reveal the card.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxHeight: .infinity)

                if manager.isFlipped && selectedOption != nil {
                    if roomId != nil && !isMyClassicTurn {
                        Text(waitingForActivePlayerLine)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                    } else if swipeNavigationEnabled {
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

            OnlineGameExitAlertsView(
                guestLeave: $showOnlineGuestLeave,
                hostEveryone: $showOnlineHostEveryone,
                hostMulti: $showOnlineHostMulti
            )
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: WYREndView(deck: deck, selectedCategories: selectedCategories, cardsPlayed: manager.cards.count),
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
        .onChange(of: selectedOption) { _, newValue in
            if newValue != nil && manager.isFlipped {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    nextButtonOpacity = 1.0
                    nextButtonOffset = 0
                }
            }
            guard roomId != nil, isMyClassicTurn, !suppressWyrSelectionPush else { return }
            pushWYROnlineState(selectedOption: newValue)
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
            if let roomId = roomId {
                SyncService.shared.startListening(roomId: roomId)
                if isHost && syncService.remoteClassicTurnsEnabled {
                    Task {
                        try? await SyncService.shared.seedClassicTurnPlayerIfNeeded(roomId: roomId, players: players ?? [])
                    }
                }
            }
            applyWYRFirestoreSnapshot()
            if manager.isFlipped && selectedOption != nil {
                nextButtonOpacity = 1.0
                nextButtonOffset = 0
            }
        }
        .onDisappear {
            if roomId != nil {
                SyncService.shared.stopListening()
            }
        }
        .onChange(of: syncService.classicRemoteSyncVersion) { _, _ in
            if roomId != nil {
                applyWYRFirestoreSnapshot()
            }
        }
    }

    private func handleOnlineOrOfflineBack() {
        guard roomId != nil else {
            dismiss()
            return
        }
        if isHost {
            let n = players?.count ?? 0
            if n > 2 {
                showOnlineHostMulti = true
            } else {
                showOnlineHostEveryone = true
            }
        } else {
            showOnlineGuestLeave = true
        }
    }

    private func applyWYRFirestoreSnapshot() {
        guard roomId != nil else { return }
        let idx = syncService.remoteCardIndex
        let flipped = syncService.remoteClassicCardFlipped
        let optRaw = syncService.remoteWyrSelectedOption
        let remoteOpt: String? = optRaw.isEmpty ? nil : optRaw

        if idx >= manager.cards.count {
            manager.applyOnlineSyncState(cardIndex: idx, isFlipped: false)
            suppressWyrSelectionPush = true
            selectedOption = nil
            DispatchQueue.main.async { suppressWyrSelectionPush = false }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { cardRotation = 0 }
            return
        }

        if manager.currentIndex == idx, manager.isFlipped == flipped, selectedOption == remoteOpt {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                cardRotation = flipped ? 180 : 0
            }
            return
        }

        suppressWyrSelectionPush = true
        manager.applyOnlineSyncState(cardIndex: idx, isFlipped: flipped)
        selectedOption = remoteOpt
        DispatchQueue.main.async { suppressWyrSelectionPush = false }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            cardRotation = flipped ? 180 : 0
        }
    }

    private func pushWYROnlineState(selectedOption opt: String?) {
        guard let rid = roomId, isMyClassicTurn else { return }
        let turnId = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
        let turn = turnId.isEmpty ? (currentUserId ?? "") : turnId
        Task {
            try? await SyncService.shared.updateWouldYouRatherOnlineState(
                roomId: rid,
                cardIndex: manager.currentIndex,
                isFlipped: manager.isFlipped,
                turnPlayerId: turn,
                selectedOption: opt
            )
        }
    }

    private func toggleCard() {
        if roomId != nil && !isMyClassicTurn { return }
        HapticManager.shared.lightImpact()

        if manager.isFlipped {
            // Flip back to front
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
                pushWYROnlineState(selectedOption: nil)
            }
        } else {
            // Flip to back
            totalCardsFlipped += 1
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.flipCard()
                pushWYROnlineState(selectedOption: selectedOption)
            }
        }
    }
    
    private func previousCard() {
        if roomId != nil && !isMyClassicTurn { return }
        isTransitioning = true

        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { cardRotation = 0 }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = 500 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if manager.isFlipped { manager.flipCard() }
            selectedOption = nil
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) { cardOffset = -500 }
            manager.previousCard()
            pushWYROnlineState(selectedOption: nil)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isTransitioning = false }
            }
        }
    }

    private func nextCard() {
        if roomId != nil && !isMyClassicTurn { return }
        isTransitioning = true

        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            nextButtonOpacity = 0
            nextButtonOffset = 20
            cardRotation = 0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = -500 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if manager.isFlipped { manager.flipCard() }
            selectedOption = nil
            var transaction = Transaction(animation: .none)
            withTransaction(transaction) { cardOffset = 500 }
            manager.nextCard()

            if let rid = roomId {
                let pl = players ?? []
                let fromId = syncService.remoteTurnPlayerId.trimmingCharacters(in: .whitespacesAndNewlines)
                let from = fromId.isEmpty ? (currentUserId ?? "") : fromId
                let nextTurn = pl.isEmpty ? from : SyncService.nextClockwisePlayerId(from: from, in: pl)
                Task {
                    try? await SyncService.shared.updateWouldYouRatherOnlineState(
                        roomId: rid,
                        cardIndex: manager.isFinished ? manager.cards.count : manager.currentIndex,
                        isFlipped: false,
                        turnPlayerId: nextTurn,
                        selectedOption: nil
                    )
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { cardOffset = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isTransitioning = false }
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
            
            VStack(spacing: 16) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text("Would You Rather")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                
                Text("Tap to reveal")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
        }
    }
}

struct WYRCardBackView: View {
    let optionA: String
    let optionB: String
    @Binding var selectedOption: String?
    /// When false, taps are disabled (another player's turn online); selection still updates from Firestore.
    var allowSelection: Bool = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 24) {
                Text("Would You Rather")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                    .padding(.top, 24)
                
                VStack(spacing: 20) {
                    // Option A
                    Button(action: {
                        guard allowSelection else { return }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedOption = "A"
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(optionA)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if selectedOption == "A" {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color.buttonBackground)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 24)
                        .background(selectedOption == "A" ? Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedOption == "A" ? Color.buttonBackground : Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0), lineWidth: selectedOption == "A" ? 2 : 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!allowSelection)
                    .opacity(allowSelection ? 1 : 0.85)
                    
                    // Divider
                    Text("or")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    
                    // Option B
                    Button(action: {
                        guard allowSelection else { return }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedOption = "B"
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(optionB)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if selectedOption == "B" {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color.buttonBackground)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 24)
                        .background(selectedOption == "B" ? Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedOption == "B" ? Color.buttonBackground : Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0), lineWidth: selectedOption == "B" ? 2 : 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!allowSelection)
                    .opacity(allowSelection ? 1 : 0.85)
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
                    imageName: "WYR artwork",
                    type: .wouldYouRather,
                    cards: [
                        Card(text: "", category: "Party", optionA: "Dance on a table", optionB: "Sing karaoke"),
                        Card(text: "", category: "Party", optionA: "Take a selfie", optionB: "Play a party game"),
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
                imageName: "WYR artwork",
                type: .wouldYouRather,
                cards: [],
                availableCategories: []
            ),
            selectedCategories: ["Party", "Wild"]
        )
    }
}

