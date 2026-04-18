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
    @EnvironmentObject private var subManager: SubscriptionManager
    @Environment(\.scenePhase) private var scenePhase

    @State private var showLobbyFromInviteBanner = false
    @State private var showLaunchPlusPaywall = false
    @State private var launchPlusPresentationTask: Task<Void, Never>?

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
        .sheet(isPresented: subManager.paywallSheetIsPresented($showLaunchPlusPaywall), onDismiss: {
            Task { await subManager.refreshEntitlements() }
        }) {
            TheSocialDeckPlusPopUpView(onDismiss: { showLaunchPlusPaywall = false })
                .environmentObject(subManager)
        }
        .onChange(of: subManager.isPlus) { _, isPlus in
            if isPlus { showLaunchPlusPaywall = false }
        }
        .onAppear {
            scheduleLaunchPlusPaywallIfEligible()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                scheduleLaunchPlusPaywallIfEligible()
            }
        }
        .onChange(of: hasCompletedFirstLaunchSplash) { _, _ in
            scheduleLaunchPlusPaywallIfEligible()
        }
        .onChange(of: hasCompletedOnboarding) { _, _ in
            scheduleLaunchPlusPaywallIfEligible()
        }
    }

    /// Presents TheSocialDeck+ after splash and onboarding, whenever the app becomes active (non‑Plus only).
    private func scheduleLaunchPlusPaywallIfEligible() {
        guard hasCompletedFirstLaunchSplash, hasCompletedOnboarding else { return }
        guard subManager.hasCompletedInitialEntitlementCheck, !subManager.isPlus else { return }
        launchPlusPresentationTask?.cancel()
        launchPlusPresentationTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled else { return }
            guard hasCompletedFirstLaunchSplash, hasCompletedOnboarding else { return }
            guard subManager.hasCompletedInitialEntitlementCheck, !subManager.isPlus else { return }
            showLaunchPlusPaywall = true
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
        .environmentObject(SubscriptionManager.shared)
}
