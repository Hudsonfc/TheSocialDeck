//
//  OnlineGameShellView.swift
//  The Social Deck
//
//  Reusable layout shell for all online games.
//  Provides the nav bar, avatar strip, and a flexible game zone slot.
//  Does not contain any game logic — purely a layout container.
//

import SwiftUI

// MARK: - Shell View

struct OnlineGameShellView<GameContent: View>: View {
    @Environment(\.dismiss) private var dismiss

    let gameName: String
    let currentRound: Int
    let totalRounds: Int
    let players: [RoomPlayer]
    let localPlayerId: String
    /// Players who have submitted for the current round (e.g. WWYD answers) — shows a checkmark on their avatar.
    let answeredUserIds: Set<String>
    /// When true, the score under each avatar is hidden (e.g. WWYD anonymous mode until the game ends).
    let hideScores: Bool
    private let gameContent: GameContent

    init(
        gameName: String,
        currentRound: Int,
        totalRounds: Int,
        players: [RoomPlayer],
        localPlayerId: String,
        answeredUserIds: Set<String> = [],
        hideScores: Bool = false,
        @ViewBuilder content: () -> GameContent
    ) {
        self.gameName = gameName
        self.currentRound = currentRound
        self.totalRounds = totalRounds
        self.players = players
        self.localPlayerId = localPlayerId
        self.answeredUserIds = answeredUserIds
        self.hideScores = hideScores
        self.gameContent = content()
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                minimalNavBar
                avatarStrip
                gameContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Minimal Nav Bar

    /// Plain chevron, centered title, plain round label — no system toolbar (avoids liquid-glass / capsule chrome).
    private var minimalNavBar: some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                HapticManager.shared.lightImpact()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryText)
                    .frame(width: 44, height: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text(gameName)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text("Round \(currentRound) of \(totalRounds)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.tertiaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Avatar Strip

    private var avatarStrip: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(players) { player in
                        playerCell(player)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            Rectangle()
                .fill(Color.borderColor)
                .frame(height: 1)
        }
    }

    // MARK: - Player Cell

    private func playerCell(_ player: RoomPlayer) -> some View {
        let isLocal = player.id == localPlayerId
        let showAnswered = answeredUserIds.contains(player.id)

        return VStack(spacing: 4) {
            AvatarView(
                avatarType: player.avatarType,
                avatarColor: player.avatarColor,
                size: 48
            )
            .overlay(
                Circle()
                    .stroke(
                        isLocal ? Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0) : Color.clear,
                        lineWidth: 3
                    )
                    .padding(-3)
            )
            .overlay(alignment: .bottomTrailing) {
                if showAnswered {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0))
                        .background(
                            Circle()
                                .fill(Color.appBackground)
                                .frame(width: 11, height: 11)
                        )
                        .offset(x: 2, y: 2)
                }
            }

            Text(player.username)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(
                    isLocal
                        ? Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0)
                        : .primaryText
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.55)
                .frame(minWidth: 56, idealWidth: 76, maxWidth: 120, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)

            if hideScores {
                Text("—")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.tertiaryText)
            } else {
                Text("\(player.gameScore ?? 0)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(
                        isLocal
                            ? Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0)
                            : .secondaryText
                    )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let mockPlayers: [RoomPlayer] = [
        RoomPlayer(
            id: "local-user",
            username: "You",
            avatarType: "avatar 1",
            avatarColor: "red",
            isHost: true,
            gameScore: 3
        ),
        RoomPlayer(
            id: "player-2",
            username: "Alex",
            avatarType: "avatar 2",
            avatarColor: "blue",
            gameScore: 1
        ),
        RoomPlayer(
            id: "player-3",
            username: "Sam",
            avatarType: "avatar 3",
            avatarColor: "green",
            gameScore: 2
        ),
        RoomPlayer(
            id: "player-4",
            username: "Jordan",
            avatarType: "avatar 4",
            avatarColor: "purple",
            gameScore: 0
        )
    ]

    NavigationStack {
        OnlineGameShellView(
            gameName: "Never Have I Ever",
            currentRound: 2,
            totalRounds: 10,
            players: mockPlayers,
            localPlayerId: "local-user"
        ) {
            VStack(spacing: 16) {
                Spacer()
                Text("Game zone goes here")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondaryText)
                Text("Drop any view in this slot")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.tertiaryText)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
