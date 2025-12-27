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
    
    // Players
    var players: [RoomPlayer]
    var hostId: String // User ID of host (usually creator)
    
    // Game State (when in game)
    var gameStartedAt: Date?
    var gameState: ColorClashGameState? // For Color Clash game state
    var flip21GameState: Flip21GameState? // For Flip 21 game state
    
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
        self.players = players
        self.hostId = hostId
        self.gameStartedAt = gameStartedAt
        self.gameState = gameState
        self.flip21GameState = flip21GameState
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
        case .twoTruthsAndALie: return "twoTruthsAndALie"
        case .popCultureTrivia: return "popCultureTrivia"
        case .historyTrivia: return "historyTrivia"
        case .scienceTrivia: return "scienceTrivia"
        case .sportsTrivia: return "sportsTrivia"
        case .movieTrivia: return "movieTrivia"
        case .musicTrivia: return "musicTrivia"
        case .truthOrDrink: return "truthOrDrink"
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
        case .colorClash: return "colorClash"
        case .flip21: return "flip21"
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
        case "twoTruthsAndALie": self = .twoTruthsAndALie
        case "popCultureTrivia": self = .popCultureTrivia
        case "historyTrivia": self = .historyTrivia
        case "scienceTrivia": self = .scienceTrivia
        case "sportsTrivia": self = .sportsTrivia
        case "movieTrivia": self = .movieTrivia
        case "musicTrivia": self = .musicTrivia
        case "truthOrDrink": self = .truthOrDrink
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
        case "colorClash": self = .colorClash
        case "flip21": self = .flip21
        case "other": self = .other
        default: return nil
        }
    }
}
