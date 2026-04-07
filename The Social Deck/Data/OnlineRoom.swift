//
//  OnlineRoom.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Room Status

enum RoomStatus: String, Codable, Equatable {
    case waiting = "waiting"      // Waiting for players to join/ready up
    case starting = "starting"    // All ready, game starting
    case inGame = "inGame"        // Game is active
    case ended = "ended"          // Game ended
}

// MARK: - Room Player

struct RoomPlayer: Codable, Identifiable, Equatable {
    var id: String // User ID
    var username: String
    var avatarType: String
    var avatarColor: String
    var isReady: Bool
    var joinedAt: Date
    var isHost: Bool
    
    // Game-specific state (when in game)
    var gameScore: Int? // Score for current game
    var isActive: Bool? // Is this player's turn (for turn-based games)
    
    private enum CodingKeys: String, CodingKey {
        case id, username, avatarType, avatarColor, isReady, joinedAt, isHost, gameScore, isActive
    }
    
    init(
        id: String,
        username: String,
        avatarType: String,
        avatarColor: String,
        isReady: Bool = false,
        joinedAt: Date = Date(),
        isHost: Bool = false,
        gameScore: Int? = nil,
        isActive: Bool? = nil
    ) {
        self.id = id
        self.username = username
        self.avatarType = avatarType
        self.avatarColor = avatarColor
        self.isReady = isReady
        self.joinedAt = joinedAt
        self.isHost = isHost
        self.gameScore = gameScore
        self.isActive = isActive
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decodeIfPresent(String.self, forKey: .username) ?? "Player"
        avatarType = try container.decodeIfPresent(String.self, forKey: .avatarType) ?? "bear"
        avatarColor = try container.decodeIfPresent(String.self, forKey: .avatarColor) ?? "blue"
        isReady = try container.decodeIfPresent(Bool.self, forKey: .isReady) ?? false
        joinedAt = try container.decodeIfPresent(Date.self, forKey: .joinedAt) ?? Date()
        isHost = try container.decodeIfPresent(Bool.self, forKey: .isHost) ?? false
        gameScore = try container.decodeIfPresent(Int.self, forKey: .gameScore)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
    }
}

// MARK: - Online Room

struct OnlineRoom: Codable, Identifiable, Equatable {
    @DocumentID var id: String? // Room ID (also used as room code)
    
    // Room Info
    var roomCode: String // 4-6 character code (e.g., "ABCD")
    var roomName: String
    var createdBy: String // User ID of creator
    var createdAt: Date
    var status: RoomStatus
    
    // Settings
    var maxPlayers: Int // 2-8
    var isPrivate: Bool
    var selectedGameType: String? // DeckType stored as string (e.g., "neverHaveIEver")
    var selectedCategory: String? // Selected category for game
    /// Online classic/date/couple lobby: host-selected categories to include in play.
    var classicSelectedCategories: [String]?
    /// Number of cards to play for classic games; nil or 0 = use all cards
    var cardCount: Int?
    /// Riddle Me This online: countdown per answering phase (host lobby). Off when nil/false.
    var timerEnabled: Bool?
    /// Riddle Me This online: seconds for the round timer when enabled.
    var timerDuration: Int?
    /// Riddle Me This online: server time when answering phase began (card flipped); drives synced countdown.
    var roundStartTimestamp: Date?
    /// Online classic/date/couple games: when true, control rotates by player turn instead of staying with host.
    var classicTurnsEnabled: Bool?
    /// Act Natural online: host enables two unknowns when the room has 4+ players (mirrors local setup).
    var actNaturalTwoUnknowns: Bool?
    
    // Players
    var players: [RoomPlayer]
    var hostId: String // User ID of host (usually creator)
    
    // Game State (when in game)
    var gameStartedAt: Date?
    var gameState: ColorClashGameState? // For Color Clash game state
    var flip21GameState: Flip21GameState? // For Flip 21 game state
    
    private enum CodingKeys: String, CodingKey {
        case id, roomCode, roomName, createdBy, createdAt, status, maxPlayers, isPrivate
        case selectedGameType, selectedCategory, classicSelectedCategories, cardCount, timerEnabled, timerDuration, classicTurnsEnabled, actNaturalTwoUnknowns
        case roundStartTimestamp, players, hostId, gameStartedAt, gameState, flip21GameState
    }
    
    init(
        id: String? = nil,
        roomCode: String,
        roomName: String,
        createdBy: String,
        createdAt: Date = Date(),
        status: RoomStatus = .waiting,
        maxPlayers: Int = 4,
        isPrivate: Bool = false,
        selectedGameType: String? = nil,
        selectedCategory: String? = nil,
        classicSelectedCategories: [String]? = nil,
        cardCount: Int? = nil,
        timerEnabled: Bool? = nil,
        timerDuration: Int? = nil,
        roundStartTimestamp: Date? = nil,
        classicTurnsEnabled: Bool? = nil,
        actNaturalTwoUnknowns: Bool? = nil,
        players: [RoomPlayer] = [],
        hostId: String,
        gameStartedAt: Date? = nil,
        gameState: ColorClashGameState? = nil,
        flip21GameState: Flip21GameState? = nil
    ) {
        self.id = id
        self.roomCode = roomCode
        self.roomName = roomName
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.status = status
        self.maxPlayers = maxPlayers
        self.isPrivate = isPrivate
        self.selectedGameType = selectedGameType
        self.selectedCategory = selectedCategory
        self.classicSelectedCategories = classicSelectedCategories
        self.cardCount = cardCount
        self.timerEnabled = timerEnabled
        self.timerDuration = timerDuration
        self.roundStartTimestamp = roundStartTimestamp
        self.classicTurnsEnabled = classicTurnsEnabled
        self.actNaturalTwoUnknowns = actNaturalTwoUnknowns
        self.players = players
        self.hostId = hostId
        self.gameStartedAt = gameStartedAt
        self.gameState = gameState
        self.flip21GameState = flip21GameState
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = (try? container.decode(DocumentID<String>.self, forKey: .id)) ?? DocumentID(wrappedValue: nil)
        roomCode = try container.decode(String.self, forKey: .roomCode)
        roomName = try container.decodeIfPresent(String.self, forKey: .roomName) ?? "Room"
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy) ?? ""
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        status = try container.decodeIfPresent(RoomStatus.self, forKey: .status) ?? .waiting
        maxPlayers = try container.decodeIfPresent(Int.self, forKey: .maxPlayers) ?? 4
        isPrivate = try container.decodeIfPresent(Bool.self, forKey: .isPrivate) ?? false
        selectedGameType = try container.decodeIfPresent(String.self, forKey: .selectedGameType)
        selectedCategory = try container.decodeIfPresent(String.self, forKey: .selectedCategory)
        classicSelectedCategories = try container.decodeIfPresent([String].self, forKey: .classicSelectedCategories)
        cardCount = try container.decodeIfPresent(Int.self, forKey: .cardCount)
        timerEnabled = try container.decodeIfPresent(Bool.self, forKey: .timerEnabled)
        timerDuration = try container.decodeIfPresent(Int.self, forKey: .timerDuration)
        roundStartTimestamp = try container.decodeIfPresent(Date.self, forKey: .roundStartTimestamp)
        classicTurnsEnabled = try container.decodeIfPresent(Bool.self, forKey: .classicTurnsEnabled)
        actNaturalTwoUnknowns = try container.decodeIfPresent(Bool.self, forKey: .actNaturalTwoUnknowns)

        do {
            players = try container.decodeIfPresent([RoomPlayer].self, forKey: .players) ?? []
        } catch {
            print("[OnlineRoom.init] *** Players decode failed: \(error) — defaulting to empty array")
            players = []
        }

        hostId = try container.decodeIfPresent(String.self, forKey: .hostId) ?? ""
        gameStartedAt = try container.decodeIfPresent(Date.self, forKey: .gameStartedAt)

        do {
            gameState = try container.decodeIfPresent(ColorClashGameState.self, forKey: .gameState)
        } catch {
            print("[OnlineRoom.init] gameState decode failed: \(error) — defaulting to nil")
            gameState = nil
        }

        do {
            flip21GameState = try container.decodeIfPresent(Flip21GameState.self, forKey: .flip21GameState)
        } catch {
            print("[OnlineRoom.init] flip21GameState decode failed: \(error) — defaulting to nil")
            flip21GameState = nil
        }
    }
    
    // Helper computed property to get current player count
    var currentPlayerCount: Int {
        return players.count
    }
    
    // Helper computed property to check if room is full
    var isFull: Bool {
        return players.count >= maxPlayers
    }
    
    // Helper computed property to check if all players are ready
    var allPlayersReady: Bool {
        guard !players.isEmpty else { return false }
        return players.allSatisfy { $0.isReady }
    }
}

// MARK: - DeckType String Extension

extension DeckType {
    /// Convert DeckType to a string representation for Firestore storage
    var stringValue: String {
        switch self {
        case .neverHaveIEver: return "neverHaveIEver"
        case .truthOrDare: return "truthOrDare"
        case .wouldYouRather: return "wouldYouRather"
        case .mostLikelyTo: return "mostLikelyTo"
        case .takeItPersonally: return "takeItPersonally"
        case .twoTruthsAndALie: return "twoTruthsAndALie"
        case .categoryClash: return "categoryClash"
        case .spinTheBottle: return "spinTheBottle"
        case .storyChain: return "storyChain"
        case .memoryMaster: return "memoryMaster"
        case .bluffCall: return "bluffCall"
        case .hotPotato: return "hotPotato"
        case .rhymeTime: return "rhymeTime"
        case .tapDuel: return "tapDuel"
        case .whatsMySecret: return "whatsMySecret"
        case .riddleMeThis: return "riddleMeThis"
        case .actItOut: return "actItOut"
        case .actNatural: return "actNatural"
        case .colorClash: return "colorClash"
        case .flip21: return "flip21"
        case .quickfireCouples: return "quickfireCouples"
        case .closerThanEver: return "closerThanEver"
        case .usAfterDark: return "usAfterDark"
        case .spillTheEx: return "spillTheEx"
        case .other: return "other"
        }
    }
    
    /// Create DeckType from string representation
    init?(stringValue: String) {
        switch stringValue {
        case "neverHaveIEver": self = .neverHaveIEver
        case "truthOrDare": self = .truthOrDare
        case "wouldYouRather": self = .wouldYouRather
        case "mostLikelyTo": self = .mostLikelyTo
        case "takeItPersonally": self = .takeItPersonally
        case "twoTruthsAndALie": self = .twoTruthsAndALie
        case "categoryClash": self = .categoryClash
        case "spinTheBottle": self = .spinTheBottle
        case "storyChain": self = .storyChain
        case "memoryMaster": self = .memoryMaster
        case "bluffCall": self = .bluffCall
        case "hotPotato": self = .hotPotato
        case "rhymeTime": self = .rhymeTime
        case "tapDuel": self = .tapDuel
        case "whatsMySecret": self = .whatsMySecret
        case "riddleMeThis": self = .riddleMeThis
        case "actItOut": self = .actItOut
        case "actNatural": self = .actNatural
        case "colorClash": self = .colorClash
        case "flip21": self = .flip21
        case "quickfireCouples": self = .quickfireCouples
        case "closerThanEver": self = .closerThanEver
        case "usAfterDark": self = .usAfterDark
        case "spillTheEx": self = .spillTheEx
        case "other": self = .other
        default: return nil
        }
    }
}
