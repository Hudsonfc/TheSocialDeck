//
//  OnlineSyncedClassicGameView.swift
//  The Social Deck
//
//  Synced card-browsing view for classic games (NHIE, WYR, TorD, StoryChain, etc.).
//  The host advances the card; all players see the same card in real time via SyncService.
//

import SwiftUI

struct OnlineSyncedClassicGameView: View {
    let roomCode: String
    let gameType: String
    let isHost: Bool
    let players: [RoomPlayer]

    @StateObject private var sync = SyncService.shared
    @StateObject private var onlineManager = OnlineManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var localIndex: Int = 0
    @State private var showEndAlert = false
    @State private var cardScale: CGFloat = 1.0
    @State private var cardOffset: CGFloat = 0

    private let soDeckRed = Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0)

    // Computed card deck for this game type
    private var cards: [Card] {
        switch gameType {
        case "neverHaveIEver": return allNHIECards.shuffled()
        case "wouldYouRather":  return allWYRCards.shuffled()
        case "truthOrDare":     return allTORCards.shuffled()
        case "storyChain":      return allStoryChainCards.shuffled()
        case "mostLikelyTo":    return allMLTCards.shuffled()
        case "twoTruthsAndALie": return allTTLCards.shuffled()
        default:                return allNHIECards.shuffled()
        }
    }

    private var currentCard: Card? {
        let idx = isHost ? localIndex : sync.remoteCardIndex
        guard cards.indices.contains(idx) else { return nil }
        return cards[idx]
    }

    private var displayIndex: Int { isHost ? localIndex : sync.remoteCardIndex }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar
                headerBar

                Spacer()

                // Card
                if let card = currentCard {
                    cardView(card: card)
                        .scaleEffect(cardScale)
                        .offset(x: cardOffset)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: displayIndex)
                } else {
                    endOfDeckView
                }

                Spacer()

                // Controls
                if isHost {
                    hostControls
                } else {
                    nonHostFooter
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            sync.startListening(roomId: roomCode)
            if isHost {
                Task { try? await sync.updateCardIndex(roomId: roomCode, index: 0) }
            }
        }
        .onDisappear {
            sync.stopListening()
        }
        .onChange(of: sync.remoteCardIndex) { newIndex in
            if !isHost {
                animateCardChange()
            }
        }
        .alert("End Game", isPresented: $showEndAlert) {
            Button("Cancel", role: .cancel) {}
            Button("End Game", role: .destructive) {
                Task { await onlineManager.leaveRoom() }
                dismiss()
            }
        } message: {
            Text("Are you sure you want to end the game for everyone?")
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button {
                showEndAlert = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0xF1 / 255.0, green: 0xF1 / 255.0, blue: 0xF1 / 255.0))
                    .clipShape(Circle())
            }

            Spacer()

            Text(gameTitle)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))

            Spacer()

            // Card counter
            Text("\(displayIndex + 1)/\(cards.count)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
                .frame(minWidth: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Card

    private func cardView(card: Card) -> some View {
        VStack(spacing: 20) {
            // Category badge
            Text(card.category)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(soDeckRed)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(soDeckRed.opacity(0.1))
                .cornerRadius(20)

            // Prefix label
            if let prefix = cardPrefix(for: card) {
                Text(prefix)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }

            // Main text
            Text(card.text)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)

            // WYR options
            if let a = card.optionA, let b = card.optionB {
                VStack(spacing: 10) {
                    wyrOptionBubble(text: a, label: "A")
                    Text("or")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                    wyrOptionBubble(text: b, label: "B")
                }
                .padding(.top, 4)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 6)
        .padding(.horizontal, 28)
    }

    private func wyrOptionBubble(text: String, label: String) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 26, height: 26)
                .background(soDeckRed)
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0xF5 / 255.0, green: 0xF5 / 255.0, blue: 0xF5 / 255.0))
        .cornerRadius(12)
    }

    // MARK: - End of Deck

    private var endOfDeckView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundColor(soDeckRed)
            Text("All done!")
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text("You've gone through all the cards.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
    }

    // MARK: - Host Controls

    private var hostControls: some View {
        VStack(spacing: 14) {
            // Player chips
            playerChips

            HStack(spacing: 14) {
                // Previous
                Button {
                    guard localIndex > 0 else { return }
                    HapticManager.shared.lightImpact()
                    animateCardChange()
                    localIndex -= 1
                    Task { try? await sync.updateCardIndex(roomId: roomCode, index: localIndex) }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(localIndex > 0 ? soDeckRed : Color.gray.opacity(0.35))
                        .frame(width: 54, height: 54)
                        .background(Color(red: 0xF5 / 255.0, green: 0xF5 / 255.0, blue: 0xF5 / 255.0))
                        .cornerRadius(14)
                }
                .disabled(localIndex == 0)

                // Next
                Button {
                    guard localIndex < cards.count - 1 else { return }
                    HapticManager.shared.mediumImpact()
                    animateCardChange()
                    localIndex += 1
                    Task { try? await sync.updateCardIndex(roomId: roomCode, index: localIndex) }
                } label: {
                    HStack(spacing: 6) {
                        Text("Next Card")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(localIndex < cards.count - 1 ? soDeckRed : Color.gray.opacity(0.35))
                    .cornerRadius(14)
                }
                .disabled(localIndex >= cards.count - 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Non-Host Footer

    private var nonHostFooter: some View {
        VStack(spacing: 14) {
            playerChips

            HStack(spacing: 6) {
                Image(systemName: "arrow.right.circle")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                Text("Host controls the cards")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 30)
        }
    }

    // MARK: - Player Chips

    private var playerChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(players) { player in
                    HStack(spacing: 6) {
                        AvatarView(avatarType: player.avatarType, avatarColor: player.avatarColor, size: 24)
                        Text(player.username)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 0xF5 / 255.0, green: 0xF5 / 255.0, blue: 0xF5 / 255.0))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Helpers

    private func animateCardChange() {
        withAnimation(.easeOut(duration: 0.12)) {
            cardScale = 0.95
            cardOffset = -8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                cardScale = 1.0
                cardOffset = 0
            }
        }
    }

    private var gameTitle: String {
        switch gameType {
        case "neverHaveIEver":  return "Never Have I Ever"
        case "wouldYouRather":  return "Would You Rather"
        case "truthOrDare":     return "Truth or Dare"
        case "storyChain":      return "Story Chain"
        case "mostLikelyTo":    return "Most Likely To"
        case "twoTruthsAndALie": return "Two Truths & a Lie"
        default:                return "Card Game"
        }
    }

    private func cardPrefix(for card: Card) -> String? {
        switch gameType {
        case "neverHaveIEver":  return "Never have I ever…"
        case "wouldYouRather":  return card.optionA != nil ? nil : "Would you rather…"
        case "truthOrDare":
            if card.cardType == .truth { return "TRUTH" }
            if card.cardType == .dare  { return "DARE"  }
            return nil
        case "storyChain":      return "Continue the story:"
        case "mostLikelyTo":    return "Most likely to…"
        default:                return nil
        }
    }
}
