//
//  Play2View.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct Play2View: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var selectedCategory = "Classic Games"
    @State private var navigateToCategorySelection: Deck? = nil
    @State private var navigateToPlayView: Deck? = nil
    @State private var navigateToStoryChainSetup: Deck? = nil
    @State private var navigateToMemoryMasterSetup: Deck? = nil
    @State private var navigateToRhymeTimeSetup: Deck? = nil
    @State private var navigateToTapDuelSetup: Deck? = nil
    @State private var navigateToRiddleMeThisSetup: Deck? = nil
    @State private var navigateToQuickfireCouplesSetup: Deck? = nil
    @State private var navigateToCloserThanEverSetup: Deck? = nil
    @State private var navigateToUsAfterDarkSetup: Deck? = nil
    @AppStorage("hasSeenWelcomeView") private var hasSeenWelcomeView: Bool = false
    @State private var showWelcomeView: Bool = false
    @State private var selectedDeckForDescription: Deck? = nil

    // MARK: - TheSocialDeck+ gating
    @EnvironmentObject private var subManager: SubscriptionManager
    @State private var showPlusPaywall = false

    private let plusLockedTypes: Set<DeckType> = [
        .mostLikelyTo, .takeItPersonally, .whatsMySecret, .bluffCall, .memoryMaster, .closerThanEver, .tapDuel, .spillTheEx
    ]

    private func isLocked(_ deck: Deck) -> Bool {
        plusLockedTypes.contains(deck.type) && !subManager.isPlus
    }
    
    // All category names (Favorites shown dynamically when items exist)
    var categories: [String] {
        var cats = ["Classic Games", "Social Deck Games", "Date/Couples", "Online Only"]
        if !favoriteDecks.isEmpty || !favoriteOnlineGames.isEmpty {
            cats.insert("Favorites", at: 0)
        }
        return cats
    }
    
    // Favorite online-only games (e.g. Color Clash) so they appear in Favorites tab
    private var favoriteOnlineGames: [OnlineGameEntry] {
        allOnlineGames.filter { game in
            guard let deckType = DeckType(rawValue: game.gameType) else { return false }
            return favoritesManager.isFavorite(deckType)
        }
    }
    
    // Selected online game for detail navigation
    @State private var selectedOnlineGame: OnlineGameEntry? = nil
    
    // Get all decks
    private var allDecks: [Deck] {
        classicGamesDecks + socialDeckGamesDecks + dateCouplesGamesDecks
    }
    
    // Get favorite decks
    private var favoriteDecks: [Deck] {
        allDecks.filter { favoritesManager.isFavorite($0.type) }
    }
    
    // Classic Games decks with 2.0 artwork
    let classicGamesDecks: [Deck] = [
        Deck(
            title: "Never Have I Ever",
            description: "Reveal your wildest experiences and learn about your friends. Take turns asking 'Never have I ever...' questions. If you've done it, put a finger down. Last person with fingers up wins! Perfect for parties and getting to know each other better.",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "NHIE 2.0",
            type: .neverHaveIEver,
            cards: allNHIECards,
            availableCategories: ["Party", "Wild", "Couples", "Social", "Dirty", "Friends", "Family"]
        ),
        Deck(
            title: "Truth or Dare",
            description: "Choose truth or dare and see where the night takes you. Answer revealing questions truthfully or complete fun challenges. Each player takes turns choosing their fate. The classic party game that never gets old!",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "TOD 2.0",
            type: .truthOrDare,
            cards: allTORCards,
            availableCategories: ["Party", "Wild", "Couples", "Social", "Dirty", "Friends", "Family"]
        ),
        Deck(
            title: "Would You Rather",
            description: "Make tough choices and discover what your friends prefer. Face impossible dilemmas and see who would choose what. Debate your choices and learn surprising things about your friends' preferences and values.",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "WYR 2.0",
            type: .wouldYouRather,
            cards: allWYRCards,
            availableCategories: ["Party", "Couples", "Social", "Dirty", "Friends", "Family", "Weird"]
        ),
        Deck(
            title: "Most Likely To",
            description: "Find out who's most likely to do crazy things. Vote on which friend is most likely to do outrageous scenarios. Funny, revealing, and perfect for groups. Discover who your friends think would do the wildest things!",
            numberOfCards: 626,
            estimatedTime: "30-45 min",
            imageName: "MLT 2.0",
            type: .mostLikelyTo,
            cards: allMLTCards,
            availableCategories: ["Party", "Wild", "Couples", "Social", "Dirty", "Friends", "Family"]
        )
    ]
    
    // Social Deck Games decks with 2.0 artwork
    let socialDeckGamesDecks: [Deck] = [
        Deck(
            title: "Spill the Ex",
            description: "Spill the Ex is a bold, laugh-out-loud party game where the tea is hot and nobody's past is completely safe. Each round, players respond to juicy relationship prompts — from harmless confessions to slightly messy moments — and the group has to guess who the story belongs to.",
            numberOfCards: 200,
            estimatedTime: "20-30 min",
            imageName: "Spill the Ex",
            type: .spillTheEx,
            cards: allSpillTheExCards,
            availableCategories: ["Confessions", "Situationship", "The Breakup", "Wild Side"]
        ),
        Deck(
            title: "Take It Personally",
            description: "Bold statements about someone in the group. Quick prompts that create reactions, tension, and laughter. Each card calls out someone with funny, dramatic, or slightly chaotic observations. Big energy, bigger reactions!",
            numberOfCards: 260,
            estimatedTime: "20-30 min",
            imageName: "take it personally",
            type: .takeItPersonally,
            cards: allTIPCards,
            availableCategories: ["Party", "Wild", "Friends", "Couples"]
        ),
        Deck(
            title: "Rhyme Time",
            description: "Say a word that rhymes with the base word before time runs out! Challenge your vocabulary and quick thinking. Repeat a rhyme or hesitate and you're out. Choose your difficulty level and see how long you can last in this word battle!",
            numberOfCards: 482,
            estimatedTime: "10-15 min",
            imageName: "RT 2.0",
            type: .rhymeTime,
            cards: allRhymeTimeCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "Tap Duel",
            description: "Fast head-to-head reaction game. Wait for GO, then tap first to win! Test your reflexes in intense one-on-one battles. Tap too early and you lose. Perfect for quick competitive rounds between friends.",
            numberOfCards: 999,
            estimatedTime: "2-5 min",
            imageName: "TD 2.0",
            type: .tapDuel,
            cards: [],
            availableCategories: []
        ),
        Deck(
            title: "What's My Secret?",
            description: "One player gets a secret rule to follow. Can the group figure out what it is? The secret player must act according to hidden rules while others try to guess. Pick categories like Party, Wild, Social, Actions, or Behavior. Think fast and stay sharp!",
            numberOfCards: 562,
            estimatedTime: "5-10 min",
            imageName: "WMS 2.0",
            type: .whatsMySecret,
            cards: allWhatsMySecretCards,
            availableCategories: ["Party", "Wild", "Social", "Actions", "Behavior"]
        ),
        Deck(
            title: "Riddle Me This",
            description: "Solve riddles quickly! The first player to say the correct answer wins the round. Test your problem-solving skills with tricky riddles. Wrong answers lock you out, so think carefully. Brain teasers that challenge your logic and creativity!",
            numberOfCards: 391,
            estimatedTime: "5-10 min",
            imageName: "RMT 2.0",
            type: .riddleMeThis,
            cards: allRiddleMeThisCards,
            availableCategories: []
        ),
        Deck(
            title: "Act It Out",
            description: "Act out prompts silently while others guess! First to guess correctly wins the round. Challenge your acting skills with categories like Actions & Verbs, Animals, Emotions, Daily Activities, Sports, Objects, Food, Famous Concepts, Movie Genres, and Nature. No talking, only acting!",
            numberOfCards: 556,
            estimatedTime: "15-30 min",
            imageName: "AIO 2.0",
            type: .actItOut,
            cards: allActItOutCards,
            availableCategories: ["Actions & Verbs", "Animals", "Emotions & Expressions", "Daily Activities", "Sports & Activities", "Objects & Tools", "Food & Cooking", "Famous Concepts", "Movie Genres", "Nature & Weather"]
        ),
        Deck(
            title: "Act Natural",
            description: "One player doesn't know the secret word — can they blend in and figure it out before getting caught? Everyone else knows the secret word and tries to subtly mention it. The secret player must figure it out while acting natural. Deception meets deduction!",
            numberOfCards: 475,
            estimatedTime: "10-20 min",
            imageName: "AN 2.0",
            type: .actNatural,
            cards: [],
            availableCategories: []
        ),
        Deck(
            title: "Category Clash",
            description: "Name items in a category before time runs out! Hesitate or repeat an answer and you're out. Choose from categories like Food & Beverages, Pop Culture, General, Sports & Activities, or Animals & Nature. The pace gets faster each round, turning it into a hilarious pressure game!",
            numberOfCards: 512,
            estimatedTime: "15-20 min",
            imageName: "CC 2.0",
            type: .categoryClash,
            cards: allCategoryClashCards,
            availableCategories: ["Food & Beverages", "Pop Culture", "General", "Sports & Activities", "Animals & Nature"]
        ),
        Deck(
            title: "Spin the Bottle",
            description: "Tap to spin and let the bottle decide everyone's fate. No strategy, no mercy, just pure chaos. Add players, spin the bottle, and see who it lands on. Classic party game with endless possibilities. Where the bottle points, fate decides!",
            numberOfCards: 40,
            estimatedTime: "20-30 min",
            imageName: "STB 2.0",
            type: .spinTheBottle,
            cards: [],
            availableCategories: []
        ),
        Deck(
            title: "Story Chain",
            description: "Add one sentence to continue the story. Pass the phone and watch the chaos unfold. Each player adds one sentence, creating an unpredictable collaborative story. Choose how many rounds to play. See where your group's imagination takes the tale!",
            numberOfCards: 444,
            estimatedTime: "15-25 min",
            imageName: "SC 2.0",
            type: .storyChain,
            cards: allStoryChainCards,
            availableCategories: []
        ),
        Deck(
            title: "Memory Master",
            description: "A timed card-matching game. Flip cards to find pairs and clear the board as fast as possible! Memorize card positions, then match pairs under pressure. Choose your difficulty level - Easy, Medium, Hard, or Expert. Challenge your memory and compete for the best time!",
            numberOfCards: 55,
            estimatedTime: "5-10 min",
            imageName: "MM 2.0",
            type: .memoryMaster,
            cards: [],
            availableCategories: []
        ),
        Deck(
            title: "Bluff Call",
            description: "Convince the group your answer is true, or call their bluff! One player sees a prompt and must convince others their answer is true. The group decides whether to believe or call the bluff. Pick categories like Party, Wild, Couples, Teens, Dirty, or Friends. Deception meets deduction!",
            numberOfCards: 584,
            estimatedTime: "15-20 min",
            imageName: "BC 2.0",
            type: .bluffCall,
            cards: allBluffCallCards,
            availableCategories: ["Party", "Wild", "Couples", "Social", "Dirty", "Friends"]
        )
    ]
    
    // Date/Couples Games decks with 2.0 artwork
    let dateCouplesGamesDecks: [Deck] = [
        Deck(
            title: "Quickfire Couples",
            description: "Fast-paced \"this or that\" choices for couples. Answer instantly to reveal preferences and chemistry.",
            numberOfCards: 408,
            estimatedTime: "15-25 min",
            imageName: "Quickfire Couples",
            type: .quickfireCouples,
            cards: allQuickfireCouplesCards,
            availableCategories: []
        ),
        Deck(
            title: "Closer Than Ever",
            description: "Meaningful questions designed to deepen connection and strengthen emotional bonds. Explore love languages, shared memories, values, and future dreams through thoughtful conversation.",
            numberOfCards: 394,
            estimatedTime: "30-45 min",
            imageName: "Closer than ever",
            type: .closerThanEver,
            cards: allCloserThanEverCards,
            availableCategories: []
        ),
        Deck(
            title: "Us After Dark",
            description: "A deeper, intimate couples game focused on honesty, curiosity, and emotional closeness. Questions explore desires, boundaries, memories, and what makes your connection special.",
            numberOfCards: 236,
            estimatedTime: "30-45 min",
            imageName: "us after dark",
            type: .usAfterDark,
            cards: allUsAfterDarkCards,
            availableCategories: []
        )
    ]
    
    // Current decks based on selected category
    var currentDecks: [Deck] {
        switch selectedCategory {
        case "Favorites":
            return favoriteDecks
        case "Classic Games":
            return classicGamesDecks
        case "Social Deck Games":
            return socialDeckGamesDecks
        case "Date/Couples":
            return dateCouplesGamesDecks
        default:
            return classicGamesDecks
        }
    }
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Category Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(categories, id: \.self) { category in
                            CategoryTab(title: category, isSelected: selectedCategory == category)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.8)).combined(with: .move(edge: .leading)),
                                    removal: .opacity.combined(with: .scale(scale: 0.8)).combined(with: .move(edge: .leading))
                                ))
                                .onTapGesture {
                                    if selectedCategory != category {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selectedCategory = category
                                        }
                                        HapticManager.shared.lightImpact()
                                    }
                                }
                        }
                    }
                    .responsiveHorizontalPadding()
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: categories)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Grid View
                ScrollView(.vertical, showsIndicators: false) {
                    if selectedCategory == "Favorites" && (!favoriteDecks.isEmpty || !favoriteOnlineGames.isEmpty) {
                        // Favorites: mix of favorite decks and favorite online games
                        let columns = [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ]
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(Array(favoriteDecks.enumerated()), id: \.element.id) { _, deck in
                                GridGameTile(deck: deck, isLocked: isLocked(deck)) {
                                    HapticManager.shared.lightImpact()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedDeckForDescription = deck
                                    }
                                }
                            }
                            ForEach(favoriteOnlineGames) { game in
                                OnlineGameTile(game: game) {
                                    HapticManager.shared.lightImpact()
                                    selectedOnlineGame = game
                                }
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    } else if selectedCategory == "Online Only" {
                        // Online Only grid — uses OnlineGameEntry data
                        let columns = [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ]
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(allOnlineGames) { game in
                                OnlineGameTile(game: game) {
                                    HapticManager.shared.lightImpact()
                                    selectedOnlineGame = game
                                }
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    } else if !currentDecks.isEmpty {
                        let columns = [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ]
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(Array(currentDecks.enumerated()), id: \.element.id) { index, deck in
                                GridGameTile(
                                    deck: deck,
                                    isLocked: isLocked(deck)
                                ) {
                                    HapticManager.shared.lightImpact()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedDeckForDescription = deck
                                    }
                                }
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Navigation links for category selection and setup views
            NavigationLink(
                destination: categorySelectionView,
                isActive: Binding(
                    get: { navigateToCategorySelection != nil },
                    set: { if !$0 { navigateToCategorySelection = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: playView,
                isActive: Binding(
                    get: { navigateToPlayView != nil },
                    set: { if !$0 { navigateToPlayView = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: storyChainSetupView,
                isActive: Binding(
                    get: { navigateToStoryChainSetup != nil },
                    set: { if !$0 { navigateToStoryChainSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: memoryMasterSetupView,
                isActive: Binding(
                    get: { navigateToMemoryMasterSetup != nil },
                    set: { if !$0 { navigateToMemoryMasterSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: rhymeTimeSetupView,
                isActive: Binding(
                    get: { navigateToRhymeTimeSetup != nil },
                    set: { if !$0 { navigateToRhymeTimeSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: tapDuelSetupView,
                isActive: Binding(
                    get: { navigateToTapDuelSetup != nil },
                    set: { if !$0 { navigateToTapDuelSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: riddleMeThisSetupView,
                isActive: Binding(
                    get: { navigateToRiddleMeThisSetup != nil },
                    set: { if !$0 { navigateToRiddleMeThisSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: quickfireCouplesSetupView,
                isActive: Binding(
                    get: { navigateToQuickfireCouplesSetup != nil },
                    set: { if !$0 { navigateToQuickfireCouplesSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: closerThanEverSetupView,
                isActive: Binding(
                    get: { navigateToCloserThanEverSetup != nil },
                    set: { if !$0 { navigateToCloserThanEverSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: usAfterDarkSetupView,
                isActive: Binding(
                    get: { navigateToUsAfterDarkSetup != nil },
                    set: { if !$0 { navigateToUsAfterDarkSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            // Online Only tab → game detail
            NavigationLink(
                destination: onlineGameDetailView,
                isActive: Binding(
                    get: { selectedOnlineGame != nil },
                    set: { if !$0 { selectedOnlineGame = nil } }
                )
            ) {
                EmptyView()
            }
        }
        .overlay {
            // Welcome View for first-time users
            if showWelcomeView {
                WelcomeView(isPresented: $showWelcomeView)
            }
            
            // Game Description Overlay
            if let deck = selectedDeckForDescription {
                GameDescriptionOverlay(
                    deck: deck,
                    selectedDeck: $selectedDeckForDescription,
                    isLocked: isLocked(deck),
                    isLockedAndNotPlus: isLocked(deck) && !subManager.isPlus,
                    onShowPaywall: { showPlusPaywall = true },
                    navigateToCategorySelection: $navigateToCategorySelection,
                    navigateToPlayView: $navigateToPlayView,
                    navigateToStoryChainSetup: $navigateToStoryChainSetup,
                    navigateToMemoryMasterSetup: $navigateToMemoryMasterSetup,
                    navigateToRhymeTimeSetup: $navigateToRhymeTimeSetup,
                    navigateToTapDuelSetup: $navigateToTapDuelSetup,
                    navigateToRiddleMeThisSetup: $navigateToRiddleMeThisSetup,
                    navigateToQuickfireCouplesSetup: $navigateToQuickfireCouplesSetup,
                    navigateToCloserThanEverSetup: $navigateToCloserThanEverSetup,
                    navigateToUsAfterDarkSetup: $navigateToUsAfterDarkSetup
                )
            }
        }
        .onAppear {
            // Show welcome view on first time
            if !hasSeenWelcomeView {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showWelcomeView = true
                }
            }
        }
        .onChange(of: showWelcomeView) { oldValue, newValue in
            if !newValue && !hasSeenWelcomeView {
                hasSeenWelcomeView = true
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryAccent)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showPlusPaywall, onDismiss: {
            Task { await subManager.refreshEntitlements() }
        }) {
            TheSocialDeckPlusPopUpView(onDismiss: { showPlusPaywall = false })
                .environmentObject(SubscriptionManager.shared)
        }
    }
    
    @ViewBuilder
    private var onlineGameDetailView: some View {
        if let game = selectedOnlineGame {
            OnlineGameDetailView(game: game)
        } else {
            Color.appBackground.ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var playView: some View {
        if let deck = navigateToPlayView {
            if deck.type == .spinTheBottle {
                SpinTheBottleView()
            }
        }
    }
    
    @ViewBuilder
    private var storyChainSetupView: some View {
        if let deck = navigateToStoryChainSetup {
            StoryChainSetupView(deck: deck)
        } else {
            Color.appBackground.ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var memoryMasterSetupView: some View {
        if let deck = navigateToMemoryMasterSetup {
            MemoryMasterSetupView(deck: deck)
        } else {
            Color.appBackground.ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var rhymeTimeSetupView: some View {
        if let deck = navigateToRhymeTimeSetup {
            RhymeTimeSetupView(deck: deck)
        } else {
            Color.appBackground.ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var tapDuelSetupView: some View {
        if let deck = navigateToTapDuelSetup {
            TapDuelSetupView(deck: deck)
        } else {
            Color.appBackground.ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var riddleMeThisSetupView: some View {
        if let deck = navigateToRiddleMeThisSetup {
            RiddleMeThisSetupView(deck: deck)
        } else {
            Color.appBackground.ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var quickfireCouplesSetupView: some View {
        if let deck = navigateToQuickfireCouplesSetup {
            QuickfireCouplesSetupView(deck: deck, selectedCategories: [])
        } else {
            Color.appBackground.ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var closerThanEverSetupView: some View {
        if let deck = navigateToCloserThanEverSetup {
            CloserThanEverSetupView(deck: deck, selectedCategories: [])
        } else {
            Color.appBackground.ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var usAfterDarkSetupView: some View {
        if let deck = navigateToUsAfterDarkSetup {
            UsAfterDarkSetupView(deck: deck, selectedCategories: [])
        } else {
            Color.appBackground.ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var categorySelectionView: some View {
        if let deck = navigateToCategorySelection {
            switch deck.type {
            // Classic Games
            case .neverHaveIEver:
                NHIECategorySelectionView(deck: deck)
            case .truthOrDare:
                TORCategorySelectionView(deck: deck)
            case .wouldYouRather:
                WYRCategorySelectionView(deck: deck)
            case .mostLikelyTo:
                MLTCategorySelectionView(deck: deck)
            case .takeItPersonally:
                TIPCategorySelectionView(deck: deck)
            // Social Deck Games
            case .rhymeTime:
                RhymeTimeSetupView(deck: deck)
            case .tapDuel:
                TapDuelSetupView(deck: deck)
            case .whatsMySecret:
                WhatsMySecretSetupView(deck: deck)
            case .riddleMeThis:
                RiddleMeThisSetupView(deck: deck)
            case .actItOut:
                ActItOutCategorySelectionView(deck: deck)
            // Social Deck Games (formerly Party Games)
            case .actNatural:
                ActNaturalPlayerSetupView(deck: deck)
            case .categoryClash:
                CategoryClashCategorySelectionView(deck: deck)
            case .spinTheBottle:
                SpinTheBottleView() // Doesn't need deck parameter
            case .storyChain:
                StoryChainSetupView(deck: deck)
            case .memoryMaster:
                MemoryMasterSetupView(deck: deck)
            case .bluffCall:
                BluffCallCategorySelectionView(deck: deck)
            case .spillTheEx:
                SpillTheExCategorySelectionView(deck: deck)
            // Date/Couples Games
            case .quickfireCouples:
                QuickfireCouplesSetupView(deck: deck, selectedCategories: [])
            case .closerThanEver:
                CloserThanEverSetupView(deck: deck, selectedCategories: [])
            case .usAfterDark:
                UsAfterDarkSetupView(deck: deck, selectedCategories: [])
            default:
                EmptyView()
            }
        }
    }
}

// Category Tab Component
struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: isSelected ? .bold : .regular, design: .rounded))
                .foregroundColor(isSelected ? .primaryAccent : .secondaryText)
            
            Rectangle()
                .fill(isSelected ? .primaryAccent : Color.clear)
                .frame(height: 3)
        }
    }
}

// Favorite Button Component with Animation
struct FavoriteButton: View {
    let deck: Deck
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @State private var isAnimating: Bool = false
    @State private var scale: CGFloat = 1.0
    
    var isFavorite: Bool {
        favoritesManager.isFavorite(deck.type)
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.3
                isAnimating = true
            }
            
            favoritesManager.toggleFavorite(deck.type)
            HapticManager.shared.lightImpact()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isAnimating = false
            }
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isFavorite ? .primaryAccent : .secondaryText)
                .frame(width: 40, height: 40)
                .background(isFavorite ? Color.primaryAccent.opacity(0.1) : Color.tertiaryBackground)
                .clipShape(Circle())
                .scaleEffect(scale)
        }
    }
}

// Game Card View Component
struct GameCardView: View {
    let deck: Deck
    @Binding var isFlipped: Bool
    let isLocked: Bool
    let onSelect: () -> Void
    let allowInteraction: Bool
    @State private var flipDegrees: Double = 0
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    // Card dimensions based on actual image ratio (420 x 577)
    private let imageAspectRatio: CGFloat = 420.0 / 577.0
    private var cardWidth: CGFloat {
        ResponsiveSize.play2CardWidth
    }
    private var cardHeight: CGFloat {
        ResponsiveSize.play2CardHeight
    }
    
    // Check if showing front or back
    private var showingFront: Bool {
        flipDegrees < 90 || flipDegrees > 270
    }
    
    // Helper to determine if background is light colored (use black text on back)
    private var isLightBackground: Bool {
        deck.type == .quickfireCouples || deck.type == .closerThanEver || 
        deck.type == .usAfterDark || deck.type == .wouldYouRather || 
        deck.type == .takeItPersonally || deck.type == .mostLikelyTo || deck.type == .tapDuel || 
        deck.type == .spinTheBottle || deck.type == .bluffCall ||
        deck.type == .storyChain || deck.type == .actItOut ||
        deck.type == .whatsMySecret || deck.type == .categoryClash
    }
    
    // Consistent text color for titles
    private var titleColor: Color {
        isLightBackground ? Color.black.opacity(0.9) : Color.white
    }
    
    // Consistent text color for descriptions
    private var descriptionColor: Color {
        isLightBackground ? Color.black.opacity(0.75) : Color.white.opacity(0.9)
    }
    
    private var backCardBackgroundColor: Color {
        if deck.type == .quickfireCouples { return Color(red: 0xFF/255.0, green: 0xB5/255.0, blue: 0xEF/255.0) }
        if deck.type == .closerThanEver { return Color(red: 0xFF/255.0, green: 0x84/255.0, blue: 0x84/255.0) }
        if deck.type == .usAfterDark { return Color(red: 0xA1/255.0, green: 0xC2/255.0, blue: 0xFF/255.0) }
        if deck.type == .neverHaveIEver || deck.type == .rhymeTime || deck.type == .memoryMaster { return Color(red: 0xFF/255.0, green: 0x84/255.0, blue: 0x84/255.0) }
        if deck.type == .truthOrDare || deck.type == .riddleMeThis || deck.type == .actNatural { return Color(red: 0xA1/255.0, green: 0xC2/255.0, blue: 0xFF/255.0) }
        if deck.type == .mostLikelyTo || deck.type == .actItOut { return Color(red: 0xB0/255.0, green: 0xE9/255.0, blue: 0x8D/255.0) }
        if deck.type == .whatsMySecret || deck.type == .categoryClash { return Color(red: 0xFF/255.0, green: 0xB5/255.0, blue: 0xEF/255.0) }
        if deck.type == .wouldYouRather || deck.type == .takeItPersonally { return Color(red: 0xFE/255.0, green: 0xFE/255.0, blue: 0xAC/255.0) }
        if deck.type == .storyChain { return Color(red: 0xFE/255.0, green: 0xB1/255.0, blue: 0x87/255.0) }
        if deck.type == .tapDuel || deck.type == .spinTheBottle || deck.type == .bluffCall { return Color.white }
        return Color.cardBackground
    }
    
    private var backCardContentPanel: some View {
        VStack(spacing: 18) {
            Text(deck.title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .tracking(0.35)
                .foregroundColor(titleColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(deck.description)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(descriptionColor)
                .multilineTextAlignment(.center)
                .lineSpacing(7)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                HapticManager.shared.lightImpact()
                onSelect()
            }) {
                HStack(spacing: 6) {
                    if isLocked {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    Text("Play")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.buttonBackground)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
            }
            .padding(.top, 2)
        }
        .padding(26)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(isLightBackground ? Color.white.opacity(0.38) : Color.black.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(isLightBackground ? Color.white.opacity(0.55) : Color.white.opacity(0.26), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 22)
    }
    
    private var cardBackView: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                Spacer()
                backCardContentPanel
                Spacer()
            }
            FavoriteButton(deck: deck)
                .padding(20)
        }
        .frame(width: cardWidth, height: cardHeight)
        .background(backCardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.cardShadowColor, radius: 12, x: 0, y: 6)
        .rotation3DEffect(.degrees(flipDegrees + 180), axis: (x: 0, y: -1, z: 0))
        .opacity(showingFront ? 0 : 1)
        .zIndex(showingFront ? 0 : 1)
    }
    
    var body: some View {
        ZStack {
            cardBackView
            
            // Front of card (image) - uses exact image aspect ratio
            ZStack(alignment: .topTrailing) {
                Image(deck.imageName)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .aspectRatio(imageAspectRatio, contentMode: .fit)
                    .frame(width: cardWidth, height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.cardShadowColor, radius: 12, x: 0, y: 6)
            }
            .overlay(alignment: .bottomLeading) {
                if isLocked {
                    HStack(spacing: 3) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("PLUS")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .clipShape(Capsule())
                    .padding(14)
                }
            }
            .rotation3DEffect(
                .degrees(flipDegrees),
                axis: (x: 0, y: -1, z: 0)
            )
            .opacity(showingFront ? 1 : 0)
            .zIndex(showingFront ? 1 : 0)
        }
        .frame(width: cardWidth, height: cardHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            if allowInteraction {
                withAnimation(.easeInOut(duration: 0.3)) {
                    flipDegrees = isFlipped ? 0 : 180
                    isFlipped.toggle()
                }
                HapticManager.shared.lightImpact()
            }
        }
        .onChange(of: isFlipped) { oldValue, newValue in
            // Sync flipDegrees when isFlipped changes externally
            if !newValue && flipDegrees != 0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    flipDegrees = 0
                }
            }
        }
    }
}

// Grid Game Tile Component
struct GridGameTile: View {
    let deck: Deck
    let isLocked: Bool
    let onTap: () -> Void
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @State private var isPressed = false
    
    // Card dimensions based on actual image ratio (420 x 577)
    private let imageAspectRatio: CGFloat = 420.0 / 577.0
    private var tileWidth: CGFloat {
        ResponsiveSize.gridTileWidth
    }
    private var tileHeight: CGFloat {
        ResponsiveSize.gridTileHeight
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 12) {
                // Game artwork
                ZStack(alignment: .topTrailing) {
                    // Background for the card area
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.tertiaryBackground)
                        .frame(width: tileWidth, height: tileHeight)
                    
                    // Card image - scaled to fit to show full shape
                    Image(deck.imageName)
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .aspectRatio(imageAspectRatio, contentMode: .fit)
                        .frame(width: tileWidth, height: tileHeight)
                        .cornerRadius(16)
                        .opacity(isLocked ? 0.85 : 1.0)

                    // Plus badge for locked games
                    if isLocked {
                        HStack(spacing: 3) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 9, weight: .bold))
                            Text("PLUS")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .clipShape(Capsule())
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }

                    // Favorite button
                    Button(action: {
                        favoritesManager.toggleFavorite(deck.type)
                        HapticManager.shared.lightImpact()
                    }) {
                        Image(systemName: favoritesManager.isFavorite(deck.type) ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(favoritesManager.isFavorite(deck.type) ? .primaryAccent : .white)
                            .frame(width: 32, height: 32)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }
                
                // Game title
                Text(deck.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
            }
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Game Description Overlay for Grid View
struct GameDescriptionOverlay: View {
    let deck: Deck
    @Binding var selectedDeck: Deck?
    let isLocked: Bool
    let isLockedAndNotPlus: Bool
    let onShowPaywall: () -> Void
    @Binding var navigateToCategorySelection: Deck?
    @Binding var navigateToPlayView: Deck?
    @Binding var navigateToStoryChainSetup: Deck?
    @Binding var navigateToMemoryMasterSetup: Deck?
    @Binding var navigateToRhymeTimeSetup: Deck?
    @Binding var navigateToTapDuelSetup: Deck?
    @Binding var navigateToRiddleMeThisSetup: Deck?
    @Binding var navigateToQuickfireCouplesSetup: Deck?
    @Binding var navigateToCloserThanEverSetup: Deck?
    @Binding var navigateToUsAfterDarkSetup: Deck?
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var navigateToOnline = false
    @State private var showOnlineSignInAlert = false

    var body: some View {
        ZStack {
            // Adaptive background
            Color.appBackground
                .ignoresSafeArea()

            // Hidden NavigationLink to online room/lobby flow for capable games
            NavigationLink(
                destination: ClassicGameOnlineView(gameTitle: deck.title, gameType: deck.type.rawValue, imageName: deck.imageName),
                isActive: $navigateToOnline
            ) { EmptyView() }.hidden()
            
            VStack(spacing: 0) {
                // Top bar with close and favorite buttons (swapped positions)
                HStack {
                    // Close button (now on the left)
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedDeck = nil
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Favorite button (now on the right)
                    Button(action: {
                        favoritesManager.toggleFavorite(deck.type)
                        HapticManager.shared.lightImpact()
                    }) {
                        Image(systemName: favoritesManager.isFavorite(deck.type) ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(favoritesManager.isFavorite(deck.type) ? .primaryAccent : .primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                }
                .responsiveHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Deck artwork - smaller version
                Image(deck.imageName)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .aspectRatio(420.0 / 577.0, contentMode: .fit)
                    .frame(width: min(180, UIScreen.main.bounds.width - 120))
                    .cornerRadius(12)
                    .opacity(isLocked ? 0.88 : 1.0)
                    .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
                    .overlay(alignment: .bottomLeading) {
                        if isLocked {
                            HStack(spacing: 3) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 9, weight: .bold))
                                Text("PLUS")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .clipShape(Capsule())
                            .padding(8)
                        }
                    }
                    .padding(.bottom, 20)
                
                Spacer()
                
                // Deck title
                Text(deck.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .responsiveHorizontalPadding()
                    .padding(.bottom, 16)
                
                Text(deck.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .responsiveHorizontalPadding()
                    .padding(.bottom, 24)
                
                Spacer()
                
                // Play button - locked games show paywall; unlocked games navigate normally
                if isLockedAndNotPlus {
                    Button(action: { onShowPaywall() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Unlock with Plus")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.3),
                                radius: 8, x: 0, y: 4)
                    }
                    .responsiveHorizontalPadding()
                    .padding(.bottom, 40)
                } else if deck.type == .neverHaveIEver || deck.type == .truthOrDare || deck.type == .wouldYouRather || deck.type == .mostLikelyTo || deck.type == .takeItPersonally || deck.type == .categoryClash || deck.type == .bluffCall || deck.type == .whatsMySecret || deck.type == .actItOut || deck.type == .spillTheEx {
                        VStack(spacing: 12) {
                            // Play Local — same as the original Play button
                            PrimaryButton(title: deck.type.supportsOnlineMultiplayer ? "Play Local" : "Play") {
                                navigateToCategorySelection = deck
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        selectedDeck = nil
                                    }
                                }
                            }

                            // Play Online — only for the 4 online-capable classic games
                            if deck.type.supportsOnlineMultiplayer {
                                Button {
                                    HapticManager.shared.lightImpact()
                                    if authManager.isAuthenticated {
                                        navigateToOnline = true
                                    } else {
                                        showOnlineSignInAlert = true
                                    }
                                } label: {
                                    Text("Play Online")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryAccent)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.appBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.primaryAccent, lineWidth: 2)
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                        .alert("Sign in to play online", isPresented: $showOnlineSignInAlert) {
                            Button("Cancel", role: .cancel) {}
                            NavigationLink(destination: SignInView()) {
                                Text("Sign In")
                            }
                        } message: {
                            Text("You need a free account to create or join online rooms.")
                        }
                    } else if deck.type == .spinTheBottle {
                        PrimaryButton(title: "Play") {
                            // Navigate first, then dismiss overlay after navigation completes
                            navigateToPlayView = deck
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                    } else if deck.type == .storyChain {
                        PrimaryButton(title: "Play") {
                            // Dismiss overlay immediately, then navigate
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToStoryChainSetup = deck
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                    } else if deck.type == .memoryMaster {
                        PrimaryButton(title: "Play") {
                            // Dismiss overlay immediately, then navigate
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToMemoryMasterSetup = deck
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                    } else if deck.type == .rhymeTime {
                        PrimaryButton(title: "Play") {
                            // Dismiss overlay immediately, then navigate
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToRhymeTimeSetup = deck
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                    } else if deck.type == .tapDuel {
                        PrimaryButton(title: "Play") {
                            // Dismiss overlay immediately, then navigate
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToTapDuelSetup = deck
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                    } else if deck.type == .riddleMeThis {
                        VStack(spacing: 12) {
                            PrimaryButton(title: "Play Local") {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    navigateToRiddleMeThisSetup = deck
                                }
                            }
                            Button {
                                HapticManager.shared.lightImpact()
                                if authManager.isAuthenticated {
                                    navigateToOnline = true
                                } else {
                                    showOnlineSignInAlert = true
                                }
                            } label: {
                                Text("Play Online")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryAccent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.appBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.primaryAccent, lineWidth: 2)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                        .alert("Sign in to play online", isPresented: $showOnlineSignInAlert) {
                            Button("Cancel", role: .cancel) {}
                            NavigationLink(destination: SignInView()) {
                                Text("Sign In")
                            }
                        } message: {
                            Text("You need a free account to create or join online rooms.")
                        }
                    } else if deck.type == .actNatural {
                        PrimaryButton(title: "Play") {
                            // Navigate first, then dismiss overlay after navigation completes
                            navigateToCategorySelection = deck
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                    } else if deck.type == .quickfireCouples {
                        VStack(spacing: 12) {
                            PrimaryButton(title: "Play Local") {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    navigateToQuickfireCouplesSetup = deck
                                }
                            }
                            Button {
                                HapticManager.shared.lightImpact()
                                if authManager.isAuthenticated {
                                    navigateToOnline = true
                                } else {
                                    showOnlineSignInAlert = true
                                }
                            } label: {
                                Text("Play Online")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryAccent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.appBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.primaryAccent, lineWidth: 2)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                        .alert("Sign in to play online", isPresented: $showOnlineSignInAlert) {
                            Button("Cancel", role: .cancel) {}
                            NavigationLink(destination: SignInView()) {
                                Text("Sign In")
                            }
                        } message: {
                            Text("You need a free account to create or join online rooms.")
                        }
                    } else if deck.type == .closerThanEver {
                        VStack(spacing: 12) {
                            PrimaryButton(title: "Play Local") {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    navigateToCloserThanEverSetup = deck
                                }
                            }
                            Button {
                                HapticManager.shared.lightImpact()
                                if authManager.isAuthenticated {
                                    navigateToOnline = true
                                } else {
                                    showOnlineSignInAlert = true
                                }
                            } label: {
                                Text("Play Online")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryAccent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.appBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.primaryAccent, lineWidth: 2)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                        .alert("Sign in to play online", isPresented: $showOnlineSignInAlert) {
                            Button("Cancel", role: .cancel) {}
                            NavigationLink(destination: SignInView()) {
                                Text("Sign In")
                            }
                        } message: {
                            Text("You need a free account to create or join online rooms.")
                        }
                    } else if deck.type == .usAfterDark {
                        VStack(spacing: 12) {
                            PrimaryButton(title: "Play Local") {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    navigateToUsAfterDarkSetup = deck
                                }
                            }
                            Button {
                                HapticManager.shared.lightImpact()
                                if authManager.isAuthenticated {
                                    navigateToOnline = true
                                } else {
                                    showOnlineSignInAlert = true
                                }
                            } label: {
                                Text("Play Online")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primaryAccent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.appBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.primaryAccent, lineWidth: 2)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                        .alert("Sign in to play online", isPresented: $showOnlineSignInAlert) {
                            Button("Cancel", role: .cancel) {}
                            NavigationLink(destination: SignInView()) {
                                Text("Sign In")
                            }
                        } message: {
                            Text("You need a free account to create or join online rooms.")
                        }
                    } else {
                        PrimaryButton(title: "Play") {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                        }
                        .responsiveHorizontalPadding()
                        .padding(.bottom, 40)
                    }
            }
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.1).combined(with: .opacity),
            removal: .scale(scale: 0.1).combined(with: .opacity)
        ))
        .zIndex(1000)
    }
}

// MARK: - Online Game Tile

/// Card tile used in the "Online Only" tab. Matches GridGameTile style.
struct OnlineGameTile: View {
    let game: OnlineGameEntry
    let onTap: () -> Void

    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @State private var isPressed = false

    private let imageAspectRatio: CGFloat = 420.0 / 577.0
    private var tileWidth: CGFloat  { ResponsiveSize.gridTileWidth }
    private var tileHeight: CGFloat { ResponsiveSize.gridTileHeight }

    /// DeckType for favoriting when this game has a matching type (e.g. colorClash).
    private var favoriteDeckType: DeckType? {
        DeckType(rawValue: game.gameType)
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) { isPressed = false }
            }
        } label: {
            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.tertiaryBackground)
                        .frame(width: tileWidth, height: tileHeight)

                    Image(game.imageName)
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFill()
                        .frame(width: tileWidth, height: tileHeight)
                        .clipped()
                        .cornerRadius(16)

                    // Favorite button (same as GridGameTile) when this game has a DeckType
                    if let deckType = favoriteDeckType {
                        Button(action: {
                            favoritesManager.toggleFavorite(deckType)
                        }) {
                            Image(systemName: favoritesManager.isFavorite(deckType) ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(favoritesManager.isFavorite(deckType) ? .primaryAccent : .white)
                                .frame(width: 32, height: 32)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(8)
                    }
                }

                Text(game.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
            }
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        Play2View()
    }
}
