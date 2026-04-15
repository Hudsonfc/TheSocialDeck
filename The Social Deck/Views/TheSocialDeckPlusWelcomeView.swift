//
//  TheSocialDeckPlusWelcomeView.swift
//  The Social Deck
//

import SwiftUI

struct TheSocialDeckPlusWelcomeView: View {
    var onDismiss: () -> Void

    @State private var heroScale: CGFloat = 0.88
    @State private var heroOpacity: Double = 0
    @State private var headlineOffset: CGFloat = 18
    @State private var headlineOpacity: Double = 0
    @State private var cardsOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    private let soDeckRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0x14/255.0, green: 0x0C/255.0, blue: 0x12/255.0),
                    Color(red: 0x2A/255.0, green: 0x14/255.0, blue: 0x1A/255.0),
                    Color(red: 0x1A/255.0, green: 0x0E/255.0, blue: 0x16/255.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [soDeckRed.opacity(0.35), Color.clear],
                center: .top,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()
            .opacity(0.9)

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                ZStack {
                    Circle()
                        .fill(soDeckRed.opacity(0.35))
                        .frame(width: 112, height: 112)
                        .blur(radius: 18)
                        .opacity(0.85)

                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                        )

                    Image(systemName: "sparkles")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, soDeckRed.opacity(0.95)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .scaleEffect(heroScale)
                .opacity(heroOpacity)
                .padding(.bottom, 28)

                VStack(spacing: 12) {
                    Text("You’re in.")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(soDeckRed.opacity(0.95))
                        .tracking(1.2)

                    Text("Congratulations")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("TheSocialDeck+ is yours—welcome to the inner circle.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                .offset(y: headlineOffset)
                .opacity(headlineOpacity)
                .padding(.bottom, 28)

                VStack(alignment: .leading, spacing: 16) {
                    welcomeHighlightRow(
                        icon: "square.grid.2x2.fill",
                        title: "Premium categories",
                        subtitle: "Spicy packs and deep cuts across your favorite decks—tap any locked pack and it’s yours."
                    )
                    welcomeHighlightRow(
                        icon: "person.crop.circle.badge.checkmark",
                        title: "Premium avatars",
                        subtitle: "Dress your profile with exclusive looks reserved for Plus members."
                    )
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 22)
                .opacity(cardsOpacity)

                Spacer(minLength: 20)

                Button(action: {
                    HapticManager.shared.mediumImpact()
                    onDismiss()
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [soDeckRed, soDeckRed.opacity(0.82)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(22)
                        .shadow(color: soDeckRed.opacity(0.45), radius: 16, x: 0, y: 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
                .opacity(buttonOpacity)
            }
        }
        .onAppear { runEntryAnimations() }
    }

    private func welcomeHighlightRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(soDeckRed.opacity(0.95))
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.white.opacity(0.1)))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func runEntryAnimations() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
            heroScale = 1.0
            heroOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                headlineOffset = 0
                headlineOpacity = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
            withAnimation(.easeOut(duration: 0.45)) {
                cardsOpacity = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.easeOut(duration: 0.4)) {
                buttonOpacity = 1.0
            }
        }
    }
}

#Preview {
    TheSocialDeckPlusWelcomeView(onDismiss: {})
}
