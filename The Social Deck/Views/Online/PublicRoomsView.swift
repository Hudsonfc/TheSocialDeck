//
//  PublicRoomsView.swift
//  The Social Deck
//
//  Browse and join open public lobby rooms for a given game type, or all games when `gameType` is nil.
//  Pass `DeckType.rawValue` (e.g. `"whatWouldYouDo"`) to filter to one game; pass `nil` for every game.
//

import SwiftUI
import FirebaseFirestore

// MARK: - ViewModel

@MainActor
final class PublicRoomsViewModel: ObservableObject {
    @Published var rooms: [OnlineRoom] = []
    @Published var isLoading = true

    private var listener: ListenerRegistration?
    let gameType: String?

    init(gameType: String?) {
        self.gameType = gameType
    }

    func startListening() {
        // Always tear down any existing listener first to prevent duplicate registrations
        // when onAppear fires more than once during NavigationLink transitions.
        listener?.remove()
        listener = nil
        isLoading = true
        listener = OnlineService.shared.listenToPublicRooms(gameType: gameType) { [weak self] updated in
            guard let self else { return }
            // Deduplicate by roomCode as a safety net against Firestore returning duplicate docs.
            var seen = Set<String>()
            let deduped = updated.filter { seen.insert($0.roomCode).inserted }
            self.rooms = deduped.filter { $0.players.count < $0.maxPlayers }
            self.isLoading = false
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

// MARK: - View

struct PublicRoomsView: View {
    /// `DeckType.rawValue` to filter to one game, or `nil` for all public waiting rooms.
    let gameType: String?
    let gameDisplayName: String

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: PublicRoomsViewModel
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared

    @State private var joiningRoomCode: String? = nil
    @State private var navigateToLobby = false
    @State private var joinError: String? = nil
    @State private var showJoinError = false

    private let soDeckRed = Color.primaryAccent

    init(gameType: String?, gameDisplayName: String) {
        self.gameType = gameType
        self.gameDisplayName = gameDisplayName
        _vm = StateObject(wrappedValue: PublicRoomsViewModel(gameType: gameType))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            NavigationLink(destination: LobbyView(), isActive: $navigateToLobby) {
                EmptyView()
            }
            .hidden()

            VStack(spacing: 0) {
                headerBar

                if vm.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.4)
                        .tint(soDeckRed)
                    Spacer()
                } else if vm.rooms.isEmpty {
                    emptyState
                } else {
                    roomList
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { vm.startListening() }
        .onDisappear { vm.stopListening() }
        .alert("Couldn't join", isPresented: $showJoinError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(joinError ?? "Something went wrong. Please try again.")
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button {
                HapticManager.shared.lightImpact()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryText)
                    .frame(width: 40, height: 40)
                    .background(Color.secondaryBackground)
                    .clipShape(Circle())
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Open Rooms")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                Text(gameDisplayName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
            }

            Spacer()

            // Balance the back button
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.appBackground)
        .overlay(
            Divider()
                .opacity(0.4),
            alignment: .bottom
        )
    }

    // MARK: - Room List

    private var roomList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ForEach(vm.rooms) { room in
                    roomCard(room)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    @ViewBuilder
    private func roomCard(_ room: OnlineRoom) -> some View {
        let host = room.players.first(where: { $0.id == room.hostId }) ?? room.players.first
        let hostName = host?.username ?? "Unknown"
        let playerCount = room.players.count
        let maxPlayers = room.maxPlayers
        let isJoiningThis = joiningRoomCode == room.roomCode

        HStack(spacing: 0) {
            // Left: cover for this room's game
            gameCoverStrip(for: room)
                .frame(width: 110)
                .clipped()

            // Right: room info
            VStack(alignment: .leading, spacing: 0) {
                // Host avatar + name row
                HStack(spacing: 10) {
                    if let host {
                        AvatarView(
                            avatarType: host.avatarType,
                            avatarColor: host.avatarColor,
                            size: 44
                        )
                    } else {
                        Circle()
                            .fill(soDeckRed.opacity(0.15))
                            .frame(width: 44, height: 44)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(hostName)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                        Text("Host")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }

                    Spacer()
                }

                Spacer(minLength: 10)

                // Player count pips
                HStack(spacing: 5) {
                    ForEach(0..<maxPlayers, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i < playerCount
                                  ? soDeckRed
                                  : Color.secondaryText.opacity(0.18))
                            .frame(width: 18, height: 6)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondaryText)
                    Text("\(playerCount)/\(maxPlayers) players")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                .padding(.top, 5)

                Spacer(minLength: 12)

                // Join button
                Button {
                    guard !isJoiningThis else { return }
                    HapticManager.shared.lightImpact()
                    Task { await joinRoom(code: room.roomCode) }
                } label: {
                    Group {
                        if isJoiningThis {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.85)
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Join Room")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(isJoiningThis ? soDeckRed.opacity(0.55) : soDeckRed)
                    .cornerRadius(10)
                }
                .disabled(joiningRoomCode != nil)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 160)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 3)
    }

    /// Cover art for the room's `selectedGameType` (same routing as Play).
    @ViewBuilder
    private func gameCoverStrip(for room: OnlineRoom) -> some View {
        OnlinePlaceholderCoverArtView(gameType: room.selectedGameType, catalogImageName: "")
            .environment(\.whatWouldYouDoCoverEmbeddedPills, false)
            .environment(\.playGridAdaptiveSocialDeckCovers, true)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 52, weight: .light))
                .foregroundColor(soDeckRed.opacity(0.5))

            Text("No open rooms right now")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)

            Text("Be the first — create a room and set it to Public so others can find you!")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Join Logic

    private func joinRoom(code: String) async {
        guard authManager.isAuthenticated else {
            joinError = "You must be signed in to join a room."
            showJoinError = true
            return
        }

        joiningRoomCode = code
        onlineManager.errorMessage = nil

        await onlineManager.joinRoom(roomCode: code)

        joiningRoomCode = nil

        if let err = onlineManager.errorMessage, !err.isEmpty {
            joinError = err
            showJoinError = true
        } else if onlineManager.currentRoom != nil {
            HapticManager.shared.success()
            navigateToLobby = true
        } else {
            joinError = "Could not join that room. It may have just filled up."
            showJoinError = true
        }
    }
}
