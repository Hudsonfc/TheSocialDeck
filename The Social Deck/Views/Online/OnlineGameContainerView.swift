//
//  OnlineGameContainerView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

#if DEBUG
/// Confirms deterministic shuffle matches across devices (compare logs on host vs guest).
fileprivate func debugPrintOnlineDeckOrder(game: String, roomCode: String, cards: [Card]) {
    let first = cards.prefix(3).map(\.text)
    print("[OnlineClassic deck] game=\(game) room=\(roomCode) first3=\(first)")
}
#endif

// MARK: - Online wrappers for the 4 classic card games
// Each wrapper creates the full deck + manager so the play view can be launched
// from the online flow with roomId/isHost without touching the local launch path.

/// Used by Truth or Dare and Most Likely To online decks (unchanged category keys).
private let onlineClassicCategories = ["Party", "Wild", "Couples", "Social", "Dirty", "Friends"]
private let onlineNHIECategories = ["Confessions", "Couples", "The Usual", "Spill the Tea", "Wild Side", "After Dark"]
private let onlineWYRCategories = ["Party", "Couples", "Social", "Dirty", "Friends", "Weird"]

private let onlineSpillTheExCategories = ["Confessions", "Situationship", "The Breakup", "Wild Side"]
private let onlineTIPCategories = ["Party", "Wild", "Friends", "Couples"]

private struct OnlineNHIEView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int
    let selectedCategories: [String]

    @StateObject private var manager: NHIEGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil, selectedCategories: [String]? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let activeCategories = (selectedCategories?.isEmpty == false) ? selectedCategories! : onlineNHIECategories
        self.selectedCategories = activeCategories
        let deck = Deck(
            title: "Never Have I Ever",
            description: "Reveal your wildest experiences and learn about your friends.",
            numberOfCards: allNHIECards.count,
            estimatedTime: "30-45 min",
            imageName: "NHIE 2.0",
            type: .neverHaveIEver,
            cards: allNHIECards,
            availableCategories: onlineNHIECategories
        )
        _manager = StateObject(wrappedValue: NHIEGameManager(deck: deck, selectedCategories: activeCategories, cardCount: cardCount ?? 0, deterministicRoomCode: roomCode))
    }

    var body: some View {
        let deck = Deck(title: "Never Have I Ever", description: "", numberOfCards: allNHIECards.count,
                        estimatedTime: "30-45 min", imageName: "NHIE 2.0", type: .neverHaveIEver,
                        cards: allNHIECards, availableCategories: onlineNHIECategories)
        NHIEPlayView(manager: manager, deck: deck, selectedCategories: selectedCategories,
                     roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
            .onAppear {
                #if DEBUG
                debugPrintOnlineDeckOrder(game: "neverHaveIEver", roomCode: roomCode, cards: manager.cards)
                #endif
            }
    }
}

private struct OnlineTORView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int
    let selectedCategories: [String]

    @StateObject private var manager: TORGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil, selectedCategories: [String]? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let activeCategories = (selectedCategories?.isEmpty == false) ? selectedCategories! : onlineClassicCategories
        self.selectedCategories = activeCategories
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
        _manager = StateObject(wrappedValue: TORGameManager(deck: deck, selectedCategories: activeCategories, cardCount: cardCount ?? 0, deterministicRoomCode: roomCode))
    }

    var body: some View {
        let deck = Deck(title: "Truth or Dare", description: "", numberOfCards: allTORCards.count,
                        estimatedTime: "30-45 min", imageName: "TOD 2.0", type: .truthOrDare,
                        cards: allTORCards, availableCategories: onlineClassicCategories)
        TORPlayView(manager: manager, deck: deck, selectedCategories: selectedCategories,
                    roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
            .onAppear {
                #if DEBUG
                debugPrintOnlineDeckOrder(game: "truthOrDare", roomCode: roomCode, cards: manager.cards)
                #endif
            }
    }
}

private struct OnlineWYRView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int
    let selectedCategories: [String]

    @StateObject private var manager: WYRGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil, selectedCategories: [String]? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let activeCategories = (selectedCategories?.isEmpty == false) ? selectedCategories! : onlineWYRCategories
        self.selectedCategories = activeCategories
        let deck = Deck(
            title: "Would You Rather",
            description: "Make tough choices and discover what your friends prefer.",
            numberOfCards: allWYRCards.count,
            estimatedTime: "30-45 min",
            imageName: "WYR 2.0",
            type: .wouldYouRather,
            cards: allWYRCards,
            availableCategories: onlineWYRCategories
        )
        _manager = StateObject(wrappedValue: WYRGameManager(deck: deck, selectedCategories: activeCategories, cardCount: cardCount ?? 0, deterministicRoomCode: roomCode))
    }

    var body: some View {
        let deck = Deck(title: "Would You Rather", description: "", numberOfCards: allWYRCards.count,
                        estimatedTime: "30-45 min", imageName: "WYR 2.0", type: .wouldYouRather,
                        cards: allWYRCards, availableCategories: onlineWYRCategories)
        WYRPlayView(manager: manager, deck: deck, selectedCategories: selectedCategories,
                    roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
            .onAppear {
                #if DEBUG
                debugPrintOnlineDeckOrder(game: "wouldYouRather", roomCode: roomCode, cards: manager.cards)
                #endif
            }
    }
}

private struct OnlineMLTView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int
    let selectedCategories: [String]

    @StateObject private var manager: MLTGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil, selectedCategories: [String]? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let activeCategories = (selectedCategories?.isEmpty == false) ? selectedCategories! : onlineClassicCategories
        self.selectedCategories = activeCategories
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
        _manager = StateObject(wrappedValue: MLTGameManager(deck: deck, selectedCategories: activeCategories, cardCount: cardCount ?? 0, deterministicRoomCode: roomCode))
    }

    var body: some View {
        let deck = Deck(title: "Most Likely To", description: "", numberOfCards: allMLTCards.count,
                        estimatedTime: "30-45 min", imageName: "MLT 2.0", type: .mostLikelyTo,
                        cards: allMLTCards, availableCategories: onlineClassicCategories)
        MLTPlayView(manager: manager, deck: deck, selectedCategories: selectedCategories,
                    roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
            .onAppear {
                #if DEBUG
                debugPrintOnlineDeckOrder(game: "mostLikelyTo", roomCode: roomCode, cards: manager.cards)
                #endif
            }
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
        _manager = StateObject(wrappedValue: QuickfireCouplesGameManager(deck: deck, selectedCategories: [], cardCount: cardCount ?? 0, deterministicRoomCode: roomCode))
    }

    var body: some View {
        let deck = Deck(title: "Quickfire Couples", description: "", numberOfCards: allQuickfireCouplesCards.count,
                        estimatedTime: "20-30 min", imageName: "Quickfire Couples", type: .quickfireCouples,
                        cards: allQuickfireCouplesCards, availableCategories: [])
        QuickfireCouplesPlayView(manager: manager, deck: deck, selectedCategories: [],
                                 roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
            .onAppear {
                #if DEBUG
                debugPrintOnlineDeckOrder(game: "quickfireCouples", roomCode: roomCode, cards: manager.cards)
                #endif
            }
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
        _manager = StateObject(wrappedValue: CloserThanEverGameManager(deck: deck, selectedCategories: [], cardCount: cardCount ?? 0, deterministicRoomCode: roomCode))
    }

    var body: some View {
        let deck = Deck(title: "Closer Than Ever", description: "", numberOfCards: allCloserThanEverCards.count,
                        estimatedTime: "30-45 min", imageName: "Closer than ever", type: .closerThanEver,
                        cards: allCloserThanEverCards, availableCategories: [])
        CloserThanEverPlayView(manager: manager, deck: deck, selectedCategories: [],
                               roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
            .onAppear {
                #if DEBUG
                debugPrintOnlineDeckOrder(game: "closerThanEver", roomCode: roomCode, cards: manager.cards)
                #endif
            }
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
        _manager = StateObject(wrappedValue: UsAfterDarkGameManager(deck: deck, selectedCategories: [], cardCount: cardCount ?? 0, deterministicRoomCode: roomCode))
    }

    var body: some View {
        let deck = Deck(title: "Us After Dark", description: "", numberOfCards: allUsAfterDarkCards.count,
                        estimatedTime: "30-45 min", imageName: "us after dark", type: .usAfterDark,
                        cards: allUsAfterDarkCards, availableCategories: [])
        UsAfterDarkPlayView(manager: manager, deck: deck, selectedCategories: [],
                            roomId: roomCode, isHost: isHost, players: players, currentUserId: currentUserId)
            .onAppear {
                #if DEBUG
                debugPrintOnlineDeckOrder(game: "usAfterDark", roomCode: roomCode, cards: manager.cards)
                #endif
            }
    }
}

private struct OnlineSpillTheExView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int
    let selectedCategories: [String]

    @StateObject private var manager: SpillTheExGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil, selectedCategories: [String]? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let activeCategories = (selectedCategories?.isEmpty == false) ? selectedCategories! : onlineSpillTheExCategories
        self.selectedCategories = activeCategories

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
        _manager = StateObject(wrappedValue: SpillTheExGameManager(deck: deck, selectedCategories: activeCategories, cardCount: cardCount ?? 0, deterministicRoomCode: roomCode))
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
            selectedCategories: selectedCategories,
            roomId: roomCode,
            isHost: isHost,
            players: players,
            currentUserId: currentUserId
        )
        .onAppear {
            #if DEBUG
            debugPrintOnlineDeckOrder(game: "spillTheEx", roomCode: roomCode, cards: manager.cards)
            #endif
        }
    }
}

private struct OnlineTIPView: View {
    let roomCode: String
    let isHost: Bool
    let players: [RoomPlayer]
    let currentUserId: String?
    let cardCount: Int
    let selectedCategories: [String]

    @StateObject private var manager: TIPGameManager

    init(roomCode: String, isHost: Bool, players: [RoomPlayer], currentUserId: String?, cardCount: Int? = nil, selectedCategories: [String]? = nil) {
        self.roomCode = roomCode
        self.isHost = isHost
        self.players = players
        self.currentUserId = currentUserId
        self.cardCount = cardCount ?? 0
        let activeCategories = (selectedCategories?.isEmpty == false) ? selectedCategories! : onlineTIPCategories
        self.selectedCategories = activeCategories

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
        _manager = StateObject(wrappedValue: TIPGameManager(deck: deck, selectedCategories: activeCategories, cardCount: cardCount ?? 0, deterministicRoomCode: roomCode))
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
            selectedCategories: selectedCategories,
            roomId: roomCode,
            isHost: isHost,
            players: players,
            currentUserId: currentUserId
        )
        .onAppear {
            #if DEBUG
            debugPrintOnlineDeckOrder(game: "takeItPersonally", roomCode: roomCode, cards: manager.cards)
            #endif
        }
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
        .onAppear {
            #if DEBUG
            debugPrintOnlineDeckOrder(game: "riddleMeThis", roomCode: roomCode, cards: cards)
            #endif
        }
    }
}

// MARK: -

struct OnlineGameContainerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    @ObservedObject private var syncService = SyncService.shared
    // RMT uses its own sync service; observe it so the connection banner fires for that game too
    @ObservedObject private var rmtSyncService = RiddleMeThisOnlineSyncService.shared
    @ObservedObject private var actNaturalSyncService = ActNaturalOnlineSyncService.shared
    @State private var colorClashConnectionLost = false
    @State private var flip21ConnectionLost = false
    @State private var showWalkthrough = false
    @State private var showLoadingScreen = false
    @State private var hasShownLoading = false
    @AppStorage("colorClashShowWalkthrough") private var showWalkthroughPreference = false

    @State private var navigateToHome = false
    /// True once we've seen an in-game room in this container (avoids "host left" on a bad initial load).
    @State private var hasEnteredInGameInThisContainer = false
    /// Preserved when `currentRoom` becomes nil so we still know this device was the host.
    @State private var wasHostForThisGameSession = false

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
                        OnlineNHIEView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount, selectedCategories: room.classicSelectedCategories)
                    case "truthOrDare":
                        OnlineTORView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount, selectedCategories: room.classicSelectedCategories)
                    case "wouldYouRather":
                        OnlineWYRView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount, selectedCategories: room.classicSelectedCategories)
                    case "mostLikelyTo":
                        OnlineMLTView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount, selectedCategories: room.classicSelectedCategories)
                    case "quickfireCouples":
                        OnlineQFCView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "closerThanEver":
                        OnlineCTEView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "usAfterDark":
                        OnlineUADView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "spillTheEx":
                        OnlineSpillTheExView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount, selectedCategories: room.classicSelectedCategories)
                    case "takeItPersonally":
                        OnlineTIPView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount, selectedCategories: room.classicSelectedCategories)
                    case "riddleMeThis":
                        OnlineRMTView(roomCode: room.roomCode, isHost: room.hostId == myUserId, players: room.players, currentUserId: myUserId, cardCount: room.cardCount)
                    case "actNatural":
                        ActNaturalOnlinePlayView(
                            roomCode: room.roomCode,
                            isHost: room.hostId == myUserId,
                            players: room.players,
                            currentUserId: myUserId,
                            twoUnknownsFromLobby: room.actNaturalTwoUnknowns ?? false,
                            totalRounds: {
                                let c = room.cardCount ?? 5
                                return c > 0 ? c : 5
                            }()
                        )
                        .id("\(room.roomCode)-actNatural")
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

            if guestShouldSeeFriendlySessionEnd {
                guestFriendlySessionEndOverlay
                    .zIndex(2)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: guestShouldSeeFriendlySessionEnd)
        .onReceive(NotificationCenter.default.publisher(for: .onlineColorClashConnectionStatusChanged)) { notification in
            colorClashConnectionLost = (notification.userInfo?["connectionLost"] as? Bool) ?? false
        }
        .onReceive(NotificationCenter.default.publisher(for: .onlineFlip21ConnectionStatusChanged)) { notification in
            flip21ConnectionLost = (notification.userInfo?["connectionLost"] as? Bool) ?? false
        }
        .onChange(of: onlineManager.currentRoom) { _, room in
            if let room, room.status == .inGame, let uid = authManager.userProfile?.userId {
                hasEnteredInGameInThisContainer = true
                wasHostForThisGameSession = (room.hostId == uid)
            }
        }
        .onChange(of: onlineManager.currentRoom?.status) { _, status in
            // Host returned room to waiting: pop all players back to lobby.
            if status == .waiting {
                dismiss()
            }
        }
        .onAppear {
            if onlineManager.currentRoom?.selectedGameType != "actNatural" {
                ActNaturalOnlineSyncService.shared.teardownSession()
            }
        }
        .onDisappear {
            hasEnteredInGameInThisContainer = false
            wasHostForThisGameSession = false
            ActNaturalOnlineSyncService.shared.teardownSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: .onlineDismissGameContainerAfterActNaturalEnd)) { _ in
            dismiss()
        }
    }

    /// Calm end-of-session UI for guests (host leaving / room gone / listener errors), instead of an orange strip or system error feel.
    private var guestShouldSeeFriendlySessionEnd: Bool {
        guard !onlineManager.userChoseToLeaveRoomSession else { return false }
        guard hasEnteredInGameInThisContainer else { return false }
        guard !wasHostForThisGameSession else { return false }
        if onlineManager.currentRoom == nil { return true }
        return anyConnectionLost
    }

    private var guestFriendlySessionEndOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.xmark")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(Color.primaryAccent)

                Text("The host has left the game")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0))
                    .multilineTextAlignment(.center)

                Text("This online session has ended.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)

                Button {
                    navigateToHome = true
                } label: {
                    Text("Go Home")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.primaryAccent)
                        .cornerRadius(14)
                }
                .padding(.top, 8)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .padding(.horizontal, 32)
        }
    }

    private var anyConnectionLost: Bool {
        syncService.connectionLost
            || rmtSyncService.connectionLost
            || actNaturalSyncService.connectionLost
            || colorClashConnectionLost
            || flip21ConnectionLost
    }
}

private extension Notification.Name {
    static let onlineColorClashConnectionStatusChanged = Notification.Name("onlineColorClashConnectionStatusChanged")
    static let onlineFlip21ConnectionStatusChanged = Notification.Name("onlineFlip21ConnectionStatusChanged")
}

