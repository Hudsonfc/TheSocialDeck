//
//  NotificationManager.swift
//  The Social Deck
//
//  Handles push-notification permissions, FCM token persistence, outbound
//  notification delivery, and in-app deep-link routing when a notification
//  is tapped.
//
//  ⚠️  SECURITY NOTE — FCM Legacy HTTP API
//  The server key below is embedded in the app binary.  Anyone who extracts
//  it can send arbitrary messages to your users.  This is acceptable for a
//  development / TestFlight build, but before App Store submission you should
//  move the send logic to a Firebase Cloud Function (or any backend you
//  control) so the key never leaves a server.
//  Get your server key from:
//  Firebase Console → Project Settings → Cloud Messaging → Server key
//

import Foundation
import FirebaseMessaging
import FirebaseFirestore
import FirebaseAuth
import UserNotifications
import UIKit

// MARK: - Deep-link destination

enum FriendsDeepLinkTab {
    case requests
    case roomInvites
}

// MARK: - Manager

@MainActor
final class NotificationManager: NSObject, ObservableObject {

    static let shared = NotificationManager()

    // When set, FriendsListView observes this and switches to the right tab.
    @Published var pendingDeepLink: FriendsDeepLinkTab? = nil

    // ── Replace this value with the real key from Firebase Console ──────────
    // Firebase Console → Project Settings → Cloud Messaging → Server key
    private let fcmServerKey = "YOUR_FCM_SERVER_KEY_HERE"
    // ────────────────────────────────────────────────────────────────────────

    private let db = Firestore.firestore()
    private var permissionRequested = false

    private override init() {
        super.init()
    }

    // MARK: - Setup (called once from The_Social_DeckApp.init)

    func configure() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    // MARK: - Permissions

    /// Call this after the user signs in for the first time (not on cold launch).
    func requestPermissionIfNeeded() {
        guard !permissionRequested else { return }
        permissionRequested = true
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            ) { granted, _ in
                guard granted else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    // MARK: - Token

    /// Persist the latest FCM token to the signed-in user's Firestore profile.
    func saveToken(_ token: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        try? await db.collection("profiles").document(userId)
            .updateData(["fcmToken": token])
    }

    // MARK: - Outbound notifications

    /// Send "New Friend Request" push to the target user.
    func sendFriendRequestNotification(toUserId: String, fromUsername: String) async {
        guard let token = await fetchFCMToken(for: toUserId) else { return }
        await sendLegacyFCM(
            to: token,
            title: "New Friend Request",
            body: "\(fromUsername) wants to be friends",
            data: ["deepLink": "requests"]
        )
    }

    /// Send "Room Invite" push to the target user.
    func sendRoomInviteNotification(toUserId: String, fromUsername: String, gameName: String) async {
        guard let token = await fetchFCMToken(for: toUserId) else { return }
        await sendLegacyFCM(
            to: token,
            title: "Room Invite",
            body: "\(fromUsername) invited you to play \(gameName)",
            data: ["deepLink": "roomInvites"]
        )
    }

    // MARK: - Private helpers

    private func fetchFCMToken(for userId: String) async -> String? {
        guard let doc = try? await db.collection("profiles").document(userId).getDocument(),
              let token = doc.data()?["fcmToken"] as? String,
              !token.isEmpty else { return nil }
        return token
    }

    private func sendLegacyFCM(
        to token: String,
        title: String,
        body: String,
        data: [String: String]
    ) async {
        guard fcmServerKey != "YOUR_FCM_SERVER_KEY_HERE" else {
            // Server key not yet configured — skip silently in development.
            return
        }
        let payload: [String: Any] = [
            "to": token,
            "notification": [
                "title": title,
                "body": body,
                "sound": "default"
            ],
            "data": data,
            "apns": [
                "payload": ["aps": ["badge": 1]]
            ]
        ]
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send"),
              let jsonData = try? JSONSerialization.data(withJSONObject: payload) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(fcmServerKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        _ = try? await URLSession.shared.data(for: request)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    /// Show notification banners even when the app is in the foreground.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    /// Handle notification tap — set deep-link destination so FriendsListView can navigate.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let rawLink = userInfo["deepLink"] as? String {
            Task { @MainActor in
                switch rawLink {
                case "requests":
                    NotificationManager.shared.pendingDeepLink = .requests
                case "roomInvites":
                    NotificationManager.shared.pendingDeepLink = .roomInvites
                default:
                    break
                }
            }
        }
        completionHandler()
    }
}

// MARK: - MessagingDelegate

extension NotificationManager: MessagingDelegate {

    /// Called by Firebase whenever a new FCM registration token is available.
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        Task { @MainActor in
            await NotificationManager.shared.saveToken(token)
        }
    }
}
