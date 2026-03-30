//
//  OnlineGameExitAlertsView.swift
//  The Social Deck
//
//  Shared confirmations for leaving online games (chevron back).
//

import SwiftUI

/// Invisible container that hosts alerts/dialogs for online exit flows.
struct OnlineGameExitAlertsView: View {
    @Binding var guestLeave: Bool
    @Binding var hostEveryone: Bool
    @Binding var hostMulti: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .alert("Leave this game?", isPresented: $guestLeave) {
                Button("Cancel", role: .cancel) {}
                Button("Leave", role: .destructive) {
                    Task {
                        await OnlineManager.shared.leaveRoom()
                        await MainActor.run { dismiss() }
                    }
                }
            } message: {
                Text("You will leave this room and return to the previous screen.")
            }
            .alert("Go back to the lobby?", isPresented: $hostEveryone) {
                Button("Cancel", role: .cancel) {}
                Button("Go back", role: .destructive) {
                    Task { await OnlineManager.shared.returnRoomToLobby() }
                }
            } message: {
                Text("Everyone will return to the lobby together.")
            }
            .confirmationDialog(
                "Go back to the lobby?",
                isPresented: $hostMulti,
                titleVisibility: .visible
            ) {
                Button("Bring everyone") {
                    Task { await OnlineManager.shared.returnRoomToLobby() }
                }
                Button("Leave on my own", role: .destructive) {
                    Task {
                        await OnlineManager.shared.hostLeaveGamePassHostToNext()
                        await MainActor.run { dismiss() }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Bring all players back to the lobby, or pass host to someone else and leave by yourself.")
            }
    }
}
