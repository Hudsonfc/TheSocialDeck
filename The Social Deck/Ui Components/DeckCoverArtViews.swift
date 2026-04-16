//
//  DeckCoverArtViews.swift
//  The Social Deck
//
//  Programmatic deck covers: Classics, Spill/TIP, Rhyme/Tap, WMS/RMT, Act games, Category Clash, Story Chain, Memory Master, Bluff Call, Spin, Two Truths, Hot Potato, Color Clash, Flip 21, date-night trio — no catalog artwork.
//

import SwiftUI

// MARK: - Social Deck play grid: adaptive programmatic surfaces (Tap Duel ignores; TIP / Act It Out already use card tokens)

struct PlayGridAdaptiveSocialDeckCoversKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// `true` on Play when showing **Social Deck Games** (or a Social Deck title in **Favorites**) so programmatic covers use `cardBackground` + semantic text like Take It Personally. Tap Duel is forced off in `DeckCoverArtView`.
    var playGridAdaptiveSocialDeckCovers: Bool {
        get { self[PlayGridAdaptiveSocialDeckCoversKey.self] }
        set { self[PlayGridAdaptiveSocialDeckCoversKey.self] = newValue }
    }
}

// MARK: - What Would You Do cover (embedded pills only on Play grid tiles)

struct WhatWouldYouDoCoverEmbeddedPillsKey: EnvironmentKey {
    /// `true` = show “New” / “Online matchmaking” pills inside the artwork (Play grid). `false` = title art only (e.g. game description overlay).
    static let defaultValue = true
}

extension EnvironmentValues {
    var whatWouldYouDoCoverEmbeddedPills: Bool {
        get { self[WhatWouldYouDoCoverEmbeddedPillsKey.self] }
        set { self[WhatWouldYouDoCoverEmbeddedPillsKey.self] = newValue }
    }
}

/// Fixed “light card” colors vs semantic colors when `playGridAdaptiveSocialDeckCovers` is active.
struct ProgrammaticSocialDeckCoverInk {
    let adaptive: Bool

    var panel: Color {
        adaptive ? Color.cardBackground : Color.white
    }

    func caption(_ fixedLight: Color) -> Color {
        adaptive ? Color.secondaryText : fixedLight
    }

    func hero(_ fixedLight: Color) -> Color {
        adaptive ? Color.primaryText : fixedLight
    }

    func hairline(lightOpacity: Double) -> Color {
        adaptive ? Color.primaryText.opacity(0.14) : Color.black.opacity(lightOpacity)
    }
}

// MARK: - Classic row (NHIE, Truth or Dare, Would You Rather, Most Likely To)

extension DeckType {
    /// Title segments for programmatic classic covers: one-line prefix (trailing space), wrapped first line, accent hero word.
    var programmaticClassicCoverParts: (prefixOneLine: String, firstLineWrapped: String, heroWord: String)? {
        switch self {
        case .neverHaveIEver:
            return ("NEVER HAVE I ", "NEVER HAVE I", "EVER")
        case .truthOrDare:
            return ("TRUTH OR ", "TRUTH OR", "DARE")
        case .wouldYouRather:
            return ("WOULD YOU ", "WOULD YOU", "RATHER")
        case .mostLikelyTo:
            return ("MOST LIKELY ", "MOST LIKELY", "TO")
        default:
            return nil
        }
    }

    var usesProgrammaticClassicCoverArt: Bool {
        programmaticClassicCoverParts != nil
    }
}

// MARK: - Shared layout (modern, minimal — matches NHIE direction)

struct ProgrammaticClassicCoverArtView: View {
    let deckType: DeckType
    /// When `false`, only the title lettering is shown (clear background, no “card” panel).
    var showsCardPanel: Bool = true

    private var parts: (prefixOneLine: String, firstLineWrapped: String, heroWord: String) {
        deckType.programmaticClassicCoverParts
            ?? ("", "", "")
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let isWYR = deckType == .wouldYouRather
            // Would You Rather needs a slightly tighter lockup so "RATHER" never hyphen-wraps.
            let captionSize = max(10, u * 0.056) * (isWYR ? 0.9 : 1.0)
            let heroSize = max(26, u * 0.198) * (isWYR ? 0.82 : 1.0)
            let captionTracking: CGFloat = isWYR ? 0.45 : 1.0
            let heroTracking: CGFloat = isWYR ? 0.2 : 0.8
            let oneLineMinScale: CGFloat = isWYR ? 0.5 : 0.68

            ZStack {
                Group {
                    if showsCardPanel {
                        Color.cardBackground
                    } else {
                        Color.clear
                    }
                }

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    ViewThatFits(in: .horizontal) {
                        titleOneLine(
                            caption: captionSize,
                            hero: heroSize,
                            captionTracking: captionTracking,
                            heroTracking: heroTracking,
                            oneLineMinScale: oneLineMinScale
                        )
                        titleTwoLines(
                            caption: captionSize,
                            hero: heroSize,
                            gap: u * 0.02,
                            captionTracking: captionTracking,
                            heroTracking: heroTracking
                        )
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    // Slightly more horizontal room for WYR so "RATHER" stays one visual line.
                    .padding(.horizontal, u * (isWYR ? 0.072 : 0.1))

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func titleOneLine(
        caption: CGFloat,
        hero: CGFloat,
        captionTracking: CGFloat,
        heroTracking: CGFloat,
        oneLineMinScale: CGFloat
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 1) {
            Text(parts.prefixOneLine)
                .font(.system(size: caption, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.secondaryText)
                .tracking(captionTracking)
                .lineLimit(1)
                .minimumScaleFactor(oneLineMinScale)
            Text(parts.heroWord)
                .font(.system(size: hero, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.primaryAccent)
                .tracking(heroTracking)
                .lineLimit(1)
                .minimumScaleFactor(0.38)
                .layoutPriority(1)
        }
        .lineLimit(1)
        .minimumScaleFactor(oneLineMinScale)
    }

    private func titleTwoLines(
        caption: CGFloat,
        hero: CGFloat,
        gap: CGFloat,
        captionTracking: CGFloat,
        heroTracking: CGFloat
    ) -> some View {
        VStack(spacing: gap) {
            Text(parts.firstLineWrapped)
                .font(.system(size: caption * 1.05, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.secondaryText)
                .tracking(captionTracking)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
            Text(parts.heroWord)
                .font(.system(size: hero, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.primaryAccent)
                .tracking(heroTracking)
                .lineLimit(1)
                .minimumScaleFactor(0.34)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Spill the Ex (white panel + rose hero)

struct ProgrammaticSpillTheExCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let ruleH = max(1, u * 0.012)
            let caption = max(9, u * 0.095)
            let hero = max(20, u * 0.24)

            ZStack {
                ink.panel

                VStack(spacing: u * 0.05) {
                    Rectangle()
                        .fill(ink.hairline(lightOpacity: 0.08))
                        .frame(width: u * 0.4, height: ruleH)

                    VStack(spacing: u * 0.022) {
                        Text("spill the")
                            .font(.system(size: caption, weight: .medium, design: .rounded))
                            .foregroundStyle(ink.caption(Color(red: 0.38, green: 0.35, blue: 0.37)))
                            .tracking(1.1)

                        Text("EX")
                            .font(.system(size: hero, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1, green: 0.66, blue: 0.80),
                                        Color(red: 0.93, green: 0.36, blue: 0.56)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .tracking(1.6)
                            .minimumScaleFactor(0.45)
                            .lineLimit(1)
                    }

                    Rectangle()
                        .fill(ink.hairline(lightOpacity: 0.06))
                        .frame(width: u * 0.4, height: ruleH)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, u * 0.08)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Take It Personally (light surface + accent bar — distinct from classics & Spill)

struct ProgrammaticTakeItPersonallyCoverArtView: View {
    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let barW = max(3, u * 0.042)
            let topLine = max(10, u * 0.098)
            let hero = max(14, u * 0.168)

            ZStack {
                Color.cardBackground

                HStack(alignment: .center, spacing: u * 0.075) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.98, green: 0.74, blue: 0.26),
                                    Color(red: 0.90, green: 0.50, blue: 0.10)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: barW, height: u * 0.58)

                    VStack(alignment: .leading, spacing: u * 0.028) {
                        Text("Take it")
                            .font(.system(size: topLine, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.secondaryText)
                            .tracking(0.6)

                        Text("personally")
                            .font(.system(size: hero, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.primaryText)
                            .tracking(0.2)
                            .minimumScaleFactor(0.48)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, u * 0.1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Rhyme Time (white panel + purple accents)

struct ProgrammaticRhymeTimeCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let tag = max(9, u * 0.086)
            let hero = max(16, u * 0.20)
            let barH = max(2, u * 0.026)

            ZStack {
                ink.panel

                VStack(spacing: u * 0.038) {
                    Text("RHYME")
                        .font(.system(size: tag, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.42, green: 0.35, blue: 0.58)))
                        .tracking(2.2)

                    RoundedRectangle(cornerRadius: barH * 0.5, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.62, green: 0.48, blue: 0.95),
                                    Color(red: 0.40, green: 0.32, blue: 0.78)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: u * 0.44, height: barH)

                    Text("time")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(ink.hero(Color(red: 0.28, green: 0.20, blue: 0.48)))
                        .tracking(0.3)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Tap Duel (white / black split + crisp center rule — no color accents)

struct ProgrammaticTapDuelCoverArtView: View {
    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let word = max(12, u * 0.15)
            let lineW = max(2.5, u * 0.036)
            let lineH = min(geo.size.height * 0.44, u * 0.52)

            HStack(spacing: 0) {
                ZStack {
                    Color(red: 0.98, green: 0.98, blue: 0.99)
                    Text("TAP")
                        .font(.system(size: word, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.9))
                        .tracking(0.5)
                        .minimumScaleFactor(0.48)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(Color.white)
                    .frame(width: lineW, height: lineH)
                    .overlay(
                        RoundedRectangle(cornerRadius: 1, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.12), lineWidth: 0.5)
                    )

                ZStack {
                    Color(red: 0.04, green: 0.04, blue: 0.045)
                    Text("DUEL")
                        .font(.system(size: word, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.97))
                        .tracking(0.35)
                        .minimumScaleFactor(0.48)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - What's My Secret (white panel + plum hero)

struct ProgrammaticWhatsMySecretCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let small = max(8, u * 0.076)
            let hero = max(14, u * 0.168)
            let ruleH = max(1, u * 0.01)

            ZStack {
                ink.panel

                VStack(spacing: u * 0.042) {
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(ink.hairline(lightOpacity: 0.08))
                        .frame(width: u * 0.34, height: ruleH)

                    Text("WHAT'S MY")
                        .font(.system(size: small, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.42, green: 0.40, blue: 0.45)))
                        .tracking(2.0)

                    Text("SECRET")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.32, green: 0.18, blue: 0.42),
                                    Color(red: 0.72, green: 0.28, blue: 0.52)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(1.0)
                        .minimumScaleFactor(0.42)
                        .lineLimit(1)

                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(ink.hairline(lightOpacity: 0.06))
                        .frame(width: u * 0.4, height: ruleH)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, u * 0.07)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Riddle Me This (white panel + red frame + type tuned to red)

struct ProgrammaticRiddleMeThisCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let cap = max(9, u * 0.084)
            let hero = max(13, u * 0.138)
            let inset = u * 0.055
            let stroke = max(1, u * 0.012)

            ZStack {
                ink.panel

                RoundedRectangle(cornerRadius: u * 0.04, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 0.92, green: 0.22, blue: 0.28),
                                Color(red: 0.68, green: 0.08, blue: 0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: stroke
                    )
                    .padding(inset)

                VStack(spacing: u * 0.04) {
                    Text("RIDDLE")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(ink.hero(Color(red: 0.14, green: 0.10, blue: 0.12)))
                        .tracking(0.6)
                        .minimumScaleFactor(0.45)
                        .lineLimit(1)

                    Text("ME THIS")
                        .font(.system(size: cap, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.50, green: 0.28, blue: 0.34)))
                        .tracking(1.6)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Act It Out (same layout language as Take It Personally: card + accent bar + two-line title)

struct ProgrammaticActItOutCoverArtView: View {
    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let barW = max(3, u * 0.042)
            let topLine = max(10, u * 0.098)
            let hero = max(14, u * 0.168)

            ZStack {
                Color.cardBackground

                HStack(alignment: .center, spacing: u * 0.075) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.42, green: 0.88, blue: 0.58),
                                    Color(red: 0.16, green: 0.62, blue: 0.52)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: barW, height: u * 0.58)

                    VStack(alignment: .leading, spacing: u * 0.028) {
                        Text("Act it")
                            .font(.system(size: topLine, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.secondaryText)
                            .tracking(0.6)

                        Text("out")
                            .font(.system(size: hero, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.primaryText)
                            .tracking(0.2)
                            .minimumScaleFactor(0.48)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, u * 0.1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Act Natural (white panel + purple rail)

struct ProgrammaticActNaturalCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let barW = max(3, u * 0.04)
            let whisper = max(8, u * 0.074)
            let hero = max(14, u * 0.15)

            ZStack {
                ink.panel

                HStack(alignment: .center, spacing: u * 0.07) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.62, green: 0.42, blue: 0.95),
                                    Color(red: 0.38, green: 0.16, blue: 0.68)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: barW, height: u * 0.56)

                    VStack(alignment: .leading, spacing: u * 0.032) {
                        Text("ACT")
                            .font(.system(size: whisper, weight: .semibold, design: .rounded))
                            .foregroundStyle(ink.caption(Color(red: 0.38, green: 0.46, blue: 0.40)))
                            .tracking(3.2)

                        Text("natural")
                            .font(.system(size: hero, weight: .heavy, design: .rounded))
                            .foregroundStyle(ink.hero(Color(red: 0.12, green: 0.26, blue: 0.20)))
                            .tracking(0.35)
                            .minimumScaleFactor(0.42)
                            .lineLimit(1)

                        RoundedRectangle(cornerRadius: 1, style: .continuous)
                            .fill(Color(red: 0.48, green: 0.28, blue: 0.78).opacity(playGridAdaptiveSocialDeckCovers ? 0.55 : 0.42))
                            .frame(width: u * 0.42, height: max(2, u * 0.018))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, u * 0.095)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Category Clash (white panel — editorial lockup + red accent rule)

struct ProgrammaticCategoryClashCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let upper = max(9, u * 0.09)
            let hero = max(15, u * 0.168)
            let ruleW = u * 0.36
            let ruleH = max(2.5, u * 0.022)

            ZStack {
                ink.panel

                VStack(alignment: .center, spacing: u * 0.04) {
                    Text("CATEGORY")
                        .font(.system(size: upper, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.42, green: 0.42, blue: 0.46)))
                        .tracking(2.4)

                    RoundedRectangle(cornerRadius: ruleH * 0.45, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.20, blue: 0.26),
                                    Color(red: 0.72, green: 0.10, blue: 0.18)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: ruleW, height: ruleH)

                    Text("Clash")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(ink.hero(Color(red: 0.08, green: 0.08, blue: 0.10)))
                        .tracking(0.15)
                        .minimumScaleFactor(0.42)
                        .lineLimit(1)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, u * 0.1)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Story Chain (white panel + warm rail — narrative)

struct ProgrammaticStoryChainCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let barW = max(3, u * 0.04)
            let topLine = max(9, u * 0.092)
            let hero = max(13, u * 0.158)

            ZStack {
                ink.panel

                HStack(alignment: .center, spacing: u * 0.07) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.62, blue: 0.38),
                                    Color(red: 0.90, green: 0.38, blue: 0.22)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: barW, height: u * 0.56)

                    VStack(alignment: .leading, spacing: u * 0.03) {
                        Text("Story")
                            .font(.system(size: topLine, weight: .semibold, design: .rounded))
                            .foregroundStyle(ink.caption(Color(red: 0.42, green: 0.41, blue: 0.44)))
                            .tracking(0.5)

                        Text("chain")
                            .font(.system(size: hero, weight: .heavy, design: .rounded))
                            .foregroundStyle(ink.hero(Color(red: 0.10, green: 0.10, blue: 0.12)))
                            .tracking(0.25)
                            .minimumScaleFactor(0.45)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, u * 0.095)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Memory Master (white panel + centered lockup)

struct ProgrammaticMemoryMasterCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let cap = max(8, u * 0.082)
            let hero = max(12, u * 0.142)
            let ruleW = u * 0.38
            let ruleH = max(2, u * 0.018)

            ZStack {
                ink.panel

                VStack(spacing: u * 0.036) {
                    Text("MEMORY")
                        .font(.system(size: cap, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.40, green: 0.44, blue: 0.52)))
                        .tracking(2.0)

                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(Color(red: 0.22, green: 0.48, blue: 0.82).opacity(0.4))
                        .frame(width: ruleW, height: ruleH)

                    Text("master")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(ink.hero(Color(red: 0.08, green: 0.11, blue: 0.20)))
                        .tracking(0.2)
                        .minimumScaleFactor(0.45)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Bluff Call (white panel — split wordmark + copper rule, no symbols)

struct ProgrammaticBluffCallCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let side = max(12, u * 0.138)
            let barW = max(2, u * 0.022)
            let barH = u * 0.34

            ZStack {
                ink.panel

                HStack(alignment: .center, spacing: u * 0.055) {
                    Text("Bluff")
                        .font(.system(size: side * 0.92, weight: .bold, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.24, green: 0.26, blue: 0.30)))
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)

                    RoundedRectangle(cornerRadius: barW * 0.45, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.82, green: 0.48, blue: 0.22),
                                    Color(red: 0.58, green: 0.30, blue: 0.14)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: barW, height: barH)

                    Text("Call")
                        .font(.system(size: side, weight: .heavy, design: .rounded))
                        .foregroundStyle(ink.hero(Color(red: 0.06, green: 0.08, blue: 0.11)))
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, u * 0.08)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Spin the Bottle (white panel — stacked wordmark + glass-green rule, no symbols)

struct ProgrammaticSpinTheBottleCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let top = max(8, u * 0.072)
            let mid = max(10, u * 0.092)
            let hero = max(14, u * 0.168)
            let ruleW = u * 0.42
            let ruleH = max(2, u * 0.016)

            ZStack {
                ink.panel

                VStack(spacing: u * 0.028) {
                    Text("SPIN")
                        .font(.system(size: top, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.40, green: 0.44, blue: 0.52)))
                        .tracking(3.0)

                    Text("the")
                        .font(.system(size: mid, weight: .medium, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.45, green: 0.48, blue: 0.52)))

                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.42, green: 0.62, blue: 0.40),
                                    Color(red: 0.26, green: 0.44, blue: 0.34)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: ruleW, height: ruleH)

                    Text("BOTTLE")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(ink.hero(Color(red: 0.08, green: 0.11, blue: 0.20)))
                        .tracking(1.0)
                        .minimumScaleFactor(0.48)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Two Truths and a Lie (white panel — stacked lockup, no symbols)

struct ProgrammaticTwoTruthsAndALieCoverArtView: View {
    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let line1 = max(8, u * 0.068)
            let amp = max(11, u * 0.10)
            let hero = max(14, u * 0.15)
            let ruleW = u * 0.4
            let ruleH = max(2, u * 0.014)

            ZStack {
                Color.white

                VStack(spacing: u * 0.026) {
                    Text("TWO TRUTHS")
                        .font(.system(size: line1, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.40, green: 0.44, blue: 0.52))
                        .tracking(1.2)
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)

                    Text("&")
                        .font(.system(size: amp, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.45, green: 0.48, blue: 0.52))

                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(Color(red: 0.22, green: 0.48, blue: 0.82).opacity(0.45))
                        .frame(width: ruleW, height: ruleH)

                    Text("A LIE")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.08, green: 0.11, blue: 0.20))
                        .tracking(0.8)
                        .minimumScaleFactor(0.48)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Hot Potato (white panel — warm accent rule, no symbols)

struct ProgrammaticHotPotatoCoverArtView: View {
    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let top = max(10, u * 0.11)
            let bot = max(12, u * 0.13)
            let ruleW = u * 0.44
            let ruleH = max(2.5, u * 0.018)

            ZStack {
                Color.white

                VStack(spacing: u * 0.04) {
                    Text("HOT")
                        .font(.system(size: top, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12))
                        .tracking(1.0)

                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.98, green: 0.55, blue: 0.22),
                                    Color(red: 0.88, green: 0.32, blue: 0.18)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: ruleW, height: ruleH)

                    Text("POTATO")
                        .font(.system(size: bot, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12))
                        .tracking(0.6)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Color Clash (white panel — tri-color rule + wordmark, no symbols)

struct ProgrammaticColorClashCoverArtView: View {
    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let cap = max(8, u * 0.07)
            let hero = max(14, u * 0.16)
            let barW = max(3, u * 0.028)
            let barH = u * 0.22
            let gap = u * 0.036

            ZStack {
                Color.white

                VStack(spacing: u * 0.034) {
                    Text("COLOR")
                        .font(.system(size: cap, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.40, green: 0.44, blue: 0.52))
                        .tracking(2.0)

                    HStack(spacing: gap) {
                        RoundedRectangle(cornerRadius: barW * 0.45, style: .continuous)
                            .fill(Color(red: 0.86, green: 0.22, blue: 0.24))
                            .frame(width: barW, height: barH)
                        RoundedRectangle(cornerRadius: barW * 0.45, style: .continuous)
                            .fill(Color(red: 0.22, green: 0.45, blue: 0.88))
                            .frame(width: barW, height: barH)
                        RoundedRectangle(cornerRadius: barW * 0.45, style: .continuous)
                            .fill(Color(red: 0.92, green: 0.78, blue: 0.18))
                            .frame(width: barW, height: barH)
                    }

                    Text("CLASH")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.08, green: 0.11, blue: 0.20))
                        .tracking(0.6)
                        .minimumScaleFactor(0.48)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Flip 21 (white panel — table-felt rule + numeric hero, no symbols)

struct ProgrammaticFlip21CoverArtView: View {
    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let top = max(10, u * 0.11)
            let hero = max(22, u * 0.28)
            let ruleW = u * 0.42
            let ruleH = max(2, u * 0.016)

            ZStack {
                Color.white

                VStack(spacing: u * 0.032) {
                    Text("FLIP")
                        .font(.system(size: top, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.40, green: 0.44, blue: 0.52))
                        .tracking(1.5)

                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.12, green: 0.42, blue: 0.30),
                                    Color(red: 0.06, green: 0.26, blue: 0.18)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: ruleW, height: ruleH)

                    Text("21")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.08, green: 0.11, blue: 0.20))
                        .minimumScaleFactor(0.45)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Quickfire Couples (white panel — pink accent rule, no symbols)

struct ProgrammaticQuickfireCouplesCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var adaptive
    private var ink: ProgrammaticSocialDeckCoverInk { ProgrammaticSocialDeckCoverInk(adaptive: adaptive) }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let top = max(7, u * 0.056)
            let hero = max(11, u * 0.095)
            let ruleW = u * 0.44
            let ruleH = max(2, u * 0.016)

            ZStack {
                ink.panel

                VStack(spacing: u * 0.03) {
                    Text("QUICKFIRE")
                        .font(.system(size: top, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.40, green: 0.44, blue: 0.52)))
                        .tracking(1.2)
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)

                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.95, green: 0.45, blue: 0.72),
                                    Color(red: 0.78, green: 0.28, blue: 0.55)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: ruleW, height: ruleH)

                    Text("COUPLES")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(ink.hero(Color(red: 0.08, green: 0.11, blue: 0.20)))
                        .tracking(0.5)
                        .minimumScaleFactor(0.48)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Closer Than Ever (white panel — coral rule, no symbols)

struct ProgrammaticCloserThanEverCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var adaptive
    private var ink: ProgrammaticSocialDeckCoverInk { ProgrammaticSocialDeckCoverInk(adaptive: adaptive) }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let top = max(8, u * 0.068)
            let mid = max(9, u * 0.078)
            let hero = max(13, u * 0.12)
            let ruleW = u * 0.4
            let ruleH = max(2, u * 0.014)

            ZStack {
                ink.panel

                VStack(spacing: u * 0.026) {
                    Text("CLOSER")
                        .font(.system(size: top, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.40, green: 0.44, blue: 0.52)))
                        .tracking(1.0)

                    Text("THAN")
                        .font(.system(size: mid, weight: .medium, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.45, green: 0.48, blue: 0.52)))

                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.98, green: 0.48, blue: 0.45),
                                    Color(red: 0.86, green: 0.32, blue: 0.38)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: ruleW, height: ruleH)

                    Text("EVER")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(ink.hero(Color(red: 0.08, green: 0.11, blue: 0.20)))
                        .tracking(0.6)
                        .minimumScaleFactor(0.48)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Us After Dark (white panel — indigo rule, no symbols)

struct ProgrammaticUsAfterDarkCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var adaptive
    private var ink: ProgrammaticSocialDeckCoverInk { ProgrammaticSocialDeckCoverInk(adaptive: adaptive) }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let small = max(8, u * 0.064)
            let hero = max(14, u * 0.13)
            let ruleW = u * 0.38
            let ruleH = max(2, u * 0.014)

            ZStack {
                ink.panel

                VStack(spacing: u * 0.028) {
                    Text("US")
                        .font(.system(size: small, weight: .semibold, design: .rounded))
                        .foregroundStyle(ink.caption(Color(red: 0.40, green: 0.44, blue: 0.52)))
                        .tracking(2.0)

                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.35, green: 0.42, blue: 0.82),
                                    Color(red: 0.18, green: 0.22, blue: 0.48)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: ruleW, height: ruleH)

                    Text("AFTER")
                        .font(.system(size: hero * 0.72, weight: .heavy, design: .rounded))
                        .foregroundStyle(ink.hero(Color(red: 0.08, green: 0.11, blue: 0.20)))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text("DARK")
                        .font(.system(size: hero, weight: .heavy, design: .rounded))
                        .foregroundStyle(ink.hero(Color(red: 0.06, green: 0.08, blue: 0.14)))
                        .tracking(1.2)
                        .minimumScaleFactor(0.48)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Router (catalog image vs programmatic)

struct DeckCoverArtView: View {
    let deck: Deck

    var body: some View {
        Group {
            if deck.type.usesProgrammaticClassicCoverArt {
                ProgrammaticClassicCoverArtView(deckType: deck.type)
            } else if deck.type == .spillTheEx {
                ProgrammaticSpillTheExCoverArtView()
            } else if deck.type == .takeItPersonally {
                ProgrammaticTakeItPersonallyCoverArtView()
            } else if deck.type == .rhymeTime {
                ProgrammaticRhymeTimeCoverArtView()
            } else if deck.type == .tapDuel {
                ProgrammaticTapDuelCoverArtView()
                    .environment(\.playGridAdaptiveSocialDeckCovers, false)
            } else if deck.type == .whatsMySecret {
                ProgrammaticWhatsMySecretCoverArtView()
            } else if deck.type == .riddleMeThis {
                ProgrammaticRiddleMeThisCoverArtView()
            } else if deck.type == .actItOut {
                ProgrammaticActItOutCoverArtView()
            } else if deck.type == .actNatural {
                ProgrammaticActNaturalCoverArtView()
            } else if deck.type == .categoryClash {
                ProgrammaticCategoryClashCoverArtView()
            } else if deck.type == .storyChain {
                ProgrammaticStoryChainCoverArtView()
            } else if deck.type == .memoryMaster {
                ProgrammaticMemoryMasterCoverArtView()
            } else if deck.type == .bluffCall {
                ProgrammaticBluffCallCoverArtView()
            } else if deck.type == .spinTheBottle {
                ProgrammaticSpinTheBottleCoverArtView()
            } else if deck.type == .twoTruthsAndALie {
                ProgrammaticTwoTruthsAndALieCoverArtView()
            } else if deck.type == .hotPotato {
                ProgrammaticHotPotatoCoverArtView()
            } else if deck.type == .colorClash {
                ProgrammaticColorClashCoverArtView()
            } else if deck.type == .flip21 {
                ProgrammaticFlip21CoverArtView()
            } else if deck.type == .quickfireCouples {
                ProgrammaticQuickfireCouplesCoverArtView()
            } else if deck.type == .closerThanEver {
                ProgrammaticCloserThanEverCoverArtView()
            } else if deck.type == .usAfterDark {
                ProgrammaticUsAfterDarkCoverArtView()
            } else if deck.type == .whatWouldYouDo {
                WhatWouldYouDoCoverArtView()
            } else {
                Image(deck.imageName)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
            }
        }
    }
}

// MARK: - Online placeholder (`gameType` string → programmatic cover when it matches `DeckType`)

struct OnlinePlaceholderCoverArtView: View {
    let gameType: String?
    let catalogImageName: String

    var body: some View {
        Group {
            if let gt = gameType, let deckType = DeckType(rawValue: gt) {
                DeckCoverArtView(deck: .coverOnly(type: deckType, catalogImageName: catalogImageName))
            } else if !catalogImageName.isEmpty {
                Image(catalogImageName)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
            } else {
                Color.tertiaryBackground
            }
        }
    }
}

// MARK: - Previews

#Preview("NHIE") {
    ProgrammaticClassicCoverArtView(deckType: .neverHaveIEver)
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("TOD") {
    ProgrammaticClassicCoverArtView(deckType: .truthOrDare)
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("WYR") {
    ProgrammaticClassicCoverArtView(deckType: .wouldYouRather)
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("MLT") {
    ProgrammaticClassicCoverArtView(deckType: .mostLikelyTo)
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Spill the Ex") {
    ProgrammaticSpillTheExCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Take It Personally") {
    ProgrammaticTakeItPersonallyCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Rhyme Time") {
    ProgrammaticRhymeTimeCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Tap Duel") {
    ProgrammaticTapDuelCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("What's My Secret") {
    ProgrammaticWhatsMySecretCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Riddle Me This") {
    ProgrammaticRiddleMeThisCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Category Clash") {
    ProgrammaticCategoryClashCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Act It Out") {
    ProgrammaticActItOutCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Act Natural") {
    ProgrammaticActNaturalCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Story Chain") {
    ProgrammaticStoryChainCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Memory Master") {
    ProgrammaticMemoryMasterCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Bluff Call") {
    ProgrammaticBluffCallCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Spin the Bottle") {
    ProgrammaticSpinTheBottleCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Two Truths") {
    ProgrammaticTwoTruthsAndALieCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Hot Potato") {
    ProgrammaticHotPotatoCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Color Clash") {
    ProgrammaticColorClashCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Flip 21") {
    ProgrammaticFlip21CoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Quickfire Couples") {
    ProgrammaticQuickfireCouplesCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Closer Than Ever") {
    ProgrammaticCloserThanEverCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}

#Preview("Us After Dark") {
    ProgrammaticUsAfterDarkCoverArtView()
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}
