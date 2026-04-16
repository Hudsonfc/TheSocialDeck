//
//  OnlineGameDetailView.swift
//  The Social Deck
//
//  Game detail screen shown when the user taps an online game card in the
//  "Online Only" tab. Layout matches GameDescriptionOverlay; actions are
//  Create Room (or sign-in gate). Join with a code from Play → Join Room.
//  Play grid games use `GameDescriptionOverlay` → Play Offline + Create Room.
//  The selected game type is passed directly into the room at creation time.
//

import SwiftUI

// MARK: - Data Model

enum BuiltInOnlineGameCover: Equatable {
    case whatWouldYouDo
}

struct OnlineGameEntry: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let imageName: String
    let gameType: String     // Matches DeckType rawValue or custom string
    let minPlayers: Int
    let maxPlayers: Int
    /// When set, grid/detail use this SwiftUI art instead of `Image(imageName)`.
    let builtInCover: BuiltInOnlineGameCover?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        imageName: String,
        gameType: String,
        minPlayers: Int,
        maxPlayers: Int,
        builtInCover: BuiltInOnlineGameCover? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageName = imageName
        self.gameType = gameType
        self.minPlayers = minPlayers
        self.maxPlayers = maxPlayers
        self.builtInCover = builtInCover
    }
}

/// Games that **only** exist as online titles (no local deck on the Play grid).
/// Shown in the "Online Only" tab when non-empty. "What Would You Do" lives under Social Deck Games.
let allOnlineGames: [OnlineGameEntry] = []

// MARK: - Detail View

struct OnlineGameDetailView: View {
    let game: OnlineGameEntry

    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared

    @State private var isCreatingRoom = false
    @State private var navigateToLobby = false
    @State private var errorMessage: String? = nil
    @State private var showError = false

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            // Hidden NavigationLinks
            NavigationLink(destination: LobbyView(), isActive: $navigateToLobby) {
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

                    Button(action: {
                        favoritesManager.toggleFavoriteRawGameType(game.gameType)
                    }) {
                        Image(systemName: favoritesManager.isFavoriteRawGameType(game.gameType) ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(favoritesManager.isFavoriteRawGameType(game.gameType) ? .primaryAccent : .primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(game.title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(game.description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(6)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        GameDescriptionTagRow(tags: GameDescriptionLayoutContent.tags(for: game))

                        GameDescriptionNumberedStepsView(steps: GameDescriptionLayoutContent.playSteps(for: game))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .responsiveHorizontalPadding()
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if game.builtInCover != nil {
                    previewOnlyFooter
                } else if authManager.isAuthenticated {
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

    // MARK: - Preview-only (no online flow)

    private var previewOnlyFooter: some View {
        VStack(spacing: 10) {
            Text("Cover preview")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondaryText)

            Text("No rooms or gameplay yet — this is only to try the art in the Online Only tab.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .responsiveHorizontalPadding()
        .padding(.bottom, 40)
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
