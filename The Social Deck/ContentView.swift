//
//  ContentView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    /// Full animated splash only the first time the app runs after install; then go straight to onboarding or home.
    @AppStorage("hasCompletedFirstLaunchSplash") private var hasCompletedFirstLaunchSplash = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject private var authManager: AuthManager

    @State private var showLobbyFromInviteBanner = false

    var body: some View {
        Group {
            if !hasCompletedFirstLaunchSplash {
                SplashView()
            } else if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if hasCompletedFirstLaunchSplash, hasCompletedOnboarding, authManager.isAuthenticated {
                RoomInviteTopBannerView(
                    onAcceptedRoomInvite: {
                        showLobbyFromInviteBanner = true
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showLobbyFromInviteBanner) {
            NavigationStack {
                LobbyView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
