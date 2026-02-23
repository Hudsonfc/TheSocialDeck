//
//  TheSocialDeckPlusPopUpView.swift
//  The Social Deck
//

import SwiftUI

/// SoDeck red #D93A3A, black #0A0A0A, white #FFFFFF
private let soDeckRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
private let soDeckBlack = Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0)

private let sectionSpacing: CGFloat = 36
private let planCardSpacing: CGFloat = 18
private let continueToRestoreSpacing: CGFloat = 24

struct TheSocialDeckPlusPopUpView: View {
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: drag indicator + close
                HStack {
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(red: 0xCC/255.0, green: 0xCC/255.0, blue: 0xCC/255.0))
                        .frame(width: 36, height: 5)
                    Spacer()
                    Button(action: { onDismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color(red: 0x5A/255.0, green: 0x5A/255.0, blue: 0x5A/255.0))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 8)

                // Crown, title, subtitle at top
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 28))
                        .foregroundColor(soDeckRed)

                    Text("TheSocialDeck+")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(soDeckBlack)
                        .multilineTextAlignment(.center)

                    Text("Unlock Plus games and pro settings.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x5A/255.0, green: 0x5A/255.0, blue: 0x5A/255.0))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)

                Spacer(minLength: 0)

                // Plans Section – Monthly & Yearly (position unchanged)
                VStack(spacing: planCardSpacing) {
                    PlanCardView(title: "Monthly", subtitle: "Billed monthly", showBestValue: false)
                    PlanCardView(title: "Yearly", subtitle: "Billed annually · Save more", showBestValue: true)
                }
                .frame(maxWidth: min(380, UIScreen.main.bounds.width - 48))
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)

                // 3. Bottom Section – Continue + Restore
                VStack(spacing: continueToRestoreSpacing) {
                    Button(action: {}) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(soDeckRed)
                            .cornerRadius(16)
                    }

                    Button(action: {}) {
                        Text("Restore Purchases")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(soDeckRed)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .padding(.top, 60)
        }
    }
}

// MARK: - Plan card (placeholder, no selection logic)
private struct PlanCardView: View {
    let title: String
    let subtitle: String
    let showBestValue: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "crown.fill")
                .font(.system(size: 22))
                .foregroundColor(soDeckRed)
                .frame(width: 44, height: 44, alignment: .center)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(soDeckBlack)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }

            Spacer(minLength: 12)

            if showBestValue {
                Text("Best Value")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(soDeckRed)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0xE8/255.0, green: 0xE8/255.0, blue: 0xE8/255.0), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    TheSocialDeckPlusPopUpView(onDismiss: {})
}
