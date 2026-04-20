//
//  ObviousAnswerOnlineView.swift
//  The Social Deck
//
//  Full online implementation of The Obvious Answer.
//  Phases: answering → results → (next round or finished)
//  Scoring: exact match (case-insensitive, normalized) against the stored correct answer.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Main View

struct ObviousAnswerOnlineView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String

    @Environment(\.dismiss) private var dismiss
    @State private var showGuestNextRoundHint = false
    @State private var showLeaveGameConfirm = false

    @StateObject private var vm: ObviousAnswerViewModel

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        _vm = StateObject(wrappedValue: ObviousAnswerViewModel(
            roomCode: roomCode,
            isHost: isHost,
            currentUserId: currentUserId
        ))
    }

    var body: some View {
        OnlineGameShellView(
            gameName: "The Obvious Answer",
            currentRound: (vm.gameState?.currentRound ?? 0) + 1,
            totalRounds: vm.gameState?.totalRounds ?? 1,
            players: playersWithScores,
            localPlayerId: currentUserId,
            answeredUserIds: shellSubmittedUserIds,
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
                .animation(.spring(response: 0.44, dampingFraction: 0.86), value: obviousAnswerPhaseAnimationID)
            }
        }
        .onAppear {
            vm.startListening()
        }
        .onDisappear {
            vm.stopListening()
        }
        .alert("Next round", isPresented: $showGuestNextRoundHint) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Ask the host to advance to the next round.")
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

    // MARK: - Derived state

    private var playersWithScores: [RoomPlayer] {
        guard let scores = vm.gameState?.scores else { return players }
        return players.map { p in
            var copy = p
            copy.gameScore = scores[p.id] ?? 0
            return copy
        }
    }

    private var shellSubmittedUserIds: Set<String> {
        guard let answers = vm.gameState?.answers else { return [] }
        return Set(answers.keys)
    }

    /// Drives smooth transitions when phase or round changes.
    private var obviousAnswerPhaseAnimationID: String {
        guard let s = vm.gameState else { return "loading" }
        return "\(s.phase.rawValue)-\(s.currentRound)"
    }

    // MARK: - Answering Phase

    @ViewBuilder
    private func answeringView(state: ObviousAnswerGameState) -> some View {
        let hasSubmitted = state.answers[currentUserId] != nil

        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    promptCard(prompt: state.currentPrompt)

                    if hasSubmitted {
                        submittedBadge(answer: state.answers[currentUserId] ?? "")
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

    private func promptCard(prompt: String) -> some View {
        VStack(spacing: 14) {
            Text("Fill in the blank")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.tertiaryText)
                .textCase(.uppercase)
                .tracking(0.8)

            styledPromptText(prompt)
                .multilineTextAlignment(.center)
                .lineSpacing(5)

            Text("Type the one obvious correct answer")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.tertiaryText)
                .multilineTextAlignment(.center)
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

    /// Renders the prompt text with `___` highlighted in the accent color.
    private func styledPromptText(_ prompt: String) -> Text {
        let parts = prompt.components(separatedBy: "___")
        var result = Text("")
        for (i, part) in parts.enumerated() {
            result = result + Text(part)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
            if i < parts.count - 1 {
                result = result + Text("___")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(Color.primaryAccent)
            }
        }
        return result
    }

    @ViewBuilder
    private func answerInputSection() -> some View {
        VStack(spacing: 16) {
            Text("Your answer")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            OATextField(text: $vm.draftAnswer)

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

    private func submittedBadge(answer: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                Text("Answer submitted!")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
            }
            Text("\"\(answer)\"")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.10))
        )
    }

    private func waitingForOthers(state: ObviousAnswerGameState) -> some View {
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

    // MARK: - Results Phase

    @ViewBuilder
    private func resultsView(state: ObviousAnswerGameState) -> some View {
        let isLastRound = state.currentRound + 1 >= state.totalRounds

        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    promptCard(prompt: state.currentPrompt)
                        .padding(.top, 4)

                    correctAnswerBanner(state: state)

                    playerResultsList(state: state)

                    roundStandingsSection(state: state)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isHost {
                hostResultsBar(state: state, isLastRound: isLastRound)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Color.appBackground
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
                    )
            } else {
                waitingForHostBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Color.appBackground
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
                    )
            }
        }
    }

    private func correctAnswerBanner(state: ObviousAnswerGameState) -> some View {
        VStack(spacing: 10) {
            Text("Correct answer")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                .textCase(.uppercase)
                .tracking(0.8)

            Text(state.correctAnswer)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.3), lineWidth: 1.5)
        )
    }

    private func playerResultsList(state: ObviousAnswerGameState) -> some View {
        let official = ObviousAnswerGameState.normalizeForMatch(state.correctAnswer)
        let ordered = players.sorted { $0.username.localizedCaseInsensitiveCompare($1.username) == .orderedAscending }

        return VStack(alignment: .leading, spacing: 12) {
            Text("This round")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondaryText)
                .padding(.leading, 4)

            ForEach(ordered, id: \.id) { player in
                if let ans = state.answers[player.id] {
                    let correct = ObviousAnswerGameState.normalizeForMatch(ans) == official
                    playerResultRow(player: player, answer: ans, isCorrect: correct)
                }
            }
        }
    }

    private func playerResultRow(player: RoomPlayer, answer: String, isCorrect: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(avatarType: player.avatarType, avatarColor: player.avatarColor, size: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(player.username)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondaryText)

                Text(answer)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primaryText)
                    .lineLimit(3)
            }

            Spacer(minLength: 8)

            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(isCorrect
                                 ? Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0)
                                 : Color(red: 0xFF/255.0, green: 0x3B/255.0, blue: 0x30/255.0))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isCorrect
                      ? Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.08)
                      : Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isCorrect
                        ? Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0).opacity(0.35)
                        : Color.clear,
                    lineWidth: 1.5
                )
        )
    }

    private func roundStandingsSection(state: ObviousAnswerGameState) -> some View {
        let ordered = players.sorted {
            (state.scores[$0.id] ?? 0) > (state.scores[$1.id] ?? 0)
        }

        return VStack(alignment: .leading, spacing: 12) {
            Text("Leaderboard")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondaryText)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(Array(ordered.enumerated()), id: \.element.id) { idx, player in
                    HStack(spacing: 12) {
                        Text("\(idx + 1)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.tertiaryText)
                            .frame(width: 22, alignment: .leading)

                        AvatarView(avatarType: player.avatarType, avatarColor: player.avatarColor, size: 32)

                        Text(player.username)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .lineLimit(1)

                        Spacer()

                        Text("\(state.scores[player.id] ?? 0)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(idx == 0 ? Color.primaryAccent : .secondaryText)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                }
            }
        }
    }

    private func hostResultsBar(state: ObviousAnswerGameState, isLastRound: Bool) -> some View {
        Button {
            HapticManager.shared.mediumImpact()
            if isLastRound {
                vm.finishGame(state: state)
            } else {
                vm.advanceToNextRound(state: state)
            }
        } label: {
            Text(isLastRound ? "See Final Scores" : "Next Round →")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.primaryAccent)
                .cornerRadius(14)
        }
    }

    private var waitingForHostBar: some View {
        Text("Waiting for host to continue…")
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundColor(.tertiaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(14)
    }

    // MARK: - Final Leaderboard

    @ViewBuilder
    private func finalLeaderboardView(state: ObviousAnswerGameState) -> some View {
        // Rank by stored scores for everyone who played — roster changes after the game must not change placements.
        let rows = state.scores.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
        let topScore = rows.first?.1 ?? 0
        let idsWithTopScore = rows.filter { $0.1 == topScore }.map { $0.0 }
        let headline: String = {
            if idsWithTopScore.count == 1, let wid = idsWithTopScore.first {
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
                    Text("Most correct obvious answers wins")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
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
                    showGuestNextRoundHint = true
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

// MARK: - Text field wrapper

private struct OATextField: View {
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

            TextField("", text: $text)
                .font(.system(size: 16, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .submitLabel(.done)
                .autocorrectionDisabled(false)
                .textInputAutocapitalization(.sentences)
        }
        .frame(height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - ViewModel

@MainActor
final class ObviousAnswerViewModel: ObservableObject {
    @Published var gameState: ObviousAnswerGameState?
    @Published var draftAnswer: String = ""
    @Published var isSubmitting = false

    private let roomCode: String
    private let isHost: Bool
    private let currentUserId: String
    private var listener: ListenerRegistration?
    private var usedPromptIndices: Set<Int> = []

    init(roomCode: String, isHost: Bool, currentUserId: String) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.currentUserId = currentUserId
    }

    func startListening() {
        let db = Firestore.firestore()
        listener = db.collection("rooms").document(roomCode).addSnapshotListener { [weak self] snap, _ in
            guard let self else { return }
            guard let snap, snap.exists else { return }
            do {
                let room = try snap.data(as: OnlineRoom.self)
                if let state = room.obviousAnswerGameState {
                    self.gameState = state
                    let roster = room.players
                    Task { await self.hostDriveResultsIfNeeded(state: state, allPlayers: roster) }
                    Task { await self.claimSocialDeckOnlineWinIfNeeded(state: state, participants: roster) }
                }
            } catch {
                print("[ObviousAnswer] snapshot decode failed: \(error)")
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
                try await OnlineService.shared.updateObviousAnswerGameState(roomCode: roomCode, gameState: state)
                await MainActor.run { self.isSubmitting = false }
            } catch {
                await MainActor.run { self.isSubmitting = false }
                print("[ObviousAnswer] submitAnswer failed: \(error)")
            }
        }
    }

    func advanceToNextRound(state: ObviousAnswerGameState) {
        guard isHost else { return }
        var next = state
        next.currentRound += 1
        let picked = pickNextPrompt()
        next.currentPrompt = picked.prompt
        next.correctAnswer = picked.correctAnswer
        next.answers = [:]
        next.phase = .answering
        draftAnswer = ""
        Task {
            do {
                try await OnlineService.shared.updateObviousAnswerGameState(roomCode: roomCode, gameState: next)
            } catch {
                print("[ObviousAnswer] advanceToNextRound failed: \(error)")
            }
        }
    }

    func finishGame(state: ObviousAnswerGameState) {
        guard isHost else { return }
        var next = state
        next.phase = .finished
        Task {
            do {
                try await OnlineService.shared.updateObviousAnswerGameState(roomCode: roomCode, gameState: next)
            } catch {
                print("[ObviousAnswer] finishGame failed: \(error)")
            }
        }
    }

    private func claimSocialDeckOnlineWinIfNeeded(state: ObviousAnswerGameState, participants: [RoomPlayer]) async {
        guard state.phase == .finished else { return }
        guard !state.socialDeckWinRecordedUserIds.contains(currentUserId) else { return }
        let ids = participants.map { $0.id }
        let maxScore = ids.map { state.scores[$0] ?? 0 }.max() ?? 0
        guard (state.scores[currentUserId] ?? 0) == maxScore else { return }
        do {
            let claimed = try await OnlineService.shared.tryClaimSocialDeckOnlineWin(roomCode: roomCode)
            if claimed {
                await AuthManager.shared.updateStats(onlineGamesWon: 1)
            }
        } catch {
            print("[ObviousAnswer] tryClaimSocialDeckOnlineWin failed: \(error)")
        }
    }

    // MARK: - Host automation

    /// When every player has submitted, compute scores and advance to results.
    private func hostDriveResultsIfNeeded(state: ObviousAnswerGameState, allPlayers: [RoomPlayer]) async {
        guard isHost, state.phase == .answering else { return }
        let allAnswered = allPlayers.allSatisfy { state.answers[$0.id] != nil }
        guard allAnswered else { return }
        await computeAndRevealResults(state: state)
    }

    private func computeAndRevealResults(state: ObviousAnswerGameState) async {
        let official = ObviousAnswerGameState.normalizeForMatch(state.correctAnswer)
        var updated = state
        for (userId, answer) in state.answers {
            if ObviousAnswerGameState.normalizeForMatch(answer) == official {
                updated.scores[userId, default: 0] += 1
            }
        }
        updated.phase = .results

        do {
            try await OnlineService.shared.updateObviousAnswerGameState(roomCode: roomCode, gameState: updated)
        } catch {
            print("[ObviousAnswer] computeAndRevealResults failed: \(error)")
        }
    }

    // MARK: - Prompt selection

    private func pickNextPrompt() -> ObviousAnswerPrompt {
        let indices = Array(0..<allObviousAnswerPrompts.count)
        let available = indices.filter { !usedPromptIndices.contains($0) }
        let pool = available.isEmpty ? indices : available
        let idx = pool.randomElement() ?? 0
        usedPromptIndices.insert(idx)
        return allObviousAnswerPrompts[idx]
    }
}
