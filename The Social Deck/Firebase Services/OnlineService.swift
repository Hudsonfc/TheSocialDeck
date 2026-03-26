//
//  OnlineService.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class OnlineService {
    static let shared = OnlineService()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private init() {}
    
    // MARK: - Room Code Generation
    
    /// Generates a unique room code (4-6 uppercase alphanumeric characters)
    private func generateRoomCode() async throws -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let codeLength = 4
        
        var attempts = 0
        let maxAttempts = 10
        
        while attempts < maxAttempts {
            let code = String((0..<codeLength).map { _ in characters.randomElement()! })
            
            // Check if code already exists
            let roomRef = db.collection("rooms").document(code)
            let snapshot = try await roomRef.getDocument()
            
            if !snapshot.exists {
                return code
            }
            
            attempts += 1
        }
        
        throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate unique room code after \(maxAttempts) attempts"])
    }
    
    // MARK: - Room Creation
    
    /// Creates a new room in Firestore
    func createRoom(
        roomName: String,
        maxPlayers: Int,
        isPrivate: Bool,
        createdBy: String,
        playerProfile: RoomPlayer,
        gameType: String? = nil
    ) async throws -> OnlineRoom {
        guard let currentUser = auth.currentUser, currentUser.uid == createdBy else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let roomCode = try await generateRoomCode()
        
        let room = OnlineRoom(
            roomCode: roomCode,
            roomName: roomName,
            createdBy: createdBy,
            createdAt: Date(),
            status: .waiting,
            maxPlayers: maxPlayers,
            isPrivate: isPrivate,
            selectedGameType: gameType,
            players: [playerProfile],
            hostId: createdBy
        )
        
        let roomRef = db.collection("rooms").document(roomCode)
        try await roomRef.setData(from: room)
        
        return room
    }
    
    // MARK: - Room Joining
    
    /// Joins an existing room
    func joinRoom(roomCode: String, playerProfile: RoomPlayer) async throws -> OnlineRoom {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        let roomRef = db.collection("rooms").document(roomCode)

        print("[OnlineService.joinRoom] Attempting to join room: \(roomCode) as user: \(currentUserId)")

        // Transaction prevents race conditions when multiple users join at once.
        _ = try await db.runTransaction { transaction, errorPointer in
            do {
                let snapshot = try transaction.getDocument(roomRef)
                guard snapshot.exists, let raw = snapshot.data() else {
                    print("[OnlineService.joinRoom] Room document does not exist for code: \(roomCode)")
                    errorPointer?.pointee = NSError(
                        domain: "OnlineService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Room not found. Please check the room code."]
                    )
                    return nil
                }

                // DEBUG: Print raw Firestore document fields
                print("[OnlineService.joinRoom] === RAW FIRESTORE DOCUMENT ===")
                for (key, value) in raw {
                    print("[OnlineService.joinRoom]   \(key): \(type(of: value)) = \(value)")
                }
                print("[OnlineService.joinRoom] === END RAW DOCUMENT ===")

                let decoder = Firestore.Decoder()
                do {
                    var room = try decoder.decode(OnlineRoom.self, from: raw)
                    print("[OnlineService.joinRoom] Decode succeeded. Players: \(room.players.count), status: \(room.status.rawValue)")

                    if room.players.contains(where: { $0.id == currentUserId }) {
                        print("[OnlineService.joinRoom] Player already in room — no-op")
                        return nil
                    }

                    guard room.players.count < room.maxPlayers else {
                        print("[OnlineService.joinRoom] Room is full: \(room.players.count)/\(room.maxPlayers)")
                        errorPointer?.pointee = NSError(
                            domain: "OnlineService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "This room is full"]
                        )
                        return nil
                    }

                    guard room.status == .waiting else {
                        print("[OnlineService.joinRoom] Room status is \(room.status.rawValue), cannot join")
                        errorPointer?.pointee = NSError(
                            domain: "OnlineService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Cannot join room while game is in progress"]
                        )
                        return nil
                    }

                    room.players.append(playerProfile)

                    let encoder = Firestore.Encoder()
                    let playersData = try room.players.map { try encoder.encode($0) }
                    transaction.updateData(["players": playersData], forDocument: roomRef)
                    print("[OnlineService.joinRoom] Transaction update written with \(room.players.count) players")
                    return nil
                } catch {
                    // Decode failed — print detailed error info
                    print("[OnlineService.joinRoom] *** DECODE FAILED ***")
                    print("[OnlineService.joinRoom] Error: \(error)")
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("[OnlineService.joinRoom] Missing key: \(key.stringValue), path: \(context.codingPath.map(\.stringValue)), desc: \(context.debugDescription)")
                        case .typeMismatch(let type, let context):
                            print("[OnlineService.joinRoom] Type mismatch: expected \(type), path: \(context.codingPath.map(\.stringValue)), desc: \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            print("[OnlineService.joinRoom] Value not found: \(type), path: \(context.codingPath.map(\.stringValue)), desc: \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("[OnlineService.joinRoom] Data corrupted: path: \(context.codingPath.map(\.stringValue)), desc: \(context.debugDescription)")
                        @unknown default:
                            print("[OnlineService.joinRoom] Unknown decoding error: \(decodingError)")
                        }
                    }

                    // Fallback: print each field's raw type/value for diagnosis
                    print("[OnlineService.joinRoom] === RAW FIELD TYPES ===")
                    if let players = raw["players"] as? [[String: Any]] {
                        for (i, p) in players.enumerated() {
                            print("[OnlineService.joinRoom]   player[\(i)]:")
                            for (pk, pv) in p {
                                print("[OnlineService.joinRoom]     \(pk): \(type(of: pv)) = \(pv)")
                            }
                        }
                    } else {
                        print("[OnlineService.joinRoom]   players field type: \(type(of: raw["players"] as Any))")
                    }
                    print("[OnlineService.joinRoom] === END RAW FIELD TYPES ===")

                    errorPointer?.pointee = error as NSError
                    return nil
                }
            } catch {
                print("[OnlineService.joinRoom] Transaction outer error: \(error)")
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        // Return fresh room state after transactional join.
        let updatedSnapshot = try await roomRef.getDocument()
        if let rawData = updatedSnapshot.data() {
            print("[OnlineService.joinRoom] Post-join raw doc keys: \(rawData.keys.sorted())")
        }
        guard updatedSnapshot.exists else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found after join."])
        }
        do {
            let updatedRoom = try updatedSnapshot.data(as: OnlineRoom.self)
            print("[OnlineService.joinRoom] Post-join decode succeeded. Players: \(updatedRoom.players.count)")
            return updatedRoom
        } catch {
            print("[OnlineService.joinRoom] *** POST-JOIN DECODE FAILED ***")
            print("[OnlineService.joinRoom] Error: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("[OnlineService.joinRoom] Missing key: \(key.stringValue), path: \(context.codingPath.map(\.stringValue))")
                case .typeMismatch(let type, let context):
                    print("[OnlineService.joinRoom] Type mismatch: expected \(type), path: \(context.codingPath.map(\.stringValue))")
                case .valueNotFound(let type, let context):
                    print("[OnlineService.joinRoom] Value not found: \(type), path: \(context.codingPath.map(\.stringValue))")
                case .dataCorrupted(let context):
                    print("[OnlineService.joinRoom] Data corrupted: path: \(context.codingPath.map(\.stringValue))")
                @unknown default:
                    break
                }
            }
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room decode failed: \(error.localizedDescription)"])
        }
    }
    
    // MARK: - Room Leaving
    
    /// Leaves a room (removes player from room)
    /// Host leaving deletes the room for most games; **Riddle Me This in-game** promotes the next player or ends cleanly if one remains.
    func leaveRoom(roomCode: String, playerId: String) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()

        guard snapshot.exists, var room = try? snapshot.data(as: OnlineRoom.self) else {
            return
        }

        let encoder = Firestore.Encoder()

        if room.hostId == playerId {
            let isRiddleInGame = room.selectedGameType == "riddleMeThis" && room.status == .inGame

            if isRiddleInGame {
                let hostIndex = room.players.firstIndex(where: { $0.id == playerId }) ?? 0
                let oldHostName = room.players.first(where: { $0.id == playerId })?.username ?? "Host"
                let remainingCount = room.players.filter { $0.id != playerId }.count

                if remainingCount == 0 {
                    try await roomRef.delete()
                    return
                }

                if remainingCount == 1 {
                    var sole = room.players.first(where: { $0.id != playerId })!
                    sole.isHost = true
                    let playersData = try [sole].map { try encoder.encode($0) }
                    try await roomRef.updateData([
                        "players": playersData,
                        "hostId": sole.id,
                        "rmtRoundPhase": "ended",
                        "rmtHostHandoffSeq": FieldValue.increment(Int64(1)),
                        "rmtHostHandoffMessage": "\(oldHostName) left — game over",
                        "roundStartTimestamp": FieldValue.delete()
                    ])
                    return
                }

                // 2+ others: next player in circular order after host becomes host.
                let nextHostId = room.players[(hostIndex + 1) % room.players.count].id
                let newHostName = room.players.first(where: { $0.id == nextHostId })?.username ?? "Host"

                var newPlayers: [RoomPlayer] = room.players
                    .filter { $0.id != playerId }
                    .map { p in
                        var q = p
                        q.isHost = (p.id == nextHostId)
                        return q
                    }

                let playersData = try newPlayers.map { try encoder.encode($0) }
                try await roomRef.updateData([
                    "players": playersData,
                    "hostId": nextHostId,
                    "rmtHostHandoffSeq": FieldValue.increment(Int64(1)),
                    "rmtHostHandoffMessage": "\(oldHostName) left — \(newHostName) is now the host"
                ])
                return
            }

            try await roomRef.delete()
            return
        }

        room.players.removeAll { $0.id == playerId }

        if room.players.isEmpty {
            try await roomRef.delete()
            return
        }

        let playersData = try room.players.map { try encoder.encode($0) }
        try await roomRef.updateData(["players": playersData])
    }
    
    // MARK: - Room Updates
    
    /// Updates a player's ready status
    func updatePlayerReadyStatus(roomCode: String, playerId: String, isReady: Bool) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, var room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        // Update player's ready status
        if let index = room.players.firstIndex(where: { $0.id == playerId }) {
            room.players[index].isReady = isReady
            let encoder = Firestore.Encoder()
            let playersData = try room.players.map { try encoder.encode($0) }
            try await roomRef.updateData(["players": playersData])
        }
    }
    
    /// Updates room settings (game type, category) - host only
    func updateRoomSettings(roomCode: String, gameType: DeckType?, category: String?) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can update room settings"])
        }
        
        var updateData: [String: Any] = [:]
        
        if let gameType = gameType {
            updateData["selectedGameType"] = gameType.stringValue
        } else {
            updateData["selectedGameType"] = FieldValue.delete()
        }
        
        if let category = category {
            updateData["selectedCategory"] = category
        } else {
            updateData["selectedCategory"] = FieldValue.delete()
        }
        
        try await roomRef.updateData(updateData)
    }

    /// Updates number of cards to play for classic games (host only). nil = use all cards.
    func updateCardCount(roomCode: String, cardCount: Int?) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()

        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }

        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can update game settings"])
        }

        if let count = cardCount, count > 0 {
            try await roomRef.updateData(["cardCount": count])
        } else {
            try await roomRef.updateData(["cardCount": FieldValue.delete()])
        }
    }

    /// Updates selected classic/date/couple categories in lobby (host only). Empty/nil clears custom selection.
    func updateClassicSelectedCategories(roomCode: String, categories: [String]?) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()

        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }

        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can update game settings"])
        }

        if let categories, !categories.isEmpty {
            try await roomRef.updateData(["classicSelectedCategories": categories])
        } else {
            try await roomRef.updateData(["classicSelectedCategories": FieldValue.delete()])
        }
    }

    /// Updates online classic/date/couple turn mode setting (host only).
    func updateClassicTurnsSetting(roomCode: String, enabled: Bool) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()

        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }

        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can update game settings"])
        }

        try await roomRef.updateData(["classicTurnsEnabled": enabled])
    }

    /// Updates Riddle Me This timer lobby settings (host only). Writes immediately to Firestore.
    func updateRiddleTimerSettings(roomCode: String, timerEnabled: Bool, timerDuration: Int) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()

        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }

        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can update game settings"])
        }

        try await roomRef.updateData([
            "timerEnabled": timerEnabled,
            "timerDuration": timerDuration
        ])
    }

    /// Starts the game (updates room status to .starting, then .inGame)
    func startGame(roomCode: String) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can start the game"])
        }
        
        guard room.status == .waiting else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Game already started or ended"])
        }
        
        guard room.allPlayersReady && room.players.count >= 2 else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "All players must be ready and at least 2 players required"])
        }
        
        // Initialize game state based on game type
        if room.selectedGameType == "colorClash" {
            let gameState = try initializeColorClashGameState(room: room)
            try await roomRef.updateData([
                "status": RoomStatus.inGame.rawValue,
                "gameStartedAt": Timestamp(date: Date()),
                "gameState": try Firestore.Encoder().encode(gameState)
            ])
        } else if room.selectedGameType == "flip21" {
            let gameState = try initializeFlip21GameState(room: room)
            try await roomRef.updateData([
                "status": RoomStatus.inGame.rawValue,
                "gameStartedAt": Timestamp(date: Date()),
                "flip21GameState": try Firestore.Encoder().encode(gameState)
            ])
        } else {
            let classicTurnEligibleTypes: Set<String> = [
                "neverHaveIEver", "truthOrDare", "wouldYouRather", "mostLikelyTo",
                "quickfireCouples", "closerThanEver", "usAfterDark", "spillTheEx", "takeItPersonally"
            ]

            var payload: [String: Any] = [
                "status": RoomStatus.inGame.rawValue,
                "gameStartedAt": Timestamp(date: Date())
            ]

            let turnsEnabled = room.classicTurnsEnabled == true
            if turnsEnabled,
               let gameType = room.selectedGameType,
               classicTurnEligibleTypes.contains(gameType),
               let firstPlayerId = room.players.first?.id {
                payload["classicTurnPlayerId"] = firstPlayerId
                payload["currentCardIndex"] = 0
                payload["classicCardFlipped"] = false
                payload["torDisplayIndex"] = 0
                payload["torHasAccepted"] = false
                payload["wyrSelectedOption"] = FieldValue.delete()
            } else {
                payload["classicTurnPlayerId"] = FieldValue.delete()
                payload["torDisplayIndex"] = FieldValue.delete()
                payload["torHasAccepted"] = FieldValue.delete()
                payload["wyrSelectedOption"] = FieldValue.delete()
            }

            // Update room status to inGame and set game started time
            try await roomRef.updateData(payload)
        }
    }
    
    // MARK: - Color Clash Game State
    
    /// Initialize Color Clash game state
    private func initializeColorClashGameState(room: OnlineRoom) throws -> ColorClashGameState {
        // Create and shuffle deck
        var deck = ColorClashCard.createStandardDeck()
        deck.shuffle()
        
        // Deal 7 cards to each player
        var playerHands: [String: [ColorClashCard]] = [:]
        let playerIds = room.players.map { $0.id }
        
        for playerId in playerIds {
            let hand = Array(deck.prefix(7))
            deck.removeFirst(7)
            playerHands[playerId] = hand
        }
        
        // Place first card on discard pile (must be a number card, not action/wild)
        var firstCard: ColorClashCard
        if let firstCardIndex = deck.firstIndex(where: { $0.type == .number && $0.number != nil }) {
            firstCard = deck.remove(at: firstCardIndex)
        } else {
            // If no number card found, use first card (fallback)
            guard !deck.isEmpty else {
                throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Deck is empty"])
            }
            firstCard = deck.removeFirst()
        }
        
        let discardPile = [firstCard]
        
        // Determine current color
        let currentColor = firstCard.color ?? firstCard.selectedColor ?? .red
        
        // Random burned color
        let burnedColor = CardColor.allCases.randomElement()
        
        // Create game state
        let gameState = ColorClashGameState(
            deck: deck,
            discardPile: discardPile,
            playerHands: playerHands,
            currentPlayerId: playerIds[0],
            playerOrder: playerIds,
            turnDirection: 1,
            currentColor: currentColor,
            burnedColor: burnedColor,
            turnStartedAt: Date(),
            turnDuration: 30.0,
            status: .playing,
            winnerId: nil,
            lastCardDeclared: [:],
            pendingDrawCards: nil,
            skipNextPlayer: false,
            lastActionPlayer: nil,
            lastActionType: nil
        )
        
        return gameState
    }
    
    /// Updates the game state in Firestore
    func updateGameState(roomCode: String, gameState: ColorClashGameState) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let encoder = Firestore.Encoder()
        let gameStateData = try encoder.encode(gameState)
        try await roomRef.updateData(["gameState": gameStateData])
    }
    
    /// Listens to game state updates in real-time
    func listenToGameState(roomCode: String, completion: @escaping (Result<ColorClashGameState, Error>) -> Void) -> ListenerRegistration {
        let roomRef = db.collection("rooms").document(roomCode)
        
        return roomRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])))
                return
            }
            
            guard let data = snapshot.data(),
                  let gameStateData = data["gameState"] as? [String: Any] else {
                // No game state yet (game not started)
                return
            }
            
            do {
                let decoder = Firestore.Decoder()
                let gameState = try decoder.decode(ColorClashGameState.self, from: gameStateData)
                completion(.success(gameState))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Flip 21 Game State
    
    /// Initialize Flip 21 game state
    private func initializeFlip21GameState(room: OnlineRoom) throws -> Flip21GameState {
        // Create and shuffle deck
        var deck = Flip21Card.createStandardDeck()
        deck.shuffle()
        
        let playerIds = room.players.map { $0.id }
        var playerHands: [String: [Flip21Card]] = [:]
        var playerStatuses: [String: PlayerRoundStatus] = [:]
        
        // Deal 1 card to each player (revealed to themselves)
        for playerId in playerIds {
            var hand: [Flip21Card] = []
            guard !deck.isEmpty else { break }
            var card = deck.removeFirst()
            card.isRevealed = true // Revealed immediately for players to see
            hand.append(card)
            playerHands[playerId] = hand
            playerStatuses[playerId] = .active
        }
        
        // Deal 1 face-up card to dealer
        var dealerHand: [Flip21Card] = []
        if !deck.isEmpty {
            var dealerCard = deck.removeFirst()
            dealerCard.isRevealed = true
            dealerHand = [dealerCard]
        }
        
        // Create game state
        let gameState = Flip21GameState(
            deck: deck,
            dealerHand: dealerHand,
            playerHands: playerHands,
            playerStatuses: playerStatuses,
            playerOrder: playerIds,
            currentPlayerIndex: 0,
            roundStatus: .playerTurns,
            roundNumber: 1,
            scores: [:]
        )
        
        return gameState
    }
    
    /// Updates the Flip 21 game state in Firestore
    func updateFlip21GameState(roomCode: String, gameState: Flip21GameState) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let encoder = Firestore.Encoder()
        let gameStateData = try encoder.encode(gameState)
        try await roomRef.updateData(["flip21GameState": gameStateData])
    }
    
    /// Listens to Flip 21 game state updates in real-time
    func listenToFlip21GameState(roomCode: String, completion: @escaping (Result<Flip21GameState, Error>) -> Void) -> ListenerRegistration {
        let roomRef = db.collection("rooms").document(roomCode)
        
        return roomRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])))
                return
            }
            
            guard let data = snapshot.data(),
                  let gameStateData = data["flip21GameState"] as? [String: Any] else {
                // No game state yet (game not started)
                return
            }
            
            do {
                let decoder = Firestore.Decoder()
                let gameState = try decoder.decode(Flip21GameState.self, from: gameStateData)
                completion(.success(gameState))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Room Listening
    
    /// Listens to room updates in real-time
    func listenToRoom(roomCode: String, completion: @escaping (Result<OnlineRoom, Error>) -> Void) -> ListenerRegistration {
        let roomRef = db.collection("rooms").document(roomCode)
        
        return roomRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])))
                return
            }
            
            do {
                let room = try snapshot.data(as: OnlineRoom.self)
                completion(.success(room))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Room Validation
    
    /// Validates if a room code exists and can be joined
    func validateRoomCode(_ roomCode: String) async throws -> Bool {
        let roomRef = db.collection("rooms").document(roomCode.uppercased())
        let snapshot = try await roomRef.getDocument()
        return snapshot.exists
    }
    
    /// Gets a room by code (without joining)
    func getRoom(roomCode: String) async throws -> OnlineRoom? {
        let roomRef = db.collection("rooms").document(roomCode.uppercased())
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists else {
            return nil
        }
        
        return try? snapshot.data(as: OnlineRoom.self)
    }
    
    // MARK: - Room Invites
    
    /// Send a room invite to a user
    func sendRoomInvite(roomCode: String, roomName: String, toUserId: String) async throws {
        guard let fromUserId = auth.currentUser?.uid else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Check if invite already exists and is pending
        let existingInviteQuery = db.collection("roomInvites")
            .whereField("roomCode", isEqualTo: roomCode)
            .whereField("toUserId", isEqualTo: toUserId)
            .whereField("status", isEqualTo: RoomInviteStatus.pending.rawValue)
            .limit(to: 1)
        
        let existingInviteSnapshot = try await existingInviteQuery.getDocuments()
        if !existingInviteSnapshot.documents.isEmpty {
            // Invite already exists and is pending
            return
        }
        
        // Create new invite
        let invite = RoomInvite(
            roomCode: roomCode,
            roomName: roomName,
            fromUserId: fromUserId,
            toUserId: toUserId
        )
        
        let _ = try db.collection("roomInvites").addDocument(from: invite)
    }
    
    /// Get pending room invites for current user
    func getPendingRoomInvites() async throws -> [RoomInvite] {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let query = db.collection("roomInvites")
            .whereField("toUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: RoomInviteStatus.pending.rawValue)
            .whereField("expiresAt", isGreaterThan: Timestamp(date: Date()))
            .order(by: "createdAt", descending: true)
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents.compactMap { doc -> RoomInvite? in
            var invite = try? doc.data(as: RoomInvite.self)
            invite?.id = doc.documentID
            return invite
        }
    }
    
    /// Accept a room invite
    func acceptRoomInvite(_ inviteId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            print("[OnlineService.acceptRoomInvite] User not authenticated")
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        print("[OnlineService.acceptRoomInvite] Accepting invite \(inviteId) for user \(currentUserId)")
        let inviteRef = db.collection("roomInvites").document(inviteId)
        let inviteSnapshot = try await inviteRef.getDocument()

        guard let invite = try? inviteSnapshot.data(as: RoomInvite.self) else {
            print("[OnlineService.acceptRoomInvite] Failed to decode invite document")
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid invite — decode failed"])
        }
        print("[OnlineService.acceptRoomInvite] Invite decoded: room=\(invite.roomCode), status=\(invite.status.rawValue), toUser=\(invite.toUserId), expired=\(invite.isExpired)")

        guard invite.toUserId == currentUserId,
              invite.status == .pending,
              !invite.isExpired else {
            print("[OnlineService.acceptRoomInvite] Guard failed — toUser match: \(invite.toUserId == currentUserId), pending: \(invite.status == .pending), not expired: \(!invite.isExpired)")
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid or expired invite"])
        }

        try await inviteRef.updateData([
            "status": RoomInviteStatus.accepted.rawValue
        ])
        print("[OnlineService.acceptRoomInvite] Invite status updated to accepted")
    }
    
    /// Decline a room invite
    func declineRoomInvite(_ inviteId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let inviteRef = db.collection("roomInvites").document(inviteId)
        let inviteSnapshot = try await inviteRef.getDocument()
        
        guard let invite = try? inviteSnapshot.data(as: RoomInvite.self),
              invite.toUserId == currentUserId,
              invite.status == .pending else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid invite"])
        }
        
        // Update invite status
        try await inviteRef.updateData([
            "status": RoomInviteStatus.declined.rawValue
        ])
    }
    
    // MARK: - Room Deletion
    
    /// Deletes a room (host only)
    func deleteRoom(roomCode: String) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can delete the room"])
        }
        
        try await roomRef.delete()
    }

    /// Deletes the room if the signed-in user is still the host (used after game end delay; may delete while `inGame`).
    func deleteRoomDocumentIfCurrentUserIsHost(roomCode: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        guard snapshot.exists, let room = try? snapshot.data(as: OnlineRoom.self) else { return }
        guard room.hostId == currentUserId else { return }
        try await roomRef.delete()
    }
    
    // MARK: - Player Management
    
    /// Kick a player from the room (host only)
    func kickPlayer(roomCode: String, playerId: String) async throws {
        let roomRef = db.collection("rooms").document(roomCode)
        let snapshot = try await roomRef.getDocument()
        
        guard snapshot.exists, var room = try? snapshot.data(as: OnlineRoom.self) else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        guard let currentUserId = auth.currentUser?.uid, room.hostId == currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only the host can kick players"])
        }
        
        guard playerId != currentUserId else {
            throw NSError(domain: "OnlineService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot kick yourself"])
        }
        
        // Remove player from room
        room.players.removeAll { $0.id == playerId }
        
        // Update room
        let encoder = Firestore.Encoder()
        let playersData = try room.players.map { try encoder.encode($0) }
        try await roomRef.updateData(["players": playersData])
    }
    
    // MARK: - Stale room cleanup (client-side)

    /// Deletes **only** rooms where `createdBy` is the current user. Never touches other users' rooms.
    /// Never deletes rooms with status `inGame`.
    ///
    /// Deletes when ANY applies:
    /// - (`waiting` or `ended`) AND `createdAt` older than 2 hours
    /// - `waiting` AND at most 1 player AND `createdAt` older than 30 minutes
    func cleanupStaleRooms() async throws {
        guard let uid = auth.currentUser?.uid else { return }

        let snapshot = try await db.collection("rooms")
            .whereField("createdBy", isEqualTo: uid)
            .getDocuments()

        let now = Date()
        let twoHoursAgo = now.addingTimeInterval(-2 * 60 * 60)
        let thirtyMinutesAgo = now.addingTimeInterval(-30 * 60)

        for doc in snapshot.documents {
            guard let room = try? doc.data(as: OnlineRoom.self) else { continue }
            guard room.createdBy == uid else { continue }
            if room.status == .inGame { continue }

            let created = room.createdAt
            let playerCount = room.players.count

            let oldWaitingOrEnded = (room.status == .waiting || room.status == .ended) && created < twoHoursAgo
            let sparseWaitingLobby = room.status == .waiting && playerCount <= 1 && created < thirtyMinutesAgo

            if oldWaitingOrEnded || sparseWaitingLobby {
                try await doc.reference.delete()
            }
        }
    }
}
