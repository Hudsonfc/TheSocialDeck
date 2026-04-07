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
    @State private var showPlusPaywall = false
    
    // App version info
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.3.6"
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
    let currentUserId: String

    init(currentUserId: String) {
        self.currentUserId = currentUserId
    }

    var body: some View {
        RiddleMeThisOnlineEndView(
            players: rmtPreviewPlayers,
            playerScores: rmtPreviewScores,
            currentUserId: currentUserId,
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

/// Shared fake riddle for in-game phase previews (matches scoring copy in `rmtPreviewAnswers`).
private let rmtPreviewPhaseCard = Card(
    text: "I wear a black and white outfit and love to swim. What am I?",
    category: "Classic",
    correctAnswer: "Penguin"
)

private let rmtPreviewPhase2PartialAnswers: [String: String] = [
    "rmtPreview2": "Penguin",
    "rmtPreview4": "A penguin for sure"
]

private let rmtPreviewStripScoresMidRound: [String: Int] = [
    "rmtPreview1": 2,
    "rmtPreview2": 3,
    "rmtPreview3": 1,
    "rmtPreview4": 2
]

private let rmtPreviewPhase1StripScores: [String: Int] = [
    "rmtPreview1": 0,
    "rmtPreview2": 0,
    "rmtPreview3": 0,
    "rmtPreview4": 0
]

/// Fixed height for the riddle play card in Settings online previews (Q1 + Ans only; same value both places).
private let rmtPreviewCardFixedHeight: CGFloat = 440

// MARK: - Riddle Me This online — Host round simulation

private enum RiddleSimPhase {
    case waitingToFlip
    case playersAnswering
    case reviewingResults
}

struct RiddleMeThisHostRoundSimulationView: View {
    let isHostPerspective: Bool

    init(isHostPerspective: Bool = true) {
        self.isHostPerspective = isHostPerspective
    }

    @State private var phase: RiddleSimPhase = .waitingToFlip
    @State private var cardRotation: Double = 0
    @State private var answerText: String = ""
    @State private var playerAnswers: [String: String] = [:]
    @State private var showCompleteMessage = false
    @State private var displayedScores: [String: Int] = rmtPreviewPreviousScores
    @State private var didAnimateResultScores = false
    @State private var simulationTask: Task<Void, Never>?
    @State private var showSimAnswerInputArea: Bool = false
    @State private var autoHostTask: Task<Void, Never>?

    private let hostId = "rmtPreview1"
    private let initialScores: [String: Int] = rmtPreviewPreviousScores
    private var viewerId: String { isHostPerspective ? hostId : "rmtPreview3" }
    private var autoSubmissionOrder: [String] {
        isHostPerspective
            ? ["rmtPreview2", "rmtPreview4", "rmtPreview3"] // Chris, Taylor, Jordan
            : ["rmtPreview2", "rmtPreview4", "rmtPreview1"] // Chris, Taylor, Maya
    }

    private var submittedCount: Int { playerAnswers.count }
    private var hostSubmitted: Bool { playerAnswers[viewerId] != nil }
    private var allSubmitted: Bool { submittedCount == rmtPreviewPlayers.count }
    private var phaseLabel: String {
        switch phase {
        case .waitingToFlip: return "Phase 1: Waiting to flip"
        case .playersAnswering: return "Phase 2: Players answering..."
        case .reviewingResults: return "Phase 3: Reviewing results"
        }
    }

    private var resolvedScores: [String: Int] {
        var updated = initialScores
        for player in rmtPreviewPlayers {
            let base = updated[player.id] ?? 0
            guard let submitted = playerAnswers[player.id] else {
                updated[player.id] = max(0, base - 1)
                continue
            }
            let isCorrect = RiddleMeThisOnlineSyncService.matches(
                submitted: submitted,
                correct: rmtPreviewPhaseCard.correctAnswer ?? ""
            )
            updated[player.id] = isCorrect ? base + 1 : max(0, base - 1)
        }
        return updated
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(phaseLabel)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
                .padding(.top, 6)

            HStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primaryText)
                    .frame(width: 36, height: 36)
                    .background(Color.tertiaryBackground)
                    .clipShape(Circle())
                Spacer()
                Text("Round 1 of 10")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
            }
            .responsiveHorizontalPadding()

            RiddleOnlinePlayerStripView(
                players: rmtPreviewPlayers,
                currentUserId: viewerId,
                playerAnswers: phase == .waitingToFlip ? [:] : playerAnswers,
                playerScores: phase == .reviewingResults ? displayedScores : initialScores,
                roundPhase: phase == .reviewingResults ? "results" : (phase == .playersAnswering ? "answering" : "question"),
                currentCard: phase == .waitingToFlip ? nil : rmtPreviewPhaseCard,
                compactStrip: true
            )
            .padding(.horizontal, 12)

            Group {
                switch phase {
                case .waitingToFlip:
                    waitingToFlipView
                case .playersAnswering:
                    playersAnsweringView
                case .reviewingResults:
                    reviewingResultsView
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: phase)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            simulationTask?.cancel()
            simulationTask = nil
            autoHostTask?.cancel()
            autoHostTask = nil
        }
    }

    private var waitingToFlipView: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 2)

            ZStack {
                RiddleCardBackView(text: "Riddle Me This")
                    .opacity(cardRotation < 90 ? 1 : 0)
                RiddleCardFrontView(text: rmtPreviewPhaseCard.text)
                    .opacity(cardRotation >= 90 ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(width: ResponsiveSize.cardWidth, height: rmtPreviewCardFixedHeight)
            .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.5)

            Spacer(minLength: 2)

            if isHostPerspective {
                PrimaryButton(title: "Flip Card") {
                    HapticManager.shared.mediumImpact()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        cardRotation = 180
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        phase = .playersAnswering
                        startAutoSubmissions()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            } else {
                Text("Waiting for host...")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .padding(.bottom, 8)
                    .onAppear {
                        autoHostTask?.cancel()
                        autoHostTask = Task {
                            try? await Task.sleep(nanoseconds: 1_100_000_000)
                            guard !Task.isCancelled else { return }
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                cardRotation = 180
                            }
                            try? await Task.sleep(nanoseconds: 550_000_000)
                            guard !Task.isCancelled else { return }
                            phase = .playersAnswering
                            startAutoSubmissions()
                        }
                    }
            }
        }
    }

    private var playersAnsweringView: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 2)

            RiddleCardFrontView(text: rmtPreviewPhaseCard.text)
                .frame(width: ResponsiveSize.cardWidth, height: rmtPreviewCardFixedHeight)

            ZStack {
                if !hostSubmitted && showSimAnswerInputArea {
                    VStack(spacing: 8) {
                        TextField("Type your answer...", text: $answerText)
                            .font(.system(size: 15, design: .rounded))
                            .padding(12)
                            .background(Color.secondaryBackground)
                            .cornerRadius(12)
                            .padding(.horizontal, 28)

                        PrimaryButton(title: "Submit Answer") {
                            HapticManager.shared.mediumImpact()
                            let hostAnswer = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
                            playerAnswers[viewerId] = hostAnswer.isEmpty ? "A penguin" : hostAnswer
                        }
                        .padding(.horizontal, 28)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                } else {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Answer submitted!")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondaryText)
                        }
                        .padding(.vertical, 4)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .opacity
                        ))

                        if allSubmitted && isHostPerspective {
                            PrimaryButton(title: "Show Answer") {
                                HapticManager.shared.mediumImpact()
                                didAnimateResultScores = false
                                displayedScores = initialScores
                                showCompleteMessage = false
                                showSimAnswerInputArea = false
                                phase = .reviewingResults
                                animateResultScores()
                            }
                            .padding(.horizontal, 28)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .scale(scale: 0.9)).combined(with: .opacity),
                                removal: .opacity
                            ))
                        } else if allSubmitted {
                            Text("Waiting for host to reveal...")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .padding(.vertical, 4)
                                .onAppear {
                                    autoHostTask?.cancel()
                                    autoHostTask = Task {
                                        try? await Task.sleep(nanoseconds: 900_000_000)
                                        guard !Task.isCancelled, phase == .playersAnswering else { return }
                                        didAnimateResultScores = false
                                        displayedScores = initialScores
                                        showCompleteMessage = false
                                        showSimAnswerInputArea = false
                                        phase = .reviewingResults
                                        animateResultScores()
                                    }
                                }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .animation(.interpolatingSpring(stiffness: 210, damping: 20), value: hostSubmitted)
            .animation(.interpolatingSpring(stiffness: 220, damping: 22), value: allSubmitted)
            .frame(minHeight: 104)


            Spacer(minLength: 2)
        }
        .onAppear {
            showSimAnswerInputArea = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                    showSimAnswerInputArea = true
                }
            }
        }
    }

    private var reviewingResultsView: some View {
        VStack(spacing: 10) {
            VStack(spacing: 4) {
                Text("The Answer")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                Text(rmtPreviewPhaseCard.correctAnswer ?? "")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.secondaryBackground)
            .cornerRadius(14)
            .padding(.horizontal, 12)

            VStack(spacing: 6) {
                ForEach(rmtPreviewPlayers) { player in
                    simulationResultRow(player: player)
                }
            }
            .padding(.horizontal, 12)

            Spacer(minLength: 4)

            if isHostPerspective {
                PrimaryButton(title: "Next Round") {
                    HapticManager.shared.mediumImpact()
                    showCompleteMessage = false
                    Task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        guard !Task.isCancelled, phase == .reviewingResults else { return }
                        showCompleteMessage = true
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, showCompleteMessage ? 0 : 8)
            } else {
                Text("Waiting for host to start next round...")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .padding(.bottom, showCompleteMessage ? 0 : 8)
                    .onAppear {
                        autoHostTask?.cancel()
                        autoHostTask = Task {
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            guard !Task.isCancelled, phase == .reviewingResults else { return }
                            showCompleteMessage = true
                        }
                    }
            }

            if showCompleteMessage {
                VStack(spacing: 8) {
                    Text("Simulation Complete!")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)

                    PrimaryButton(title: "Restart") {
                        HapticManager.shared.mediumImpact()
                        restartSimulation()
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 8)
            }
        }
    }

    private func simulationResultRow(player: RoomPlayer) -> some View {
        let submitted = playerAnswers[player.id]
        let score = displayedScores[player.id] ?? 0
        let before = initialScores[player.id] ?? 0
        let after = resolvedScores[player.id] ?? 0
        let delta = after - before
        let isCorrect: Bool = {
            guard let answer = submitted else { return false }
            return RiddleMeThisOnlineSyncService.matches(
                submitted: answer,
                correct: rmtPreviewPhaseCard.correctAnswer ?? ""
            )
        }()
        let isYou = player.id == viewerId

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
                if delta != 0 {
                    Text(delta > 0 ? "+\(delta)" : "\(delta)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(delta > 0 ? .green : .red)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background((delta > 0 ? Color.green : Color.red).opacity(0.12))
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

    private func startAutoSubmissions() {
        simulationTask?.cancel()
        simulationTask = Task {
            for playerId in autoSubmissionOrder {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                guard !Task.isCancelled, phase == .playersAnswering else { return }
                if playerAnswers[playerId] == nil {
                    playerAnswers[playerId] = rmtPreviewAnswers[playerId] ?? "A penguin"
                }
            }
        }
    }

    private func restartSimulation() {
        simulationTask?.cancel()
        simulationTask = nil
        autoHostTask?.cancel()
        autoHostTask = nil
        phase = .waitingToFlip
        cardRotation = 0
        answerText = ""
        playerAnswers = [:]
        showCompleteMessage = false
        displayedScores = initialScores
        didAnimateResultScores = false
        showSimAnswerInputArea = false
    }

    private func animateResultScores() {
        guard !didAnimateResultScores else { return }
        didAnimateResultScores = true
        for (index, player) in rmtPreviewPlayers.enumerated() {
            let target = resolvedScores[player.id] ?? 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12 + (Double(index) * 0.1)) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                    displayedScores[player.id] = target
                }
            }
        }
    }
}

// MARK: - Riddle Me This online — Settings preview hub (5 screens)

struct RiddleMeThisOnlinePreviewHubView: View {
    @State private var page: Int = 0
    /// Card rotation angle shared between Phase 1 (0°) and Phase 2 (180°).
    @State private var cardRotation: Double = 0
    /// Whether "Jordan" (rmtPreview3 = You in Phase 2) has tapped Submit.
    @State private var youSubmitted: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                RiddlePhase1QuestionHostPreviewView(
                    cardRotation: $cardRotation,
                    isHost: true,
                    currentUserId: "rmtPreview1",
                    onFlip: { page = 1 }
                )
                .tag(0)

                RiddlePhase2AnsweringGuestPreviewView(
                    youSubmitted: $youSubmitted
                )
                .tag(1)

                RiddlePhase3RoundResultsHostPreviewView(
                    isHost: true,
                    currentUserId: "rmtPreview1",
                    onNextRound: {
                        withAnimation(.none) { cardRotation = 0 }
                        youSubmitted = false
                        page = 0
                    }
                )
                .tag(2)

                RiddleMeThisRoundResultsPreviewView(currentUserId: rmtPreviewCurrentUserId)
                    .tag(3)

                RiddleMeThisOnlineEndPreviewView(currentUserId: rmtPreviewCurrentUserId)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: page) { _ in
                // Reset interactive state on any swipe
                withAnimation(.none) { cardRotation = 0 }
                youSubmitted = false
            }

            HStack(spacing: 8) {
                ForEach(0..<5) { i in
                    Circle()
                        .fill(page == i ? Color.primaryText : Color.secondaryText.opacity(0.4))
                        .frame(width: page == i ? 8 : 6, height: page == i ? 8 : 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: page)
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Riddle Me This online — Non-Host preview hub

struct RiddleMeThisOnlineNonHostPreviewHubView: View {
    @State private var page: Int = 0
    @State private var cardRotation: Double = 0
    @State private var youSubmitted: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                RiddlePhase1QuestionHostPreviewView(
                    cardRotation: $cardRotation,
                    isHost: false,
                    currentUserId: "rmtPreview3",
                    onFlip: {}
                )
                .tag(0)

                RiddlePhase2AnsweringGuestPreviewView(
                    youSubmitted: $youSubmitted
                )
                .tag(1)

                RiddlePhase3RoundResultsHostPreviewView(
                    isHost: false,
                    currentUserId: "rmtPreview3",
                    onNextRound: {}
                )
                .tag(2)

                RiddleMeThisRoundResultsPreviewView(currentUserId: "rmtPreview3")
                    .tag(3)

                RiddleMeThisOnlineEndPreviewView(currentUserId: "rmtPreview3")
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: page) { _ in
                // Reset interactive state on any swipe
                withAnimation(.none) { cardRotation = 0 }
                youSubmitted = false
            }

            HStack(spacing: 8) {
                ForEach(0..<5) { i in
                    Circle()
                        .fill(page == i ? Color.primaryText : Color.secondaryText.opacity(0.4))
                        .frame(width: page == i ? 8 : 6, height: page == i ? 8 : 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: page)
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: Phase 1 — Question (host)

private struct RiddlePhase1QuestionHostPreviewView: View {
    @Binding var cardRotation: Double
    let isHost: Bool
    let currentUserId: String
    let onFlip: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primaryText)
                    .frame(width: 36, height: 36)
                    .background(Color.tertiaryBackground)
                    .clipShape(Circle())
                Spacer()
                Text("Round 1 of 10")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
            }
            .responsiveHorizontalPadding()
            .padding(.top, 6)

            RiddleOnlinePlayerStripView(
                players: rmtPreviewPlayers,
                currentUserId: currentUserId,
                playerAnswers: [:],
                playerScores: rmtPreviewPhase1StripScores,
                roundPhase: "question",
                currentCard: nil,
                compactStrip: true
            )
            .padding(.horizontal, 12)

            Spacer(minLength: 4)

            let effectiveRotation = isHost ? cardRotation : 0
            ZStack {
                RiddleCardBackView(text: "Riddle Me This")
                    .opacity(effectiveRotation < 90 ? 1 : 0)
                RiddleCardFrontView(text: rmtPreviewPhaseCard.text)
                    .opacity(effectiveRotation >= 90 ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(width: ResponsiveSize.cardWidth, height: rmtPreviewCardFixedHeight)
            .rotation3DEffect(.degrees(effectiveRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .padding(.vertical, 4)

            Spacer(minLength: 4)

            if isHost {
                PrimaryButton(title: "Flip Card") {
                    HapticManager.shared.mediumImpact()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        cardRotation = 180
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        onFlip()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            } else {
                Text("Waiting for host...")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// MARK: Phase 2 — Answering (non-host: Jordan = You)

private struct RiddlePhase2AnsweringGuestPreviewView: View {
    @Binding var youSubmitted: Bool
    @State private var answerText: String = ""

    private var liveAnswers: [String: String] {
        var base = rmtPreviewPhase2PartialAnswers        // Chris + Taylor already submitted
        if youSubmitted { base["rmtPreview3"] = answerText.isEmpty ? "A penguin" : answerText }
        return base
    }
    private var submittedCount: Int { liveAnswers.count }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primaryText)
                    .frame(width: 36, height: 36)
                    .background(Color.tertiaryBackground)
                    .clipShape(Circle())
                Spacer()
                Text("Round 1 of 10")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
            }
            .responsiveHorizontalPadding()
            .padding(.top, 6)

            RiddleOnlinePlayerStripView(
                players: rmtPreviewPlayers,
                currentUserId: "rmtPreview3",
                playerAnswers: liveAnswers,
                playerScores: rmtPreviewStripScoresMidRound,
                roundPhase: "answering",
                currentCard: rmtPreviewPhaseCard,
                compactStrip: true
            )
            .padding(.horizontal, 12)

            Spacer(minLength: 2)

            RiddleCardFrontView(text: rmtPreviewPhaseCard.text)
                .frame(width: ResponsiveSize.cardWidth, height: rmtPreviewCardFixedHeight)

            if !youSubmitted {
                VStack(spacing: 8) {
                    TextField("Type your answer...", text: $answerText)
                        .font(.system(size: 15, design: .rounded))
                        .padding(12)
                        .background(Color.secondaryBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 28)

                    PrimaryButton(title: "Submit Answer") {
                        HapticManager.shared.mediumImpact()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            youSubmitted = true
                        }
                    }
                    .padding(.horizontal, 28)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    Text("Answer submitted!")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                .padding(.vertical, 6)
            }

            Text("Waiting for host to reveal...")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// MARK: Phase 3 — Results (host, one round)

private struct RiddlePhase3RoundResultsHostPreviewView: View {
    let isHost: Bool
    let currentUserId: String
    let onNextRound: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primaryText)
                    .frame(width: 36, height: 36)
                    .background(Color.tertiaryBackground)
                    .clipShape(Circle())
                Spacer()
                Text("Round 1 of 10")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
            }
            .responsiveHorizontalPadding()
            .padding(.top, 6)

            VStack(spacing: 4) {
                Text("The Answer")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                Text(rmtPreviewPhaseCard.correctAnswer ?? "")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.secondaryBackground)
            .cornerRadius(14)
            .padding(.horizontal, 12)

            VStack(spacing: 6) {
                ForEach(rmtPreviewPlayers) { player in
                    rmtPhase3PreviewResultRow(player: player)
                }
            }
            .padding(.horizontal, 12)

            Spacer(minLength: 4)

            if isHost {
                PrimaryButton(title: "Next Round") {
                    HapticManager.shared.mediumImpact()
                    onNextRound()
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            } else {
                Text("Waiting for host to start next round...")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
    }

    private func rmtPhase3PreviewResultRow(player: RoomPlayer) -> some View {
        let submitted = rmtPreviewAnswers[player.id]
        let score = rmtPreviewScores[player.id] ?? 0
        let isCorrect: Bool = {
            guard let answer = submitted else { return false }
            return RiddleMeThisOnlineSyncService.matches(
                submitted: answer,
                correct: rmtPreviewPhaseCard.correctAnswer ?? ""
            )
        }()
        let isYou = player.id == currentUserId

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
                if let answer = submitted {
                    Text(answer)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                } else {
                    Text("No answer")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .italic()
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isCorrect ? .green : .red)
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

struct RiddleMeThisRoundResultsPreviewView: View {
    let currentUserId: String
    @State private var displayedScores: [String: Int] = rmtPreviewPreviousScores
    @State private var hasAnimatedScores = false

    init(currentUserId: String) {
        self.currentUserId = currentUserId
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("The Answer")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                    Text("Penguin")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color.secondaryBackground)
                .cornerRadius(14)
                .padding(.horizontal, 12)
                .padding(.top, 6)

                VStack(spacing: 6) {
                    ForEach(rmtPreviewPlayers) { player in
                        rmtRoundResultRow(player)
                    }
                }
                .padding(.horizontal, 12)

                Spacer(minLength: 0)
            }
        }
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
        let isYou = player.id == currentUserId

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
