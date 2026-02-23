//
//  TheSocialDeckPlusPopUpView.swift
//  The Social Deck
//

import SwiftUI

/// SoDeck red brand color #D93A3A
private let soDeckRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

struct TheSocialDeckPlusPopUpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 0) {
                // Card container - white, rounded
                VStack(spacing: 24) {
                    // Close button - top right of card
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0x5A/255.0, green: 0x5A/255.0, blue: 0x5A/255.0))
                                .frame(width: 36, height: 36)
                                .background(Color(red: 0xF0/255.0, green: 0xF0/255.0, blue: 0xF0/255.0))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 20)

                    // Header
                    VStack(spacing: 8) {
                        Text("TheSocialDeck+")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))

                        Text("Unlock Plus games + pro settings.")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x5A/255.0, green: 0x5A/255.0, blue: 0x5A/255.0))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    // Plan cards
                    VStack(spacing: 12) {
                        // Monthly - placeholder
                        PlanCardView(title: "Monthly", showBestValue: false)

                        // Yearly - placeholder with Best Value
                        PlanCardView(title: "Yearly", showBestValue: true)
                    }
                    .padding(.horizontal, 20)

                    // Continue button
                    Button(action: {}) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(soDeckRed)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Restore Purchases - secondary text
                    Button(action: {}) {
                        Text("Restore Purchases")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(soDeckRed)
                    }
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 8)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Placeholder plan card (no selection logic)
private struct PlanCardView: View {
    let title: String
    let showBestValue: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                Text("Placeholder plan")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
            Spacer()
            if showBestValue {
                Text("Best Value")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(soDeckRed)
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
        .cornerRadius(12)
    }
}

#Preview {
    TheSocialDeckPlusPopUpView()
}
