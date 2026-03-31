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

private let onlineClassicCategories = ["Party", "Wild", "Couples", "Social", "Dirty", "Friends", "Family"]
private let onlineWYRCategories = ["Party", "Wild", "Couples", "Social", "Dirty", "Friends", "Family", "Weird"]

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
        let activeCategories = (selectedCategories?.isEmpty == false) ? selectedCategories! : onlineClassicCategories
        self.selectedCategories = activeCategories
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
        _manager = StateObject(wrappedValue: NHIEGameManager(deck: deck, selectedCategories: activeCategories, cardCount: cardCount ?? 0, deterministicRoomCode: roomCode))
    }

    var body: some View {
        let deck = Deck(title: "Never Have I Ever", description: "", numberOfCards: allNHIECards.count,
                        estimatedTime: "30-45 min", imageName: "NHIE 2.0", type: .neverHaveIEver,
                        cards: allNHIECards, availableCategories: onlineClassicCategories)
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
    @State private var colorClashConnectionLost = false
    @State private var flip21ConnectionLost = false
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
            if anyConnectionLost && !onlineManager.isHost {
                connectionLostBanner
                    .zIndex(1)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: anyConnectionLost)
        .onReceive(NotificationCenter.default.publisher(for: .onlineColorClashConnectionStatusChanged)) { notification in
            colorClashConnectionLost = (notification.userInfo?["connectionLost"] as? Bool) ?? false
        }
        .onReceive(NotificationCenter.default.publisher(for: .onlineFlip21ConnectionStatusChanged)) { notification in
            flip21ConnectionLost = (notification.userInfo?["connectionLost"] as? Bool) ?? false
        }
        // When the room disappears, alert unless this device intentionally left (avoids false "host left" after self-leave).
        .onChange(of: onlineManager.currentRoom) { _, room in
            if room == nil {
                if !onlineManager.userChoseToLeaveRoomSession && !showHostLeftAlert {
                    showHostLeftAlert = true
                }
            }
        }
        .onChange(of: onlineManager.currentRoom?.status) { _, status in
            // Host returned room to waiting: pop all players back to lobby.
            if status == .waiting {
                dismiss()
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

    private var anyConnectionLost: Bool {
        syncService.connectionLost
            || rmtSyncService.connectionLost
            || colorClashConnectionLost
            || flip21ConnectionLost
    }
}

private extension Notification.Name {
    static let onlineColorClashConnectionStatusChanged = Notification.Name("onlineColorClashConnectionStatusChanged")
    static let onlineFlip21ConnectionStatusChanged = Notification.Name("onlineFlip21ConnectionStatusChanged")
}

