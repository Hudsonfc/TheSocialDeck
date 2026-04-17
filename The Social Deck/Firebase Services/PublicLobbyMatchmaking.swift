//
//  PublicLobbyMatchmaking.swift
//  The Social Deck
//
//  Reusable “Find Game” discovery: query public lobbies by `selectedGameType`.
//  Wire new games by passing their Firestore game-type string (same as `DeckType.rawValue`).
//

import Foundation

enum PublicLobbyMatchmaking {
    /// `OnlineRoom.selectedGameType` for What Would You Do.
    static let whatWouldYouDo = DeckType.whatWouldYouDo.rawValue

    /// Returns a room code suitable for `OnlineManager.joinRoom`, or `nil` if no joinable public lobby exists.
    static func findJoinableRoomCode(gameType: String, currentUserId: String) async throws -> String? {
        try await OnlineService.shared.findJoinablePublicLobbyRoomCode(
            gameType: gameType,
            currentUserId: currentUserId
        )
    }
}
