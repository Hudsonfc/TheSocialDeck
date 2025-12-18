//
//  FriendService.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class FriendService: ObservableObject {
    static let shared = FriendService()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    @Published var friends: [FriendProfile] = []
    @Published var pendingRequests: [FriendRequest] = [] // Requests sent to me
    @Published var sentRequests: [FriendRequest] = [] // Requests I sent
    @Published var blockedUsers: [BlockedUser] = [] // Users I've blocked
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var friendsListener: ListenerRegistration?
    private var pendingRequestsListener: ListenerRegistration?
    private var sentRequestsListener: ListenerRegistration?
    
    private init() {}
    
    // MARK: - Friend Requests
    
    /// Send a friend request to a user
    func sendFriendRequest(to userId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        guard userId != currentUserId else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot send friend request to yourself"])
        }
        
        // Check if user is blocked
        if await isUserBlocked(userId) {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot send request to this user"])
        }
        
        // Check if friend request already exists
        let existingRequestQuery = db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .whereField("toUserId", isEqualTo: userId)
            .limit(to: 1)
        
        let existingRequestSnapshot = try await existingRequestQuery.getDocuments()
        
        if let existingDoc = existingRequestSnapshot.documents.first {
            let existingRequest = try existingDoc.data(as: FriendRequest.self)
            if existingRequest.status == .pending {
                throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Friend request already sent"])
            }
        }
        
        // Check if reverse request exists (they sent one to me)
        let reverseRequestQuery = db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: userId)
            .whereField("toUserId", isEqualTo: currentUserId)
            .limit(to: 1)
        
        let reverseRequestSnapshot = try await reverseRequestQuery.getDocuments()
        
        if let reverseDoc = reverseRequestSnapshot.documents.first {
            let reverseRequest = try reverseDoc.data(as: FriendRequest.self)
            if reverseRequest.status == .pending {
                // Accept the existing request instead
                try await acceptFriendRequest(reverseRequest.id!)
                return
            }
        }
        
        // Create new friend request
        let friendRequest = FriendRequest(
            fromUserId: currentUserId,
            toUserId: userId,
            status: .pending
        )
        
        let _ = try db.collection("friendRequests").addDocument(from: friendRequest)
    }
    
    /// Accept a friend request
    func acceptFriendRequest(_ requestId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let requestRef = db.collection("friendRequests").document(requestId)
        let requestSnapshot = try await requestRef.getDocument()
        
        guard let request = try? requestSnapshot.data(as: FriendRequest.self),
              request.toUserId == currentUserId,
              request.status == .pending else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid friend request"])
        }
        
        // Update request status to accepted
        try await requestRef.updateData([
            "status": FriendRequestStatus.accepted.rawValue,
            "updatedAt": Timestamp(date: Date())
        ])
        
        // Create reverse friend relationship (bidirectional)
        let reverseRequest = FriendRequest(
            fromUserId: request.toUserId,
            toUserId: request.fromUserId,
            status: .accepted,
            createdAt: request.createdAt,
            updatedAt: Date()
        )
        
        // Check if reverse already exists
        let reverseQuery = db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: request.toUserId)
            .whereField("toUserId", isEqualTo: request.fromUserId)
            .limit(to: 1)
        
        let reverseSnapshot = try await reverseQuery.getDocuments()
        if let reverseDoc = reverseSnapshot.documents.first {
            // Update existing reverse
            try await reverseDoc.reference.updateData([
                "status": FriendRequestStatus.accepted.rawValue,
                "updatedAt": Timestamp(date: Date())
            ])
        } else {
            // Create new reverse
            let _ = try db.collection("friendRequests").addDocument(from: reverseRequest)
        }
    }
    
    /// Reject a friend request
    func rejectFriendRequest(_ requestId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let requestRef = db.collection("friendRequests").document(requestId)
        let requestSnapshot = try await requestRef.getDocument()
        
        guard let request = try? requestSnapshot.data(as: FriendRequest.self),
              request.toUserId == currentUserId,
              request.status == .pending else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid friend request"])
        }
        
        // Update request status to rejected
        try await requestRef.updateData([
            "status": FriendRequestStatus.rejected.rawValue,
            "updatedAt": Timestamp(date: Date())
        ])
    }
    
    /// Remove a friend (delete the friend relationship)
    func removeFriend(_ userId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Delete both directions of the friend relationship
        let query1 = db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: FriendRequestStatus.accepted.rawValue)
        
        let query2 = db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: userId)
            .whereField("toUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: FriendRequestStatus.accepted.rawValue)
        
        let snapshot1 = try await query1.getDocuments()
        let snapshot2 = try await query2.getDocuments()
        
        for doc in snapshot1.documents {
            try await doc.reference.delete()
        }
        
        for doc in snapshot2.documents {
            try await doc.reference.delete()
        }
    }
    
    // MARK: - Load Friends
    
    /// Load all accepted friends
    func loadFriends() async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Get all accepted friend requests where I'm the sender or receiver
            let query = db.collection("friendRequests")
                .whereField("status", isEqualTo: FriendRequestStatus.accepted.rawValue)
                .whereField("fromUserId", isEqualTo: currentUserId)
            
            let snapshot = try await query.getDocuments()
            
            var friendProfiles: [FriendProfile] = []
            
            for doc in snapshot.documents {
                let request = try doc.data(as: FriendRequest.self)
                
                // Get the friend's profile
                let profileRef = db.collection("profiles").document(request.toUserId)
                let profileSnapshot = try await profileRef.getDocument()
                
                if let profile = try? profileSnapshot.data(as: UserProfile.self) {
                    let friendProfile = FriendProfile(profile: profile, friendRequestId: doc.documentID, isOnline: false)
                    friendProfiles.append(friendProfile)
                }
            }
            
            // Also check requests where I'm the receiver
            let receivedQuery = db.collection("friendRequests")
                .whereField("status", isEqualTo: FriendRequestStatus.accepted.rawValue)
                .whereField("toUserId", isEqualTo: currentUserId)
            
            let receivedSnapshot = try await receivedQuery.getDocuments()
            
            for doc in receivedSnapshot.documents {
                let request = try doc.data(as: FriendRequest.self)
                
                // Get the friend's profile
                let profileRef = db.collection("profiles").document(request.fromUserId)
                let profileSnapshot = try await profileRef.getDocument()
                
                if let profile = try? profileSnapshot.data(as: UserProfile.self) {
                    let friendProfile = FriendProfile(profile: profile, friendRequestId: doc.documentID, isOnline: false)
                    // Avoid duplicates
                    if !friendProfiles.contains(where: { $0.userId == friendProfile.userId }) {
                        friendProfiles.append(friendProfile)
                    }
                }
            }
            
            friends = friendProfiles
            isLoading = false
        } catch {
            errorMessage = "Failed to load friends: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }
    
    /// Load pending friend requests (sent to me)
    func loadPendingRequests() async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let query = db.collection("friendRequests")
            .whereField("toUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: FriendRequestStatus.pending.rawValue)
            .order(by: "createdAt", descending: true)
        
        let snapshot = try await query.getDocuments()
        var requests = try snapshot.documents.compactMap { doc -> FriendRequest? in
            var request = try doc.data(as: FriendRequest.self)
            request.id = doc.documentID
            
            // Filter out expired requests (auto-expire after 30 days)
            if request.isExpired {
                // Delete expired request
                Task {
                    try? await doc.reference.delete()
                }
                return nil
            }
            
            return request
        }
        
        // Filter out requests from blocked users
        let blockedUserIds = Set(blockedUsers.map { $0.blockedUserId })
        requests = requests.filter { !blockedUserIds.contains($0.fromUserId) }
        
        pendingRequests = requests
    }
    
    /// Load sent friend requests (requests I sent)
    func loadSentRequests() async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let query = db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: FriendRequestStatus.pending.rawValue)
            .order(by: "createdAt", descending: true)
        
        let snapshot = try await query.getDocuments()
        sentRequests = try snapshot.documents.compactMap { doc in
            var request = try doc.data(as: FriendRequest.self)
            request.id = doc.documentID
            return request
        }
    }
    
    // MARK: - Search Users
    
    /// Search for users by username (case-insensitive prefix search)
    func searchUsers(by username: String, limit: Int = 20) async throws -> [UserProfile] {
        guard !username.isEmpty, username.count >= 2 else {
            return []
        }
        
        let searchLower = username.lowercased()
        
        // Firestore doesn't support case-insensitive search directly
        // We'll do a prefix search using the lowercase version
        // Note: This requires usernames to be stored in lowercase for optimal results
        // For now, we'll search using the provided case and also try lowercase
        let query = db.collection("profiles")
            .whereField("username", isGreaterThanOrEqualTo: searchLower)
            .whereField("username", isLessThan: searchLower + "\u{f8ff}")
            .limit(to: limit)
        
        let snapshot = try await query.getDocuments()
        
        var results = try snapshot.documents.compactMap { doc -> UserProfile? in
            try? doc.data(as: UserProfile.self)
        }
        
        // Filter results to include only profiles that contain the search term (case-insensitive)
        results = results.filter { profile in
            profile.username.lowercased().hasPrefix(searchLower)
        }
        
        // Filter out blocked users
        let blockedUserIds = Set(blockedUsers.map { $0.blockedUserId })
        results = results.filter { !blockedUserIds.contains($0.userId) }
        
        return results
    }
    
    /// Get user profile by ID
    func getUserProfile(userId: String) async throws -> UserProfile? {
        let profileRef = db.collection("profiles").document(userId)
        let snapshot = try await profileRef.getDocument()
        
        guard snapshot.exists else {
            return nil
        }
        
        return try? snapshot.data(as: UserProfile.self)
    }
    
    // MARK: - Listeners
    
    /// Start listening to friends updates
    func startListeningToFriends() {
        guard let currentUserId = auth.currentUser?.uid else { return }
        
        stopListeningToFriends()
        
        let query = db.collection("friendRequests")
            .whereField("status", isEqualTo: FriendRequestStatus.accepted.rawValue)
            .whereField("fromUserId", isEqualTo: currentUserId)
        
        friendsListener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let error = error {
                    self.errorMessage = "Failed to listen to friends: \(error.localizedDescription)"
                    return
                }
                
                // Reload friends when changes occur
                try? await self.loadFriends()
            }
        }
    }
    
    /// Stop listening to friends updates
    func stopListeningToFriends() {
        friendsListener?.remove()
        friendsListener = nil
    }
    
    /// Start listening to pending requests
    func startListeningToPendingRequests() {
        guard let currentUserId = auth.currentUser?.uid else { return }
        
        pendingRequestsListener?.remove()
        
        let query = db.collection("friendRequests")
            .whereField("toUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: FriendRequestStatus.pending.rawValue)
            .order(by: "createdAt", descending: true)
        
        pendingRequestsListener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let error = error {
                    self.errorMessage = "Failed to listen to requests: \(error.localizedDescription)"
                    return
                }
                
                guard let snapshot = snapshot else {
                    self.pendingRequests = []
                    return
                }
                
                self.pendingRequests = snapshot.documents.compactMap { doc -> FriendRequest? in
                    guard var request = try? doc.data(as: FriendRequest.self) else {
                        return nil
                    }
                    request.id = doc.documentID
                    
                    // Filter out expired requests
                    if request.isExpired {
                        Task {
                            try? await doc.reference.delete()
                        }
                        return nil
                    }
                    
                    return request
                }
            }
        }
    }
    
    /// Stop listening to pending requests
    func stopListeningToPendingRequests() {
        pendingRequestsListener?.remove()
        pendingRequestsListener = nil
    }
    
    // MARK: - Blocking
    
    /// Block a user
    func blockUser(_ userId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        guard userId != currentUserId else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot block yourself"])
        }
        
        // Check if already blocked
        if await isUserBlocked(userId) {
            return // Already blocked
        }
        
        // Remove friend relationship if exists
        try? await removeFriend(userId)
        
        // Create block record
        let blockedUser = BlockedUser(
            blockedById: currentUserId,
            blockedUserId: userId
        )
        
        try db.collection("blockedUsers").addDocument(from: blockedUser)
        
        // Load blocked users to update state
        try await loadBlockedUsers()
    }
    
    /// Unblock a user
    func unblockUser(_ userId: String) async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let query = db.collection("blockedUsers")
            .whereField("blockedById", isEqualTo: currentUserId)
            .whereField("blockedUserId", isEqualTo: userId)
        
        let snapshot = try await query.getDocuments()
        
        for doc in snapshot.documents {
            try await doc.reference.delete()
        }
        
        // Update blocked users list
        try await loadBlockedUsers()
    }
    
    /// Check if a user is blocked
    func isUserBlocked(_ userId: String) async -> Bool {
        guard let currentUserId = auth.currentUser?.uid else {
            return false
        }
        
        return blockedUsers.contains { $0.blockedUserId == userId }
    }
    
    /// Load blocked users
    func loadBlockedUsers() async throws {
        guard let currentUserId = auth.currentUser?.uid else {
            throw NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let query = db.collection("blockedUsers")
            .whereField("blockedById", isEqualTo: currentUserId)
        
        let snapshot = try await query.getDocuments()
        blockedUsers = try snapshot.documents.compactMap { doc in
            try? doc.data(as: BlockedUser.self)
        }
    }
}

