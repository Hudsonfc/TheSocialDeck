//
//  WhatWouldYouDoOnlineView.swift
//  The Social Deck
//
//  Full online implementation of What Would You Do.
//  Phases: answering → revealing → voting → results → (next round or finished)
//

import SwiftUI
import FirebaseFirestore

// MARK: - Main View

struct WhatWouldYouDoOnlineView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String

    @Environment(\.dismiss) private var dismiss
    @State private var showGuestPlayAgainHint = false
    @State private var showLeaveGameConfirm = false

    @StateObject private var vm: WhatWouldYouDoViewModel

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        _vm = StateObject(wrappedValue: WhatWouldYouDoViewModel(
            roomCode: roomCode,
            currentUserId: currentUserId
        ))
    }

    var body: some View {
        OnlineGameShellView(
            gameName: "What Would You Do?",
            currentRound: (vm.gameState?.currentRound ?? 0) + 1,
            totalRounds: vm.gameState?.totalRounds ?? 1,
            players: playersWithScores,
            localPlayerId: currentUserId,
            answeredUserIds: shellSubmittedUserIds,
            hideScores: shellHideScores,
            onBack: {
                if isHost {
                    Task { await OnlineManager.shared.returnRoomToLobby() }
                } else {
                    Task {
                        await OnlineManager.shared.leaveRoom()
                        await MainActor.run { dismiss() }
                    }
                }
            }
        ) {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                Group {
                    if let state = vm.gameState {
                        switch state.phase {
                        case .answering:
                            answeringView(state: state)
                        case .revealing:
                            revealingView(state: state)
                        case .voting:
                            votingView(state: state)
                        case .results:
                            resultsView(state: state)
                        case .finished:
                            finalLeaderboardView(state: state)
                        }
                    } else {
                        ProgressView()
                            .scaleEffect(1.4)
                            .tint(Color.primaryAccent)
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)).combined(with: .scale(scale: 0.98)),
                    removal: .opacity.combined(with: .move(edge: .leading)).combined(with: .scale(scale: 0.98))
                ))
                .animation(.spring(response: 0.44, dampingFraction: 0.86), value: wwydPhaseAnimationID)
            }
        }
        .onAppear {
            vm.startListening()
        }
        .onDisappear {
            vm.stopListening()
        }
        .alert("Play again", isPresented: $showGuestPlayAgainHint) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Ask your host to tap Play Again — everyone will return to the lobby together.")
        }
        .alert("Leave this game?", isPresented: $showLeaveGameConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Leave", role: .destructive) {
                Task {
                    await OnlineManager.shared.leaveRoom()
                    await MainActor.run { dismiss() }
                }
            }
        } message: {
            Text("You will leave this online room.")
        }
    }

    // MARK: - Players with scores from state

    private var playersWithScores: [RoomPlayer] {
        guard let scores = vm.gameState?.scores else { return players }
        return players.map { p in
            var copy = p
            copy.gameScore = scores[p.id] ?? 0
            return copy
        }
    }

    /// Submitted answers for this round — drives checkmarks on the shell avatars.
    private var shellSubmittedUserIds: Set<String> {
        guard let answers = vm.gameState?.answers else { return [] }
        return Set(answers.keys)
    }

    /// Anonymous mode hides running scores until the final leaderboard.
    private var shellHideScores: Bool {
        guard let s = vm.gameState else { return false }
        return s.anonymousMode && s.phase != .finished
    }

    /// Drives smooth transitions when phase or round changes.
    private var wwydPhaseAnimationID: String {
        guard let s = vm.gameState else { return "loading" }
        return "\(s.phase.rawValue)-\(s.currentRound)"
    }

    private func anonymousAnswerLabel(playerId: String, state: WhatWouldYouDoGameState) -> String {
        guard let idx = state.revealOrder.firstIndex(of: playerId) else { return "Answer" }
        return "Answer \(idx + 1)"
    }

    // MARK: - Answering Phase

    @ViewBuilder
    private func answeringView(state: WhatWouldYouDoGameState) -> some View {
        let hasSubmitted = state.answers[currentUserId] != nil

        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    promptCard(text: state.currentPrompt)

                    if hasSubmitted {
                        submittedBadge()
                        waitingForOthers(state: state)
                    } else {
                        answerInputSection()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func promptCard(text: String) -> some View {
        VStack(spacing: 12) {
            Text("What would you do if…")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.tertiaryText)
                .textCase(.uppercase)
                .tracking(0.8)

            Text(text)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    @ViewBuilder
    private func answerInputSection() -> some View {
        VStack(spacing: 16) {
            Text("Your answer")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            WWYDTextEditor(text: $vm.draftAnswer)

            Button {
                HapticManager.shared.lightImpact()
                vm.submitAnswer()
            } label: {
                if vm.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Text("Submit")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                vm.draftAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSubmitting
                    ? Color.primaryAccent.opacity(0.4)
                    : Color.primaryAccent
            )
            .cornerRadius(14)
            .disabled(vm.draftAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSubmitting)
        }
    }

    private func submittedBadge() -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
            Text("Answer submitted!")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.12))
        )
    }

    private func waitingForOthers(state: WhatWouldYouDoGameState) -> some View {
        let answered = state.answers.keys.count
        let total = players.count
        return VStack(spacing: 8) {
            Text("Waiting for others…")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
            Text("\(answered) / \(total) answered")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.tertiaryText)
        }
    }

    // MARK: - Revealing Phase

    @ViewBuilder
    private func revealingView(state: WhatWouldYouDoGameState) -> some View {
        VStack(spacing: 24) {
            promptCard(text: state.currentPrompt)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            Text("Revealing answers…")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.tertiaryText)

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(Array(state.revealOrder.enumerated()), id: \.offset) { idx, playerId in
                        if idx <= state.revealIndex, let answer = state.answers[playerId] {
                            answerCard(playerId: playerId, answer: answer, isHighlighted: idx == state.revealIndex, state: state)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .animation(.spring(response: 0.45, dampingFraction: 0.8), value: state.revealIndex)
            }
        }
    }

    private func answerCard(playerId: String, answer: String, isHighlighted: Bool, state: WhatWouldYouDoGameState) -> some View {
        let player = players.first(where: { $0.id == playerId })
        let anonymous = state.anonymousMode

        return HStack(alignment: .top, spacing: 14) {
            if anonymous {
                ZStack {
                    Circle()
                        .fill(Color.secondaryText.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Text("\((state.revealOrder.firstIndex(of: playerId) ?? 0) + 1)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
            } else if let p = player {
                AvatarView(avatarType: p.avatarType, avatarColor: p.avatarColor, size: 40)
            } else {
                Circle().fill(Color.secondaryText.opacity(0.3)).frame(width: 40, height: 40)
            }
            VStack(alignment: .leading, spacing: 2) {
                if anonymous {
                    Text(anonymousAnswerLabel(playerId: playerId, state: state))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                } else {
                    Text(player?.username ?? "Player")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                Text(answer)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isHighlighted
                      ? Color.primaryAccent.opacity(0.1)
                      : Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isHighlighted ? Color.primaryAccent.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
    }

    // MARK: - Voting Phase

    @ViewBuilder
    private func votingView(state: WhatWouldYouDoGameState) -> some View {
        let need = WhatWouldYouDoGameState.requiredVotesPerPlayer(playerCount: players.count)
        let mine = state.votes[currentUserId] ?? []
        let finishedMine = mine.count >= need

        VStack(spacing: 0) {
            promptCard(text: state.currentPrompt)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            VStack(spacing: 8) {
                Text(need == 1 ? "Vote for your favourite answer" : "Pick \(need) answers you like (tap again to undo)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

                Text("\(mine.count)/\(need) votes")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(soDeckRedForWWYD)

                if finishedMine {
                    Text("Waiting for others to finish voting…")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.tertiaryText)
                }
            }

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(state.revealOrder, id: \.self) { playerId in
                        if let answer = state.answers[playerId] {
                            votingAnswerRow(
                                playerId: playerId,
                                answer: answer,
                                myVotes: mine,
                                votesRequired: need,
                                state: state
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
    }

    private var soDeckRedForWWYD: Color {
        Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
    }

    private func votingAnswerRow(playerId: String, answer: String, myVotes: [String], votesRequired: Int, state: WhatWouldYouDoGameState) -> some View {
        let isOwnAnswer = playerId == currentUserId
        let isVotedFor = myVotes.contains(playerId)
        let atCap = myVotes.count >= votesRequired
        let voteCount = state.votesReceived(by: playerId)
        let player = players.first(where: { $0.id == playerId })
        let anonymous = state.anonymousMode
        let canAddVote = !isOwnAnswer && !atCap && !isVotedFor
        let canRemoveVote = isVotedFor && !isOwnAnswer

        return Button {
            guard !isOwnAnswer else { return }
            if canAddVote || canRemoveVote {
                HapticManager.shared.lightImpact()
                vm.toggleVote(for: playerId, allPlayerCount: players.count)
            }
        } label: {
            HStack(spacing: 14) {
                if anonymous {
                    ZStack {
                        Circle()
                            .fill(Color.secondaryText.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Text("\((state.revealOrder.firstIndex(of: playerId) ?? 0) + 1)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                } else if let p = player {
                    AvatarView(avatarType: p.avatarType, avatarColor: p.avatarColor, size: 40)
                } else {
                    Circle().fill(Color.secondaryText.opacity(0.3)).frame(width: 40, height: 40)
                }
                VStack(alignment: .leading, spacing: 2) {
                    if anonymous {
                        Text(anonymousAnswerLabel(playerId: playerId, state: state))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondaryText)
                    } else {
                        Text(player?.username ?? "Player")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                    Text(answer)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                }
                Spacer()
                if myVotes.count >= votesRequired {
                    if voteCount > 0 {
                        Text("\(voteCount)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(isVotedFor ? .white : .primaryText)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(isVotedFor ? Color.primaryAccent : Color.secondaryText.opacity(0.15)))
                    }
                } else if isOwnAnswer {
                    Text("Yours")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.tertiaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.secondaryText.opacity(0.12)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isVotedFor
                          ? Color.primaryAccent.opacity(0.1)
                          : Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isVotedFor ? Color.primaryAccent.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
            .opacity(isOwnAnswer ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isOwnAnswer || (!isVotedFor && atCap))
    }

    // MARK: - Results Phase

    @ViewBuilder
    private func resultsView(state: WhatWouldYouDoGameState) -> some View {
        let isLastRound = state.currentRound >= state.totalRounds - 1

        VStack(spacing: 24) {
            if state.anonymousMode {
                anonymousRoundCompleteBanner()
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                answersWithVotesAnonymous(state: state)
            } else {
                winnerBanner(winnerId: roundWinnerId(state: state))
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                answersWithVotes(state: state)
            }

            if isHost {
                Button {
                    HapticManager.shared.lightImpact()
                    if isLastRound {
                        vm.finishGame(state: state)
                    } else {
                        vm.advanceToNextRound(state: state, allPlayers: players)
                    }
                } label: {
                    Text(isLastRound ? "See Final Results" : "Next Round")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryAccent)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            } else {
                Text("Waiting for host to start next round…")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.tertiaryText)
                    .padding(.bottom, 32)
            }
        }
    }

    private func anonymousRoundCompleteBanner() -> some View {
        VStack(spacing: 10) {
            Text("Round complete")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
            Text("Who wrote each answer stays secret, and scores unlock after the final round.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    private func answersWithVotesAnonymous(state: WhatWouldYouDoGameState) -> some View {
        let sorted = state.revealOrder.sorted { a, b in
            state.votesReceived(by: a) > state.votesReceived(by: b)
        }
        return ScrollView {
            VStack(spacing: 10) {
                ForEach(sorted, id: \.self) { playerId in
                    if let answer = state.answers[playerId] {
                        let voteCount = state.votesReceived(by: playerId)
                        HStack(spacing: 12) {
                            Text(anonymousAnswerLabel(playerId: playerId, state: state))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .frame(width: 72, alignment: .leading)
                            Text(answer)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.primaryText)
                                .lineLimit(3)
                            Spacer()
                            Text("\(voteCount) vote\(voteCount == 1 ? "" : "s")")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondaryText)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    private func winnerBanner(winnerId: String?) -> some View {
        let winner = players.first(where: { $0.id == winnerId })
        return VStack(spacing: 10) {
            if let w = winner {
                AvatarView(avatarType: w.avatarType, avatarColor: w.avatarColor, size: 56)
                Text("\(w.username) wins this round!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
            } else {
                Text("It's a tie!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    private func answersWithVotes(state: WhatWouldYouDoGameState) -> some View {
        let sorted = state.revealOrder.sorted { a, b in
            state.votesReceived(by: a) > state.votesReceived(by: b)
        }
        return ScrollView {
            VStack(spacing: 10) {
                ForEach(sorted, id: \.self) { playerId in
                    if let answer = state.answers[playerId] {
                        let voteCount = state.votesReceived(by: playerId)
                        let player = players.first(where: { $0.id == playerId })
                        HStack(spacing: 12) {
                            if let p = player {
                                AvatarView(avatarType: p.avatarType, avatarColor: p.avatarColor, size: 36)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(player?.username ?? "Player")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondaryText)
                                Text(answer)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .lineLimit(3)
                            }
                            Spacer()
                            Text("\(voteCount) vote\(voteCount == 1 ? "" : "s")")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondaryText)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    private func roundWinnerId(state: WhatWouldYouDoGameState) -> String? {
        var voteCounts: [String: Int] = [:]
        for votedId in state.votes.values.flatMap({ $0 }) {
            voteCounts[votedId, default: 0] += 1
        }
        guard let max = voteCounts.values.max(), max > 0 else { return nil }
        let winners = voteCounts.filter { $0.value == max }.map { $0.key }
        return winners.count == 1 ? winners[0] : nil
    }

    // MARK: - Final Leaderboard

    @ViewBuilder
    private func finalLeaderboardView(state: WhatWouldYouDoGameState) -> some View {
        let rows = state.scores.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
        let topScore = rows.first?.1 ?? 0
        let idsWithTop = rows.filter { $0.1 == topScore }.map { $0.0 }
        let headline: String = {
            if state.anonymousMode {
                return idsWithTop.count == 1 ? "We have a winner!" : "It's a tie!"
            }
            if idsWithTop.count == 1, let wid = idsWithTop.first {
                let name = players.first { $0.id == wid }?.username ?? "Player"
                return "\(name) wins!"
            }
            return "It's a tie!"
        }()

        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 0xFF/255.0, green: 0xCC/255.0, blue: 0x00/255.0))
                    Text(headline)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                    if state.anonymousMode {
                        Text("Final scores — answers were anonymous during play.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(UIColor.secondarySystemBackground)))
                .padding(.horizontal, 20)

                VStack(spacing: 10) {
                    ForEach(Array(rows.enumerated()), id: \.element.0) { idx, entry in
                        let playerId = entry.0
                        let score = entry.1
                        let roomPlayer = players.first { $0.id == playerId }
                        HStack(spacing: 14) {
                            Text("\(idx + 1)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.tertiaryText)
                                .frame(width: 24)
                            if let p = roomPlayer {
                                AvatarView(avatarType: p.avatarType, avatarColor: p.avatarColor, size: 44)
                                Text(p.username)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)
                            } else {
                                Circle()
                                    .fill(Color.secondaryText.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                Text("Player")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondaryText)
                            }
                            Spacer()
                            Text("\(score) pts")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(idx == 0 ? Color.primaryAccent : .secondaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .padding(.top, 24)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            finalResultsBottomBar
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Color.appBackground
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
                )
        }
    }

    private var finalResultsBottomBar: some View {
        HStack(spacing: 12) {
            Button {
                HapticManager.shared.lightImpact()
                if isHost {
                    Task { await OnlineManager.shared.returnRoomToLobby() }
                } else {
                    showGuestPlayAgainHint = true
                }
            } label: {
                Text("Play Again")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primaryAccent)
                    .cornerRadius(14)
            }

            Button {
                HapticManager.shared.lightImpact()
                showLeaveGameConfirm = true
            } label: {
                Text("Leave Game")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.primaryAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primaryAccent.opacity(0.12))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.primaryAccent.opacity(0.35), lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Simple multiline text editor wrapper

private struct WWYDTextEditor: View {
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))

            if text.isEmpty {
                Text("Type your answer…")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.tertiaryText)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .font(.system(size: 16, design: .rounded))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(minHeight: 100, maxHeight: 160)
        }
        .frame(minHeight: 100, maxHeight: 160)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - ViewModel

@MainActor
final class WhatWouldYouDoViewModel: ObservableObject {
    @Published var gameState: WhatWouldYouDoGameState?
    @Published var draftAnswer: String = ""
    @Published var isSubmitting = false

    private let roomCode: String
    private let currentUserId: String
    private var listener: ListenerRegistration?
    private var usedPromptIndices: Set<Int> = []

    init(roomCode: String, currentUserId: String) {
        self.roomCode = roomCode
        self.currentUserId = currentUserId
    }

    func startListening() {
        let db = Firestore.firestore()
        listener = db.collection("rooms").document(roomCode).addSnapshotListener { [weak self] snap, _ in
            guard let self else { return }
            guard let snap, snap.exists else { return }
            do {
                let room = try snap.data(as: OnlineRoom.self)
                if let state = room.whatWouldYouDoGameState {
                    self.gameState = state
                    let roster = room.players
                    // Host auto-advances reveal: once all answers in + revealIndex < end
                    Task { await self.hostDriveRevealIfNeeded(state: state, allPlayers: roster) }
                    // Once all voted, host transitions to results
                    Task { await self.hostDriveVotingIfNeeded(state: state, allPlayers: roster) }
                }
            } catch {
                print("[WWYD] snapshot decode failed: \(error)")
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func submitAnswer() {
        let trimmed = draftAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, var state = gameState else { return }
        isSubmitting = true
        state.answers[currentUserId] = trimmed
        Task {
            do {
                try await OnlineService.shared.updateWhatWouldYouDoGameState(roomCode: roomCode, gameState: state)
                await MainActor.run { self.isSubmitting = false }
            } catch {
                await MainActor.run { self.isSubmitting = false }
                print("[WWYD] submitAnswer failed: \(error)")
            }
        }
    }

    func toggleVote(for targetUserId: String, allPlayerCount: Int) {
        guard var state = gameState else { return }
        let need = WhatWouldYouDoGameState.requiredVotesPerPlayer(playerCount: allPlayerCount)
        guard targetUserId != currentUserId else { return }
        var mine = state.votes[currentUserId] ?? []
        if let idx = mine.firstIndex(of: targetUserId) {
            mine.remove(at: idx)
        } else {
            guard mine.count < need else { return }
            guard !mine.contains(targetUserId) else { return }
            mine.append(targetUserId)
        }
        if mine.isEmpty {
            state.votes.removeValue(forKey: currentUserId)
        } else {
            state.votes[currentUserId] = mine
        }
        Task {
            do {
                try await OnlineService.shared.updateWhatWouldYouDoGameState(roomCode: roomCode, gameState: state)
            } catch {
                print("[WWYD] toggleVote failed: \(error)")
            }
        }
    }

    func advanceToNextRound(state: WhatWouldYouDoGameState, allPlayers: [RoomPlayer]) {
        var next = state
        let winnerId = roundWinnerId(state: state)
        if let w = winnerId {
            next.scores[w, default: 0] += 1
        }
        next.currentRound += 1
        next.currentPrompt = pickNextPrompt(usedIndices: &usedPromptIndices)
        next.answers = [:]
        next.votes = [:]
        next.phase = .answering
        next.revealIndex = -1
        next.revealOrder = allPlayers.map { $0.id }.shuffled()
        Task {
            do {
                try await OnlineService.shared.updateWhatWouldYouDoGameState(roomCode: roomCode, gameState: next)
            } catch {
                print("[WWYD] advanceToNextRound failed: \(error)")
            }
        }
    }

    func finishGame(state: WhatWouldYouDoGameState) {
        var next = state
        let winnerId = roundWinnerId(state: state)
        if let w = winnerId {
            next.scores[w, default: 0] += 1
        }
        next.phase = .finished
        Task {
            do {
                try await OnlineService.shared.updateWhatWouldYouDoGameState(roomCode: roomCode, gameState: next)
            } catch {
                print("[WWYD] finishGame failed: \(error)")
            }
        }
    }

    // MARK: - Host automation helpers

    /// Once all players have answered, host transitions to revealing and drives the reveal index forward.
    private func hostDriveRevealIfNeeded(state: WhatWouldYouDoGameState, allPlayers: [RoomPlayer]) async {
        guard gameStateIsHostControlled() else { return }
        guard state.phase == .answering else { return }
        guard state.answers.count >= allPlayers.count else { return }

        var updated = state
        updated.phase = .revealing
        updated.revealIndex = -1
        do {
            try await OnlineService.shared.updateWhatWouldYouDoGameState(roomCode: roomCode, gameState: updated)
            try await revealAllAnswers(state: updated)
        } catch {
            print("[WWYD] hostDriveRevealIfNeeded failed: \(error)")
        }
    }

    private func revealAllAnswers(state: WhatWouldYouDoGameState) async throws {
        var current = state
        for idx in current.revealOrder.indices {
            try await Task.sleep(nanoseconds: 1_200_000_000)
            // Re-read latest state to be safe
            if let latest = gameState, latest.phase != .revealing { return }
            current.revealIndex = idx
            try await OnlineService.shared.updateWhatWouldYouDoGameState(roomCode: roomCode, gameState: current)
        }
        // All revealed → move to voting
        try await Task.sleep(nanoseconds: 1_000_000_000)
        current.phase = .voting
        try await OnlineService.shared.updateWhatWouldYouDoGameState(roomCode: roomCode, gameState: current)
    }

    /// Once all players have voted, host transitions to results.
    private func hostDriveVotingIfNeeded(state: WhatWouldYouDoGameState, allPlayers: [RoomPlayer]) async {
        guard gameStateIsHostControlled() else { return }
        guard state.phase == .voting else { return }
        let need = WhatWouldYouDoGameState.requiredVotesPerPlayer(playerCount: allPlayers.count)
        let eligibleVoters = allPlayers.map { $0.id }
        guard eligibleVoters.allSatisfy({ (state.votes[$0] ?? []).count == need }) else { return }

        var updated = state
        updated.phase = .results
        do {
            try await OnlineService.shared.updateWhatWouldYouDoGameState(roomCode: roomCode, gameState: updated)
        } catch {
            print("[WWYD] hostDriveVotingIfNeeded failed: \(error)")
        }
    }

    private func gameStateIsHostControlled() -> Bool {
        OnlineManager.shared.currentRoom?.hostId == currentUserId
    }

    // MARK: - Helpers

    private func roundWinnerId(state: WhatWouldYouDoGameState) -> String? {
        var voteCounts: [String: Int] = [:]
        for votedId in state.votes.values.flatMap({ $0 }) {
            voteCounts[votedId, default: 0] += 1
        }
        guard let max = voteCounts.values.max(), max > 0 else { return nil }
        let winners = voteCounts.filter { $0.value == max }.map { $0.key }
        return winners.count == 1 ? winners[0] : nil
    }

    private func pickNextPrompt(usedIndices: inout Set<Int>) -> String {
        let all = allWhatWouldYouDoPrompts
        let available = (0..<all.count).filter { !usedIndices.contains($0) }
        let pool = available.isEmpty ? Array(0..<all.count) : available
        let idx = pool.randomElement() ?? 0
        usedIndices.insert(idx)
        if usedIndices.count >= all.count { usedIndices.removeAll() }
        return all[idx]
    }
}
