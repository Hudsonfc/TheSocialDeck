//
//  OnlineGameDetailView.swift
//  The Social Deck
//
//  Game detail screen shown when the user taps an online game card in the
//  "Online Only" tab. From here they can Create a Room or Join a Room.
//  The selected game type is passed directly into the room at creation time.
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
        imageName: "color clash artwork logo",
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

    @State private var isCreatingRoom = false
    @State private var navigateToLobby = false
    @State private var navigateToJoin = false
    @State private var showSignIn = false
    @State private var errorMessage: String? = nil
    @State private var showError = false

    private let soDeckRed = Color(red: 0xD9 / 255.0, green: 0x3A / 255.0, blue: 0x3A / 255.0)

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // Hidden NavigationLinks
            NavigationLink(destination: LobbyView(), isActive: $navigateToLobby) {
                EmptyView()
            }
            .hidden()

            NavigationLink(destination: JoinRoomView(), isActive: $navigateToJoin) {
                EmptyView()
            }
            .hidden()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Artwork
                    Image(game.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [Color.clear, Color.white],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 100)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        )

                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        Text(game.title)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))

                        // Player count pill
                        HStack(spacing: 6) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 13, weight: .semibold))
                            Text("\(game.minPlayers)–\(game.maxPlayers) players")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(soDeckRed)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(soDeckRed.opacity(0.1))
                        .cornerRadius(20)

                        // Description
                        Text(game.description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x4A / 255.0, green: 0x4A / 255.0, blue: 0x4A / 255.0))
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)

                        Divider()
                            .padding(.vertical, 4)

                        // Action buttons — or sign-in gate
                        if authManager.isAuthenticated {
                            actionButtons
                        } else {
                            signInGate
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                }
            }
        }
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
        VStack(spacing: 14) {
            // Create Room
            Button {
                Task { await createRoom() }
            } label: {
                HStack(spacing: 8) {
                    if isCreatingRoom {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Create Room")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(soDeckRed)
                .cornerRadius(14)
            }
            .disabled(isCreatingRoom)

            // Join Room
            Button {
                HapticManager.shared.lightImpact()
                navigateToJoin = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Join Room")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundColor(soDeckRed)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(soDeckRed, lineWidth: 2)
                )
                .cornerRadius(14)
            }
            .disabled(isCreatingRoom)
        }
    }

    // MARK: - Sign-In Gate

    private var signInGate: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(Color.gray.opacity(0.5))

            Text("Sign in to play online")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))

            Text("You need a free account to create or join online rooms.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            NavigationLink(destination: SignInView()) {
                Text("Sign In")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(soDeckRed)
                    .cornerRadius(14)
            }
        }
        .padding(.vertical, 8)
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
