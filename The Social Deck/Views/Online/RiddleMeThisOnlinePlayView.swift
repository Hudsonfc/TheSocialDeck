//
//  RiddleMeThisOnlinePlayView.swift
//  The Social Deck
//
//  Online play view for Riddle Me This. Implements a full 3-phase
//  round flow: question → answering → results.
//  Card order is identical on all devices via a seeded shuffle on the room code.
//

import SwiftUI
import UIKit

struct RiddleMeThisOnlinePlayView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    /// Deterministically-shuffled cards (same order on every device for this room)
    let cards: [Card]

    @StateObject private var syncService = RiddleMeThisOnlineSyncService.shared

    @State private var answerText: String = ""
    @State private var hasInitialised: Bool = false
    @State private var cardRotation: Double = 0
    @State private var showHomeAlert: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showEndView: Bool = false

    // MARK: - Derived helpers

    private var currentCard: Card? {
        guard syncService.currentRiddleIndex < cards.count else { return nil }
        return cards[syncService.currentRiddleIndex]
    }

    private var hasSubmitted: Bool {
        guard let uid = currentUserId else { return false }
        return syncService.playerAnswers[uid] != nil
    }

    private var allPlayersSubmitted: Bool {
        players.allSatisfy { syncService.playerAnswers[$0.id] != nil }
    }

    private var submittedCount: Int {
        players.filter { syncService.playerAnswers[$0.id] != nil }.count
    }

    private var isLastRound: Bool {
        syncService.currentRiddleIndex >= cards.count - 1
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                if !players.isEmpty {
                    RiddleOnlinePlayerStripView(
                        players: players,
                        currentUserId: currentUserId,
                        playerAnswers: syncService.playerAnswers,
                        playerScores: syncService.playerScores,
                        roundPhase: syncService.roundPhase,
                        currentCard: currentCard
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }

                Group {
                    switch syncService.roundPhase {
                    case "answering":
                        answeringPhaseView
                    case "results":
                        resultsPhaseView
                    case "ended":
                        // Phase-change handler navigates; show spinner while transitioning
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(Color.buttonBackground)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    default: // "question"
                        questionPhaseView
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: syncService.roundPhase)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            syncService.resetLocalState()
            syncService.startListening(roomId: roomCode)
            if isHost && !hasInitialised {
                hasInitialised = true
                Task { try? await syncService.initGameState(roomId: roomCode, players: players) }
            }
        }
        .onDisappear {
            syncService.stopListening()
        }
        // Animate card flip when host flips
        .onChange(of: syncService.isCardFlipped) { flipped in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = flipped ? 180 : 0
            }
        }
        // Reset local state when round advances
        .onChange(of: syncService.currentRiddleIndex) { _ in
            withAnimation(.none) { cardRotation = 0 }
            answerText = ""
        }
        // Non-host end-of-game: host sets phase to "ended"
        .onChange(of: syncService.roundPhase) { phase in
            if phase == "ended" { showEndView = true }
        }
        .alert("Leave game?", isPresented: $showHomeAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Go Home", role: .destructive) { navigateToHome = true }
        } message: {
            Text("Are you sure you want to leave? Your progress will be lost.")
        }
        .background(
            NavigationLink(destination: HomeView(), isActive: $navigateToHome) { EmptyView() }
        )
        .background(
            NavigationLink(
                destination: RiddleMeThisOnlineEndView(
                    players: players,
                    playerScores: syncService.playerScores,
                    currentUserId: currentUserId,
                    totalRounds: cards.count
                ),
                isActive: $showEndView
            ) { EmptyView() }
        )
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { showHomeAlert = true } label: {
                Image(systemName: "house.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primaryText)
                    .frame(width: 44, height: 44)
                    .background(Color.tertiaryBackground)
                    .clipShape(Circle())
            }

            Spacer()

            Text("Round \(syncService.currentRiddleIndex + 1) of \(cards.count)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primaryText)
        }
        .responsiveHorizontalPadding()
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Phase 1: Question

    private var questionPhaseView: some View {
        VStack(spacing: 0) {
            Spacer()

            riddleCardView

            Spacer()

            if isHost {
                PrimaryButton(title: "Flip Card") {
                    HapticManager.shared.mediumImpact()
                    Task { try? await syncService.flipCard(roomId: roomCode) }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            } else {
                Text("Waiting for host to flip the card...")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Phase 2: Answering

    private var answeringPhaseView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                riddleCardView
                    .padding(.top, 4)

                Text("\(submittedCount) of \(players.count) answered")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)

                // Answer input — all players including host
                if !hasSubmitted {
                    VStack(spacing: 12) {
                        TextField("Type your answer...", text: $answerText)
                            .font(.system(size: 16, design: .rounded))
                            .padding(14)
                            .background(Color.secondaryBackground)
                            .cornerRadius(12)
                            .padding(.horizontal, 40)

                        PrimaryButton(title: "Submit Answer") {
                            let trimmed = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty, let uid = currentUserId else { return }
                            HapticManager.shared.mediumImpact()
                            Task {
                                try? await syncService.submitAnswer(roomId: roomCode, uid: uid, answer: trimmed)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Answer submitted!")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                    .padding(.vertical, 12)
                }

                // Host-only: "Show Answer" button (always visible) +
                //            "Everyone has answered" prompt when all submitted
                if isHost {
                    if allPlayersSubmitted {
                        VStack(spacing: 10) {
                            Text("Everyone has answered!")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.green)
                            showAnswerButton
                        }
                    } else {
                        showAnswerButton
                    }
                }

                Spacer(minLength: 40)
            }
        }
    }

    private var showAnswerButton: some View {
        Button {
            guard let card = currentCard else { return }
            HapticManager.shared.mediumImpact()
            Task {
                try? await syncService.revealAnswer(
                    roomId: roomCode,
                    correctAnswer: card.correctAnswer ?? "",
                    currentScores: syncService.playerScores,
                    allPlayerIds: players.map { $0.id }
                )
            }
        } label: {
            Text("Show Answer")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.primaryAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.appBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 30).stroke(Color.primaryAccent, lineWidth: 2)
                )
                .clipShape(Capsule())
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Phase 3: Results

    private var resultsPhaseView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Correct answer banner
                if let card = currentCard {
                    VStack(spacing: 6) {
                        Text("The Answer")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                        Text(card.correctAnswer ?? "")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.secondaryBackground)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                }

                // Player result rows
                VStack(spacing: 10) {
                    ForEach(players) { player in
                        playerResultRow(player: player)
                    }
                }
                .padding(.horizontal, 16)

                // Host action
                if isHost {
                    Group {
                        if isLastRound {
                            PrimaryButton(title: "End Game") {
                                HapticManager.shared.mediumImpact()
                                Task {
                                    try? await syncService.endGame(roomId: roomCode)
                                }
                                // Host navigates immediately after writing
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showEndView = true
                                }
                            }
                        } else {
                            PrimaryButton(title: "Next Round") {
                                HapticManager.shared.mediumImpact()
                                Task {
                                    try? await syncService.nextRound(
                                        roomId: roomCode,
                                        nextIndex: syncService.currentRiddleIndex + 1
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                } else {
                    Text(isLastRound
                         ? "Game over! Waiting for host..."
                         : "Waiting for host to start the next round...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
    }

    private func playerResultRow(player: RoomPlayer) -> some View {
        let submitted = syncService.playerAnswers[player.id]
        let score = syncService.playerScores[player.id] ?? 0
        let isCorrect: Bool = {
            guard let answer = submitted, let card = currentCard else { return false }
            return RiddleMeThisOnlineSyncService.matches(
                submitted: answer,
                correct: card.correctAnswer ?? ""
            )
        }()
        let isYou = player.id == currentUserId

        return HStack(spacing: 12) {
            AvatarView(avatarType: player.avatarType, avatarColor: player.avatarColor, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(player.username)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                    if isYou {
                        Text("(You)")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                }
                if let answer = submitted {
                    Text(answer)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                } else {
                    Text("No answer")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .italic()
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isCorrect ? .green : .red)
                Text("\(score) pt\(score == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(12)
        .background(Color.secondaryBackground)
        .cornerRadius(12)
    }

    // MARK: - Shared card view

    private var riddleCardView: some View {
        ZStack {
            RiddleCardBackView(text: "Riddle Me This")
                .opacity(cardRotation < 90 ? 1 : 0)

            if let card = currentCard {
                RiddleCardFrontView(text: card.text)
                    .opacity(cardRotation >= 90 ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .frame(width: ResponsiveSize.cardWidth, height: ResponsiveSize.cardHeight)
        .rotation3DEffect(
            .degrees(cardRotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
    }
}

// MARK: - Riddle Online Player Strip

struct RiddleOnlinePlayerStripView: View {
    let players: [RoomPlayer]
    let currentUserId: String?
    let playerAnswers: [String: String]
    let playerScores: [String: Int]
    let roundPhase: String
    let currentCard: Card?

    private let soDeckRed = Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(players) { player in
                    playerChip(player)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 86)
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(Color.tertiaryBackground.opacity(0.8))
        .cornerRadius(12)
    }

    private func playerChip(_ player: RoomPlayer) -> some View {
        let isYou = player.id == currentUserId
        let hasAnswered = playerAnswers[player.id] != nil
        let score = playerScores[player.id] ?? 0

        let resultMark: String? = {
            guard roundPhase == "results", let answer = playerAnswers[player.id],
                  let card = currentCard else { return nil }
            return RiddleMeThisOnlineSyncService.matches(
                submitted: answer,
                correct: card.correctAnswer ?? ""
            ) ? "✅" : "❌"
        }()

        return VStack(spacing: 3) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    avatarType: player.avatarType,
                    avatarColor: player.avatarColor,
                    size: 40
                )
                .overlay(
                    Circle()
                        .stroke(player.isHost ? soDeckRed : Color.clear, lineWidth: 3)
                        .padding(-2)
                )

                if roundPhase == "answering" && hasAnswered {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                        .background(Color.white.clipShape(Circle()))
                        .offset(x: 4, y: 4)
                } else if let mark = resultMark {
                    Text(mark)
                        .font(.system(size: 12))
                        .offset(x: 4, y: 4)
                } else if player.isHost {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(2)
                        .background(soDeckRed)
                        .clipShape(Circle())
                        .offset(x: 4, y: 4)
                }
            }

            Text(isYou ? "You" : player.username)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(isYou ? .primaryText : .secondaryText)
                .lineLimit(1)

            Text("\(score) pt\(score == 1 ? "" : "s")")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.appBackground.opacity(0.5))
        .cornerRadius(10)
    }
}

// MARK: - Online End View

struct RiddleMeThisOnlineEndView: View {
    let players: [RoomPlayer]
    let playerScores: [String: Int]
    let currentUserId: String?
    let totalRounds: Int

    @State private var navigateToHome: Bool = false

    private var sortedPlayers: [(player: RoomPlayer, score: Int)] {
        players
            .map { (player: $0, score: playerScores[$0.id] ?? 0) }
            .sorted { $0.score > $1.score }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Image("RMT 2.0")
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: 140, height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.cardShadowColor, radius: 15, x: 0, y: 8)

                        VStack(spacing: 8) {
                            Text("Game Over!")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primaryText)
                            Text("Final Scores — \(totalRounds) Riddle\(totalRounds == 1 ? "" : "s")")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                        }

                        // Leaderboard
                        VStack(spacing: 10) {
                            ForEach(Array(sortedPlayers.enumerated()), id: \.offset) { index, entry in
                                let isYou = entry.player.id == currentUserId
                                HStack(spacing: 12) {
                                    Text(index == 0 ? "🥇" : index == 1 ? "🥈" : index == 2 ? "🥉" : "\(index + 1).")
                                        .font(.system(size: 18))
                                        .frame(width: 28)

                                    AvatarView(
                                        avatarType: entry.player.avatarType,
                                        avatarColor: entry.player.avatarColor,
                                        size: 36
                                    )

                                    Text(entry.player.username + (isYou ? " (You)" : ""))
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryText)

                                    Spacer()

                                    Text("\(entry.score) pt\(entry.score == 1 ? "" : "s")")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                }
                                .padding(14)
                                .background(isYou ? Color.primaryAccent.opacity(0.08) : Color.secondaryBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isYou ? Color.primaryAccent.opacity(0.4) : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        Button {
                            HapticManager.shared.mediumImpact()
                            navigateToHome = true
                        } label: {
                            Text("Home")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color.buttonBackground)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.secondaryBackground)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(destination: HomeView(), isActive: $navigateToHome) { EmptyView() }
        )
    }
}
