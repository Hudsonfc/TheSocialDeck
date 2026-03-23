//
//  NotificationManager.swift
//  The Social Deck
//
//  Handles push-notification permissions, FCM token persistence, outbound
//  notification delivery, and in-app deep-link routing when a notification
//  is tapped.
//
//  Outbound sends use the FCM HTTP v1 API (legacy HTTP API is deprecated).
//
//  ⚠️  AUTH LIMIT (important)
//  Google's FCM v1 `messages:send` endpoint expects a short-lived **OAuth 2.0
//  access token** obtained with a **service account** (scope:
//  https://www.googleapis.com/auth/firebase.messaging).
//  A **Firebase ID token** (`getIDToken()`) is an end-user credential and is
//  not the same token type; the API may respond with 401 Unauthorized.
//  For production, send from Cloud Functions or your backend using the Admin
//  SDK or service-account JWT flow. The code below follows the requested
//  `getIDToken()` Bearer approach so you can verify behavior and migrate.
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

    /// Must match Firebase project ID (see GoogleService-Info.plist `PROJECT_ID`).
    private let fcmProjectId = "thesocialdeck-fe6c5"

    private var fcmV1SendURL: URL {
        URL(string: "https://fcm.googleapis.com/v1/projects/\(fcmProjectId)/messages:send")!
    }

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
        await sendFCMv1(
            to: token,
            title: "New Friend Request",
            body: "\(fromUsername) wants to be friends",
            data: ["deepLink": "requests"]
        )
    }

    /// Send "Room Invite" push to the target user.
    func sendRoomInviteNotification(toUserId: String, fromUsername: String, gameName: String) async {
        guard let token = await fetchFCMToken(for: toUserId) else { return }
        await sendFCMv1(
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

    /// FCM HTTP v1 — https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages/send
    private func sendFCMv1(
        to token: String,
        title: String,
        body: String,
        data: [String: String]
    ) async {
        guard let user = Auth.auth().currentUser else {
            print("[NotificationManager] sendFCMv1: no signed-in user; cannot get ID token")
            return
        }
        let idToken: String
        do {
            idToken = try await user.getIDToken()
        } catch {
            print("[NotificationManager] sendFCMv1: getIDToken failed: \(error)")
            return
        }

        // FCM `data` map values must be strings (already satisfied by [String: String]).

        let message: [String: Any] = [
            "token": token,
            "notification": [
                "title": title,
                "body": body
            ],
            "data": data,
            "apns": [
                "payload": [
                    "aps": [
                        "sound": "default",
                        "badge": 1
                    ] as [String: Any]
                ]
            ]
        ]
        let payload: [String: Any] = ["message": message]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("[NotificationManager] sendFCMv1: JSON encode failed")
            return
        }

        var request = URLRequest(url: fcmV1SendURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        do {
            let (respData, response) = try await URLSession.shared.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            if code < 200 || code >= 300 {
                let bodyText = String(data: respData, encoding: .utf8) ?? "(no body)"
                print("[NotificationManager] sendFCMv1: HTTP \(code) — \(bodyText)")
            }
        } catch {
            print("[NotificationManager] sendFCMv1: request failed: \(error)")
        }
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
