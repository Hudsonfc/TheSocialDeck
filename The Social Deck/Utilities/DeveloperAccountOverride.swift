//
//  DeveloperAccountOverride.swift
//  The Social Deck
//
//  Client-only entitlement bypass for a single Firebase UID (no UI exposure).
//

import FirebaseAuth

enum DeveloperAccountOverride {
    static let firebaseUID = "sV5a6G65NnPgmSC8fByVldtUsYf1"

    /// When true, SubscriptionManager treats Plus as active and AvatarStoreManager treats all premium avatars as owned.
    static var isActive: Bool {
        Auth.auth().currentUser?.uid == firebaseUID
    }
}
