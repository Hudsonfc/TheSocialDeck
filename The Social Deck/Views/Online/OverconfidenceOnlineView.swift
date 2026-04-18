//
//  OverconfidenceOnlineView.swift
//  The Social Deck
//
//  Full online implementation of Overconfidence.
//  Phases: answering (pick answer + set confidence) → results → (next round or finished)
//  Scoring: correct = +confidence, wrong = −confidence. Scores can go negative.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Main View

struct OverconfidenceOnlineView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String

    @Environment(\.dismiss) private var dismiss
    @State private var showGuestNextRoundHint = false
    @State private var showLeaveGameConfirm = false

    @StateObject private var vm: OverconfidenceViewModel

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        _vm = StateObject(wrappedValue: OverconfidenceViewModel(
            roomCode: roomCode,
            isHost: isHost,
            currentUserId: currentUserId
        ))
    }

    var body: some View {
        OnlineGameShellView(
            gameName: "Overconfidence",
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
                .animation(.spring(response: 0.44, dampingFraction: 0.86), value: overconfidencePhaseAnimationID)
            }
        }
        .onAppear {
            vm.startListening()
        }
        .onDisappear {
            vm.stopListening()
        }
        .alert("Waiting on host", isPresented: $showGuestNextRoundHint) {
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

    // MARK: - Derived

    private var playersWithScores: [RoomPlayer] {
        guard let scores = vm.gameState?.scores else { return players }
        return players.map { p in
            var copy = p
            copy.gameScore = scores[p.id] ?? 0
            return copy
        }
    }

    private var shellSubmittedUserIds: Set<String> {
        guard let subs = vm.gameState?.submissions else { return [] }
        return Set(subs.keys)
    }

    private var overconfidencePhaseAnimationID: String {
        guard let s = vm.gameState else { return "loading" }
        return "\(s.phase.rawValue)-\(s.currentRound)"
    }

    // MARK: - Answering Phase

    @ViewBuilder
    private func answeringView(state: OverconfidenceGameState) -> some View {
        let hasSubmitted = state.submissions[currentUserId] != nil

        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    questionCard(question: state.currentQuestion)

                    if hasSubmitted {
                        submittedBadge(sub: state.submissions[currentUserId]!)
                        waitingForOthers(state: state)
                    } else {
                        answerOptionsSection(state: state)
                        confidenceSliderSection()
                        submitButton()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func questionCard(question: String) -> some View {
        VStack(spacing: 12) {
            Text("TRIVIA")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.tertiaryText)
                .tracking(1.2)

            Text(question)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    @ViewBuilder
    private func answerOptionsSection(state: OverconfidenceGameState) -> some View {
        VStack(spacing: 10) {
            ForEach(state.currentOptions, id: \.self) { option in
                let selected = vm.selectedAnswer == option
                Button {
                    HapticManager.shared.lightImpact()
                    vm.selectedAnswer = option
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(selected ? Color.primaryAccent : Color(UIColor.tertiarySystemBackground))
                                .frame(width: 28, height: 28)
                            if selected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        Text(option)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(selected ? .primaryText : .secondaryText)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selected ? Color.primaryAccent.opacity(0.10) : Color(UIColor.secondarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selected ? Color.primaryAccent.opacity(0.60) : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func confidenceSliderSection() -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Confidence")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                    Text("How sure are you?")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.tertiaryText)
                }
                Spacer()
                confidenceBadge(value: vm.confidence)
            }

            Slider(value: Binding(
                get: { Double(vm.confidence) },
                set: { vm.confidence = Int($0) }
            ), in: 0...100, step: 1)
            .tint(confidenceColor(vm.confidence))

            HStack {
                Text("0")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.tertiaryText)
                Spacer()
                Text("Just guessing")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.tertiaryText)
                Spacer()
                Text("100")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.tertiaryText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    private func confidenceBadge(value: Int) -> some View {
        Text("\(value)")
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundColor(confidenceColor(value))
            .monospacedDigit()
            .frame(minWidth: 44, alignment: .trailing)
    }

    private func confidenceColor(_ value: Int) -> Color {
        if value <= 30 { return Color(red: 0.20, green: 0.60, blue: 0.86) }
        if value <= 60 { return Color(red: 0.99, green: 0.70, blue: 0.15) }
        return Color(red: 0.85, green: 0.22, blue: 0.22)
    }

    @ViewBuilder
    private func submitButton() -> some View {
        let canSubmit = vm.selectedAnswer != nil && !vm.isSubmitting
        Button {
            HapticManager.shared.lightImpact()
            vm.submitAnswer()
        } label: {
            Group {
                if vm.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Text("Lock In")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canSubmit ? Color.primaryAccent : Color.primaryAccent.opacity(0.4))
            .cornerRadius(14)
        }
        .disabled(!canSubmit)
    }

    private func submittedBadge(sub: OverconfidenceSubmission) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundColor(Color(red: 0.20, green: 0.78, blue: 0.35))
                Text("Locked in!")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.20, green: 0.78, blue: 0.35))
            }
            Text("\"\(sub.answer)\"  ·  \(sub.confidence)% confident")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.20, green: 0.78, blue: 0.35).opacity(0.10))
        )
    }

    private func waitingForOthers(state: OverconfidenceGameState) -> some View {
        let done = state.submissions.count
        let total = players.count
        return VStack(spacing: 6) {
            Text("Waiting for others…")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
            Text("\(done) / \(total) locked in")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.tertiaryText)
        }
    }

    // MARK: - Results Phase

    @ViewBuilder
    private func resultsView(state: OverconfidenceGameState) -> some View {
        let isLastRound = state.currentRound + 1 >= state.totalRounds

        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    questionCard(question: state.currentQuestion)
                        .padding(.top, 4)

                    correctAnswerBanner(answer: state.correctAnswer)

                    playerResultsList(state: state)

                    standingsSection(state: state)
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

    private func correctAnswerBanner(answer: String) -> some View {
        VStack(spacing: 8) {
            Text("CORRECT ANSWER")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.20, green: 0.78, blue: 0.35))
                .tracking(1.0)

            Text(answer)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.20, green: 0.78, blue: 0.35).opacity(0.10))
        )
    }

    @ViewBuilder
    private func playerResultsList(state: OverconfidenceGameState) -> some View {
        VStack(spacing: 10) {
            Text("THIS ROUND")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.tertiaryText)
                .tracking(1.0)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(players) { player in
                let sub = state.submissions[player.id]
                let isCorrect = sub?.answer == state.correctAnswer
                let delta = sub.map { isCorrect ? $0.confidence : -$0.confidence }

                HStack(spacing: 12) {
                    AvatarView(avatarType: player.avatarType, avatarColor: player.avatarColor, size: 38)
                        .frame(width: 38, height: 38)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(player.username)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .lineLimit(1)

                        if let sub {
                            HStack(spacing: 6) {
                                Text(sub.answer)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.35) : Color.primaryAccent)
                                    .lineLimit(1)
                                Text("·")
                                    .foregroundColor(.tertiaryText)
                                    .font(.system(size: 12))
                                Text("\(sub.confidence)% conf.")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.tertiaryText)
                            }
                        } else {
                            Text("No answer")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.tertiaryText)
                        }
                    }

                    Spacer()

                    if let delta {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(delta >= 0 ? "+\(delta)" : "\(delta)")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundColor(delta >= 0 ? Color(red: 0.20, green: 0.78, blue: 0.35) : Color.primaryAccent)
                                .monospacedDigit()
                            Text("pts")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.tertiaryText)
                        }
                    }

                    resultIcon(isCorrect: sub != nil ? isCorrect : nil)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
        }
    }

    private func resultIcon(isCorrect: Bool?) -> some View {
        let name: String
        let color: Color
        if let correct = isCorrect {
            name = correct ? "checkmark.circle.fill" : "xmark.circle.fill"
            color = correct ? Color(red: 0.20, green: 0.78, blue: 0.35) : Color.primaryAccent
        } else {
            name = "minus.circle.fill"
            color = .tertiaryText
        }
        return Image(systemName: name)
            .font(.system(size: 22, weight: .medium))
            .foregroundColor(color)
    }

    @ViewBuilder
    private func standingsSection(state: OverconfidenceGameState) -> some View {
        VStack(spacing: 10) {
            Text("STANDINGS")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.tertiaryText)
                .tracking(1.0)
                .frame(maxWidth: .infinity, alignment: .leading)

            let sorted = players.sorted {
                (state.scores[$0.id] ?? 0) > (state.scores[$1.id] ?? 0)
            }
            ForEach(Array(sorted.enumerated()), id: \.element.id) { idx, player in
                let score = state.scores[player.id] ?? 0
                HStack(spacing: 12) {
                    Text("#\(idx + 1)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(idx == 0 ? Color.primaryAccent : .tertiaryText)
                        .frame(width: 28)

                    AvatarView(avatarType: player.avatarType, avatarColor: player.avatarColor, size: 34)
                        .frame(width: 34, height: 34)

                    Text(player.username)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .lineLimit(1)

                    Spacer()

                    Text("\(score)")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(score >= 0 ? (idx == 0 ? Color.primaryAccent : .secondaryText) : Color(red: 0.85, green: 0.22, blue: 0.22))
                        .monospacedDigit()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
        }
    }

    private func hostResultsBar(state: OverconfidenceGameState, isLastRound: Bool) -> some View {
        Button {
            HapticManager.shared.mediumImpact()
            if isLastRound {
                vm.finishGame(state: state)
            } else {
                vm.advanceToNextRound(state: state)
            }
        } label: {
            Text(isLastRound ? "See Final Scores" : "Next Round")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.primaryAccent)
                .cornerRadius(14)
        }
    }

    private var waitingForHostBar: some View {
        Button {
            showGuestNextRoundHint = true
        } label: {
            Text("Waiting for host…")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.secondaryBackground)
                .cornerRadius(14)
        }
    }

    // MARK: - Final Leaderboard

    @ViewBuilder
    private func finalLeaderboardView(state: OverconfidenceGameState) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("🏆")
                            .font(.system(size: 48))
                        Text("Final Scores")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.primaryText)
                        Text("Confidence is a double-edged sword.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    let sorted = players.sorted {
                        (state.scores[$0.id] ?? 0) > (state.scores[$1.id] ?? 0)
                    }
                    ForEach(Array(sorted.enumerated()), id: \.element.id) { idx, player in
                        let score = state.scores[player.id] ?? 0
                        HStack(spacing: 14) {
                            Text(idx == 0 ? "🥇" : idx == 1 ? "🥈" : idx == 2 ? "🥉" : "#\(idx + 1)")
                                .font(.system(size: idx < 3 ? 28 : 16, weight: .bold, design: .rounded))
                                .frame(width: 36)

                            AvatarView(avatarType: player.avatarType, avatarColor: player.avatarColor, size: 44)
                                .frame(width: 44, height: 44)

                            Text(player.username)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                                .lineLimit(1)

                            Spacer()

                            Text("\(score)")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(score >= 0 ? (idx == 0 ? Color.primaryAccent : .secondaryText) : Color(red: 0.85, green: 0.22, blue: 0.22))
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
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

// MARK: - ViewModel

@MainActor
final class OverconfidenceViewModel: ObservableObject {
    @Published var gameState: OverconfidenceGameState?
    @Published var selectedAnswer: String? = nil
    @Published var confidence: Int = 50
    @Published var isSubmitting = false

    private let roomCode: String
    private let isHost: Bool
    private let currentUserId: String
    private var listener: ListenerRegistration?
    private var usedQuestionIndices: Set<Int> = []

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
                if let state = room.overconfidenceGameState {
                    let oldPhase = self.gameState?.phase
                    let oldRound = self.gameState?.currentRound
                    self.gameState = state
                    // Reset local selection when a new answering round starts
                    if state.phase == .answering && (oldPhase != .answering || oldRound != state.currentRound) {
                        self.selectedAnswer = nil
                        self.confidence = 50
                    }
                    let roster = room.players
                    Task { await self.hostDriveResultsIfNeeded(state: state, allPlayers: roster) }
                }
            } catch {
                print("[Overconfidence] snapshot decode failed: \(error)")
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func submitAnswer() {
        guard let answer = selectedAnswer else { return }
        isSubmitting = true
        var state = gameState
        guard state != nil else { isSubmitting = false; return }
        let sub = OverconfidenceSubmission(answer: answer, confidence: confidence)
        state!.submissions[currentUserId] = sub
        Task {
            do {
                try await OnlineService.shared.updateOverconfidenceGameState(roomCode: roomCode, gameState: state!)
                await MainActor.run { self.isSubmitting = false }
            } catch {
                await MainActor.run { self.isSubmitting = false }
                print("[Overconfidence] submitAnswer failed: \(error)")
            }
        }
    }

    func advanceToNextRound(state: OverconfidenceGameState) {
        guard isHost else { return }
        var next = state
        next.currentRound += 1
        let q = pickNextQuestion()
        next.currentQuestion = q.question
        next.currentOptions = q.options.shuffled()
        next.correctAnswer = q.correctAnswer
        next.submissions = [:]
        next.phase = .answering
        Task {
            do {
                try await OnlineService.shared.updateOverconfidenceGameState(roomCode: roomCode, gameState: next)
            } catch {
                print("[Overconfidence] advanceToNextRound failed: \(error)")
            }
        }
    }

    func finishGame(state: OverconfidenceGameState) {
        guard isHost else { return }
        var next = state
        next.phase = .finished
        Task {
            do {
                try await OnlineService.shared.updateOverconfidenceGameState(roomCode: roomCode, gameState: next)
            } catch {
                print("[Overconfidence] finishGame failed: \(error)")
            }
        }
    }

    // MARK: - Host automation

    private func hostDriveResultsIfNeeded(state: OverconfidenceGameState, allPlayers: [RoomPlayer]) async {
        guard isHost, state.phase == .answering else { return }
        let allAnswered = allPlayers.allSatisfy { state.submissions[$0.id] != nil }
        guard allAnswered else { return }
        await computeAndAdvanceToResults(state: state)
    }

    private func computeAndAdvanceToResults(state: OverconfidenceGameState) async {
        var updated = state
        for (userId, sub) in state.submissions {
            let isCorrect = sub.answer == state.correctAnswer
            let delta = isCorrect ? sub.confidence : -sub.confidence
            updated.scores[userId, default: 0] += delta
        }
        updated.phase = .results
        do {
            try await OnlineService.shared.updateOverconfidenceGameState(roomCode: roomCode, gameState: updated)
        } catch {
            print("[Overconfidence] computeAndAdvanceToResults failed: \(error)")
        }
    }

    // MARK: - Question selection

    private func pickNextQuestion() -> OverconfidenceQuestion {
        let indices = Array(0..<allOverconfidenceQuestions.count)
        let available = indices.filter { !usedQuestionIndices.contains($0) }
        let pool = available.isEmpty ? indices : available
        let idx = pool.randomElement() ?? 0
        usedQuestionIndices.insert(idx)
        return allOverconfidenceQuestions[idx]
    }
}
