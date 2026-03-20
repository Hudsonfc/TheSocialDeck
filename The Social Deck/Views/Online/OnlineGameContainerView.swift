//
//  OnlineGameContainerView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

// MARK: - Online wrappers for the 4 classic card games
// Each wrapper creates the full deck + manager so the play view can be launched
// from the online flow with roomId/isHost without touching the local launch path.

private let onlineClassicCategories = ["Party", "Wild", "Couples", "Social", "Dirty", "Friends", "Family"]

private let onlineSpillTheExCategories = ["Confessions", "Situationship", "The Breakup", "Wild Side"]
private let onlineTIPCategories = ["Party", "Wild", "Friends", "Couples"]

private struct OnlineNHIEView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int

    @StateObject private var manager: NHIEGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let deck = Deck(
            title: "Never Have I Ever",
            description: "Reveal your wildest experiences and learn about your friends.",
            numberOfCards: allNHIECards.count,
            estimatedTime: "30-45 min",
            imageName: "NHIE 2.0",
            type: .neverHaveIEver,
            cards: allNHIECards,
            availableCategories: onlineClassicCategories
        )
        _manager = StateObject(wrappedValue: NHIEGameManager(deck: deck, selectedCategories: onlineClassicCategories, cardCount: cardCount ?? 0))
    }

    var body: some View {
        let deck = Deck(title: "Never Have I Ever", description: "", numberOfCards: allNHIECards.count,
                        estimatedTime: "30-45 min", imageName: "NHIE 2.0", type: .neverHaveIEver,
                        cards: allNHIECards, availableCategories: onlineClassicCategories)
        NHIEPlayView(manager: manager, deck: deck, selectedCategories: onlineClassicCategories,
                     roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
    }
}

private struct OnlineTORView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int

    @StateObject private var manager: TORGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let deck = Deck(
            title: "Truth or Dare",
            description: "Choose truth or dare and see where the night takes you.",
            numberOfCards: allTORCards.count,
            estimatedTime: "30-45 min",
            imageName: "TOD 2.0",
            type: .truthOrDare,
            cards: allTORCards,
            availableCategories: onlineClassicCategories
        )
        _manager = StateObject(wrappedValue: TORGameManager(deck: deck, selectedCategories: onlineClassicCategories, cardCount: cardCount ?? 0))
    }

    var body: some View {
        let deck = Deck(title: "Truth or Dare", description: "", numberOfCards: allTORCards.count,
                        estimatedTime: "30-45 min", imageName: "TOD 2.0", type: .truthOrDare,
                        cards: allTORCards, availableCategories: onlineClassicCategories)
        TORPlayView(manager: manager, deck: deck, selectedCategories: onlineClassicCategories,
                    roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
    }
}

private struct OnlineWYRView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int

    @StateObject private var manager: WYRGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let deck = Deck(
            title: "Would You Rather",
            description: "Make tough choices and discover what your friends prefer.",
            numberOfCards: allWYRCards.count,
            estimatedTime: "30-45 min",
            imageName: "WYR 2.0",
            type: .wouldYouRather,
            cards: allWYRCards,
            availableCategories: onlineClassicCategories
        )
        _manager = StateObject(wrappedValue: WYRGameManager(deck: deck, selectedCategories: onlineClassicCategories, cardCount: cardCount ?? 0))
    }

    var body: some View {
        let deck = Deck(title: "Would You Rather", description: "", numberOfCards: allWYRCards.count,
                        estimatedTime: "30-45 min", imageName: "WYR 2.0", type: .wouldYouRather,
                        cards: allWYRCards, availableCategories: onlineClassicCategories)
        WYRPlayView(manager: manager, deck: deck, selectedCategories: onlineClassicCategories,
                    roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
    }
}

private struct OnlineMLTView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int

    @StateObject private var manager: MLTGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let deck = Deck(
            title: "Most Likely To",
            description: "Find out who's most likely to do crazy things.",
            numberOfCards: allMLTCards.count,
            estimatedTime: "30-45 min",
            imageName: "MLT 2.0",
            type: .mostLikelyTo,
            cards: allMLTCards,
            availableCategories: onlineClassicCategories
        )
        _manager = StateObject(wrappedValue: MLTGameManager(deck: deck, selectedCategories: onlineClassicCategories, cardCount: cardCount ?? 0))
    }

    var body: some View {
        let deck = Deck(title: "Most Likely To", description: "", numberOfCards: allMLTCards.count,
                        estimatedTime: "30-45 min", imageName: "MLT 2.0", type: .mostLikelyTo,
                        cards: allMLTCards, availableCategories: onlineClassicCategories)
        MLTPlayView(manager: manager, deck: deck, selectedCategories: onlineClassicCategories,
                    roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
    }
}

private struct OnlineQFCView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int

    @StateObject private var manager: QuickfireCouplesGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let deck = Deck(
            title: "Quickfire Couples",
            description: "Rapid-fire choices that reveal who knows who best.",
            numberOfCards: allQuickfireCouplesCards.count,
            estimatedTime: "20-30 min",
            imageName: "Quickfire Couples",
            type: .quickfireCouples,
            cards: allQuickfireCouplesCards,
            availableCategories: []
        )
        _manager = StateObject(wrappedValue: QuickfireCouplesGameManager(deck: deck, selectedCategories: [], cardCount: cardCount ?? 0))
    }

    var body: some View {
        let deck = Deck(title: "Quickfire Couples", description: "", numberOfCards: allQuickfireCouplesCards.count,
                        estimatedTime: "20-30 min", imageName: "Quickfire Couples", type: .quickfireCouples,
                        cards: allQuickfireCouplesCards, availableCategories: [])
        QuickfireCouplesPlayView(manager: manager, deck: deck, selectedCategories: [],
                                 roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
    }
}

private struct OnlineCTEView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int

    @StateObject private var manager: CloserThanEverGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let deck = Deck(
            title: "Closer Than Ever",
            description: "Deep questions to bring you and your partner closer.",
            numberOfCards: allCloserThanEverCards.count,
            estimatedTime: "30-45 min",
            imageName: "Closer than ever",
            type: .closerThanEver,
            cards: allCloserThanEverCards,
            availableCategories: []
        )
        _manager = StateObject(wrappedValue: CloserThanEverGameManager(deck: deck, selectedCategories: [], cardCount: cardCount ?? 0))
    }

    var body: some View {
        let deck = Deck(title: "Closer Than Ever", description: "", numberOfCards: allCloserThanEverCards.count,
                        estimatedTime: "30-45 min", imageName: "Closer than ever", type: .closerThanEver,
                        cards: allCloserThanEverCards, availableCategories: [])
        CloserThanEverPlayView(manager: manager, deck: deck, selectedCategories: [],
                               roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
    }
}

private struct OnlineUADView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int

    @StateObject private var manager: UsAfterDarkGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let deck = Deck(
            title: "Us After Dark",
            description: "Intimate questions for after dark conversations.",
            numberOfCards: allUsAfterDarkCards.count,
            estimatedTime: "30-45 min",
            imageName: "us after dark",
            type: .usAfterDark,
            cards: allUsAfterDarkCards,
            availableCategories: []
        )
        _manager = StateObject(wrappedValue: UsAfterDarkGameManager(deck: deck, selectedCategories: [], cardCount: cardCount ?? 0))
    }

    var body: some View {
        let deck = Deck(title: "Us After Dark", description: "", numberOfCards: allUsAfterDarkCards.count,
                        estimatedTime: "30-45 min", imageName: "us after dark", type: .usAfterDark,
                        cards: allUsAfterDarkCards, availableCategories: [])
        UsAfterDarkPlayView(manager: manager, deck: deck, selectedCategories: [],
                            roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
    }
}

private struct OnlineSpillTheExView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int

    @StateObject private var manager: SpillTheExGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0

        let deck = Deck(
            title: "Spill the Ex",
            description: "Hot takes about past relationships.",
            numberOfCards: allSpillTheExCards.count,
            estimatedTime: "20-30 min",
            imageName: "Spill the Ex",
            type: .spillTheEx,
            cards: allSpillTheExCards,
            availableCategories: onlineSpillTheExCategories
        )
        _manager = StateObject(wrappedValue: SpillTheExGameManager(deck: deck, selectedCategories: onlineSpillTheExCategories, cardCount: cardCount ?? 0))
    }

    var body: some View {
        let deck = Deck(
            title: "Spill the Ex",
            description: "",
            numberOfCards: allSpillTheExCards.count,
            estimatedTime: "20-30 min",
            imageName: "Spill the Ex",
            type: .spillTheEx,
            cards: allSpillTheExCards,
            availableCategories: onlineSpillTheExCategories
        )
        SpillTheExPlayView(
            manager: manager,
            deck: deck,
            selectedCategories: onlineSpillTheExCategories,
            roomId: roomCode,
            isHost: isHost,
            players: players,
            currentUserId: currentUserId
        )
    }
}

private struct OnlineTIPView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int

    @StateObject private var manager: TIPGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0

        let deck = Deck(
            title: "Take It Personally",
            description: "Bold statements about the group",
            numberOfCards: allTIPCards.count,
            estimatedTime: "20-30 min",
            imageName: "take it personally",
            type: .takeItPersonally,
            cards: allTIPCards,
            availableCategories: onlineTIPCategories
        )
        _manager = StateObject(wrappedValue: TIPGameManager(deck: deck, selectedCategories: onlineTIPCategories, cardCount: cardCount ?? 0))
    }

    var body: some View {
        let deck = Deck(
            title: "Take It Personally",
            description: "",
            numberOfCards: allTIPCards.count,
            estimatedTime: "20-30 min",
            imageName: "take it personally",
            type: .takeItPersonally,
            cards: allTIPCards,
            availableCategories: onlineTIPCategories
        )
        TIPPlayView(
            manager: manager,
            deck: deck,
            selectedCategories: onlineTIPCategories,
            roomId: roomCode,
            isHost: isHost,
            players: players,
            currentUserId: currentUserId
        )
    }
}

private struct OnlineRMTView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int

    /// Deterministic card ordering keyed to the room code so all devices agree.
    private let cards: [Card]

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        // Riddle online uses this value as number of rounds.
        let count = (cardCount ?? 5) > 0 ? (cardCount ?? 5) : 5
        let shuffled = riddleDeterministicShuffle(allRiddleMeThisCards, roomCode: roomCode)
        self.cardCount = count
        self.cards = Array(shuffled.prefix(count))
    }

    var body: some View {
        RiddleMeThisOnlinePlayView(
            roomCode: roomCode,
            isHost: isHost,
            players: players,
            currentUserId: currentUserId,
            cards: cards
        )
    }
}

// MARK: -

struct OnlineGameContainerView: View {
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    @ObservedObject private var syncService = SyncService.shared
    // RMT uses its own sync service; observe it so the connection banner fires for that game too
    @ObservedObject private var rmtSyncService = RiddleMeThisOnlineSyncService.shared
    @State private var showWalkthrough = false
    @State private var showLoadingScreen = false
    @State private var hasShownLoading = false
    @AppStorage("colorClashShowWalkthrough") private var showWalkthroughPreference = false

    // Fix 1: host-left / room-dissolved detection
    @State private var showHostLeftAlert = false
    @State private var navigateToHome = false

    var body: some View {
        ZStack(alignment: .top) {
            // Hidden NavigationLink — fires when user taps "Go Home" after host leaves
            NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                EmptyView()
            }.hidden()

            // Main game content (unchanged logic)
            Group {
                // Only show game if status is still inGame - navigation handles the exit
                if let room = onlineManager.currentRoom,
                   room.status == .inGame,
                   let gameType = room.selectedGameType,
                   let myUserId = authManager.userProfile?.userId {

                    switch gameType {
                    case "colorClash":
                        // Color Clash specific walkthrough/loading
                        Group {
                            if showWalkthrough && showWalkthroughPreference {
                                ColorClashWalkthroughView(showCloseButton: false)
                                    .onDisappear {
                                        showLoadingScreen = true
                                    }
                            } else if showLoadingScreen && !hasShownLoading {
                                ColorClashLoadingScreen()
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                            withAnimation {
                                                hasShownLoading = true
                                                showLoadingScreen = false
                                            }
                                        }
                                    }
                            } else {
                                OnlineColorClashPlayView(roomCode: room.roomCode, myUserId: myUserId)
                            }
                        }
                        .onAppear {
                            if showWalkthroughPreference {
                                showWalkthrough = true
                            } else {
                                showLoadingScreen = true
                            }
                        }
                    case "flip21":
                        OnlineFlip21PlayView(roomCode: room.roomCode, myUserId: myUserId)
                    case "neverHaveIEver":
                        OnlineNHIEView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "truthOrDare":
                        OnlineTORView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "wouldYouRather":
                        OnlineWYRView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "mostLikelyTo":
                        OnlineMLTView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "quickfireCouples":
                        OnlineQFCView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "closerThanEver":
                        OnlineCTEView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "usAfterDark":
                        OnlineUADView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "spillTheEx":
                        OnlineSpillTheExView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "takeItPersonally":
                        OnlineTIPView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "riddleMeThis":
                        OnlineRMTView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "storyChain", "twoTruthsAndALie":
                        OnlineSyncedClassicGameView(
                            roomCode: room.roomCode,
                            gameType: gameType,
                            isHost: room.hostId == myUserId,
                            players: room.players
                        )
                    default:
                        // Placeholder for other games
                        VStack(spacing: 24) {
                            Text("Game: \(gameType)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text("Coming soon...")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    // Loading state (entering game)
                    VStack(spacing: 24) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        Text("Loading game...")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }

            // Fix 2: connection-lost banner — shown to non-hosts when Firestore drops.
            // Classic games use SyncService; Riddle Me This uses its own sync service.
            // Both are checked so the banner fires regardless of which game type is active.
            if (syncService.connectionLost || rmtSyncService.connectionLost) && !onlineManager.isHost {
                connectionLostBanner
                    .zIndex(1)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: syncService.connectionLost)
        // Fix 1: when the room disappears while a game is active, alert all players
        .onChange(of: onlineManager.currentRoom) { room in
            if room == nil && !showHostLeftAlert {
                showHostLeftAlert = true
            }
        }
        .alert("Host has left the game", isPresented: $showHostLeftAlert) {
            Button("Go Home") { navigateToHome = true }
        } message: {
            Text("The host has left. This game has ended.")
        }
    }

    // MARK: - Connection Lost Banner

    private var connectionLostBanner: some View {
        Text("Connection lost — trying to reconnect...")
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Color.orange)
    }
}

