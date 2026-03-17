//
//  ClassicGameOnlineView.swift
//  The Social Deck
//
//  Shown when the user taps "Play Online" from a classic game description
//  screen. Presents Create Room and Join Room for the selected game.
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
    @State private var navigateToJoin = false
    @State private var errorMessage: String? = nil
    @State private var showError = false

    private let soDeckRed = Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0)

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            NavigationLink(destination: LobbyView(), isActive: $navigateToLobby) {
                EmptyView()
            }.hidden()

            NavigationLink(destination: JoinRoomView(), isActive: $navigateToJoin) {
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

                // Game artwork — same as description screen (large, centered, rounded, shadow)
                Image(imageName)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .aspectRatio(420.0 / 577.0, contentMode: .fit)
                    .frame(width: min(180, UIScreen.main.bounds.width - 120))
                    .cornerRadius(12)
                    .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
                    .padding(.bottom, 20)

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

                // Subtitle: "Play Online" in smaller grey
                Text("Play Online")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .padding(.bottom, 8)

                // One-line hint in subtle secondary style
                Text("2–8 players • Cards sync in real time")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.tertiaryText)
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

            Button {
                HapticManager.shared.lightImpact()
                navigateToJoin = true
            } label: {
                Text("Join Room")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(soDeckRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(soDeckRed, lineWidth: 2)
                    )
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

            Text("You need a free account to create or join online rooms.")
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
            maxPlayers: 8,
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
