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
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var gameCenterService = GameCenterService.shared
    
    init() {
        FirebaseApp.configure()
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
        }
        .modelContainer(sharedModelContainer)
    }
}
