//
//  TheSocialDeckPlusWelcomeView.swift
//  The Social Deck
//

import SwiftUI

struct TheSocialDeckPlusWelcomeView: View {
    var onDismiss: () -> Void

    @State private var crownScale: CGFloat = 0.4
    @State private var crownOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 24
    @State private var buttonScale: CGFloat = 0.9
    @State private var buttonOpacity: Double = 0
    @State private var sparkleOpacity: Double = 0

    private let soDeckRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
    private let soDeckBlack = Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0)

    private let unlockedGames = [
        "Most Likely To",
        "Take It Personally",
        "What's My Secret?",
        "Bluff Call",
        "Memory Master",
        "Closer Than Ever",
        "Tap Duel"
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0xFD/255.0, green: 0xF0/255.0, blue: 0xF0/255.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Crown + sparkle burst
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(soDeckRed.opacity(0.08))
                        .frame(width: 140, height: 140)
                        .scaleEffect(crownScale * 1.1)
                        .opacity(sparkleOpacity)

                    // Inner circle
                    Circle()
                        .fill(soDeckRed.opacity(0.13))
                        .frame(width: 100, height: 100)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(soDeckRed)
                }
                .scaleEffect(crownScale)
                .opacity(crownOpacity)
                .padding(.bottom, 32)

                // Title + subtitle
                VStack(spacing: 10) {
                    Text("Welcome to")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))

                    Text("TheSocialDeck+")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(soDeckBlack)

                    Text("You're all unlocked. Let's play.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x5A/255.0, green: 0x5A/255.0, blue: 0x5A/255.0))
                        .multilineTextAlignment(.center)
                }
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                .padding(.bottom, 40)

                // Unlocked games card
                VStack(alignment: .leading, spacing: 0) {
                    Text("UNLOCKED GAMES")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(soDeckRed)
                        .tracking(1.0)
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 12)

                    ForEach(Array(unlockedGames.enumerated()), id: \.offset) { index, game in
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(soDeckRed)
                                Text(game)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(soDeckBlack)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 11)

                            if index < unlockedGames.count - 1 {
                                Divider()
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 6)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0xEE/255.0, green: 0xEE/255.0, blue: 0xEE/255.0), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 6)
                .padding(.horizontal, 24)
                .opacity(contentOpacity)
                .offset(y: contentOffset)

                Spacer()

                // Let's Go button
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    onDismiss()
                }) {
                    Text("Let's Go!")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(soDeckRed)
                        .cornerRadius(24)
                        .shadow(color: soDeckRed.opacity(0.35), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .scaleEffect(buttonScale)
                .opacity(buttonOpacity)
            }
        }
        .onAppear { runEntryAnimations() }
    }

    private func runEntryAnimations() {
        // Crown bounces in
        withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
            crownScale = 1.0
            crownOpacity = 1.0
        }
        // Outer glow pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                sparkleOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                sparkleOpacity = 0.4
            }
        }
        // Content slides up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
        // Button fades in last
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                buttonScale = 1.0
                buttonOpacity = 1.0
            }
        }
    }
}

#Preview {
    TheSocialDeckPlusWelcomeView(onDismiss: {})
}
