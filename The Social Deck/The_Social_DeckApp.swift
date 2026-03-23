//
//  The_Social_DeckApp.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct The_Social_DeckApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var gameCenterService = GameCenterService.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        FirebaseApp.configure()
        // Set up notification delegates so the system can deliver push tokens
        // and tap-events to NotificationManager before any view is shown.
        NotificationManager.shared.configure()
        // GameCenterService initializes automatically on init
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(subscriptionManager)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { phase in
            guard authManager.isAuthenticated else { return }
            switch phase {
            case .active:
                Task { await authManager.setOnlineStatus(true) }
            case .background, .inactive:
                Task { await authManager.setOnlineStatus(false) }
            @unknown default:
                break
            }
        }
    }
}
