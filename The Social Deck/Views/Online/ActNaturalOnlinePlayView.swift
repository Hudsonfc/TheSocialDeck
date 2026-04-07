//
//  ActNaturalOnlinePlayView.swift
//  The Social Deck
//
//  Online Act Natural: each player flips their own card; strip shows checkmarks (Riddle-style);
//  host proceeds to discussion, then reveal, then end.
//

import SwiftUI

struct ActNaturalOnlinePlayView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    /// Lobby choice — same for all clients once loaded from room.
    let twoUnknownsFromLobby: Bool
    /// From lobby `cardCount` (same field as other games’ round counts).
    let totalRounds: Int

    @StateObject private var sync = ActNaturalOnlineSyncService.shared

    @State private var hasHostInitialized = false
    @State private var cardRotation: Double = 0
    @State private var hasFlippedOnce = false
    @State private var didSubmitFlip = false
    @State private var showHostEndedGameAlert = false
    @State private var hasHandledActNaturalSessionEnd = false
    @State private var showOnlineGuestLeave = false
    @State private var showOnlineHostEveryone = false
    @State private var showOnlineHostMulti = false

    private var phaseTransitionId: String {
        "\(sync.phase)-\(sync.rolesRevealed)-\(sync.roundIndex)"
    }

    private var effectiveTotalRounds: Int {
        max(1, totalRounds)
    }

    private var secretWord: ActNaturalWord {
        actNaturalSecretWord(roomCode: roomCode, roundIndex: sync.roundIndex)
    }

    private var sortedPlayerIds: [String] {
        players.map(\.id).sorted()
    }

    private var unknownIds: Set<String> {
        actNaturalUnknownUserIds(
            roomCode: roomCode,
            sortedPlayerIds: sortedPlayerIds,
            twoUnknownsFromLobby: twoUnknownsFromLobby,
            roundIndex: sync.roundIndex
        )
    }

    /// After this round’s truth is shown, host can start another round if any remain.
    private var hasAnotherRound: Bool {
        sync.roundIndex + 1 < effectiveTotalRounds
    }

    private var myUnknown: Bool {
        guard let uid = currentUserId else { return false }
        return unknownIds.contains(uid)
    }

    private var allFlipped: Bool {
        players.allSatisfy { sync.flipped[$0.id] == true }
    }

    private var unknownPlayers: [RoomPlayer] {
        players.filter { unknownIds.contains($0.id) }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                if !players.isEmpty && sync.phase == "reveal" {
                    ActNaturalOnlinePlayerStripView(
                        players: players,
                        currentUserId: currentUserId,
                        flipped: sync.flipped,
                        phase: sync.phase
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }

                Group {
                    switch sync.phase {
                    case "discussion":
                        if sync.rolesRevealed {
                            rolesRevealContent
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                                    removal: .opacity.combined(with: .move(edge: .leading))
                                ))
                        } else {
                            discussionContent
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .leading)),
                                    removal: .opacity.combined(with: .move(edge: .trailing))
                                ))
                        }
                    case "ended":
                        Color.clear
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    default:
                        revealPhaseContent
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.98)),
                                removal: .opacity
                            ))
                    }
                }
                .animation(.spring(response: 0.45, dampingFraction: 0.88), value: phaseTransitionId)
            }

            OnlineGameExitAlertsView(
                guestLeave: $showOnlineGuestLeave,
                hostEveryone: $showOnlineHostEveryone,
                hostMulti: $showOnlineHostMulti
            )
        }
        .navigationBarHidden(true)
        .alert("The host ended the game", isPresented: $showHostEndedGameAlert) {
            Button("OK") {
                hasHandledActNaturalSessionEnd = true
                Task { await exitActNaturalAfterHostEndedGame() }
            }
        } message: {
            Text("The host ended this Act Natural session. Tap OK to leave the room. You will return to the previous screen.")
        }
        .onAppear {
            hasHandledActNaturalSessionEnd = false
            showHostEndedGameAlert = false
            sync.resetLocalState()
            sync.startListening(roomId: roomCode)
            if isHost && !hasHostInitialized {
                hasHostInitialized = true
                Task { try? await sync.initGameState(roomId: roomCode) }
            }
        }
        .onDisappear {
            showHostEndedGameAlert = false
            sync.teardownSession()
        }
        .onChange(of: sync.phase) { _, phase in
            guard phase == "ended", !isHost else { return }
            if !showHostEndedGameAlert && !hasHandledActNaturalSessionEnd {
                showHostEndedGameAlert = true
            }
        }
        .onChange(of: sync.roundIndex) { _, _ in
            resetLocalRoundUI()
        }
        .onChange(of: sync.flipped) { _, _ in
            syncLocalFlipStateWithServer()
        }
    }

    /// Host ended the game (or guest confirmed alert): leave room and pop game UI without the old end-screen `NavigationLink`.
    @MainActor
    private func exitActNaturalAfterHostEndedGame() async {
        ActNaturalOnlineSyncService.shared.teardownSession()
        NotificationCenter.default.post(name: .onlineDismissGameContainerAfterActNaturalEnd, object: nil)
        await OnlineManager.shared.leaveRoom()
    }

    private func resetLocalRoundUI() {
        cardRotation = 0
        hasFlippedOnce = false
        didSubmitFlip = false
    }

    private func syncLocalFlipStateWithServer() {
        guard let uid = currentUserId else { return }
        if sync.flipped[uid] == true, !hasFlippedOnce {
            hasFlippedOnce = true
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                cardRotation = 180
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button {
                if isHost {
                    if players.count > 2 {
                        showOnlineHostMulti = true
                    } else {
                        showOnlineHostEveryone = true
                    }
                } else {
                    showOnlineGuestLeave = true
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryText)
                    .frame(width: 44, height: 44)
                    .background(Color.tertiaryBackground)
                    .clipShape(Circle())
            }

            Spacer()

            Text(topBarTitle)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primaryText)
        }
        .responsiveHorizontalPadding()
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private var topBarTitle: String {
        let r = sync.roundIndex + 1
        let t = effectiveTotalRounds
        switch sync.phase {
        case "discussion":
            return sync.rolesRevealed ? "Round \(r)/\(t) · The truth" : "Round \(r)/\(t) · Discussion"
        case "revealed": return "Round \(r)/\(t) · The truth"
        case "ended": return "Finished"
        default: return "Round \(r)/\(t)"
        }
    }

    // MARK: - Reveal phase

    private var revealPhaseContent: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Tap your card to see your role")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)

            ZStack {
                ActNaturalCardFrontView()
                    .opacity(cardRotation < 90 ? 1 : 0)

                ActNaturalCardBackView(
                    player: ActNaturalPlayer(name: "", isUnknown: myUnknown, hasViewed: true),
                    secretWord: secretWord.word
                )
                .opacity(cardRotation >= 90 ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(width: ResponsiveSize.cardWidth, height: ResponsiveSize.cardHeight)
            .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .onTapGesture {
                toggleMyCard()
            }

            Spacer()

            if let uid = currentUserId, sync.flipped[uid] == true {
                if isHost {
                    if allFlipped {
                        PrimaryButton(title: "Proceed to discussion") {
                            HapticManager.shared.mediumImpact()
                            Task { try? await sync.hostProceedToDiscussion(roomId: roomCode) }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else {
                        Text("Waiting for everyone to flip…")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                    }
                } else {
                    Text(allFlipped ? "Waiting for host to continue…" : "Waiting for other players to flip…")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                }
            }
        }
    }

    private func toggleMyCard() {
        guard let uid = currentUserId else { return }
        if sync.flipped[uid] == true || hasFlippedOnce { return }

        HapticManager.shared.lightImpact()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            cardRotation = 180
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            hasFlippedOnce = true
            if !didSubmitFlip {
                didSubmitFlip = true
                Task { try? await sync.markPlayerFlipped(roomId: roomCode, uid: uid) }
            }
        }
    }

    // MARK: - Discussion

    private var discussionContent: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                if sync.timerEnabled {
                    TimelineView(.periodic(from: .now, by: 0.25)) { context in
                        discussionTimerView(at: context.date)
                    }
                }

                ZStack {
                    Circle()
                        .fill(Color.buttonBackground.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(Color.buttonBackground)
                }

                VStack(spacing: 16) {
                    Text("Discussion Time!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)

                    Text("Talk about the word without saying it directly. Unknown players try to blend in!")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }

                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.buttonBackground)

                    Text("\(unknownIds.count) unknown player\(unknownIds.count == 1 ? "" : "s") among \(players.count) players")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
            }

            Spacer()

            if isHost {
                PrimaryButton(title: "Reveal the Truth") {
                    HapticManager.shared.mediumImpact()
                    Task { try? await sync.hostRevealRoles(roomId: roomCode) }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            } else {
                Text("Waiting for host to reveal…")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .padding(.bottom, 40)
            }
        }
    }

    @ViewBuilder
    private func discussionTimerView(at date: Date) -> some View {
        let duration = max(sync.timerDuration, 1)
        let remaining: Int = {
            if let start = sync.roundStartTimestamp {
                let elapsed = Int(date.timeIntervalSince(start))
                return max(0, sync.timerDuration - elapsed)
            }
            return sync.timerDuration
        }()

        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.tertiaryBackground, lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(remaining) / CGFloat(duration))
                    .stroke(
                        remaining < 60 ? Color.red : Color.buttonBackground,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                Text(formatDiscussionTime(remaining))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(remaining < 60 ? Color.red : Color.primaryText)
            }
        }
    }

    private func formatDiscussionTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - Roles revealed

    private var rolesRevealContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("The Secret Word")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                        .tracking(1)

                    Text(secretWord.word)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)

                    Text(secretWord.category)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.buttonBackground))
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.secondaryBackground)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 24)

                VStack(spacing: 16) {
                    Text("The Unknown\(unknownPlayers.count == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                        .tracking(1)

                    VStack(spacing: 12) {
                        ForEach(unknownPlayers) { player in
                            HStack(spacing: 12) {
                                AvatarView(
                                    avatarType: player.avatarType,
                                    avatarColor: player.avatarColor,
                                    size: 44
                                )

                                Text(player.username + (player.id == currentUserId ? " (You)" : ""))
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryText)

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.secondaryBackground)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 24)

                if isHost {
                    VStack(spacing: 12) {
                        if hasAnotherRound {
                            PrimaryButton(title: "Next Round") {
                                HapticManager.shared.mediumImpact()
                                let next = sync.roundIndex + 1
                                Task { try? await sync.hostAdvanceToNextRound(roomId: roomCode, nextRoundIndex: next) }
                            }
                        }
                        Button {
                            HapticManager.shared.mediumImpact()
                            Task {
                                do {
                                    try await sync.hostFinishGame(roomId: roomCode)
                                } catch {
                                    return
                                }
                                await MainActor.run { hasHandledActNaturalSessionEnd = true }
                                await exitActNaturalAfterHostEndedGame()
                            }
                        } label: {
                            Text(hasAnotherRound ? "End Game" : "Finish")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(hasAnotherRound ? .primaryAccent : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(hasAnotherRound ? Color.appBackground : Color.buttonBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(hasAnotherRound ? Color.primaryAccent : Color.clear, lineWidth: 2)
                                )
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                } else {
                    Text(hasAnotherRound ? "Waiting for host…" : "Waiting for host to finish…")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .padding(.bottom, 40)
                }
            }
            .padding(.top, 24)
        }
    }
}

// MARK: - Player strip (Riddle-style checkmarks when flipped)

struct ActNaturalOnlinePlayerStripView: View {
    let players: [RoomPlayer]
    let currentUserId: String?
    let flipped: [String: Bool]
    let phase: String
    var compactStrip: Bool = false

    private let soDeckRed = Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0)

    private var avatarSize: CGFloat { compactStrip ? 34 : 40 }
    private var stripHeight: CGFloat { compactStrip ? 68 : 86 }
    private var chipSpacing: CGFloat { compactStrip ? 6 : 10 }
    private var hostRingWidth: CGFloat { compactStrip ? 2 : 3 }
    /// Fixed column width so every chip has the same hit box regardless of name length.
    private var chipColumnWidth: CGFloat { compactStrip ? 64 : 72 }

    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: chipSpacing) {
                    ForEach(players) { player in
                        playerChip(player)
                    }
                }
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
        let didFlip = flipped[player.id] == true

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

                if phase == "reveal" && didFlip {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: compactStrip ? 11 : 14))
                        .foregroundColor(.green)
                        .background(Color.white.clipShape(Circle()))
                        .offset(x: compactStrip ? 3 : 4, y: compactStrip ? 3 : 4)
                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                } else if phase == "reveal" && player.isHost {
                    Image(systemName: "crown.fill")
                        .font(.system(size: compactStrip ? 8 : 10))
                        .foregroundColor(.white)
                        .padding(compactStrip ? 1 : 2)
                        .background(soDeckRed)
                        .clipShape(Circle())
                        .offset(x: compactStrip ? 3 : 4, y: compactStrip ? 3 : 4)
                }
            }
            .frame(width: chipColumnWidth, alignment: .center)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: didFlip)

            Text(isYou ? "You" : player.username)
                .font(.system(size: compactStrip ? 9 : 10, weight: .semibold, design: .rounded))
                .foregroundColor(isYou ? .primaryText : .secondaryText)
                .lineLimit(1)
                .frame(width: chipColumnWidth, alignment: .center)
                .minimumScaleFactor(0.85)
        }
        .frame(width: chipColumnWidth + (compactStrip ? 12 : 16), alignment: .center)
        .padding(.horizontal, compactStrip ? 6 : 8)
        .padding(.vertical, compactStrip ? 3 : 4)
        .background(Color.appBackground.opacity(0.5))
        .cornerRadius(compactStrip ? 8 : 10)
    }
}
