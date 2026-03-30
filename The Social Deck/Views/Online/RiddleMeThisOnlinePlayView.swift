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
import Combine

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
    @State private var showOnlineGuestLeave = false
    @State private var showOnlineHostEveryone = false
    @State private var showOnlineHostMulti = false
    @State private var showEndView: Bool = false
    /// Prevents double reveal when timer fires and host also taps Show Answer.
    @State private var didRevealThisRound: Bool = false
    /// Displayed scores animated per-row when results appear.
    @State private var displayedResultScores: [String: Int] = [:]
    @State private var didAnimateResultScores: Bool = false
    @State private var showAnswerInputArea: Bool = false
    @State private var showTimerChip: Bool = false
    @State private var hostHandoffBannerText: String?

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
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
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

            if let banner = hostHandoffBannerText {
                VStack {
                    Text(banner)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primaryText)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color.tertiaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: hostHandoffBannerText)
            }

            OnlineGameExitAlertsView(
                guestLeave: $showOnlineGuestLeave,
                hostEveryone: $showOnlineHostEveryone,
                hostMulti: $showOnlineHostMulti
            )
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
        .onChange(of: syncService.hostHandoffMessage) { _, newMsg in
            let trimmed = newMsg.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            guard trimmed.localizedCaseInsensitiveContains("now the host") else { return }
            let display = riddleHostHandoffBannerText(from: trimmed)
            hostHandoffBannerText = display
            let shown = display
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                if hostHandoffBannerText == shown {
                    hostHandoffBannerText = nil
                }
            }
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
            didRevealThisRound = false
            displayedResultScores = [:]
            didAnimateResultScores = false
        }
        // Non-host end-of-game: host sets phase to "ended"
        .onChange(of: syncService.roundPhase) { phase in
            if phase == "ended" { showEndView = true }
            if phase == "answering" { didRevealThisRound = false }
            if phase != "answering" {
                showAnswerInputArea = false
                showTimerChip = false
            }
            if phase == "results" {
                didRevealThisRound = true
                // Snapshot pre-reveal scores (all zeroed for this round start), animate to final.
                displayedResultScores = syncService.playerScores
                didAnimateResultScores = false
                animateOnlineResultScores()
            }
        }
        // Host: auto Show Answer when synced countdown reaches zero
        .onReceive(Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()) { _ in
            guard isHost, !didRevealThisRound else { return }
            guard syncService.roundPhase == "answering",
                  syncService.timerEnabled,
                  let start = syncService.roundStartTimestamp,
                  let card = currentCard else { return }
            let elapsed = Date().timeIntervalSince(start)
            guard elapsed >= Double(syncService.timerDuration) else { return }
            didRevealThisRound = true
            HapticManager.shared.mediumImpact()
            Task {
                try? await syncService.revealAnswer(
                    roomId: roomCode,
                    correctAnswer: card.correctAnswer ?? "",
                    currentScores: syncService.playerScores,
                    allPlayerIds: players.map { $0.id }
                )
            }
        }
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

    private func handleOnlineOrOfflineBack() {
        if isHost {
            if players.count > 2 {
                showOnlineHostMulti = true
            } else {
                showOnlineHostEveryone = true
            }
        } else {
            showOnlineGuestLeave = true
        }
    }

    /// Prefer "you are now the host" when the promoted host is the current user.
    private func riddleHostHandoffBannerText(from raw: String) -> String {
        let parts = raw.components(separatedBy: " — ")
        guard parts.count >= 2,
              let uid = currentUserId,
              let myName = players.first(where: { $0.id == uid })?.username else { return raw }
        let right = parts.dropFirst().joined(separator: " — ")
        if right == "\(myName) is now the host" {
            return "\(parts[0]) — you are now the host"
        }
        return raw
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { handleOnlineOrOfflineBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
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
                // Reserve timer slot so card doesn't shift when timer appears.
                ZStack {
                    if syncService.timerEnabled && showTimerChip {
                        TimelineView(.periodic(from: .now, by: 1.0)) { context in
                            Group {
                                if let countdown = answeringCountdownText(at: context.date) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "timer")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.buttonBackground)
                                        Text(countdown)
                                            .font(.system(size: 17, weight: .bold, design: .rounded))
                                            .monospacedDigit()
                                            .foregroundColor(Color.buttonBackground)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.buttonBackground.opacity(0.15))
                                    .cornerRadius(16)
                                }
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.82).combined(with: .opacity),
                            removal: .scale(scale: 0.96).combined(with: .opacity)
                        ))
                    }
                }
                .frame(height: 40)
                .padding(.top, 4)

                riddleCardView
                    .padding(.top, 4)

                // Answer input — all players including host
                ZStack {
                    if !hasSubmitted && showAnswerInputArea {
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
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                    } else {
                        VStack(spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Answer submitted!")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondaryText)
                            }
                            .padding(.vertical, 4)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .opacity
                            ))

                            // Host: when everyone is done, smoothly hand off this control
                            // from "Submit Answer" into "Show Answer" in the same area.
                            if isHost && allPlayersSubmitted {
                                showAnswerButton(horizontalPadding: 40)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .scale(scale: 0.9)).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }
                .animation(.interpolatingSpring(stiffness: 210, damping: 20), value: hasSubmitted)
                .animation(.interpolatingSpring(stiffness: 220, damping: 22), value: allPlayersSubmitted)
                // Reserve answer-area slot so card stays fixed.
                .frame(minHeight: 120)

                // Host-only: "Show Answer" button (always visible) +
                //            "Everyone has answered" prompt when all submitted
                if isHost {
                    if allPlayersSubmitted {
                        VStack(spacing: 10) {
                            // Avoid duplicate button: if host already submitted, button is shown
                            // above in the same slot where Submit used to be.
                            if !hasSubmitted {
                                showAnswerButton
                            }
                        }
                    } else {
                        showAnswerButton
                    }
                }

                Spacer(minLength: 40)
            }
        }
        .onAppear {
            showAnswerInputArea = false
            showTimerChip = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                    showAnswerInputArea = true
                    showTimerChip = syncService.timerEnabled
                }
            }
        }
    }

    private var showAnswerButton: some View {
        showAnswerButton(horizontalPadding: 40)
    }

    private func showAnswerButton(horizontalPadding: CGFloat) -> some View {
        Button {
            guard let card = currentCard else { return }
            didRevealThisRound = true
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
        .padding(.horizontal, horizontalPadding)
    }

    /// Remaining time for the answering-phase countdown (nil = hide chip until server timestamp arrives).
    private func answeringCountdownText(at date: Date) -> String? {
        guard syncService.timerEnabled,
              syncService.roundPhase == "answering",
              let start = syncService.roundStartTimestamp else { return nil }
        let end = start.addingTimeInterval(TimeInterval(syncService.timerDuration))
        let left = max(0, end.timeIntervalSince(date))
        let totalSeconds = Int(ceil(left))
        if totalSeconds >= 60 {
            let m = totalSeconds / 60
            let s = totalSeconds % 60
            return String(format: "%d:%02d", m, s)
        }
        return "\(totalSeconds)s"
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
                                    var didEnd = false
                                    do {
                                        try await syncService.endGame(roomId: roomCode)
                                        didEnd = true
                                    } catch {
                                        didEnd = false
                                    }
                                    await MainActor.run {
                                        if didEnd {
                                            OnlineManager.shared.scheduleRoomDeletionAfterGameEnd(roomCode: roomCode)
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            showEndView = true
                                        }
                                    }
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
        let finalScore = syncService.playerScores[player.id] ?? 0
        let displayedScore = displayedResultScores[player.id] ?? finalScore
        let isCorrect: Bool = {
            guard let answer = submitted, let card = currentCard else { return false }
            return RiddleMeThisOnlineSyncService.matches(
                submitted: answer,
                correct: card.correctAnswer ?? ""
            )
        }()
        let isYou = player.id == currentUserId
        // delta: +1 correct, -1 wrong/no-answer (same logic as revealAnswer)
        let delta = isCorrect ? 1 : -1

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

                Text(delta > 0 ? "+\(delta)" : "\(delta)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(delta > 0 ? .green : .red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background((delta > 0 ? Color.green : Color.red).opacity(0.12))
                    .clipShape(Capsule())

                Text("\(displayedScore) pt\(displayedScore == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .animation(.spring(response: 0.45, dampingFraction: 0.78), value: displayedScore)
            }
        }
        .padding(12)
        .background(Color.secondaryBackground)
        .cornerRadius(12)
    }

    private func animateOnlineResultScores() {
        guard !didAnimateResultScores else { return }
        didAnimateResultScores = true
        for (index, player) in players.enumerated() {
            let target = syncService.playerScores[player.id] ?? 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 + Double(index) * 0.1) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                    displayedResultScores[player.id] = target
                }
            }
        }
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
    /// Smaller avatars and strip — used by Settings previews only; default matches live online play.
    var compactStrip: Bool = false

    private let soDeckRed = Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0)

    private var avatarSize: CGFloat { compactStrip ? 34 : 40 }
    private var stripHeight: CGFloat { compactStrip ? 68 : 86 }
    private var chipSpacing: CGFloat { compactStrip ? 6 : 10 }
    private var hostRingWidth: CGFloat { compactStrip ? 2 : 3 }

    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: chipSpacing) {
                    ForEach(players) { player in
                        playerChip(player)
                    }
                }
                // Keep chips centered when they don't fill strip width;
                // naturally scrolls/left-aligns once content is wider than available width.
                .frame(minWidth: geo.size.width, alignment: .center)
                .padding(.horizontal, compactStrip ? 0 : 4)
            }
        }
        .frame(height: stripHeight)
        .padding(.vertical, compactStrip ? 3 : 6)
        .padding(.horizontal, compactStrip ? 10 : 16)
        .background(Color.tertiaryBackground.opacity(0.8))
        .cornerRadius(compactStrip ? 10 : 12)
    }

    private func playerChip(_ player: RoomPlayer) -> some View {
        let isYou = player.id == currentUserId
        let hasAnswered = playerAnswers[player.id] != nil
        let score = playerScores[player.id] ?? 0

        let resultMarkCorrectness: Bool? = {
            guard roundPhase == "results", let answer = playerAnswers[player.id],
                  let card = currentCard else { return nil }
            return RiddleMeThisOnlineSyncService.matches(
                submitted: answer,
                correct: card.correctAnswer ?? ""
            )
        }()

        return VStack(spacing: compactStrip ? 2 : 3) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    avatarType: player.avatarType,
                    avatarColor: player.avatarColor,
                    size: avatarSize
                )
                .overlay(
                    Circle()
                        .stroke(player.isHost ? soDeckRed : Color.clear, lineWidth: hostRingWidth)
                        .padding(-2)
                )

                if roundPhase == "answering" && hasAnswered {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: compactStrip ? 11 : 14))
                        .foregroundColor(.green)
                        .background(Color.white.clipShape(Circle()))
                        .offset(x: compactStrip ? 3 : 4, y: compactStrip ? 3 : 4)
                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                } else if let isCorrect = resultMarkCorrectness {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: compactStrip ? 11 : 13, weight: .bold))
                        .foregroundColor(isCorrect ? .green : .red)
                        .background(Color.white.clipShape(Circle()))
                        .offset(x: compactStrip ? 3 : 4, y: compactStrip ? 3 : 4)
                } else if player.isHost {
                    Image(systemName: "crown.fill")
                        .font(.system(size: compactStrip ? 8 : 10))
                        .foregroundColor(.white)
                        .padding(compactStrip ? 1 : 2)
                        .background(soDeckRed)
                        .clipShape(Circle())
                        .offset(x: compactStrip ? 3 : 4, y: compactStrip ? 3 : 4)
                }
            }
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: hasAnswered)

            Text(isYou ? "You" : player.username)
                .font(.system(size: compactStrip ? 9 : 10, weight: .semibold, design: .rounded))
                .foregroundColor(isYou ? .primaryText : .secondaryText)
                .lineLimit(1)

            Text("\(score) pt\(score == 1 ? "" : "s")")
                .font(.system(size: compactStrip ? 9 : 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
        }
        .padding(.horizontal, compactStrip ? 6 : 8)
        .padding(.vertical, compactStrip ? 3 : 4)
        .background(Color.appBackground.opacity(0.5))
        .cornerRadius(compactStrip ? 8 : 10)
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
