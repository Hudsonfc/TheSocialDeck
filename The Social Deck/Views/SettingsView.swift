//
//  SettingsView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subManager: SubscriptionManager
    @State private var generalButtonPressed = false
    @State private var whatsNewButtonPressed = false
    @State private var feedbackButtonPressed = false
    @State private var rateUsButtonPressed = false
    @State private var previewOnlineUIButtonPressed = false
    @State private var showPlusPaywall = false
    
    // App version info
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.3"
    }
    
    
    var body: some View {
        ZStack {
            // Adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
            ScrollView {
                    VStack(spacing: 20) {
                    // Title
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // TheSocialDeck+ button
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            if subManager.isPlus {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            } else {
                                showPlusPaywall = true
                            }
                        }) {
                            ZStack {
                                Color.buttonBackground
                                    .cornerRadius(16)
                                HStack(spacing: 8) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                        .frame(height: 20)
                                        .clipped()
                                    Text(subManager.isPlus ? "TheSocialDeck+ · Active" : "TheSocialDeck+")
                                        .font(.system(size: 18, weight: .regular, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: true)
                                        .baselineOffset(0.5)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .offset(x: -11)
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.85, height: 60)
                        }
                        .sheet(isPresented: $showPlusPaywall) {
                            TheSocialDeckPlusPopUpView(onDismiss: { showPlusPaywall = false })
                                .environmentObject(SubscriptionManager.shared)
                        }

                        // General Settings Button
                        SettingsNavigationButton(
                            title: "General",
                            destination: GeneralSettingsView(),
                            isPressed: $generalButtonPressed
                        )
                        
                        // What's New Button
                        SettingsNavigationButton(
                            title: "What's New",
                            destination: WhatsNewView(),
                            isPressed: $whatsNewButtonPressed
                        )
                        
                        // Feedback Button
                        SettingsNavigationButton(
                            title: "Feedback",
                            destination: FeedbackView(),
                            isPressed: $feedbackButtonPressed
                        )
                        
                        // Rate Us Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                rateUsButtonPressed = true
                            }
                            HapticManager.shared.mediumImpact()
                            requestReview()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    rateUsButtonPressed = false
                                }
                            }
                        }) {
                            Text("Rate Us")
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width * 0.85, height: 60)
                                .background(Color.buttonBackground)
                                .cornerRadius(16)
                        }
                        .scaleEffect(rateUsButtonPressed ? 0.97 : 1.0)

                        // Spacer to push bottom buttons down
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 40)
                    }
                    
                // Instagram link
                if let instagramURL = URL(string: "https://www.instagram.com/thesocialdeckapp/") {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        UIApplication.shared.open(instagramURL)
                    }) {
                        InstagramIconView(size: 22)
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.secondaryBackground)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.borderColor, lineWidth: 1)
                            )
                    }
                    .buttonStyle(InstagramButtonStyle())
                    .padding(.bottom, 20)
                }
                
                // App Version
                VStack(spacing: 4) {
                    Text("The Social Deck")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                    Text("Version \(appVersion)")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.tertiaryText)
                }
                .padding(.bottom, 16)
                
                // Bottom buttons - Privacy Policy and Terms of Service
                HStack(spacing: 24) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .underline()
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        Text("Terms of Service")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .underline()
                    }
                }
                .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryText)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

// Preview of online game UI (non-host sees "Waiting for host to advance…")
private let previewCategories = ["Party", "Wild", "Couples", "Social", "Dirty", "Friends", "Family"]

struct OnlineGameUIPreviewView: View {
    @StateObject private var manager: NHIEGameManager

    private static let previewPlayers: [RoomPlayer] = [
        RoomPlayer(id: "previewHost", username: "Alex", avatarType: "avatar 1", avatarColor: "blue", isReady: true, isHost: true),
        RoomPlayer(id: "previewYou", username: "You", avatarType: "avatar 2", avatarColor: "red", isReady: true, isHost: false),
        RoomPlayer(id: "preview3", username: "Jordan", avatarType: "avatar 3", avatarColor: "green", isReady: true, isHost: false)
    ]

    init() {
        let deck = Deck(
            title: "Never Have I Ever",
            description: "Preview",
            numberOfCards: allNHIECards.count,
            estimatedTime: "30-45 min",
            imageName: "NHIE 2.0",
            type: .neverHaveIEver,
            cards: allNHIECards,
            availableCategories: previewCategories
        )
        _manager = StateObject(wrappedValue: NHIEGameManager(deck: deck, selectedCategories: previewCategories))
    }

    var body: some View {
        let deck = Deck(
            title: "Never Have I Ever",
            description: "Preview",
            numberOfCards: allNHIECards.count,
            estimatedTime: "30-45 min",
            imageName: "NHIE 2.0",
            type: .neverHaveIEver,
            cards: allNHIECards,
            availableCategories: previewCategories
        )
        NHIEPlayView(
            manager: manager,
            deck: deck,
            selectedCategories: previewCategories,
            roomId: "preview",
            isHost: false,
            players: Self.previewPlayers,
            currentUserId: "previewYou"
        )
    }
}

struct RiddleMeThisOnlineEndPreviewView: View {
    var body: some View {
        RiddleMeThisOnlineEndView(
            players: rmtPreviewPlayers,
            playerScores: rmtPreviewScores,
            currentUserId: rmtPreviewCurrentUserId,
            totalRounds: 10
        )
    }
}

private let rmtPreviewPlayers: [RoomPlayer] = [
    RoomPlayer(id: "rmtPreview1", username: "Maya", avatarType: "avatar 1", avatarColor: "yellow", isReady: true, isHost: true),
    RoomPlayer(id: "rmtPreview2", username: "Chris", avatarType: "avatar 2", avatarColor: "blue", isReady: true, isHost: false),
    RoomPlayer(id: "rmtPreview3", username: "Jordan", avatarType: "avatar 3", avatarColor: "green", isReady: true, isHost: false),
    RoomPlayer(id: "rmtPreview4", username: "Taylor", avatarType: "avatar 4", avatarColor: "red", isReady: true, isHost: false)
]

private let rmtPreviewScores: [String: Int] = [
    "rmtPreview2": 9, // 1st — gold
    "rmtPreview4": 7, // 2nd — silver
    "rmtPreview1": 5, // 3rd — bronze
    "rmtPreview3": 3
]

private let rmtPreviewPreviousScores: [String: Int] = [
    "rmtPreview2": 8, // +1
    "rmtPreview4": 8, // -1
    "rmtPreview1": 4, // +1
    "rmtPreview3": 4  // -1
]

private let rmtPreviewAnswers: [String: String] = [
    "rmtPreview1": "I think it is a penguin",
    "rmtPreview2": "Penguin",
    "rmtPreview3": "Maybe a polar bear?",
    "rmtPreview4": "A penguin for sure"
]

private let rmtPreviewCurrentUserId = "rmtPreview4"
private let rmtPreviewCorrectAnswer = "penguin"

struct RiddleMeThisRoundResultsPreviewView: View {
    @State private var displayedScores: [String: Int] = rmtPreviewPreviousScores
    @State private var hasAnimatedScores = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Text("The Answer")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                        Text("Penguin")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.secondaryBackground)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    VStack(spacing: 10) {
                        ForEach(rmtPreviewPlayers) { player in
                            rmtRoundResultRow(player)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !hasAnimatedScores else { return }
            hasAnimatedScores = true
            for (index, player) in rmtPreviewPlayers.enumerated() {
                let target = rmtPreviewScores[player.id] ?? 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 + (Double(index) * 0.12)) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                        displayedScores[player.id] = target
                    }
                }
            }
        }
    }

    private func rmtRoundResultRow(_ player: RoomPlayer) -> some View {
        let submitted = rmtPreviewAnswers[player.id]
        let score = displayedScores[player.id] ?? 0
        let previousScore = rmtPreviewPreviousScores[player.id] ?? 0
        let finalScore = rmtPreviewScores[player.id] ?? 0
        let scoreDelta = finalScore - previousScore
        let isCorrect = (submitted ?? "")
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .contains(rmtPreviewCorrectAnswer)
        let isYou = player.id == rmtPreviewCurrentUserId

        return HStack(spacing: 12) {
            AvatarView(avatarType: player.avatarType, avatarColor: player.avatarColor, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(player.username)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                    if isYou {
                        Text("(You)")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                }

                Text(submitted ?? "No answer")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .lineLimit(2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isCorrect ? .green : .red)

                if scoreDelta != 0 {
                    Text(scoreDelta > 0 ? "+\(scoreDelta)" : "\(scoreDelta)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(scoreDelta > 0 ? .green : .red)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background((scoreDelta > 0 ? Color.green : Color.red).opacity(0.12))
                        .clipShape(Capsule())
                }

                Text("\(score) pt\(score == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(12)
        .background(Color.secondaryBackground)
        .cornerRadius(12)
    }
}

// Scale-down on press for Instagram button
struct InstagramButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Minimalist Instagram glyph: rounded square + lens circle + viewfinder dot
struct InstagramIconView: View {
    var size: CGFloat = 24
    
    var body: some View {
        let strokeWidth = max(1.5, size * 0.08)
        let cornerRadius = size * 0.22
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(lineWidth: strokeWidth)
                .frame(width: size, height: size)
            Circle()
                .strokeBorder(lineWidth: strokeWidth)
                .frame(width: size * 0.52, height: size * 0.52)
            Circle()
                .strokeBorder(lineWidth: strokeWidth)
                .frame(width: size * 0.2, height: size * 0.2)
                .offset(x: size * 0.28, y: -size * 0.28)
        }
        .frame(width: size, height: size)
    }
}

struct SettingsNavigationButton<Destination: View>: View {
    let title: String
    let destination: Destination
    @Binding var isPressed: Bool
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width * 0.85, height: 60)
                .background(Color.buttonBackground)
                .cornerRadius(16)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                    HapticManager.shared.lightImpact()
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
