# Online Features Architecture Map

## Current State
- ✅ Basic UI views exist (CreateRoomView, JoinRoomView, OnlineRoomView)
- ✅ Firebase Authentication is set up
- ✅ User profiles with unique usernames
- ✅ 21 different game types available
- ⚠️ Empty service/manager files (OnlineService, OnlineManager, OnlineRoom)
- ⚠️ No real-time synchronization yet

---

## 1. Data Models

### OnlineRoom (Firestore Document)
```swift
struct OnlineRoom: Codable, Identifiable {
    @DocumentID var id: String? // Room ID (also used as room code)
    
    // Room Info
    var roomCode: String // 4-6 character code (e.g., "ABCD")
    var roomName: String
    var createdBy: String // User ID of creator
    var createdAt: Date
    var status: RoomStatus // .waiting, .inGame, .ended
    
    // Settings
    var maxPlayers: Int (2-8)
    var isPrivate: Bool
    var selectedGameType: DeckType? // Selected game type
    var selectedCategory: String? // Selected category for game
    
    // Players
    var players: [RoomPlayer] // Array of players in room
    var hostId: String // User ID of host (usually creator)
    
    // Game State (when in game)
    var currentGameState: GameState? // Current game state if active
    var gameStartedAt: Date?
}

enum RoomStatus: String, Codable {
    case waiting = "waiting"      // Waiting for players to join/ready up
    case starting = "starting"    // All ready, game starting
    case inGame = "inGame"        // Game is active
    case ended = "ended"          // Game ended
}

struct RoomPlayer: Codable, Identifiable {
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
}
```

---

## 2. Services Layer

### OnlineService (Firestore Operations)
Responsibilities:
- Create room in Firestore
- Join room (add player to room)
- Leave room (remove player from room)
- Update room settings (game type, category, max players)
- Listen to room updates (real-time)
- Delete/close room
- Validate room code exists
- Check if room is full
- Update player ready status
- Start game (update room status)

Key Methods:
```swift
- createRoom(roomName, maxPlayers, isPrivate) -> String (room code)
- joinRoom(roomCode: String) async throws -> OnlineRoom
- leaveRoom(roomCode: String) async throws
- updatePlayerReadyStatus(roomCode: String, isReady: Bool) async throws
- updateRoomSettings(roomCode: String, gameType: DeckType?, category: String?) async throws
- startGame(roomCode: String) async throws
- listenToRoom(roomCode: String) -> AsyncStream<OnlineRoom>
- deleteRoom(roomCode: String) async throws
```

---

## 3. Manager Layer

### OnlineManager (Business Logic & State Management)
Responsibilities:
- Manage current room state
- Handle room lifecycle (create, join, leave)
- Coordinate game synchronization
- Handle real-time updates
- Manage player interactions
- Error handling and recovery

Key Properties:
```swift
@Published var currentRoom: OnlineRoom?
@Published var isLoading: Bool
@Published var errorMessage: String?
@Published var isConnected: Bool
```

Key Methods:
```swift
- createRoom(settings) async
- joinRoom(roomCode) async
- leaveRoom() async
- toggleReadyStatus() async
- selectGameType(gameType) async
- selectCategory(category) async
- startGame() async
- listenToRoomUpdates() // Real-time listener
- cleanup() // Remove listeners, cleanup state
```

---

## 4. Game Synchronization

### GameState (when room.status == .inGame)
```swift
struct GameState: Codable {
    var currentCardIndex: Int
    var currentCard: Card
    var currentPlayerId: String? // For turn-based games
    var round: Int
    var scores: [String: Int] // [userId: score]
    var actions: [GameAction] // History of actions
    var settings: GameSettings // Game-specific settings
}

struct GameAction: Codable {
    var id: String
    var type: ActionType
    var playerId: String
    var timestamp: Date
    var data: [String: Any]? // Action-specific data
}

enum ActionType: String, Codable {
    case cardDrawn
    case cardAnswered
    case turnPassed
    case scoreUpdated
    // Game-specific actions
}
```

### SyncService (Game Synchronization)
Responsibilities:
- Sync current card across all players
- Sync game state (scores, rounds, turns)
- Handle player actions in real-time
- Manage turn-based game flow
- Sync game end conditions

---

## 5. Room Lifecycle Flow

### Creating a Room
1. User taps "Create Room" → CreateRoomView
2. User fills in: room name, max players, private/public
3. OnlineManager.createRoom() called
4. OnlineService generates unique room code (4-6 chars)
5. Creates Firestore document in `rooms/{roomCode}`
6. Adds creator as first player (host, ready=false)
7. Navigate to OnlineRoomView
8. Start listening to room updates

### Joining a Room
1. User taps "Join Room" → JoinRoomView
2. User enters room code
3. OnlineManager.joinRoom(roomCode) called
4. OnlineService validates room exists, not full, not in game
5. Adds player to room.players array
6. Updates Firestore room document
7. Navigate to OnlineRoomView
8. Start listening to room updates

### In Room (OnlineRoomView)
1. Display room code
2. Display player list with avatars
3. Show ready status for each player
4. Host can select game type and category
5. All players can toggle ready status
6. When all ready + host starts → change status to .starting
7. Real-time updates via Firestore listener

### Starting Game
1. Host taps "Start Game" (enabled when all ready)
2. OnlineManager.startGame() called
3. OnlineService updates room.status = .starting
4. Randomize/shuffle cards
5. Initialize GameState
6. Update room.status = .inGame
7. Navigate to appropriate game play view (e.g., NHIEPlayView)
8. Game view syncs via GameState

### Leaving Room
1. User taps "Leave Room"
2. OnlineManager.leaveRoom() called
3. Remove player from room.players array
4. If host leaves → transfer host to next player (or delete room if empty)
5. If room becomes empty → delete room document
6. Cleanup listeners
7. Navigate back to OnlineView

---

## 6. Real-Time Synchronization Strategy

### Firestore Listeners
- Use Firestore `addSnapshotListener` for real-time updates
- Listen to room document changes
- Update local state when room changes
- Handle player joins/leaves in real-time
- Handle ready status changes
- Handle game state changes during gameplay

### Update Flow
```
Room Change (Firestore) 
  → OnlineService listener fires
  → OnlineManager updates @Published currentRoom
  → UI automatically updates (SwiftUI reactivity)
```

---

## 7. Error Handling

### Common Scenarios
- Room not found (invalid code)
- Room is full
- Room already in game (can't join)
- Network disconnection
- Player disconnect during game
- Host leaves mid-game
- Room deleted while user is in it

### Recovery Strategies
- Show error alerts
- Auto-leave room on errors
- Handle network reconnection
- Graceful degradation

---

## 8. Security Rules (Firestore)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Room access rules
    match /rooms/{roomCode} {
      // Anyone can read (to check if room exists)
      allow read: if true;
      
      // Only authenticated users can write
      allow create: if request.auth != null;
      
      // Players can update their own ready status
      // Host can update room settings
      allow update: if request.auth != null && 
        (request.resource.data.diff(resource.data).affectedKeys()
         .hasOnly(['players']) || 
         resource.data.hostId == request.auth.uid);
      
      // Only host can delete
      allow delete: if request.auth != null && 
        resource.data.hostId == request.auth.uid;
    }
  }
}
```

---

## 9. Implementation Order (Recommended)

### Phase 1: Core Room Management
1. ✅ OnlineRoom data model
2. ✅ OnlineService - Create/Join/Leave room
3. ✅ OnlineManager - Room state management
4. ✅ Update CreateRoomView with functionality
5. ✅ Update JoinRoomView with functionality
6. ✅ Update OnlineRoomView with real player list

### Phase 2: Real-Time Sync
7. ✅ Firestore listeners for room updates
8. ✅ Real-time player list updates
9. ✅ Ready status synchronization
10. ✅ Host transfer on leave

### Phase 3: Game Selection & Start
11. ✅ Game type selection (host only)
12. ✅ Category selection (host only)
13. ✅ Start game functionality
14. ✅ Navigate to game view

### Phase 4: Game Synchronization
15. ✅ GameState model
16. ✅ SyncService for game sync
17. ✅ Card synchronization during gameplay
18. ✅ Score synchronization
19. ✅ Game end synchronization

### Phase 5: Polish & Edge Cases
20. ✅ Error handling
21. ✅ Network disconnection handling
22. ✅ Room cleanup (auto-delete empty rooms)
23. ✅ UI polish and animations

---

## 10. Technical Considerations

### Room Code Generation
- Generate 4-6 character codes (alphanumeric uppercase)
- Check uniqueness in Firestore
- Retry if collision (very rare with proper length)

### Performance
- Limit room listener to current room only
- Batch player updates if possible
- Use Firestore indexes for queries

### Scalability
- Rooms are ephemeral (delete when empty or game ends)
- No need for complex querying (direct room code access)
- Consider room TTL (auto-delete after X hours of inactivity)

### Testing
- Test with multiple devices/simulators
- Test network disconnection scenarios
- Test host leaving scenarios
- Test room full scenarios
- Test invalid room codes

---

## Questions to Consider

1. **Room Persistence**: Should rooms persist after game ends, or auto-delete?
   - Recommendation: Auto-delete after game ends or when empty

2. **Reconnection**: What happens if a player disconnects mid-game?
   - Recommendation: Mark as inactive, allow rejoin if reconnects within X minutes

3. **Game Type Restrictions**: Can all 21 game types be played online?
   - Some games may be better suited for online (turn-based) vs others (real-time)

4. **Spectator Mode**: Should there be a spectator mode for full rooms?
   - Could be future feature

5. **Room Discovery**: Public room browser vs code-only?
   - Currently code-only (simpler, more private)

---

## Next Steps

1. Review and approve this architecture
2. Start with Phase 1 implementation
3. Test incrementally as we build
4. Iterate based on testing and feedback




