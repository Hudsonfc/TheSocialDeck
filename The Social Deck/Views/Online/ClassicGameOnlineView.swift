//
//  ClassicGameOnlineView.swift
//  The Social Deck
//
//  Legacy intermediate screen for classic online flow; the Play grid overlay
//  now creates a room directly. Kept for reference or future navigation.
//

import SwiftUI

struct ClassicGameOnlineView: View {
    let gameTitle: String
    let gameType: String  // DeckType.rawValue
    let imageName: String  // Deck artwork, same as description screen

    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared

    @State private var isCreatingRoom = false
    @State private var navigateToLobby = false
    @State private var errorMessage: String? = nil
    @State private var showError = false

    private let soDeckRed = Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0)

    private var onlineMaxPlayers: Int {
        gameType == "actNatural" ? 12 : 8
    }

    private var playerCountSubtitle: String {
        gameType == "actNatural" ? "3–12 players" : "2–8 players"
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            NavigationLink(destination: LobbyView(), isActive: $navigateToLobby) {
                EmptyView()
            }.hidden()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 16)

                Spacer()

                // Title — same bold style as description screen
                Text(gameTitle)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .responsiveHorizontalPadding()
                    .padding(.bottom, 8)

                // Subtitle in secondary text
                Text("Create a room")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .padding(.bottom, 8)

                // Player count — centered with small icon (no sync copy)
                HStack {
                    Spacer(minLength: 0)
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text(playerCountSubtitle)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.tertiaryText)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)

                Spacer()

                if authManager.isAuthenticated {
                    actionButtons
                } else {
                    signInGate
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Something went wrong. Please try again.")
        }
        .onChange(of: onlineManager.errorMessage) { msg in
            if let msg, !msg.isEmpty {
                errorMessage = msg
                showError = true
                isCreatingRoom = false
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task { await createRoom() }
            } label: {
                Group {
                    if isCreatingRoom {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Text("Create Room")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(soDeckRed)
                .cornerRadius(16)
            }
            .disabled(isCreatingRoom)
        }
        .responsiveHorizontalPadding()
        .padding(.bottom, 40)
    }

    // MARK: - Sign-In Gate

    private var signInGate: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(.secondaryText)

            Text("Sign in to play online")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)

            Text("You need a free account to create an online room. Use Join Room on the Play screen to join with a code.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            NavigationLink(destination: SignInView()) {
                Text("Sign In")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(soDeckRed)
                    .cornerRadius(16)
            }
        }
        .responsiveHorizontalPadding()
        .padding(.bottom, 40)
    }

    // MARK: - Create Room

    private func createRoom() async {
        HapticManager.shared.mediumImpact()
        isCreatingRoom = true

        await onlineManager.createRoom(
            roomName: gameTitle,
            maxPlayers: onlineMaxPlayers,
            isPrivate: false,
            gameType: gameType
        )

        await MainActor.run {
            isCreatingRoom = false
            if onlineManager.currentRoom != nil {
                HapticManager.shared.success()
                navigateToLobby = true
            }
        }
    }
}
