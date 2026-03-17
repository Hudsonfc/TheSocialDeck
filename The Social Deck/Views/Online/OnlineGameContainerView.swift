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

private let onlineClassicCategories = ["Party", "Wild", "Couples", "Social", "Dirty", "Friends"]

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

// MARK: -

struct OnlineGameContainerView: View {
    @StateObject private var onlineManager = OnlineManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showWalkthrough = false
    @State private var showLoadingScreen = false
    @State private var hasShownLoading = false
    @AppStorage("colorClashShowWalkthrough") private var showWalkthroughPreference = false
    
    var body: some View {
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
    }
}

