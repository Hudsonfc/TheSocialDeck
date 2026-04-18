//
//  ClassicCategorySelectionUI.swift
//  The Social Deck
//
//  Shared 2-column category grid, adaptive cards, and display copy for classic
//  category selection screens. Card keys still match `Card.category` strings.
//

import SwiftUI

/// Matches `TheSocialDeckPlusPopUpView` brand accent (`soDeckRed`) — used for all locked category styling app-wide.
private let categorySelectionPlusPremiumAccent = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

// MARK: - Accent (selected border)

extension DeckType {
    /// Border highlight for selected category cards on selection screens (unified brand red for every game).
    var categorySelectionAccent: Color {
        categorySelectionPlusPremiumAccent
    }
}

// MARK: - Display titles & subtitles (UI only; keys unchanged)

enum ClassicCategoryDisplayCopy {
    static func title(for category: String, deckType: DeckType) -> String {
        lines(for: category, deckType: deckType).title
    }

    static func subtitle(for category: String, deckType: DeckType) -> String {
        lines(for: category, deckType: deckType).subtitle
    }

    private static func lines(for category: String, deckType: DeckType) -> (title: String, subtitle: String) {
        switch deckType {
        case .neverHaveIEver:
            return nhie(category)
        case .truthOrDare:
            return tor(category)
        case .wouldYouRather:
            return wyr(category)
        case .mostLikelyTo:
            return mlt(category)
        case .takeItPersonally:
            return tip(category)
        case .spillTheEx:
            return spill(category)
        case .categoryClash:
            return clash(category)
        case .actItOut:
            return actItOut(category)
        case .bluffCall:
            return bluff(category)
        case .twoTruthsAndALie:
            return ttl(category)
        case .quickfireCouples:
            return quickfire(category)
        case .closerThanEver:
            return closerThanEver(category)
        case .usAfterDark:
            return usAfterDark(category)
        case .whatsMySecret:
            return wms(category)
        default:
            return (category, "Prompts from this pack.")
        }
    }

    // MARK: Never Have I Ever

    private static func nhie(_ c: String) -> (String, String) {
        switch c {
        case "Confessions":
            return ("Confessions", "Guilty pleasures and secrets that make you squirm.")
        case "Couples":
            return ("Couples", "Dating mishaps, ex stories, and romantic history.")
        case "The Usual":
            return ("The Usual", "Everyday embarrassments everyone relates to.")
        case "Spill the Tea":
            return ("Spill the Tea", "Pot-stirring questions that might expose too much.")
        case "Wild Side":
            return ("Wild Side", "Bold choices, risky nights, and unhinged moments.")
        case "After Dark":
            return ("After Dark", "Flirty and spicy—keep the room comfortable.")
        default:
            return (c, "Never Have I Ever prompts from this pack.")
        }
    }

    // MARK: Truth or Dare

    private static func tor(_ c: String) -> (String, String) {
        switch c {
        case "Party":
            return ("Warm-Up Round", "Truths and dares that break the ice fast.")
        case "Wild":
            return ("No Safety Net", "Escalated dares and truths for brave groups.")
        case "Couples":
            return ("Just Us Two", "Flirty prompts tuned for pairs.")
        case "Social":
            return ("Group Dynamics", "Votes, secrets, and “who would…” energy.")
        case "Dirty":
            return ("Lights Low", "Adult-only prompts—keep it consensual.")
        case "Friends":
            return ("Core Four Energy", "Roasts, loyalty, and friendship flexes.")
        case "Family":
            return ("Living-Room Legends", "Fun-for-home truths and tame dares.")
        default:
            return (c, "Truth or Dare prompts from this pack.")
        }
    }

    // MARK: Would You Rather

    private static func wyr(_ c: String) -> (String, String) {
        switch c {
        case "Party":
            return ("Split the Room", "Would-you-rathers built to start debates.")
        case "Couples":
            return ("Love on Hard Mode", "Relationship choices with no easy answer.")
        case "Social":
            return ("Friend Physics", "Group vibes, loyalty, and social trade-offs.")
        case "Dirty":
            return ("Rated R Forks", "Bold hypotheticals for adults only.")
        case "Friends":
            return ("Bestie Brain", "Pick-your-poison between squad staples.")
        case "Family":
            return ("Dinner Table Dilemmas", "Weird-but-safe family comparisons.")
        case "Weird":
            return ("Cursed Curiosity", "Strange, funny, and wonderfully unhinged picks.")
        default:
            return (c, "Would You Rather prompts from this pack.")
        }
    }

    // MARK: Most Likely To

    private static func mlt(_ c: String) -> (String, String) {
        switch c {
        case "Party":
            return ("Who’s Up First?", "Votes for the life of the party.")
        case "Wild":
            return ("Most Likely to Snap", "Chaos agents, risk-takers, and wild cards.")
        case "Couples":
            return ("Soft Launch Energy", "Rom-com predictions for pairs.")
        case "Social":
            return ("Group Forecast", "Who texts first, who’s late, who’s drama.")
        case "Dirty":
            return ("Unfiltered Forecast", "Spicy “most likely” for adults only.")
        case "Friends":
            return ("The Roast Index", "Loving callouts your crew will deny.")
        case "Family":
            return ("Household Headlines", "Wholesome family superlatives.")
        default:
            return (c, "Most Likely To prompts from this pack.")
        }
    }

    // MARK: Take It Personally

    private static func tip(_ c: String) -> (String, String) {
        switch c {
        case "Party":
            return ("Spotlight Statements", "Callouts that hit harder with a crowd.")
        case "Wild":
            return ("No Filter", "Chaotic observations about the group.")
        case "Friends":
            return ("Inside Joke Fuel", "Personalized zingers for real friends.")
        case "Couples":
            return ("Two-Player Shade", "Playful digs made for pairs.")
        default:
            return (c, "Take It Personally prompts from this pack.")
        }
    }

    // MARK: Spill the Ex

    private static func spill(_ c: String) -> (String, String) {
        switch c {
        case "Confessions":
            return ("Receipts Drawer", "Stories you swear were deleted.")
        case "Situationship":
            return ("It’s Complicated", "Almost-relationship gray areas.")
        case "The Breakup":
            return ("The Final Scene", "Endings, lessons, and plot twists.")
        case "Wild Side":
            return ("Plot Twist Era", "Messy, bold, and unforgettable moments.")
        default:
            return (c, "Spill the Ex prompts from this pack.")
        }
    }

    // MARK: Category Clash

    private static func clash(_ c: String) -> (String, String) {
        switch c {
        case "Food & Beverages":
            return ("Snack Bracket", "Eats, drinks, and midnight cravings under pressure.")
        case "Pop Culture":
            return ("Screen Time", "Movies, music, memes, and main-character moments.")
        case "General":
            return ("Lightning Round", "Everyday lists that still trip people up.")
        case "Sports & Activities":
            return ("Game Day Brain", "Teams, hobbies, and “name three…” speed.")
        case "Animals & Nature":
            return ("Planet Speedrun", "Creatures, climates, and outdoor flexes.")
        default:
            return (c, "Category Clash lists from this pack.")
        }
    }

    // MARK: Act It Out

    private static func actItOut(_ c: String) -> (String, String) {
        switch c {
        case "Actions & Verbs":
            return ("Move It", "Jump, reach, hide—pure motion prompts.")
        case "Animals":
            return ("Creature Feature", "From pets to predators—mime the species.")
        case "Emotions & Expressions":
            return ("Face Value", "Feelings without saying a word.")
        case "Daily Activities":
            return ("Real Life Bits", "Morning routines to midnight snacks.")
        case "Sports & Activities":
            return ("Sweat & Swagger", "Games, gyms, and weekend warriors.")
        case "Objects & Tools":
            return ("Prop Department", "Everyday items as your stage stars.")
        case "Food & Cooking":
            return ("Chef’s Mime", "Chop, sizzle, taste—no talking allowed.")
        case "Famous Concepts":
            return ("Icon Energy", "Big ideas the room can guess without names.")
        case "Movie Genres":
            return ("Genre Gym", "Horror face, rom-com swoon—show the vibe.")
        case "Nature & Weather":
            return ("Storm & Sunshine", "Skies, seasons, and wild outdoors.")
        default:
            return (c, "Act It Out prompts from this pack.")
        }
    }

    // MARK: Bluff Call

    private static func bluff(_ c: String) -> (String, String) {
        switch c {
        case "Party":
            return ("Convince the Room", "Party prompts built for bold bluffs.")
        case "Wild":
            return ("High-Stakes Fibs", "Stories wild enough to doubt.")
        case "Couples":
            return ("Two Truths, One Fib?", "Relationship tales worth side-eyeing.")
        case "Social":
            return ("Group Chat IRL", "Friend dynamics and social myths.")
        case "Dirty":
            return ("Adults Only Table", "Spicy prompts—keep it consensual.")
        case "Friends":
            return ("Loyalty Test", "Best-friend lore that might be too real.")
        default:
            return (c, "Bluff Call prompts from this pack.")
        }
    }

    // MARK: Two Truths and a Lie

    private static func ttl(_ c: String) -> (String, String) {
        switch c {
        case "Party":
            return ("Icebreaker Trio", "Safe-to-wild statements for new groups.")
        case "Wild":
            return ("Hard to Believe", "Stories that sound fake—but one isn’t.")
        case "Couples":
            return ("Heart & Hoax", "Love facts mixed with clever lies.")
        case "Social":
            return ("Squad Files", "Friend-group history with a twist.")
        case "Dirty":
            return ("After Hours", "Adult truths—keep the room comfortable.")
        case "Friends":
            return ("Day-One Energy", "Childhood, college, and “we never talk about this.”")
        default:
            return (c, "Two Truths and a Lie prompts from this pack.")
        }
    }

    // MARK: Quickfire Couples

    private static func quickfire(_ c: String) -> (String, String) {
        switch c {
        case "Light & Fun":
            return ("Soft Launch", "Easy this-or-that to warm you up.")
        case "Preferences":
            return ("Taste Test", "Food, habits, and little lifestyle picks.")
        case "Personality":
            return ("Soul Snapshot", "Values, quirks, and how you move through life.")
        case "Date Ideas":
            return ("Planner Mode", "Nights out, cozy in, and dream adventures.")
        case "Relationship":
            return ("Us Talk", "Boundaries, dreams, and the serious-good stuff.")
        default:
            return (c, "Quickfire Couples prompts from this pack.")
        }
    }

    // MARK: Closer Than Ever

    private static func closerThanEver(_ c: String) -> (String, String) {
        switch c {
        case "Love Languages":
            return ("Heart Codes", "How you give, receive, and feel loved day to day.")
        case "Memories":
            return ("Our Timeline", "Moments that define you two—sweet, funny, big.")
        case "Vulnerability":
            return ("Brave Space", "Gentle honesty about fears and soft spots.")
        case "Intimacy":
            return ("Closer Still", "Trust, touch, and emotional closeness prompts.")
        default:
            return (c, "Closer Than Ever prompts from this pack.")
        }
    }

    // MARK: Us After Dark

    private static func usAfterDark(_ c: String) -> (String, String) {
        switch c {
        case "Memories":
            return ("Soft Focus", "Moments that made you feel seen and wanted.")
        case "Connection":
            return ("Only Us", "What makes your bond feel rare and real.")
        case "Desires":
            return ("After Hours", "Curiosity, longing, and what you crave together.")
        case "Intimacy":
            return ("Low Light", "Quiet heat—presence, privacy, and closeness.")
        default:
            return (c, "Us After Dark prompts from this pack.")
        }
    }

    // MARK: What's My Secret

    private static func wms(_ c: String) -> (String, String) {
        switch c {
        case "Party":
            return ("Room Rules", "Social quirks the table can decode.")
        case "Wild":
            return ("Controlled Chaos", "Odd behaviors with a hidden pattern.")
        case "Social":
            return ("Friend Physics", "Group habits disguised as a secret.")
        case "Actions":
            return ("Micro-Moves", "Tiny repeated actions as clues.")
        case "Behavior":
            return ("Tell Signs", "Mannerisms that spill the secret.")
        default:
            return (c, "What's My Secret prompts from this pack.")
        }
    }
}

// MARK: - Card icons (SF Symbols; keys match `Card.category`)

enum ClassicCategoryCardIcon {
    /// Icon for the category pack row. Uses `deckType` when the same key appears in multiple games.
    static func symbol(category: String, deckType: DeckType) -> String {
        switch (deckType, category) {
        case (.neverHaveIEver, "Confessions"):
            return "bubble.left.and.bubble.right.fill"
        case (.spillTheEx, "Confessions"):
            return "tray.full.fill"
        case (.neverHaveIEver, "Wild Side"):
            return "bolt.fill"
        case (.spillTheEx, "Wild Side"):
            return "film.stack.fill"
        default:
            break
        }
        return fallbackSymbol(for: category)
    }

    private static func fallbackSymbol(for c: String) -> String {
        switch c {
        case "Confessions": return "text.quote"
        case "Couples": return "heart.circle.fill"
        case "The Usual": return "sun.max.fill"
        case "Spill the Tea": return "cup.and.saucer.fill"
        case "Wild Side": return "bolt.fill"
        case "After Dark": return "moon.stars.fill"
        case "Party": return "party.popper.fill"
        case "Wild": return "flame.fill"
        case "Social": return "person.3.fill"
        case "Dirty": return "leaf.fill"
        case "Friends": return "hand.thumbsup.fill"
        case "Family": return "figure.2.and.child.holdinghands"
        case "Weird": return "questionmark.circle.fill"
        case "Situationship": return "link.circle.fill"
        case "The Breakup": return "heart.slash.fill"
        case "Light & Fun": return "sparkles"
        case "Preferences": return "slider.horizontal.3"
        case "Personality": return "person.fill.viewfinder"
        case "Date Ideas": return "calendar.badge.heart"
        case "Relationship": return "heart.rectangle.fill"
        case "Actions": return "hand.point.up.left.fill"
        case "Behavior": return "eye.fill"
        case "Food & Beverages": return "fork.knife"
        case "Pop Culture": return "tv.fill"
        case "General": return "list.bullet.rectangle.fill"
        case "Sports & Activities": return "figure.run"
        case "Animals & Nature": return "leaf.circle.fill"
        case "Actions & Verbs": return "figure.walk"
        case "Animals": return "pawprint.fill"
        case "Emotions & Expressions": return "theatermasks.fill"
        case "Daily Activities": return "sun.horizon.fill"
        case "Objects & Tools": return "wrench.and.screwdriver.fill"
        case "Food & Cooking": return "frying.pan.fill"
        case "Famous Concepts": return "star.circle.fill"
        case "Movie Genres": return "film.fill"
        case "Nature & Weather": return "cloud.sun.fill"
        case "Love Languages": return "heart.text.square.fill"
        case "Memories": return "photo.on.rectangle.angled"
        case "Vulnerability": return "heart.circle.fill"
        case "Intimacy": return "moon.stars.fill"
        case "Desires": return "flame.fill"
        case "Connection": return "link.circle.fill"
        default:
            return "square.grid.2x2.fill"
        }
    }
}

// MARK: - Grid card

struct ClassicCategoryGridCard: View {
    let categoryKey: String
    let deckType: DeckType
    let title: String
    let subtitle: String
    let isSelected: Bool
    let isLocked: Bool
    let accentColor: Color
    let action: () -> Void

    private let corner: CGFloat = 16
    private var cardFill: Color {
        Color(light: Color.secondaryBackground, dark: Color(red: 0.22, green: 0.22, blue: 0.26))
    }

    private var neutralBorder: Color {
        Color.borderColor
    }

    private var lockedCardBorder: Color {
        categorySelectionPlusPremiumAccent.opacity(0.82)
    }

    /// Fixed height so every category box matches across games and rows.
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
                                    categorySelectionPlusPremiumAccent.opacity(0.12),
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
                    Image(systemName: ClassicCategoryCardIcon.symbol(category: categoryKey, deckType: deckType))
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
                                    categorySelectionPlusPremiumAccent
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
        if isLocked { return categorySelectionPlusPremiumAccent.opacity(0.5) }
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

// MARK: - Shared layout

private let classicCategoryGridColumns = [
    GridItem(.flexible(), spacing: 14, alignment: .top),
    GridItem(.flexible(), spacing: 14, alignment: .top)
]

struct ClassicCategorySelectionRoot<Destination: View>: View {
    let deck: Deck
    @Binding var selectedCategories: Set<String>
    let freeCategories: Set<String>
    @Binding var navigateToSetup: Bool
    let isLocked: (String) -> Bool
    @ViewBuilder let destination: () -> Destination

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subManager: SubscriptionManager
    @State private var showPlusPaywall = false
    @State private var categoryGridAppeared = false

    private var accent: Color {
        deck.type.categorySelectionAccent
    }

    private var fullSelectable: Set<String> {
        subManager.isPlus ? Set(deck.availableCategories) : freeCategories
    }

    private func onTapCategory(_ category: String) {
        if isLocked(category) {
            showPlusPaywall = true
        } else if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    Text(deck.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 0) {
                        Text("Select categories")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .padding(.bottom, 6)

                        Text("Tap packs to mix prompts. Locked packs need Plus.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 20)

                        LazyVGrid(columns: classicCategoryGridColumns, spacing: 12) {
                            ForEach(Array(deck.availableCategories.enumerated()), id: \.element) { index, category in
                                ClassicCategoryGridCard(
                                    categoryKey: category,
                                    deckType: deck.type,
                                    title: ClassicCategoryDisplayCopy.title(for: category, deckType: deck.type),
                                    subtitle: ClassicCategoryDisplayCopy.subtitle(for: category, deckType: deck.type),
                                    isSelected: selectedCategories.contains(category),
                                    isLocked: isLocked(category),
                                    accentColor: accent,
                                    action: { onTapCategory(category) }
                                )
                                .opacity(categoryGridAppeared ? 1 : 0)
                                .offset(y: categoryGridAppeared ? 0 : 16)
                                .animation(
                                    .spring(response: 0.48, dampingFraction: 0.84)
                                        .delay(Double(index) * 0.042),
                                    value: categoryGridAppeared
                                )
                            }
                        }
                        .padding(.bottom, 16)

                        Button(action: {
                            if selectedCategories == fullSelectable {
                                selectedCategories.removeAll()
                            } else {
                                selectedCategories = fullSelectable
                            }
                        }) {
                            Text(selectedCategories == fullSelectable ? "Deselect All" : "Select All")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryAccent)
                        }
                        .padding(.bottom, 24)
                    }
                    .responsiveHorizontalPadding()
                }

                PrimaryButton(title: "Continue") {
                    HapticManager.shared.lightImpact()
                    navigateToSetup = true
                }
                .responsiveHorizontalPadding()
                .disabled(selectedCategories.isEmpty)
                .opacity(selectedCategories.isEmpty ? 0.5 : 1.0)
                .padding(.top, 8)
                .padding(.bottom, 28)
                .background(Color.appBackground)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            categoryGridAppeared = false
            DispatchQueue.main.async {
                withAnimation {
                    categoryGridAppeared = true
                }
            }
        }
        .sheet(isPresented: subManager.paywallSheetIsPresented($showPlusPaywall)) {
            TheSocialDeckPlusPopUpView(onDismiss: { showPlusPaywall = false })
                .environmentObject(subManager)
        }
        .onChange(of: subManager.isPlus) { _, isPlus in
            if isPlus { showPlusPaywall = false }
        }
        .background(
            NavigationLink(destination: destination(), isActive: $navigateToSetup) {
                EmptyView()
            }
            .hidden()
        )
    }
}
