//
//  OnlinePlayerStripView.swift
//  The Social Deck
//
//  Shows all players' avatars and a clear indication of host (controls the cards) and you.
//

import SwiftUI

struct OnlinePlayerStripView: View {
    let players: [RoomPlayer]
    let currentUserId: String?

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
        .frame(height: 64)
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(Color.tertiaryBackground.opacity(0.8))
        .cornerRadius(12)
        .responsiveHorizontalPadding()
    }

    private func playerChip(_ player: RoomPlayer) -> some View {
        let isYou = player.id == currentUserId
        let isTurn = player.isHost // Host's turn to control flipping/advancing

        return VStack(spacing: 4) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    avatarType: player.avatarType,
                    avatarColor: player.avatarColor,
                    size: 44
                )
                .overlay(
                    Circle()
                        .stroke(isTurn ? soDeckRed : Color.clear, lineWidth: 3)
                        .padding(-2)
                )

                if player.isHost {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(2)
                        .background(soDeckRed)
                        .clipShape(Circle())
                        .offset(x: 2, y: 2)
                }
            }

            // Fixed-height slot: "Your turn" (only you see this when you're host), "Their turn" (host is someone else), or "You" (just you)
            ZStack {
                if player.isHost {
                    Text(isYou ? "Your turn" : "Their turn")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(soDeckRed)
                        .lineLimit(1)
                } else if isYou {
                    Text("You")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                }
            }
            .frame(height: 18)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.appBackground.opacity(0.5))
        .cornerRadius(10)
    }
}
