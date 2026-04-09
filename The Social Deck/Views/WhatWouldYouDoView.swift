//
//  WhatWouldYouDoView.swift
//  The Social Deck
//
//  Table layout: background image with avatar placeholders on the four corner grey
//  circles (normalized positions in image space, 0…1).
//

import SwiftUI
import UIKit

struct WhatWouldYouDoView: View {
    /// Upscale factor so the table reads larger on screen (avatars scale with it to stay on grey circles).
    private let tableScale: CGFloat = 1.34

    private let nameSpacing: CGFloat = 4
    private let nameFontSize: CGFloat = 11

    /// Preview / simulation length (set to 1 to reach the end screen quickly).
    private let totalRounds: Int = 1

    /// Base diameter tuned to the art at 1.0 scale; multiplied by `tableScale` when the table is enlarged.
    private let baseAvatarDiameter: CGFloat = 52

    private var avatarDiameter: CGFloat { baseAvatarDiameter * tableScale }

    /// Mock players: same `avatarType` / `avatarColor` pattern as `AvatarView` (e.g. `avatar 1` … images in Assets).
    private let slots: [(name: String, avatarType: String, avatarColor: String, normX: CGFloat, normY: CGFloat)] = [
        ("Jake", "avatar 1", "blue", 0.26, 0.21),
        ("Mia", "avatar 2", "pink", 0.74, 0.21),
        ("Leo", "avatar 3", "green", 0.26, 0.79),
        ("Sara", "avatar 4", "purple", 0.74, 0.79),
    ]

    /// In simulate mode, seat 0 is treated as the local player (everyone still sees the same prompt).
    private let simulatedLocalSeatIndex: Int = 0

    /// Each player casts this many votes (can stack multiple on the same person). No self-votes.
    private let votesPerPlayer: Int = 3
    /// Points granted to a player per vote they receive.
    private let pointsPerVote: Int = 4

    /// Answer phase and voting phase both use a 30s countdown in the UI.
    private let timedPhaseSeconds: Int = 30

    /// Same scenario text for all players each round (answers stay private per device).
    private let wwydPrompts: [String] = [
        "You're stuck in an elevator with a stranger who won't stop humming. What do you do?",
        "You find cash on the ground outside a busy store with no one claiming it. What's your move?",
        "A friend asks you to cover for them in a small lie to their partner. How do you respond?",
        "You're offered your dream job but it means moving away from everyone you know in two weeks. What happens next?",
        "Someone cuts in front of you in a long line and pretends not to notice. What do you do?",
        "You accidentally read a private message not meant for you. What's your next step?",
    ]

    private var promptForCurrentRound: String {
        let idx = min(max(currentRound - 1, 0), wwydPrompts.count - 1)
        return wwydPrompts[idx]
    }

    /// 0 = avatars at table center (pre-start); 1 = seated on grey circles.
    @State private var entranceProgress: CGFloat = 0
    /// After the first “Simulate”, seats stay at the table between rounds (no fly-in repeat).
    @State private var seatEntranceCompleted: Bool = false
    @State private var currentRound: Int = 1
    /// Running vote points across all completed rounds (for the end screen).
    @State private var cumulativeVotePointsBySeat: [Int: Int] = [:]
    @State private var navigateToGameEnd: Bool = false
    @State private var endGameWinnerNames: [String] = []
    @State private var endGameWinnerScore: Int = 0
    /// Full-screen scores (after last round, before `WhatWouldYouDoEndView`), Riddle-style bridge.
    @State private var showPreEndScoresOverlay: Bool = false

    /// Full-screen “Round x of y” intro (opacity-driven fade in/out).
    @State private var roundIntroOpacity: Double = 0

    /// Full-screen “Voting time” between answer phase and reveal.
    @State private var votingIntroOpacity: Double = 0

    /// After voting overlay: large card shows all seats’ answers for the round just played.
    @State private var showEveryoneAnswers: Bool = false
    @State private var resultsPromptSnapshot: String = ""
    @State private var roundCapturedAnswers: [Int: String] = [:]

    /// After answers reveal: table voting (names hidden, max-points hint under avatars).
    @State private var showVotingPhase: Bool = false
    /// Voter seat → each entry is one vote for that recipient index (repeats allowed).
    @State private var votesFromSeat: [Int: [Int]] = [:]
    @State private var isFinalizingVotes: Bool = false
    @State private var showVotePointBadges: Bool = false
    /// Animated point totals next to avatars (`+N`); keyed by seat.
    @State private var votePointsDisplay: [Int: Int] = [:]
    @State private var votingSecondsLeft: Int = 0
    @State private var votingTimerGeneration: Int = 0
    @State private var answerPhaseSecondsLeft: Int = 0
    @State private var answerTimerGeneration: Int = 0
    /// When true, mock peers may not submit late answers for this round.
    @State private var isAnswerPhaseClosed: Bool = false
    @State private var resultsAreInOpacity: Double = 0
    /// Brief highlight on an answer row after the local player votes there.
    @State private var voteRowFlashSeat: Int? = nil

    /// Center card: slides from below, then zooms, then flips (back → empty front).
    @State private var centerCardOffsetY: CGFloat = 0
    @State private var centerCardOpacity: Double = 0
    /// Starts small on the table art, then animates to 1.0 (full `ResponsiveSize` card).
    private let centerCardTableScale: CGFloat = 0.26

    @State private var centerCardScale: CGFloat = 0.26
    /// 0 = back (“What would you do?”) facing player; 180 = prompt / answer side.
    @State private var cardFlipDegrees: Double = 0

    /// After flip + reading time: show only this player’s answer field (others invisible on this device).
    @State private var showAnswerComposer: Bool = false
    @State private var myAnswerDraft: String = ""

    /// Seats that have submitted this prompt (0 = simulated “you”). Cleared when everyone has submitted, before the card dismisses.
    @State private var submittedSeatIndices: Set<Int> = []
    @State private var isWindingDownRound: Bool = false

    @FocusState private var isAnswerFieldFocused: Bool

    /// Incremented on each Simulate tap so in-flight `Task` steps can bail if restarted.
    @State private var simulateSequenceVersion = 0

    private var wwydLocalWaitingForPeers: Bool {
        submittedSeatIndices.contains(simulatedLocalSeatIndex)
            && submittedSeatIndices.count < slots.count
            && !isWindingDownRound
    }

    /// Voting runs while the center card shows everyone’s answers (large reveal), not after.
    private var tableVotingActive: Bool {
        showVotingPhase && showEveryoneAnswers && !showVotePointBadges
    }

    /// Taller than classic play cards so prompt + composer breathe (width unchanged).
    private var wwydCardSize: CGSize {
        let extraHeight: CGFloat = ResponsiveSize.isPad ? 72 : 58
        return CGSize(
            width: ResponsiveSize.cardWidth,
            height: ResponsiveSize.cardHeight + extraHeight
        )
    }

    private var activeWwydCardSize: CGSize {
        wwydCardSize
    }

    /// Only seats that actually submitted a non-empty answer appear in the reveal / voting list.
    private var resultsAnswerRowsWithSeat: [(seat: Int, name: String, answer: String)] {
        slots.enumerated().compactMap { pair in
            let trimmed = roundCapturedAnswers[pair.offset]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !trimmed.isEmpty else { return nil }
            return (seat: pair.offset, name: pair.element.name, answer: trimmed)
        }
    }

    private var answerPhaseTimerVisible: Bool {
        (showAnswerComposer || wwydLocalWaitingForPeers) && !isWindingDownRound
    }

    private var wwydSortedCumulativeRows: [(seat: Int, name: String, points: Int)] {
        slots.enumerated()
            .map { (seat: $0.offset, name: $0.element.name, points: cumulativeVotePointsBySeat[$0.offset] ?? 0) }
            .sorted { lhs, rhs in
                if lhs.points != rhs.points { return lhs.points > rhs.points }
                return lhs.name < rhs.name
            }
    }

    private var wwydPreEndScoresSubtitle: String {
        guard let top = wwydSortedCumulativeRows.first else { return "" }
        let maxScore = top.points
        let leaders = wwydSortedCumulativeRows.filter { $0.points == maxScore }.map(\.name)
        if maxScore == 0 {
            return "No points this game — still a win for showing up."
        }
        if leaders.count == 1 {
            return "\(leaders[0]) finished with the most points."
        }
        return "\(leaders.joined(separator: ", ")) tied for the lead."
    }

    private var localVotesRemaining: Int {
        let used = votesFromSeat[simulatedLocalSeatIndex]?.count ?? 0
        return max(0, votesPerPlayer - used)
    }

    /// Live total points each seat has received from all voters (used in the voting table).
    private var aggregateVotePointsBySeat: [Int: Int] {
        var totals: [Int: Int] = [:]
        for idx in slots.indices {
            totals[idx] = 0
        }
        for (_, list) in votesFromSeat {
            for recipient in list {
                totals[recipient, default: 0] += pointsPerVote
            }
        }
        return totals
    }

    private func simulatedPeerAnswer(seat: Int, roundNumber: Int) -> String {
        let options = [
            "I'd stay calm and look for the least awkward way out.",
            "Honesty first — I'd speak up, but keep it kind.",
            "I'd wait a beat and see how the situation develops.",
            "Probably crack a joke, then decide what to actually do.",
            "I'd ask someone I trust before I commit to anything.",
            "Take the high road, even if it's not the easiest path.",
        ]
        let idx = (seat * 3 + roundNumber) % options.count
        return options[idx]
    }

    private var imageAspectRatio: CGFloat {
        guard let image = UIImage(named: "what would you do ui"),
              image.size.height > 0
        else {
            return 9.0 / 16.0
        }
        return image.size.width / image.size.height
    }

    /// Size of the image after aspect-fit inside the container (before table upscale).
    private func baseFittedImageSize(container: CGSize) -> CGSize {
        let cw = container.width
        let ch = container.height
        guard cw > 0, ch > 0 else { return .zero }
        let containerAspect = cw / ch
        if containerAspect > imageAspectRatio {
            let h = ch
            let w = h * imageAspectRatio
            return CGSize(width: w, height: h)
        } else {
            let w = cw
            let h = w / imageAspectRatio
            return CGSize(width: w, height: h)
        }
    }

    /// Fitted size with table slightly enlarged.
    private func scaledFittedSize(container: CGSize) -> CGSize {
        let base = baseFittedImageSize(container: container)
        return CGSize(width: base.width * tableScale, height: base.height * tableScale)
    }

    private func imageOrigin(container: CGSize, fitted: CGSize) -> CGPoint {
        CGPoint(
            x: (container.width - fitted.width) / 2,
            y: (container.height - fitted.height) / 2
        )
    }

    /// Height of the label stack under the avatar (names, voting hint, or +pts).
    private var stackedLabelHeight: CGFloat {
        if showVotePointBadges {
            return nameFontSize + 4 + 12
        }
        if tableVotingActive {
            return 6
        }
        return nameFontSize + 4
    }

    /// `.position` is the center of the view; offset so the **avatar** center sits on the grey dot.
    private var positionYAdjustment: CGFloat {
        let textBlockHeight = stackedLabelHeight
        let stackHeight = avatarDiameter + nameSpacing + textBlockHeight
        let stackCenterY = stackHeight / 2
        let avatarCenterY = avatarDiameter / 2
        return stackCenterY - avatarCenterY
    }

    private func runSimulateStart() {
        HapticManager.shared.mediumImpact()

        simulateSequenceVersion += 1
        let version = simulateSequenceVersion

        roundIntroOpacity = 0
        centerCardOpacity = 0
        centerCardOffsetY = 0
        centerCardScale = centerCardTableScale
        cardFlipDegrees = 0
        showAnswerComposer = false
        myAnswerDraft = ""
        isAnswerFieldFocused = false
        submittedSeatIndices = []
        isWindingDownRound = false
        votingIntroOpacity = 0
        showEveryoneAnswers = false
        resultsPromptSnapshot = ""
        roundCapturedAnswers = [:]
        showVotingPhase = false
        votesFromSeat = [:]
        isFinalizingVotes = false
        showVotePointBadges = false
        votePointsDisplay = [:]
        votingSecondsLeft = 0
        votingTimerGeneration += 1
        answerPhaseSecondsLeft = 0
        answerTimerGeneration += 1
        isAnswerPhaseClosed = false
        resultsAreInOpacity = 0
        voteRowFlashSeat = nil
        showPreEndScoresOverlay = false

        if currentRound == 1 {
            cumulativeVotePointsBySeat = [:]
        }

        if seatEntranceCompleted {
            entranceProgress = 1
        } else {
            entranceProgress = 0
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.88, dampingFraction: 0.74)) {
                    entranceProgress = 1
                }
            }
            seatEntranceCompleted = true
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_280_000_000)
            guard simulateSequenceVersion == version else { return }
            withAnimation(.easeOut(duration: 0.42)) {
                roundIntroOpacity = 1
            }

            try? await Task.sleep(nanoseconds: 1_350_000_000)
            guard simulateSequenceVersion == version else { return }
            withAnimation(.easeOut(duration: 0.48)) {
                roundIntroOpacity = 0
            }

            try? await Task.sleep(nanoseconds: 580_000_000)
            guard simulateSequenceVersion == version else { return }
            centerCardOffsetY = 340
            centerCardOpacity = 0
            centerCardScale = centerCardTableScale
            cardFlipDegrees = 0
            withAnimation(.spring(response: 0.62, dampingFraction: 0.82)) {
                centerCardOffsetY = 0
                centerCardOpacity = 1
            }
            HapticManager.shared.lightImpact()

            try? await Task.sleep(nanoseconds: 1_750_000_000)
            guard simulateSequenceVersion == version else { return }
            withAnimation(.easeInOut(duration: 0.58)) {
                centerCardScale = 1.0
            }

            try? await Task.sleep(nanoseconds: 1_150_000_000)
            guard simulateSequenceVersion == version else { return }
            withAnimation(.spring(response: 0.58, dampingFraction: 0.78)) {
                cardFlipDegrees = 180
            }
            HapticManager.shared.lightImpact()

            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard simulateSequenceVersion == version else { return }
            withAnimation(.easeOut(duration: 0.38)) {
                showAnswerComposer = true
            }
            startAnswerPhaseCountdown(sequenceVersion: version)
            startMockPeerSubmissions(sequenceVersion: version, roundNumber: currentRound)
        }
    }

    /// Staggered “other seats submitted” for the preview (same device).
    private func startMockPeerSubmissions(sequenceVersion version: Int, roundNumber: Int) {
        let peerSeats = slots.indices.filter { $0 != simulatedLocalSeatIndex }
        let delaysNs: [UInt64] = [950_000_000, 1_720_000_000, 2_480_000_000]
        for (i, seat) in peerSeats.enumerated() {
            let delay = i < delaysNs.count ? delaysNs[i] : 2_600_000_000
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: delay)
                guard simulateSequenceVersion == version else { return }
                guard cardFlipDegrees > 90 else { return }
                guard !isWindingDownRound else { return }
                guard !isAnswerPhaseClosed else { return }
                guard submittedSeatIndices.count < slots.count else { return }
                let peerAnswer = simulatedPeerAnswer(seat: seat, roundNumber: roundNumber)
                withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
                    submittedSeatIndices.insert(seat)
                    roundCapturedAnswers[seat] = peerAnswer
                }
                tryCompleteRoundIfNeeded(sequenceVersion: version)
            }
        }
    }

    private func tryCompleteRoundIfNeeded(sequenceVersion version: Int) {
        guard submittedSeatIndices.count == slots.count else { return }
        guard !isWindingDownRound else { return }
        beginAnswerToVotingTransition(sequenceVersion: version, promptSnapshot: promptForCurrentRound)
    }

    private func completeAnswerPhaseDueToTimer(sequenceVersion version: Int) {
        guard !isWindingDownRound else { return }
        guard showAnswerComposer || wwydLocalWaitingForPeers else { return }
        beginAnswerToVotingTransition(sequenceVersion: version, promptSnapshot: promptForCurrentRound)
    }

    private func startAnswerPhaseCountdown(sequenceVersion version: Int) {
        answerTimerGeneration += 1
        let gen = answerTimerGeneration
        answerPhaseSecondsLeft = timedPhaseSeconds
        Task { @MainActor in
            for _ in 0..<timedPhaseSeconds {
                try? await Task.sleep(1_000_000_000)
                guard simulateSequenceVersion == version, answerTimerGeneration == gen else { return }
                guard showAnswerComposer || wwydLocalWaitingForPeers else { return }
                guard !isWindingDownRound else { return }
                answerPhaseSecondsLeft -= 1
            }
            guard simulateSequenceVersion == version, answerTimerGeneration == gen else { return }
            guard !isWindingDownRound else { return }
            completeAnswerPhaseDueToTimer(sequenceVersion: version)
        }
    }

    private func beginAnswerToVotingTransition(sequenceVersion version: Int, promptSnapshot: String) {
        guard !isWindingDownRound else { return }

        let submittedSnapshot = submittedSeatIndices
        var pruned: [Int: String] = [:]
        for idx in submittedSnapshot {
            guard let raw = roundCapturedAnswers[idx]?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { continue }
            pruned[idx] = raw
        }
        roundCapturedAnswers = pruned

        answerTimerGeneration += 1
        isAnswerPhaseClosed = true
        isWindingDownRound = true

        withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
            submittedSeatIndices.removeAll()
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 480_000_000)
            guard simulateSequenceVersion == version else { return }

            isAnswerFieldFocused = false
            showAnswerComposer = false

            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                centerCardScale = centerCardTableScale
                cardFlipDegrees = 0
            }
            myAnswerDraft = ""

            try? await Task.sleep(nanoseconds: 550_000_000)
            guard simulateSequenceVersion == version else { return }
            isWindingDownRound = false

            resultsPromptSnapshot = promptSnapshot

            withAnimation(.easeOut(duration: 0.42)) {
                votingIntroOpacity = 1
            }

            try? await Task.sleep(nanoseconds: 2_100_000_000)
            guard simulateSequenceVersion == version else { return }
            withAnimation(.easeOut(duration: 0.48)) {
                votingIntroOpacity = 0
            }

            try? await Task.sleep(nanoseconds: 520_000_000)
            guard simulateSequenceVersion == version else { return }

            votesFromSeat = [:]
            isFinalizingVotes = false
            showVotePointBadges = false
            votePointsDisplay = [:]

            showEveryoneAnswers = true
            withAnimation(.easeInOut(duration: 0.55)) {
                centerCardScale = 1.0
            }
            withAnimation(.spring(response: 0.58, dampingFraction: 0.78)) {
                cardFlipDegrees = 180
            }
            HapticManager.shared.lightImpact()

            try? await Task.sleep(nanoseconds: 420_000_000)
            guard simulateSequenceVersion == version else { return }
            showVotingPhase = true
            startMockVoting(sequenceVersion: version)
            startVotingCountdown(sequenceVersion: version)
        }
    }

    private func mockRecipientForPeerVote(seat: Int, voteIndex: Int, eligibleRecipients: [Int]) -> Int {
        let others = eligibleRecipients.filter { $0 != seat }
        guard !others.isEmpty else { return seat }
        return others[(seat * 7 + voteIndex * 5) % others.count]
    }

    private func appendMockVote(seat: Int, voteIndex: Int, sequenceVersion version: Int, eligibleRecipients: [Int]) {
        guard simulateSequenceVersion == version else { return }
        guard showVotingPhase, showEveryoneAnswers, !isFinalizingVotes, !showVotePointBadges else { return }
        var list = votesFromSeat[seat] ?? []
        guard list.count < votesPerPlayer else { return }
        let recipient = mockRecipientForPeerVote(seat: seat, voteIndex: voteIndex, eligibleRecipients: eligibleRecipients)
        guard recipient != seat else { return }
        list.append(recipient)
        var next = votesFromSeat
        next[seat] = list
        withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
            votesFromSeat = next
        }
    }

    private func startMockVoting(sequenceVersion version: Int) {
        let eligibleRecipients = slots.indices.filter { idx in
            let t = roundCapturedAnswers[idx]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return !t.isEmpty
        }
        var delayNs: UInt64 = 500_000_000
        for seat in slots.indices where seat != simulatedLocalSeatIndex {
            for k in 0..<votesPerPlayer {
                let d = delayNs
                delayNs += 700_000_000
                let voteIdx = k
                let elig = eligibleRecipients
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: d)
                    appendMockVote(seat: seat, voteIndex: voteIdx, sequenceVersion: version, eligibleRecipients: elig)
                }
            }
        }
    }

    private func startVotingCountdown(sequenceVersion version: Int) {
        votingTimerGeneration += 1
        let gen = votingTimerGeneration
        votingSecondsLeft = timedPhaseSeconds
        Task { @MainActor in
            for _ in 0..<timedPhaseSeconds {
                try? await Task.sleep(1_000_000_000)
                guard simulateSequenceVersion == version, votingTimerGeneration == gen else { return }
                guard showVotingPhase, showEveryoneAnswers else { return }
                votingSecondsLeft -= 1
            }
            guard simulateSequenceVersion == version, votingTimerGeneration == gen else { return }
            finalizeVotingRound(sequenceVersion: version)
        }
    }

    private func tallyVotePoints() -> [Int: Int] {
        var totals: [Int: Int] = [:]
        for idx in slots.indices {
            totals[idx] = 0
        }
        for (_, recipients) in votesFromSeat {
            for r in recipients {
                totals[r, default: 0] += pointsPerVote
            }
        }
        return totals
    }

    private func finalizeVotingRound(sequenceVersion version: Int) {
        guard !isFinalizingVotes else { return }
        guard showVotingPhase, showEveryoneAnswers else { return }

        votingTimerGeneration += 1
        isFinalizingVotes = true
        showVotingPhase = false
        showEveryoneAnswers = false
        let totals = tallyVotePoints()
        for idx in slots.indices {
            cumulativeVotePointsBySeat[idx, default: 0] += totals[idx] ?? 0
        }

        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            centerCardScale = centerCardTableScale
            cardFlipDegrees = 0
        }
        HapticManager.shared.mediumImpact()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 520_000_000)
            guard simulateSequenceVersion == version else { return }

            withAnimation(.easeOut(duration: 0.42)) {
                resultsAreInOpacity = 1
            }

            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard simulateSequenceVersion == version else { return }
            withAnimation(.easeOut(duration: 0.48)) {
                resultsAreInOpacity = 0
            }

            try? await Task.sleep(nanoseconds: 480_000_000)
            guard simulateSequenceVersion == version else { return }

            votePointsDisplay = Dictionary(uniqueKeysWithValues: slots.indices.map { ($0, 0) })
            showVotePointBadges = true

            for index in slots.indices {
                let pts = totals[index] ?? 0
                try? await Task.sleep(nanoseconds: 95_000_000)
                guard simulateSequenceVersion == version else { return }
                withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                    votePointsDisplay[index] = pts
                }
            }

            try? await Task.sleep(nanoseconds: 720_000_000)
            guard simulateSequenceVersion == version else { return }
            if currentRound < totalRounds {
                currentRound += 1
            } else {
                let maxScore = cumulativeVotePointsBySeat.values.max() ?? 0
                endGameWinnerNames = slots.enumerated()
                    .filter { cumulativeVotePointsBySeat[$0.offset, default: 0] == maxScore }
                    .map { $0.element.name }
                endGameWinnerScore = maxScore
                showPreEndScoresOverlay = true
            }
            isFinalizingVotes = false
        }
    }

    private func localVoteForAnswerRow(recipientSeat: Int) {
        guard tableVotingActive, !isFinalizingVotes else { return }
        guard recipientSeat != simulatedLocalSeatIndex else { return }
        var list = votesFromSeat[simulatedLocalSeatIndex] ?? []
        guard list.count < votesPerPlayer else { return }
        list.append(recipientSeat)
        var next = votesFromSeat
        next[simulatedLocalSeatIndex] = list
        withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
            votesFromSeat = next
        }
        HapticManager.shared.lightImpact()
        voteRowFlashSeat = recipientSeat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            if voteRowFlashSeat == recipientSeat {
                voteRowFlashSeat = nil
            }
        }
    }

    private func submitMyAnswer() {
        let trimmed = myAnswerDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        HapticManager.shared.mediumImpact()
        isAnswerFieldFocused = false
        roundCapturedAnswers[simulatedLocalSeatIndex] = trimmed
        myAnswerDraft = ""

        withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
            submittedSeatIndices.insert(simulatedLocalSeatIndex)
        }
        withAnimation(.easeOut(duration: 0.28)) {
            showAnswerComposer = false
        }

        tryCompleteRoundIfNeeded(sequenceVersion: simulateSequenceVersion)
    }

    /// Per-player progress with a short stagger so seats fill in order.
    private func seatProgress(forIndex index: Int) -> CGFloat {
        let stagger: CGFloat = 0.09
        let span = 1 - stagger * CGFloat(slots.count - 1)
        let t = (entranceProgress - CGFloat(index) * stagger) / span
        return min(1, max(0, t))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geo in
                let container = geo.size
                let fitted = scaledFittedSize(container: container)
                let origin = imageOrigin(container: container, fitted: fitted)
                let cx = container.width / 2
                let cy = container.height / 2
                let startX = cx
                let startY = cy + positionYAdjustment
                let cardSize = activeWwydCardSize

                ZStack {
                    Color.appBackground
                        .ignoresSafeArea()

                    Image("what would you do ui")
                        .resizable()
                        .scaledToFit()
                        .frame(width: fitted.width, height: fitted.height)
                        .position(x: container.width / 2, y: container.height / 2)

                    ForEach(Array(slots.enumerated()), id: \.offset) { index, slot in
                        let dotX = origin.x + slot.normX * fitted.width
                        let dotY = origin.y + slot.normY * fitted.height
                        let endX = dotX
                        let endY = dotY + positionYAdjustment
                        let p = seatProgress(forIndex: index)
                        let x = startX + (endX - startX) * p
                        let y = startY + (endY - startY) * p
                        let pts = votePointsDisplay[index] ?? 0

                        VStack(spacing: nameSpacing) {
                            ZStack(alignment: .bottomTrailing) {
                                AvatarView(
                                    avatarType: slot.avatarType,
                                    avatarColor: slot.avatarColor,
                                    size: avatarDiameter
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            index == simulatedLocalSeatIndex && tableVotingActive
                                                ? Color.primaryAccent.opacity(0.55)
                                                : Color.clear,
                                            lineWidth: 2.5
                                        )
                                        .padding(-2)
                                )

                                if submittedSeatIndices.contains(index) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: max(12, avatarDiameter * 0.26), weight: .regular))
                                        .foregroundColor(.green)
                                        .background(Color.white.clipShape(Circle()))
                                        .offset(x: avatarDiameter * 0.12, y: avatarDiameter * 0.12)
                                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                                }
                            }
                            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: Array(submittedSeatIndices).sorted())

                            if tableVotingActive {
                                Color.clear.frame(height: 2)
                            } else {
                                Text(slot.name)
                                    .font(.system(size: nameFontSize, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)
                                    .shadow(color: .white.opacity(0.6), radius: 0, x: 0, y: 0.5)

                                if showVotePointBadges && pts > 0 {
                                    Text("+\(pts)")
                                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                                        .foregroundColor(.green)
                                        .shadow(color: .white.opacity(0.5), radius: 0, x: 0, y: 0.5)
                                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                                }
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.72), value: votePointsDisplay[index])
                        .scaleEffect(0.25 + 0.75 * p)
                        .opacity(Double(0.2 + 0.8 * p))
                        .position(x: x, y: y)
                    }

                    wwydFlippableTableCard(size: cardSize)
                        .position(x: cx, y: cy + centerCardOffsetY)
                        .opacity(centerCardOpacity)
                }
            }

            if simulateSequenceVersion > 0 {
                Text("Round \(currentRound) of \(totalRounds)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText.opacity(0.92))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.primaryText.opacity(0.08), lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, (tableVotingActive || answerPhaseTimerVisible) ? 102 : 56)
                    .allowsHitTesting(false)
            }

            roundIntroFullScreen
            votingTimeFullScreen
            resultsAreInFullScreen

            if tableVotingActive {
                HStack(spacing: 14) {
                    Text(String(format: "%02d", votingSecondsLeft))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(
                            votingSecondsLeft <= 10
                                ? Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0)
                                : Color.primaryText.opacity(0.85)
                        )
                    Text("·")
                        .font(.system(size: 13, weight: .light, design: .rounded))
                        .foregroundColor(Color.primaryText.opacity(0.35))
                    Text("\(localVotesRemaining) left")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.primaryText.opacity(0.55))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.primaryText.opacity(0.08), lineWidth: 1)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 52)
                .allowsHitTesting(false)
            } else if answerPhaseTimerVisible {
                HStack(spacing: 14) {
                    Text(String(format: "%02d", answerPhaseSecondsLeft))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(
                            answerPhaseSecondsLeft <= 10
                                ? Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0)
                                : Color.primaryText.opacity(0.85)
                        )
                    Text("·")
                        .font(.system(size: 13, weight: .light, design: .rounded))
                        .foregroundColor(Color.primaryText.opacity(0.35))
                    Text("to submit")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.primaryText.opacity(0.55))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.primaryText.opacity(0.08), lineWidth: 1)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 52)
                .allowsHitTesting(false)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if !showPreEndScoresOverlay {
                        Button(action: runSimulateStart) {
                            Text("Simulate")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 12)
                                .background(Color.buttonBackground)
                                .cornerRadius(14)
                                .shadow(color: Color.shadowColor.opacity(0.35), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 20)
                        .padding(.bottom, 24)
                    }
                }
            }

            if showPreEndScoresOverlay {
                wwydPreEndScoresOverlay
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("What Would You Do")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(
                destination: WhatWouldYouDoEndView(
                    winnerNames: endGameWinnerNames,
                    winnerScore: endGameWinnerScore,
                    totalRounds: totalRounds
                ),
                isActive: $navigateToGameEnd
            ) {
                EmptyView()
            }
        )
    }

    private var wwydPreEndScoresOverlay: some View {
        let trophyGreen = Color(red: 0x34 / 255.0, green: 0xC7 / 255.0, blue: 0x59 / 255.0)
        let rows = wwydSortedCumulativeRows
        let maxPts = rows.first?.points ?? 0

        return ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(trophyGreen.opacity(0.1))
                            .frame(width: 150, height: 150)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(trophyGreen)
                    }

                    Text("Top scores")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)

                    Text(wwydPreEndScoresSubtitle)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                .padding(.bottom, 20)

                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.seat) { rank, row in
                        let isLeader = row.points == maxPts && maxPts > 0
                        HStack {
                            Text("\(rank + 1).")
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundColor(.secondaryText)
                                .frame(width: 28, alignment: .leading)

                            Text(row.name)
                                .font(.system(size: 17, weight: isLeader ? .bold : .semibold, design: .rounded))
                                .foregroundColor(.primaryText)

                            Spacer()

                            Text("\(row.points) pts")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(isLeader ? trophyGreen : .primaryText)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)

                        if rank < rows.count - 1 {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color.secondaryBackground)
                .cornerRadius(20)
                .padding(.horizontal, 24)

                Spacer()

                PrimaryButton(title: "Continue") {
                    HapticManager.shared.mediumImpact()
                    showPreEndScoresOverlay = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        navigateToGameEnd = true
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }

    private var roundIntroFullScreen: some View {
        ZStack {
            Color.black.opacity(0.68)
            Text("Round \(currentRound) of \(totalRounds)")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .padding(.horizontal, 24)
        }
        .ignoresSafeArea()
        .opacity(roundIntroOpacity)
        .allowsHitTesting(roundIntroOpacity > 0.5)
    }

    private var votingTimeFullScreen: some View {
        ZStack {
            Color.black.opacity(0.68)
            Text("Voting time")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .padding(.horizontal, 24)
        }
        .ignoresSafeArea()
        .opacity(votingIntroOpacity)
        .allowsHitTesting(votingIntroOpacity > 0.5)
    }

    private var resultsAreInFullScreen: some View {
        ZStack {
            Color.black.opacity(0.68)
            Text("Results are in")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .padding(.horizontal, 24)
        }
        .ignoresSafeArea()
        .opacity(resultsAreInOpacity)
        .allowsHitTesting(resultsAreInOpacity > 0.5)
    }

    /// Vertical card: back = title; front = shared prompt + local-only answer; scale + Y-flip (same pattern as `WYRPlayView`).
    private func wwydFlippableTableCard(size: CGSize) -> some View {
        let corner = min(58, max(36, size.width * 0.19))
        let brandRed = Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0)

        return ZStack {
            wwydCardBackFace(size: size, corner: corner, brandRed: brandRed)
                .opacity(cardFlipDegrees < 90 ? 1 : 0)

            wwydCardFrontFace(
                size: size,
                corner: corner,
                brandRed: brandRed,
                prompt: promptForCurrentRound,
                resultsPrompt: resultsPromptSnapshot,
                resultsRows: resultsAnswerRowsWithSeat,
                votesPerPlayerCaption: votesPerPlayer,
                showEveryoneAnswers: showEveryoneAnswers,
                showAnswerComposer: showAnswerComposer,
                localWaitingForPeers: wwydLocalWaitingForPeers,
                answerText: $myAnswerDraft,
                focusBinding: $isAnswerFieldFocused,
                onSubmit: submitMyAnswer,
                voteRowsActive: tableVotingActive,
                localSeatIndexForVoting: simulatedLocalSeatIndex,
                localVotesLeftForVoting: localVotesRemaining,
                aggregateVotePointsBySeat: aggregateVotePointsBySeat,
                voteFlashSeat: voteRowFlashSeat,
                onVoteAnswerRow: localVoteForAnswerRow
            )
                .opacity(cardFlipDegrees >= 90 ? 1 : 0)
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .center,
                    anchorZ: 0,
                    perspective: 0.5
                )
        }
        .frame(width: size.width, height: size.height)
        .rotation3DEffect(
            .degrees(cardFlipDegrees),
            axis: (x: 0, y: 1, z: 0),
            anchor: .center,
            anchorZ: 0,
            perspective: 0.5
        )
        .scaleEffect(centerCardScale)
    }

    private func wwydCardBackFace(size: CGSize, corner: CGFloat, brandRed: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color.white)
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(brandRed.opacity(0.45), lineWidth: 3)

            Text("What would you do?")
                .font(.system(size: min(22, size.width * 0.072), weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 14)
                .frame(width: size.width, height: size.height)
        }
        .frame(width: size.width, height: size.height)
        .shadow(color: Color.cardShadowColor, radius: 12, x: 0, y: 6)
    }

    private func wwydCardFrontFace(
        size: CGSize,
        corner: CGFloat,
        brandRed: Color,
        prompt: String,
        resultsPrompt: String,
        resultsRows: [(seat: Int, name: String, answer: String)],
        votesPerPlayerCaption: Int,
        showEveryoneAnswers: Bool,
        showAnswerComposer: Bool,
        localWaitingForPeers: Bool,
        answerText: Binding<String>,
        focusBinding: FocusState<Bool>.Binding,
        onSubmit: @escaping () -> Void,
        voteRowsActive: Bool,
        localSeatIndexForVoting: Int,
        localVotesLeftForVoting: Int,
        aggregateVotePointsBySeat: [Int: Int],
        voteFlashSeat: Int?,
        onVoteAnswerRow: @escaping (Int) -> Void
    ) -> some View {
        let canSubmit = !answerText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let promptFont = min(19, size.width * 0.054)

        let promptBlock = Text(prompt)
            .font(.system(size: promptFont, weight: .bold, design: .rounded))
            .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
            .multilineTextAlignment(.center)
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: size.width - 32)
            .padding(.horizontal, 6)

        return ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color.cardBackground)
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(brandRed.opacity(0.35), lineWidth: 2.5)

            Group {
                if showEveryoneAnswers {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: voteRowsActive ? 12 : 16) {
                            if voteRowsActive {
                                VStack(spacing: 6) {
                                    Text("Click to vote")
                                        .font(.system(size: min(24, size.width * 0.07), weight: .heavy, design: .rounded))
                                        .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                                        .frame(maxWidth: .infinity, alignment: .center)

                                    Text("You have a total of \(votesPerPlayerCaption) votes.")
                                        .font(.system(size: min(13, size.width * 0.038), weight: .medium, design: .rounded))
                                        .foregroundColor(Color.primaryText.opacity(0.42))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, alignment: .center)

                                    Text(resultsPrompt)
                                        .font(.system(size: min(12, size.width * 0.036), weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .lineSpacing(4)
                                        .padding(.horizontal, 4)
                                }
                                .padding(.top, 6)
                                .padding(.bottom, 8)
                            }

                            if !voteRowsActive {
                                Text(resultsPrompt)
                                    .font(.system(size: min(13, size.width * 0.04), weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 6)
                                    .padding(.bottom, 4)
                            }

                            VStack(alignment: .leading, spacing: voteRowsActive ? 10 : 14) {
                                ForEach(resultsRows, id: \.seat) { row in
                                    let isOwnAnswerRow = row.seat == localSeatIndexForVoting
                                    let rowTappable = voteRowsActive && !isOwnAnswerRow && localVotesLeftForVoting > 0
                                    let pointsReceived = aggregateVotePointsBySeat[row.seat] ?? 0
                                    let hasVotes = pointsReceived > 0
                                    let isFlashing = voteFlashSeat == row.seat
                                    let cornerR: CGFloat = (voteRowsActive && isOwnAnswerRow) ? 12 : 16

                                    HStack(alignment: .top, spacing: 10) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            if !voteRowsActive {
                                                Text(row.name)
                                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                                    .foregroundColor(Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0))
                                            }

                                            Text(row.answer)
                                                .font(
                                                    .system(
                                                        size: (voteRowsActive && isOwnAnswerRow) ? 13 : 15,
                                                        weight: .regular,
                                                        design: .rounded
                                                    )
                                                )
                                                .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineSpacing((voteRowsActive && isOwnAnswerRow) ? 3 : 4)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                        if voteRowsActive {
                                            ZStack(alignment: .topTrailing) {
                                                if hasVotes {
                                                    Text("+\(pointsReceived)")
                                                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                                                        .foregroundColor(.green)
                                                        .padding(.top, 2)
                                                        .animation(.easeOut(duration: 0.2), value: pointsReceived)
                                                }
                                            }
                                            .frame(width: 52, alignment: .trailing)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, (voteRowsActive && isOwnAnswerRow) ? 11 : 15)
                                    .padding(.vertical, (voteRowsActive && isOwnAnswerRow) ? 9 : 15)
                                    .background(
                                        (isOwnAnswerRow && voteRowsActive)
                                            ? Color.gray.opacity(0.2)
                                            : Color(red: 0xF8 / 255.0, green: 0xF8 / 255.0, blue: 0xF8 / 255.0)
                                    )
                                    .cornerRadius(cornerR)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: cornerR, style: .continuous)
                                            .stroke(
                                                isFlashing
                                                    ? Color.green.opacity(0.85)
                                                    : rowTappable
                                                        ? Color.primaryAccent.opacity(0.28)
                                                        : hasVotes
                                                            ? Color.green.opacity(0.4)
                                                            : Color.clear,
                                                lineWidth: isFlashing ? 2.5 : 1.5
                                            )
                                    )
                                    .shadow(
                                        color: Color.green.opacity(isFlashing ? 0.35 : 0),
                                        radius: isFlashing ? 10 : 0,
                                        x: 0,
                                        y: 0
                                    )
                                    .opacity(isOwnAnswerRow && voteRowsActive ? 0.52 : 1)
                                    .scaleEffect(isFlashing ? 1.02 : 1)
                                    .animation(.spring(response: 0.38, dampingFraction: 0.68), value: isFlashing)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if rowTappable {
                                            onVoteAnswerRow(row.seat)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, voteRowsActive ? 34 : 16)
                        .padding(.bottom, voteRowsActive ? 16 : 16)
                    }
                    .frame(width: size.width, height: size.height)
                } else if showAnswerComposer {
                    VStack(spacing: 0) {
                        Spacer(minLength: 14)
                        promptBlock
                        Spacer(minLength: 18)
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("Type your answer…", text: answerText, axis: .vertical)
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .lineLimit(3...6)
                                .padding(14)
                                .background(Color(red: 0xF5 / 255.0, green: 0xF5 / 255.0, blue: 0xF5 / 255.0))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                )
                                .focused(focusBinding)

                            Text("Only you see what you type.")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary.opacity(0.9))

                            Button(action: onSubmit) {
                                Text("Submit")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(canSubmit ? Color.buttonBackground : Color.gray.opacity(0.45))
                                    .cornerRadius(16)
                            }
                            .buttonStyle(.plain)
                            .disabled(!canSubmit)
                        }
                        .padding(.horizontal, 16)
                        Spacer(minLength: 16)
                    }
                    .frame(width: size.width, height: size.height)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else if localWaitingForPeers {
                    VStack(spacing: 0) {
                        Spacer()
                        promptBlock
                        Spacer(minLength: 16)
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 28, weight: .regular))
                                .foregroundColor(.green)
                            Text("Answer sent")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                            Text("Waiting for other players…")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)
                        Spacer()
                    }
                    .frame(width: size.width, height: size.height)
                } else {
                    VStack(spacing: 0) {
                        Spacer()
                        promptBlock
                        Spacer()
                    }
                    .frame(width: size.width, height: size.height)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .shadow(color: Color.cardShadowColor, radius: 12, x: 0, y: 6)
        .animation(.easeInOut(duration: 0.32), value: showAnswerComposer)
        .animation(.easeInOut(duration: 0.28), value: localWaitingForPeers)
        .animation(.easeInOut(duration: 0.35), value: showEveryoneAnswers)
    }
}

#Preview {
    NavigationStack {
        WhatWouldYouDoView()
    }
}
