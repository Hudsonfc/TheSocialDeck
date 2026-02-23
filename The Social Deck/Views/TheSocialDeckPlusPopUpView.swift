//
//  TheSocialDeckPlusPopUpView.swift
//  The Social Deck
//

import SwiftUI

// MARK: - Brand tokens
private let soDeckRed   = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
private let soDeckBlack = Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0)
private let soDeckGray  = Color(red: 0x5A/255.0, green: 0x5A/255.0, blue: 0x5A/255.0)
private let soDeckLightGray = Color(red: 0xAA/255.0, green: 0xAA/255.0, blue: 0xAA/255.0)

// MARK: - Plan model
private enum PlusPlan { case monthly, yearly }

// MARK: - Main view
struct TheSocialDeckPlusPopUpView: View {
    var onDismiss: () -> Void

    @State private var selectedPlan: PlusPlan = .yearly

    var body: some View {
        ZStack {
            // Subtle background gradient
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Close button row ──────────────────────────────────
                    HStack {
                        Spacer()
                        Button(action: { onDismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(soDeckGray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 64)
                    .padding(.bottom, 20)

                    // ── SECTION 1: Header ─────────────────────────────────
                    VStack(spacing: 10) {
                        // Crown in soft red circle
                        ZStack {
                            Circle()
                                .fill(soDeckRed.opacity(0.10))
                                .frame(width: 76, height: 76)
                            Image(systemName: "crown.fill")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(soDeckRed)
                        }
                        .padding(.bottom, 4)

                        Text("TheSocialDeck+")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(soDeckBlack)
                            .multilineTextAlignment(.center)

                        Text("Unlock Plus games and pro settings.")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(soDeckGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        // Feature bullets
                        VStack(alignment: .leading, spacing: 10) {
                            PlusFeatureRow(text: "Access exclusive Plus games")
                            PlusFeatureRow(text: "Advanced game controls")
                            PlusFeatureRow(text: "Custom themes & settings")
                            PlusFeatureRow(text: "Support future updates")
                        }
                        .padding(.top, 14)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 36)

                    // ── SECTION 2: Plan selection ─────────────────────────
                    VStack(spacing: 20) {
                        // Yearly first (emphasized)
                        PlusPlanCard(
                            title: "Yearly",
                            price: "$29.99/year",
                            detail: "Just $2.50/month",
                            showBestValue: true,
                            isSelected: selectedPlan == .yearly
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPlan = .yearly
                            }
                        }

                        // Monthly
                        PlusPlanCard(
                            title: "Monthly",
                            price: "$4.99/month",
                            detail: "Billed monthly",
                            showBestValue: false,
                            isSelected: selectedPlan == .monthly
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPlan = .monthly
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: min(480, UIScreen.main.bounds.width))
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 36)

                    // ── SECTION 3: CTA ────────────────────────────────────
                    VStack(spacing: 14) {
                        // Dynamic continue button
                        Button(action: {}) {
                            Text(selectedPlan == .yearly ? "Continue with Yearly" : "Continue with Monthly")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(soDeckRed)
                                .cornerRadius(24)
                                .shadow(color: soDeckRed.opacity(0.30), radius: 12, x: 0, y: 6)
                        }
                        .animation(.easeInOut(duration: 0.2), value: selectedPlan)
                        .padding(.horizontal, 20)

                        Button(action: {}) {
                            Text("Restore Purchases")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(soDeckRed)
                        }
                        .padding(.top, 2)

                        Text("Terms of Service  ·  Privacy Policy")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(soDeckLightGray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 48)
                }
            }
        }
    }
}

// MARK: - Feature bullet row
private struct PlusFeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(soDeckRed)
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(soDeckBlack)
        }
    }
}

// MARK: - Plan selection card
private struct PlusPlanCard: View {
    let title: String
    let price: String
    let detail: String
    let showBestValue: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 14) {
                    // Radio indicator
                    ZStack {
                        Circle()
                            .stroke(
                                isSelected ? soDeckRed : Color(red: 0xCC/255.0, green: 0xCC/255.0, blue: 0xCC/255.0),
                                lineWidth: 2
                            )
                            .frame(width: 22, height: 22)
                        if isSelected {
                            Circle()
                                .fill(soDeckRed)
                                .frame(width: 12, height: 12)
                        }
                    }

                    // Label + detail
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(soDeckBlack)
                        Text(detail)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    }

                    Spacer(minLength: 8)

                    // Price
                    Text(price)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? soDeckRed : soDeckBlack)
                        .padding(.trailing, showBestValue ? 0 : 0)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
                .padding(.top, showBestValue ? 10 : 0)

                // Best Value pill
                if showBestValue {
                    Text("Best Value")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(soDeckRed)
                        .cornerRadius(8)
                        .padding(.top, 12)
                        .padding(.trailing, 16)
                }
            }
            .background(
                isSelected
                    ? soDeckRed.opacity(0.06)
                    : Color.white
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? soDeckRed : Color(red: 0xE5/255.0, green: 0xE5/255.0, blue: 0xE5/255.0),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? soDeckRed.opacity(0.14) : Color.black.opacity(0.05),
                radius: isSelected ? 14 : 6,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    TheSocialDeckPlusPopUpView(onDismiss: {})
}
