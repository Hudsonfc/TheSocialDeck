//
//  LobbyView.swift
//  The Social Deck
//

import SwiftUI

struct LobbyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var subManager = SubscriptionManager.shared

    @State private var showLeaveAlert = false
    @State private var showShareSheet = false
    @State private var showInviteFriends = false
    @State private var showKickAlert = false
    @State private var playerToKick: RoomPlayer? = nil
    @State private var showCategorySelector = false
    @State private var copiedCode = false
    @State private var isLeaving = false
    @State private var navigateToGame = false

    private let soDeckRed = Color.primaryAccent

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            // Hidden NavigationLink that fires when game starts
            NavigationLink(
                destination: OnlineGameContainerView(),
                isActive: $navigateToGame
            ) { EmptyView() }
            .hidden()

            if onlineManager.currentRoom == nil && !isLeaving {
                roomGoneView
            } else {
                mainContent
                    .opacity(isLeaving ? 0.3 : 1)
                    .blur(radius: isLeaving ? 3 : 0)

                if isLeaving {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)
                            .tint(soDeckRed)
                        Text("Leaving room…")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isLeaving)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    HapticManager.shared.lightImpact()
                    showLeaveAlert = true
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    HapticManager.shared.lightImpact()
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(soDeckRed)
                }
            }
        }
        // Leave confirmation
        .alert("Leave Room", isPresented: $showLeaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Leave", role: .destructive) { doLeave() }
        } message: {
            Text(onlineManager.isHost
                 ? "You are the host. Leaving will transfer host to another player."
                 : "Are you sure you want to leave?")
        }
        // Kick confirmation
        .alert("Remove Player", isPresented: $showKickAlert) {
            Button("Cancel", role: .cancel) { playerToKick = nil }
            Button("Remove", role: .destructive) {
                if let p = playerToKick {
                    Task { try? await onlineManager.kickPlayer(p.id) }
                }
                playerToKick = nil
            }
        } message: {
            if let p = playerToKick {
                Text("Remove \(p.username) from the room?")
            }
        }
        // Share sheet
        .sheet(isPresented: $showShareSheet) {
            if let room = onlineManager.currentRoom {
                ShareSheet(activityItems: [
                    "Hey! Join my game on The Social Deck \u{1F0CF}\nRoom code: \(room.roomCode)\nDownload the app: https://apps.apple.com/app/the-social-deck/id6740043553"
                ])
            }
        }
        // Invite friends sheet
        .sheet(isPresented: $showInviteFriends) {
            if let room = onlineManager.currentRoom {
                InviteFriendsSheet(room: room)
            }
        }
        .sheet(isPresented: $showCategorySelector) {
            LobbyCategorySelectionSheet(
                title: "Select Categories",
                categories: lobbyCategoriesForSelectedGame,
                plusLockedCategories: plusLockedCategoriesForSelectedGame,
                selectedCategories: onlineManager.currentRoom?.classicSelectedCategories ?? []
            ) { updated in
                Task { await onlineManager.updateClassicSelectedCategories(updated) }
            }
            .environmentObject(SubscriptionManager.shared)
        }
        // Push game when in session; clear when back to lobby (so NavigationLink does not re-open after dismiss).
        .onAppear {
            navigateToGame = (onlineManager.currentRoom?.status == .inGame)
        }
        .onChange(of: onlineManager.currentRoom?.status) { _, newStatus in
            navigateToGame = (newStatus == .inGame)
        }
        // Watch for room deletion / being kicked
        .onChange(of: onlineManager.currentRoom) { room in
            if room == nil && !isLeaving {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { dismiss() }
            }
        }
    }

    // MARK: - Main Scroll Content

    /// Game types that support "cards to play" setting in the lobby
    private static let classicGameTypesWithCardCount: Set<String> = [
        "neverHaveIEver", "truthOrDare", "wouldYouRather", "mostLikelyTo",
        "quickfireCouples", "closerThanEver", "usAfterDark",
        "spillTheEx", "takeItPersonally", "riddleMeThis"
    ]

    private var isClassicGameWithCardCount: Bool {
        guard let type = onlineManager.currentRoom?.selectedGameType else { return false }
        return Self.classicGameTypesWithCardCount.contains(type)
    }

    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                roomCodeCard
                playerListSection
                if onlineManager.isHost && isClassicGameWithCardCount {
                    gameSettingsSection
                } else if isClassicGameWithCardCount {
                    gameSettingsReadOnlySection
                }
                actionButtons
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Room Code Card

    private var roomCodeCard: some View {
        VStack(spacing: 12) {
            Text("Room Code")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)

            Button {
                UIPasteboard.general.string = onlineManager.currentRoom?.roomCode
                HapticManager.shared.success()
                withAnimation(.spring(response: 0.3)) { copiedCode = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut) { copiedCode = false }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(onlineManager.currentRoom?.roomCode ?? "")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(copiedCode ? .green : .primaryText)
                        .tracking(6)
                    Image(systemName: copiedCode ? "checkmark.circle.fill" : "doc.on.doc")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(copiedCode ? .green : .secondaryText)
                }
                .animation(.spring(response: 0.3), value: copiedCode)
            }
            .buttonStyle(PlainButtonStyle())

            Text(copiedCode ? "Copied!" : "Tap to copy")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(copiedCode ? .green : .secondaryText)
                .animation(.easeInOut(duration: 0.2), value: copiedCode)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 24)
        .background(Color.secondaryBackground)
        .cornerRadius(16)
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Player List

    private var playerListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            let count = onlineManager.currentRoom?.players.count ?? 0
            let max = onlineManager.currentRoom?.maxPlayers ?? 8

            Text("Players (\(count)/\(max))")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)

            if let players = onlineManager.currentRoom?.players {
                ForEach(players) { player in
                    LobbyPlayerRow(
                        player: player,
                        canKick: onlineManager.isHost && player.id != authManager.userProfile?.userId
                    ) {
                        playerToKick = player
                        showKickAlert = true
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                }
            }

            // Invite friends row
            Button {
                HapticManager.shared.lightImpact()
                showInviteFriends = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(soDeckRed)
                    Text("Invite Friends")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(soDeckRed)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(soDeckRed.opacity(0.07))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(soDeckRed.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
        .animation(.spring(response: 0.3, dampingFraction: 0.8),
                   value: onlineManager.currentRoom?.players.count)
    }

    // MARK: - Game Settings (host only, classic games)

    private static let cardCountOptions: [Int?] = [nil, 10, 20, 30, 50]
    private static let riddleRoundOptions: [Int] = Array(stride(from: 5, through: 50, by: 5))
    private static let riddleTimerDurations: [Int] = [15, 30, 60, 90, 120]

    private var isRiddleMeThisLobby: Bool {
        onlineManager.currentRoom?.selectedGameType == "riddleMeThis"
    }

    private var currentRiddleRounds: Int {
        let count = onlineManager.currentRoom?.cardCount ?? 5
        return count > 0 ? count : 5
    }

    private var currentClassicTurnsEnabled: Bool {
        onlineManager.currentRoom?.classicTurnsEnabled ?? false
    }

    private var currentGameType: String {
        onlineManager.currentRoom?.selectedGameType ?? ""
    }

    private var lobbyCategoriesForSelectedGame: [String] {
        switch currentGameType {
        case "neverHaveIEver", "truthOrDare", "mostLikelyTo":
            return ["Party", "Wild", "Couples", "Social", "Dirty", "Friends", "Family"]
        case "wouldYouRather":
            return ["Party", "Wild", "Couples", "Social", "Dirty", "Friends", "Family", "Weird"]
        case "spillTheEx":
            return ["Confessions", "Situationship", "The Breakup", "Wild Side"]
        case "takeItPersonally":
            return ["Party", "Wild", "Friends", "Couples"]
        default:
            return []
        }
    }

    private var plusLockedCategoriesForSelectedGame: Set<String> {
        switch currentGameType {
        case "neverHaveIEver", "truthOrDare", "wouldYouRather":
            return ["Dirty", "Couples", "Wild"]
        default:
            return []
        }
    }

    private var selectedClassicCategoriesInRoom: [String] {
        let selected = onlineManager.currentRoom?.classicSelectedCategories ?? []
        if !selected.isEmpty { return selected }
        if subManager.isPlus { return lobbyCategoriesForSelectedGame }
        return lobbyCategoriesForSelectedGame.filter { !plusLockedCategoriesForSelectedGame.contains($0) }
    }

    private var hasCategorySettingForCurrentGame: Bool {
        !lobbyCategoriesForSelectedGame.isEmpty && !isRiddleMeThisLobby
    }

    private var gameSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game settings")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)

            Text(isRiddleMeThisLobby ? "Rounds to play" : "Cards to play")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.gray)

            if isRiddleMeThisLobby {
                let currentRounds = currentRiddleRounds
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Self.riddleRoundOptions, id: \.self) { rounds in
                            Button {
                                HapticManager.shared.lightImpact()
                                Task { await onlineManager.updateCardCount(rounds) }
                            } label: {
                                Text("\(rounds)")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(currentRounds == rounds ? .white : soDeckRed)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(currentRounds == rounds ? soDeckRed : soDeckRed.opacity(0.08))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(soDeckRed.opacity(currentRounds == rounds ? 0 : 0.3), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 2)
                }
            } else {
                let current = onlineManager.currentRoom?.cardCount
                HStack(spacing: 10) {
                    ForEach(Array(Self.cardCountOptions.enumerated()), id: \.offset) { _, option in
                        Button {
                            HapticManager.shared.lightImpact()
                            Task { await onlineManager.updateCardCount(option) }
                        } label: {
                            Text(option == nil ? "All" : "\(option!)")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(current == option ? .white : soDeckRed)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(current == option ? soDeckRed : soDeckRed.opacity(0.08))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(soDeckRed.opacity(current == option ? 0 : 0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }

            if hasCategorySettingForCurrentGame {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Categories")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    Button {
                        HapticManager.shared.lightImpact()
                        showCategorySelector = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("Select Categories")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Spacer()
                            Text("\(selectedClassicCategoriesInRoom.count) selected")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondaryText)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(soDeckRed)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(soDeckRed.opacity(0.08))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(soDeckRed.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 8)
            }

            if !isRiddleMeThisLobby {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Taking turns")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                        Text("Rotate who flips cards each round")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { currentClassicTurnsEnabled },
                            set: { on in
                                Task { await onlineManager.updateClassicTurnsEnabled(on) }
                            }
                        )
                    )
                    .labelsHidden()
                    .tint(soDeckRed)
                }
                .padding(.top, 8)
            }

            if isRiddleMeThisLobby {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Timer")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                            Text("Add urgency to each round")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Toggle(
                            "",
                            isOn: Binding(
                                get: { onlineManager.currentRoom?.timerEnabled ?? false },
                                set: { on in
                                    let dur = onlineManager.currentRoom?.timerDuration ?? 30
                                    Task { await onlineManager.updateRiddleTimer(enabled: on, durationSeconds: dur) }
                                }
                            )
                        )
                        .labelsHidden()
                        .tint(soDeckRed)
                    }

                    if onlineManager.currentRoom?.timerEnabled == true {
                        let selectedDur = onlineManager.currentRoom?.timerDuration ?? 30
                        Text("\(selectedDur) seconds")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(soDeckRed)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Self.riddleTimerDurations, id: \.self) { sec in
                                    Button {
                                        HapticManager.shared.lightImpact()
                                        Task { await onlineManager.updateRiddleTimer(enabled: true, durationSeconds: sec) }
                                    } label: {
                                        Text("\(sec)s")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(selectedDur == sec ? .white : soDeckRed)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .background(selectedDur == sec ? soDeckRed : soDeckRed.opacity(0.08))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(soDeckRed.opacity(selectedDur == sec ? 0 : 0.3), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
    }

    private var gameSettingsReadOnlySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game settings")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)

            if isRiddleMeThisLobby {
                Text("Rounds: \(currentRiddleRounds)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
            } else {
                let current = onlineManager.currentRoom?.cardCount
                Text("Cards: \(current == nil ? "All" : "\(current!)")")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)

                Text("Taking turns: \(currentClassicTurnsEnabled ? "On" : "Off")")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)

                if hasCategorySettingForCurrentGame {
                    Text("Categories")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.top, 4)

                    let visible = selectedClassicCategoriesInRoom
                    Text(visible.joined(separator: ", "))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(soDeckRed)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 14) {
            let allReady = onlineManager.currentRoom?.allPlayersReady ?? false
            let playerCount = onlineManager.currentRoom?.players.count ?? 0

            if onlineManager.isHost {
                // HOST: Start Game (only enabled when all ready + >=2 players)
                Button {
                    Task { await onlineManager.startGame() }
                } label: {
                    HStack(spacing: 8) {
                        if onlineManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "play.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text("Start Game")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(allReady && playerCount >= 2 ? soDeckRed : Color.gray.opacity(0.4))
                    .cornerRadius(14)
                }
                .disabled(!allReady || playerCount < 2 || onlineManager.isLoading)

                if !allReady || playerCount < 2 {
                    Text(playerCount < 2
                         ? "Need at least 2 players to start"
                         : "Waiting for all players to be ready…")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                // HOST Ready toggle
                readyToggleButton

            } else {
                // NON-HOST: waiting message or ready toggle
                if allReady {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.9)
                            .tint(soDeckRed)
                        Text("Waiting for host to start…")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.secondaryBackground)
                    .cornerRadius(14)
                }

                readyToggleButton
            }

            // Leave Room
            Button {
                HapticManager.shared.lightImpact()
                showLeaveAlert = true
            } label: {
                Text("Leave Room")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(soDeckRed)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(soDeckRed.opacity(0.08))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(soDeckRed.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 24)
    }

    private var readyToggleButton: some View {
        let isReady = onlineManager.isCurrentPlayerReady
        return Button {
            Task { await onlineManager.toggleReadyStatus() }
        } label: {
            Text(isReady ? "Un-ready" : "Ready up")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(soDeckRed)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(soDeckRed, lineWidth: 2)
                )
                .cornerRadius(14)
        }
        .disabled(onlineManager.isLoading)
    }

    // MARK: - Room Gone State

    private var roomGoneView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("Room not found")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text("This room may have been deleted.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
            Button("Go Back") { dismiss() }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(soDeckRed)
                .cornerRadius(12)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
    }

    // MARK: - Leave Action

    private func doLeave() {
        HapticManager.shared.mediumImpact()
        withAnimation { isLeaving = true }
        Task {
            await onlineManager.leaveRoom()
            await MainActor.run {
                withAnimation { dismiss() }
            }
        }
    }
}

private struct LobbyCategorySelectionSheet: View {
    let title: String
    let categories: [String]
    let plusLockedCategories: Set<String>
    let selectedCategories: [String]
    let onSave: ([String]) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subManager: SubscriptionManager
    @State private var showPlusPaywall = false
    @State private var localSelected: Set<String> = []

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            let locked = plusLockedCategories.contains(category) && !subManager.isPlus
                            let selected = localSelected.contains(category)
                            CategoryButton(
                                title: category,
                                isSelected: selected,
                                isLocked: locked,
                                cardCount: 0
                            ) {
                                if locked {
                                    showPlusPaywall = true
                                } else if selected {
                                    localSelected.remove(category)
                                } else {
                                    localSelected.insert(category)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(Array(localSelected))
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
            .onAppear {
                if selectedCategories.isEmpty {
                    let available = subManager.isPlus
                        ? Set(categories)
                        : Set(categories.filter { !plusLockedCategories.contains($0) })
                    localSelected = available
                } else {
                    localSelected = Set(selectedCategories)
                }
            }
            .sheet(isPresented: $showPlusPaywall) {
                TheSocialDeckPlusPopUpView(onDismiss: { showPlusPaywall = false })
                    .environmentObject(SubscriptionManager.shared)
            }
        }
    }
}

// MARK: - Player Row

private struct LobbyPlayerRow: View {
    let player: RoomPlayer
    let canKick: Bool
    let onKick: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(
                avatarType: player.avatarType,
                avatarColor: player.avatarColor,
                size: 46
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(player.username)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)

                    if player.isHost {
                        Text("Host")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.primaryAccent)
                            .cornerRadius(8)
                    }
                }

                HStack(spacing: 5) {
                    Circle()
                        .fill(player.isReady ? Color.green : Color.gray.opacity(0.4))
                        .frame(width: 7, height: 7)
                    Text(player.isReady ? "Ready" : "Not ready")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(player.isReady ? .green : .gray)
                }
            }

            Spacer()

            if canKick {
                Button {
                    HapticManager.shared.lightImpact()
                    onKick()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.red.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 6)
    }
}
