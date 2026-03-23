//
//  AppDelegate.swift
//  The Social Deck
//
//  Minimal UIApplicationDelegate that forwards the APNs device token to
//  Firebase Messaging so FCM can route push notifications to this device.
//

import UIKit
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // Non-fatal — the device may simply not support push (simulator, etc.)
        print("[AppDelegate] Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
