//
//  TheSocialDeckPlusPopUpView.swift
//  The Social Deck
//

import SwiftUI
import StoreKit

// MARK: - Brand tokens
private let soDeckRed       = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
private let soDeckBlack     = Color(red: 0xF2/255.0, green: 0xF2/255.0, blue: 0xF2/255.0)
private let soDeckGray      = Color(red: 0xB0/255.0, green: 0xB0/255.0, blue: 0xB8/255.0)
private let soDeckLightGray = Color(red: 0x70/255.0, green: 0x70/255.0, blue: 0x78/255.0)

// Background layers
private let soDeckBgTop     = Color(red: 0x10/255.0, green: 0x0E/255.0, blue: 0x13/255.0)
private let soDeckBgBottom  = Color(red: 0x1C/255.0, green: 0x18/255.0, blue: 0x22/255.0)
private let soDeckCardBg    = Color(red: 0x22/255.0, green: 0x1E/255.0, blue: 0x28/255.0)
private let soDeckCardBorder = Color(red: 0x38/255.0, green: 0x34/255.0, blue: 0x40/255.0)

// MARK: - Paywall view
struct TheSocialDeckPlusPopUpView: View {
    var onDismiss: () -> Void

    @EnvironmentObject private var subManager: SubscriptionManager
    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var showWelcome = false

    // Derived display values
    private var yearlyPrice: String {
        subManager.yearlyProduct?.displayPrice.appending("/year") ?? "$29.99/year"
    }
    private var monthlyPrice: String {
        subManager.monthlyProduct?.displayPrice.appending("/month") ?? "$4.99/month"
    }

    /// Effective monthly rate for yearly plan, e.g. "$2.50 monthly"
    private var yearlyEffectiveMonthlyLine: String? {
        guard let yearly = subManager.yearlyProduct else { return nil }
        let perMonth = yearly.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        guard let str = formatter.string(from: perMonth as NSDecimalNumber) else { return nil }
        return "\(str) monthly"
    }

    // CTA button label
    private var ctaLabel: String {
        if subManager.isPlus { return "Unlocked ✓" }
        switch subManager.selectedPlan {
        case .yearly:  return "Continue with Yearly"
        case .monthly: return "Continue with Monthly"
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [soDeckBgTop, soDeckBgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Close row ─────────────────────────────────────────
                    HStack {
                        Spacer()
                        Button(action: { onDismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(soDeckGray)
                        }
                        .disabled(subManager.isLoading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 64)
                    .padding(.bottom, 20)

                    // ── SECTION 1: Header ──────────────────────────────────
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(soDeckRed.opacity(0.10))
                                .frame(width: 76, height: 76)
                            Image(systemName: "rectangle.stack.fill")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(soDeckRed)
                                .rotationEffect(.degrees(90))
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

                    // ── SECTION 2: Plan cards ──────────────────────────────
                    VStack(spacing: 20) {
                        PlusPlanCard(
                            title: "Yearly",
                            price: yearlyPrice,
                            detail: "Billed annually",
                            subtitle: yearlyEffectiveMonthlyLine,
                            showBestValue: true,
                            isSelected: subManager.selectedPlan == .yearly
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                subManager.selectedPlan = .yearly
                            }
                        }

                        PlusPlanCard(
                            title: "Monthly",
                            price: monthlyPrice,
                            detail: "Billed monthly",
                            showBestValue: false,
                            isSelected: subManager.selectedPlan == .monthly
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                subManager.selectedPlan = .monthly
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: min(480, UIScreen.main.bounds.width))
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 36)

                    // ── SECTION 3: CTA ─────────────────────────────────────
                    VStack(spacing: 14) {
                        // Continue / Unlocked button
                        Button {
                            guard !subManager.isPlus else { onDismiss(); return }
                            Task { await subManager.purchaseSelectedPlan() }
                        } label: {
                            ZStack {
                                Text(ctaLabel)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .opacity(subManager.isLoading ? 0 : 1)

                                if subManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                subManager.isPlus
                                    ? Color.green.opacity(0.85)
                                    : soDeckRed.opacity(subManager.isLoading ? 0.6 : 1)
                            )
                            .cornerRadius(24)
                            .shadow(
                                color: (subManager.isPlus ? Color.green : soDeckRed).opacity(0.30),
                                radius: 12, x: 0, y: 6
                            )
                        }
                        .disabled(subManager.isLoading)
                        .animation(.easeInOut(duration: 0.2), value: subManager.selectedPlan)
                        .animation(.easeInOut(duration: 0.3), value: subManager.isPlus)
                        .padding(.horizontal, 20)

                        // Error message (animated)
                        if let error = subManager.errorMessage {
                            Text(error)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(soDeckRed)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Restore purchases
                        Button {
                            Task { await subManager.restorePurchases() }
                        } label: {
                            Text("Restore Purchases")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(soDeckRed)
                        }
                        .disabled(subManager.isLoading)
                        .padding(.top, 2)

                        Text("Subscription auto-renews. Cancel anytime in\nSettings > Apple ID > Subscriptions.")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(soDeckLightGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)

                        HStack(spacing: 4) {
                            Button("Terms of Service") { showTerms = true }
                            Text("·")
                            Button("Privacy Policy") { showPrivacy = true }
                        }
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(soDeckLightGray)
                    }
                    .padding(.bottom, 48)
                    .animation(.easeInOut(duration: 0.25), value: subManager.errorMessage)
                }
            }
        }
        .sheet(isPresented: $showTerms) {
            NavigationStack { TermsOfServiceView() }
        }
        .sheet(isPresented: $showPrivacy) {
            NavigationStack { PrivacyPolicyView() }
        }
        // Welcome screen shown right after a successful purchase
        .fullScreenCover(isPresented: $showWelcome) {
            TheSocialDeckPlusWelcomeView {
                showWelcome = false
                onDismiss()
            }
        }
        .onChange(of: subManager.isPlus) { _, isNowPlus in
            if isNowPlus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    showWelcome = true
                }
            }
        }
        // If already subscribed when the sheet opens, dismiss immediately
        .onAppear {
            if subManager.isPlus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
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
    var subtitle: String? = nil
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
                                isSelected
                                    ? soDeckRed
                                    : Color(red: 0xCC/255.0, green: 0xCC/255.0, blue: 0xCC/255.0),
                                lineWidth: 2
                            )
                            .frame(width: 22, height: 22)
                        if isSelected {
                            Circle()
                                .fill(soDeckRed)
                                .frame(width: 12, height: 12)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(soDeckBlack)
                        Text(detail)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(soDeckGray)
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(soDeckGray)
                        }
                    }

                    Spacer(minLength: 8)

                    Text(price)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? soDeckRed : soDeckBlack)
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
            .background(isSelected ? soDeckRed.opacity(0.12) : soDeckCardBg)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? soDeckRed : soDeckCardBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? soDeckRed.opacity(0.14) : Color.black.opacity(0.05),
                radius: isSelected ? 14 : 6, x: 0, y: isSelected ? 4 : 2
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
