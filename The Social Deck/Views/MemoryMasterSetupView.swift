//
//  MemoryMasterSetupView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct MemoryMasterSetupView: View {
    let deck: Deck
    @State private var navigateToPlay: Bool = false
    @State private var selectedDifficulty: MemoryMasterDifficulty = .easy
    @State private var showPlusPaywall = false
    @State private var difficultyGridAppeared = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subManager: SubscriptionManager

    private let difficultySelectionGridColumns = [
        GridItem(.flexible(), spacing: 14, alignment: .top),
        GridItem(.flexible(), spacing: 14, alignment: .top)
    ]

    private var selectionAccent: Color {
        deck.type.categorySelectionAccent
    }

    private func difficultyIsPlusLocked(_ difficulty: MemoryMasterDifficulty) -> Bool {
        (difficulty == .hard || difficulty == .expert) && !subManager.isPlus
    }

    private func onTapDifficulty(_ difficulty: MemoryMasterDifficulty) {
        if difficultyIsPlusLocked(difficulty) {
            showPlusPaywall = true
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                selectedDifficulty = difficulty
            }
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Select Difficulty")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                                .padding(.bottom, 6)

                            Text("Tap a difficulty to play. Hard and Expert need Plus.")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 20)

                            LazyVGrid(columns: difficultySelectionGridColumns, spacing: 12) {
                                ForEach(Array(MemoryMasterDifficulty.allCases.enumerated()), id: \.element) { index, difficulty in
                                    MemoryMasterDifficultyGridCard(
                                        title: difficulty.displayName,
                                        subtitle: difficulty.selectionSubtitle,
                                        systemImage: difficulty.selectionIcon,
                                        isSelected: selectedDifficulty == difficulty,
                                        isLocked: difficultyIsPlusLocked(difficulty),
                                        accentColor: selectionAccent,
                                        action: { onTapDifficulty(difficulty) }
                                    )
                                    .opacity(difficultyGridAppeared ? 1 : 0)
                                    .offset(y: difficultyGridAppeared ? 0 : 16)
                                    .animation(
                                        .spring(response: 0.48, dampingFraction: 0.84)
                                            .delay(Double(index) * 0.042),
                                        value: difficultyGridAppeared
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 24)
                        }
                        .responsiveHorizontalPadding()
                    }

                    PrimaryButton(title: "Start Game") {
                        navigateToPlay = true
                    }
                    .responsiveHorizontalPadding()
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                    .disabled(difficultyIsPlusLocked(selectedDifficulty))
                    .opacity(difficultyIsPlusLocked(selectedDifficulty) ? 0.5 : 1)
                    .background(Color.appBackground)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            difficultyGridAppeared = false
            DispatchQueue.main.async {
                withAnimation {
                    difficultyGridAppeared = true
                }
            }
        }
        .onChange(of: subManager.isPlus) { _, isPlus in
            if isPlus {
                showPlusPaywall = false
            } else if selectedDifficulty == .hard || selectedDifficulty == .expert {
                selectedDifficulty = .easy
            }
        }
        .sheet(isPresented: subManager.paywallSheetIsPresented($showPlusPaywall)) {
            TheSocialDeckPlusPopUpView(onDismiss: { showPlusPaywall = false })
                .environmentObject(subManager)
        }
        .background(
            NavigationLink(
                destination: MemoryMasterPlayView(
                    manager: MemoryMasterGameManager(difficulty: selectedDifficulty),
                    deck: deck
                ),
                isActive: $navigateToPlay
            ) {
                EmptyView()
            }
        )
    }
}

// MARK: - Difficulty card (matches `ClassicCategoryGridCard` layout)

private struct MemoryMasterDifficultyGridCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let isSelected: Bool
    let isLocked: Bool
    let accentColor: Color
    let action: () -> Void

    private let corner: CGFloat = 16
    private var cardFill: Color {
        Color(light: Color.secondaryBackground, dark: Color(red: 0.22, green: 0.22, blue: 0.26))
    }

    private var neutralBorder: Color { Color.borderColor }

    private var lockedCardBorder: Color {
        accentColor.opacity(0.82)
    }

    private let uniformCardHeight: CGFloat = 172

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(cardFill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isLocked {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    accentColor.opacity(0.12),
                                    Color.primary.opacity(0.07),
                                    Color.primary.opacity(0.2)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(iconColor)
                        .frame(width: 34, height: 34, alignment: .center)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityHidden(true)

                    Spacer(minLength: 14)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(titleColor)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(subtitle)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(subtitleColor)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(2)
                            .lineLimit(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(isLocked ? 0.72 : 1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .white,
                                    Color.white.opacity(0.92),
                                    accentColor
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.primaryText.opacity(0.35), radius: 5, x: 0, y: 2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)
                        .accessibilityLabel("Locked, Plus required")
                }
            }
            .frame(maxWidth: .infinity, minHeight: uniformCardHeight, maxHeight: uniformCardHeight, alignment: .topLeading)
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(
                        isLocked ? lockedCardBorder : (isSelected ? accentColor : neutralBorder),
                        lineWidth: isLocked ? 2 : (isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        if isLocked { return accentColor.opacity(0.5) }
        if isSelected { return accentColor.opacity(0.95) }
        return Color.secondaryText.opacity(0.75)
    }

    private var titleColor: Color {
        if isLocked { return Color.primaryText.opacity(0.78) }
        return .primaryText
    }

    private var subtitleColor: Color {
        if isLocked { return Color.secondaryText.opacity(0.72) }
        return Color.secondaryText
    }
}

#Preview {
    NavigationView {
        MemoryMasterSetupView(
            deck: Deck(
                title: "Memory Master",
                description: "Test your memory with escalating challenges.",
                numberOfCards: 55,
                estimatedTime: "20-30 min",
                imageName: "Art 1.4",
                type: .memoryMaster,
                cards: [],
                availableCategories: []
            )
        )
        .environmentObject(SubscriptionManager.shared)
    }
}
