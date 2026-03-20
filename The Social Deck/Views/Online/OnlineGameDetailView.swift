//
//  OnlineGameDetailView.swift
//  The Social Deck
//
//  Game detail screen shown when the user taps an online game card in the
//  "Online Only" tab. Layout matches GameDescriptionOverlay; actions are
//  Create Room / Join Room (or sign-in gate). The selected game type is
//  passed directly into the room at creation time.
//

import SwiftUI

// MARK: - Data Model

struct OnlineGameEntry: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let gameType: String     // Matches DeckType rawValue or custom string
    let minPlayers: Int
    let maxPlayers: Int
}

/// Single source of truth for all online-capable games — used by both
/// the Online Only tab and the detail screen.
let allOnlineGames: [OnlineGameEntry] = [
    OnlineGameEntry(
        title: "Color Clash",
        description: "A fast-paced card game where players match colors and numbers. Play cards, use action cards to shake things up, and be the first to empty your hand. Wild cards, skips, reverses — anything goes.",
        imageName: "colorclash",
        gameType: "colorClash",
        minPlayers: 2,
        maxPlayers: 6
    ),
]

// MARK: - Detail View

struct OnlineGameDetailView: View {
    let game: OnlineGameEntry

    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared

    @State private var isCreatingRoom = false
    @State private var navigateToLobby = false
    @State private var navigateToJoin = false
    @State private var errorMessage: String? = nil
    @State private var showError = false

    private var favoriteDeckType: DeckType? {
        DeckType(rawValue: game.gameType)
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            // Hidden NavigationLinks
            NavigationLink(destination: LobbyView(), isActive: $navigateToLobby) {
                EmptyView()
            }
            .hidden()

            NavigationLink(destination: JoinRoomView(), isActive: $navigateToJoin) {
                EmptyView()
            }
            .hidden()

            VStack(spacing: 0) {
                // Top bar with close and favorite (same as GameDescriptionOverlay)
                HStack {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }

                    Spacer()

                    if let deckType = favoriteDeckType {
                        Button(action: {
                            favoritesManager.toggleFavorite(deckType)
                            HapticManager.shared.lightImpact()
                        }) {
                            Image(systemName: favoritesManager.isFavorite(deckType) ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(favoritesManager.isFavorite(deckType) ? .primaryAccent : .primaryText)
                                .frame(width: 44, height: 44)
                                .background(Color.tertiaryBackground)
                                .clipShape(Circle())
                        }
                    }
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Game artwork (same style as GameDescriptionOverlay)
                Image(game.imageName)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .aspectRatio(420.0 / 577.0, contentMode: .fit)
                    .frame(width: min(180, UIScreen.main.bounds.width - 120))
                    .cornerRadius(12)
                    .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
                    .padding(.bottom, 20)

                Spacer()

                // Title (same as overlay)
                Text(game.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .responsiveHorizontalPadding()
                    .padding(.bottom, 8)

                // Player count — centered pill with small icon
                HStack {
                    Spacer(minLength: 0)
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("\(game.minPlayers)–\(game.maxPlayers) players")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.primaryAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.primaryAccent.opacity(0.12))
                    .cornerRadius(20)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)

                // Description (same as overlay)
                Text(game.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .responsiveHorizontalPadding()
                    .padding(.bottom, 24)

                Spacer()

                // Actions: Create Room / Join Room (or sign-in gate)
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
            // Create Room (same style as PrimaryButton / Play)
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
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.buttonBackground)
                .cornerRadius(16)
            }
            .disabled(isCreatingRoom)

            // Join Room (outline style, same corner radius)
            Button {
                HapticManager.shared.lightImpact()
                navigateToJoin = true
            } label: {
                Text("Join Room")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primaryAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primaryAccent, lineWidth: 2)
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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.buttonBackground)
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
            roomName: game.title,
            maxPlayers: game.maxPlayers,
            isPrivate: false,
            gameType: game.gameType
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
