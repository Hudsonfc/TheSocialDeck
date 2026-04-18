//
//  TheSocialDeckPlusPopUpView.swift
//  The Social Deck
//

import SwiftUI
import StoreKit

// MARK: - Brand tokens
private let soDeckRed        = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
private let soDeckRedDark    = Color(red: 0xBB/255.0, green: 0x20/255.0, blue: 0x20/255.0)
private let soDeckBgTop      = Color(red: 0x10/255.0, green: 0x0E/255.0, blue: 0x13/255.0)
private let soDeckCardBg     = Color(white: 1, opacity: 0.07)
private let soDeckCardBorder = Color(white: 1, opacity: 0.16)
private let soDeckGray       = Color(red: 0xB0/255.0, green: 0xB0/255.0, blue: 0xB8/255.0)
private let soDeckLightGray  = Color(red: 0x70/255.0, green: 0x70/255.0, blue: 0x78/255.0)

// MARK: - Paywall view
struct TheSocialDeckPlusPopUpView: View {
    var onDismiss: () -> Void

    @EnvironmentObject private var subManager: SubscriptionManager
    @State private var showTerms   = false
    @State private var showPrivacy = false

    // MARK: - Derived price strings

    private var yearlyPrice: String {
        subManager.yearlyProduct?.displayPrice.appending("/year") ?? "$29.99/year"
    }

    private var monthlyPrice: String {
        subManager.monthlyProduct?.displayPrice.appending("/month") ?? "$5.99/month"
    }

    private var yearlyPerMonth: String? {
        guard let yearly = subManager.yearlyProduct else { return nil }
        let perMonth = yearly.price / 12
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.locale = .current
        guard let s = fmt.string(from: perMonth as NSDecimalNumber) else { return nil }
        return "~\(s)/month"
    }

    private var yearlyDiscountBadge: String {
        guard let yearly  = subManager.yearlyProduct,
              let monthly = subManager.monthlyProduct else { return "BEST VALUE" }
        let annualised = (monthly.price as NSDecimalNumber).doubleValue * 12
        let yearlyD    = (yearly.price  as NSDecimalNumber).doubleValue
        guard annualised > 0 else { return "BEST VALUE" }
        let pct = Int(((annualised - yearlyD) / annualised * 100).rounded())
        return pct > 0 ? "SAVE \(pct)%" : "BEST VALUE"
    }

    // MARK: - Body

    var body: some View {
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height

        ZStack {

            // ── Layer 1: solid dark base ──────────────────────────────
            soDeckBgTop.ignoresSafeArea()

            // ── Layer 2: animated card grid — clamped to screen size ──
            // The hero is given an explicit frame so it never inflates
            // the ZStack beyond screen bounds.
            PaywallGameCardsHero()
                .frame(width: screenW, height: screenH, alignment: .top)
                .clipped()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // ── Layer 3: gradient — cards visible top, dark at bottom ─
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.00), location: 0.00),
                    .init(color: .black.opacity(0.12), location: 0.25),
                    .init(color: soDeckBgTop.opacity(0.85), location: 0.40),
                    .init(color: soDeckBgTop,               location: 0.52),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // ── Layer 4: content pinned to the bottom of the screen ───
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 11) {

                    // Headline
                    VStack(spacing: 1) {
                        Text("Unlock the")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("Ultimate Deck")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [soDeckRed,
                                             Color(red: 0xFF/255.0, green: 0x70/255.0, blue: 0x70/255.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .multilineTextAlignment(.center)

                    // Feature bullets
                    PaywallFeaturesBox()

                    // Plan selector cards
                    VStack(spacing: 8) {
                        PaywallPlanCard(
                            title: "Yearly",
                            price: yearlyPrice,
                            detail: "Billed annually",
                            subtitle: yearlyPerMonth,
                            badgeText: yearlyDiscountBadge,
                            isSelected: subManager.selectedPlan == .yearly
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                subManager.selectedPlan = .yearly
                            }
                        }

                        PaywallPlanCard(
                            title: "Monthly",
                            price: monthlyPrice,
                            detail: "Billed every month",
                            subtitle: nil,
                            badgeText: nil,
                            isSelected: subManager.selectedPlan == .monthly
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                subManager.selectedPlan = .monthly
                            }
                        }
                    }

                    // Error (shown inline when present)
                    if let error = subManager.errorMessage {
                        Text(error)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(soDeckRed)
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // CTA button
                    VStack(spacing: 5) {
                        Button {
                            guard !subManager.isPlus else { onDismiss(); return }
                            Task { await subManager.purchaseSelectedPlan() }
                        } label: {
                            ZStack {
                                Text(subManager.isPlus ? "Unlocked ✓" : "Continue")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .opacity(subManager.isLoading ? 0 : 1)
                                if subManager.isLoading {
                                    ProgressView().tint(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Group {
                                    if subManager.isPlus {
                                        LinearGradient(colors: [.green, .green.opacity(0.80)],
                                                       startPoint: .leading, endPoint: .trailing)
                                    } else {
                                        LinearGradient(colors: [soDeckRed, soDeckRedDark],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                                    }
                                }
                            )
                            .clipShape(Capsule())
                            .shadow(
                                color: (subManager.isPlus ? Color.green : soDeckRed).opacity(0.45),
                                radius: 14, x: 0, y: 5
                            )
                        }
                        .disabled(subManager.isLoading)
                        .animation(.easeInOut(duration: 0.3), value: subManager.isPlus)
                        .animation(.easeInOut(duration: 0.25), value: subManager.errorMessage)

                        Text("Cancel anytime")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.38))
                    }

                    // Footer
                    VStack(spacing: 8) {
                        Button {
                            Task { await subManager.restorePurchases() }
                        } label: {
                            Text("Restore Purchases")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(soDeckGray)
                                .underline()
                        }
                        .disabled(subManager.isLoading)

                        Text("Subscription auto-renews. Cancel anytime in\nSettings > Apple ID > Subscriptions.")
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundColor(soDeckLightGray)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 4) {
                            Button("Terms of Service") { showTerms = true }
                            Text("·").foregroundColor(soDeckLightGray)
                            Button("Privacy Policy") { showPrivacy = true }
                        }
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(soDeckLightGray)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 44)
            }

            // ── Layer 5: close button pinned to top-right ─────────────
            VStack {
                HStack {
                    Spacer()
                    Button(action: { onDismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.75))
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.white.opacity(0.16)))
                    }
                    .disabled(subManager.isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                Spacer()
            }
        }
        .sheet(isPresented: $showTerms) {
            NavigationStack { TermsOfServiceView() }
        }
        .sheet(isPresented: $showPrivacy) {
            NavigationStack { PrivacyPolicyView() }
        }
        .onChange(of: subManager.isPlus) { _, isNowPlus in
            if isNowPlus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onDismiss()
                }
            }
        }
        .onAppear {
            if subManager.isPlus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Animated masonry hero background

private struct PaywallGameCardsHero: View {
    // Same aspect ratio Play2View uses for grid tiles (420 × 577 artwork)
    private static let aspectRatio: CGFloat = 420.0 / 577.0
    private let colGap: CGFloat = 8
    private let rowGap: CGFloat = 8

    private let col1: [DeckType] = [
        .neverHaveIEver, .spillTheEx, .actItOut, .quickfireCouples, .closerThanEver, .memoryMaster
    ]
    private let col2: [DeckType] = [
        .truthOrDare, .takeItPersonally, .riddleMeThis, .actNatural, .usAfterDark, .bluffCall
    ]
    private let col3: [DeckType] = [
        .wouldYouRather, .mostLikelyTo, .rhymeTime, .storyChain, .flip21
    ]

    var body: some View {
        let screenW = UIScreen.main.bounds.width
        let cardW   = (screenW - colGap * 2) / 3
        let cardH   = cardW / Self.aspectRatio
        let step    = cardH + rowGap

        HStack(alignment: .top, spacing: colGap) {
            AnimatingCardColumn(types: col1, cardW: cardW, cardH: cardH, rowGap: rowGap,
                                duration: 24, masonryOffset: 0)
            AnimatingCardColumn(types: col2, cardW: cardW, cardH: cardH, rowGap: rowGap,
                                duration: 28, masonryOffset: step * 0.55)
            AnimatingCardColumn(types: col3, cardW: cardW, cardH: cardH, rowGap: rowGap,
                                duration: 21, masonryOffset: step * 0.26)
        }
    }
}

// MARK: - Single auto-scrolling column

private struct AnimatingCardColumn: View {
    let types: [DeckType]
    let cardW: CGFloat
    let cardH: CGFloat
    let rowGap: CGFloat
    let duration: Double
    let masonryOffset: CGFloat

    @State private var scrolled = false
    @Environment(\.colorScheme) private var colorScheme

    private var singleSetH: CGFloat { CGFloat(types.count) * (cardH + rowGap) }

    /// Flip 21 uses a hard-coded white panel; tint it to match paywall charcoal in dark mode.
    private let flip21DarkMultiply = Color(red: 0.18, green: 0.16, blue: 0.22)

    var body: some View {
        let doubled = types + types
        let useAdaptivePanels = colorScheme == .dark
        VStack(spacing: rowGap) {
            ForEach(Array(doubled.enumerated()), id: \.offset) { _, deckType in
                Group {
                    if colorScheme == .dark && deckType == .flip21 {
                        DeckCoverArtView(deck: .coverOnly(type: deckType))
                            .environment(\.playGridAdaptiveSocialDeckCovers, useAdaptivePanels)
                            .environment(\.whatWouldYouDoCoverEmbeddedPills, false)
                            .colorMultiply(flip21DarkMultiply)
                    } else {
                        DeckCoverArtView(deck: .coverOnly(type: deckType))
                            .environment(\.playGridAdaptiveSocialDeckCovers, useAdaptivePanels)
                            .environment(\.whatWouldYouDoCoverEmbeddedPills, false)
                    }
                }
                .frame(width: cardW, height: cardH)
                .cornerRadius(10)
                .clipped()
                .allowsHitTesting(false)
            }
        }
        .offset(y: masonryOffset)
        .offset(y: scrolled ? -singleSetH : 0)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    scrolled = true
                }
            }
        }
    }
}

// MARK: - Feature bullets card

private struct PaywallFeaturesBox: View {
    private let features: [String] = [
        "Unlimited room creation & online play",
        "Access to online games",
        "Premium categories across all decks",
        "Custom avatar colors",
        "More online games coming soon",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ForEach(features, id: \.self) { line in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color.primaryAccent)
                        .frame(width: 18, alignment: .center)

                    Text(line)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.88))

                    Spacer(minLength: 0)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(soDeckCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(soDeckCardBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - Plan selection card

private struct PaywallPlanCard: View {
    let title: String
    let price: String
    let detail: String
    let subtitle: String?
    let badgeText: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(isSelected ? soDeckRed : Color.white.opacity(0.35), lineWidth: 2)
                            .frame(width: 20, height: 20)
                        if isSelected {
                            Circle()
                                .fill(soDeckRed)
                                .frame(width: 10, height: 10)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        Text(detail)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.50))
                        if let sub = subtitle {
                            Text(sub)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(isSelected ? soDeckRed.opacity(0.85) : Color.white.opacity(0.40))
                        }
                    }

                    Spacer(minLength: 8)

                    Text(price)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? soDeckRed : .white)
                }
                .padding(.horizontal, 16)
                .padding(.top, badgeText != nil ? 28 : 13)
                .padding(.bottom, 13)

                if let badge = badgeText {
                    Text(badge)
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(soDeckRed))
                        .padding(.top, 10)
                        .padding(.trailing, 14)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? soDeckRed.opacity(0.10) : soDeckCardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? soDeckRed : soDeckCardBorder,
                                  lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? soDeckRed.opacity(0.18) : .black.opacity(0.05),
                    radius: isSelected ? 12 : 3, x: 0, y: isSelected ? 4 : 1)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.72), value: isSelected)
    }
}

#Preview {
    TheSocialDeckPlusPopUpView(onDismiss: {})
        .environmentObject(SubscriptionManager.shared)
}
