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
    @StateObject private var authManager = AuthManager.shared
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

    // MARK: - TheSocialDeck+ (game tiles are not gated; Plus is for categories & avatars)
    @EnvironmentObject private var subManager: SubscriptionManager
    @State private var showPlusPaywall = false

    private func isLocked(_ deck: Deck) -> Bool {
        false
    }

    /// Dark-mode-friendly programmatic covers on Social Deck Games and Date/Couples tabs (and their Favorites tiles). Tap Duel stays split high-contrast art.
    private func playGridAdaptiveSocialDeckCovers(for deck: Deck) -> Bool {
        guard deck.type != .tapDuel else { return false }
        if selectedCategory == "Social Deck Games" { return true }
        if selectedCategory == "Date/Couples" { return true }
        if selectedCategory == "Favorites" {
            return socialDeckGamesDecks.contains { $0.type == deck.type }
                || dateCouplesGamesDecks.contains { $0.type == deck.type }
        }
        return false
    }
    
    // All category names (Favorites shown dynamically when items exist)
    var categories: [String] {
        var cats = ["Classic Games", "Social Deck Games", "Date/Couples"]
        if !allOnlineGames.isEmpty {
            cats.append("Online Only")
        }
        if !favoriteDecks.isEmpty || !favoriteOnlineGames.isEmpty {
            cats.insert("Favorites", at: 0)
        }
        return cats
    }
    
    // Favorite online-only games (from `allOnlineGames`) so they appear in Favorites tab
    private var favoriteOnlineGames: [OnlineGameEntry] {
        allOnlineGames.filter { favoritesManager.isFavoriteRawGameType($0.gameType) }
    }
    
    // Selected online game for detail navigation
    @State private var selectedOnlineGame: OnlineGameEntry? = nil
    @State private var navigateToJoinRoom = false
    @State private var navigateToSignInForJoin = false
    @State private var showJoinRoomOptionsSheet = false
    @State private var navigateToBrowsePublicRooms = false
    
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
            availableCategories: ["Confessions", "Couples", "The Usual", "Spill the Tea", "Wild Side", "After Dark"]
        ),
        Deck(
            title: "Truth or Dare",
            description: "Choose truth or dare and see where the night takes you. Answer revealing questions truthfully or complete fun challenges. Each player takes turns choosing their fate. The classic party game that never gets old!",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "TOD 2.0",
            type: .truthOrDare,
            cards: allTORCards,
            availableCategories: ["Party", "Wild", "Couples", "Social", "Dirty", "Friends"]
        ),
        Deck(
            title: "Would You Rather",
            description: "Make tough choices and discover what your friends prefer. Face impossible dilemmas and see who would choose what. Debate your choices and learn surprising things about your friends' preferences and values.",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "WYR 2.0",
            type: .wouldYouRather,
            cards: allWYRCards,
            availableCategories: ["Party", "Couples", "Social", "Dirty", "Friends", "Weird"]
        ),
        Deck(
            title: "Most Likely To",
            description: "Find out who's most likely to do crazy things. Vote on which friend is most likely to do outrageous scenarios. Funny, revealing, and perfect for groups. Discover who your friends think would do the wildest things!",
            numberOfCards: 626,
            estimatedTime: "30-45 min",
            imageName: "MLT 2.0",
            type: .mostLikelyTo,
            cards: allMLTCards,
            availableCategories: ["Party", "Wild", "Couples", "Social", "Dirty", "Friends"]
        )
    ]
    
    // Social Deck Games decks with 2.0 artwork
    let socialDeckGamesDecks: [Deck] = [
        Deck(
            title: "What Would You Do",
            description: "An online party game for your group in one room. Each round everyone sees the same “what would you do if…” scenario, writes a short answer in private, and submits. When everyone’s in, answers reveal one by one on screen. Then players vote for their favorites—you can’t vote for yourself—and scores update each round until the final leaderboard. The host can run another game from the lobby; optional anonymous mode hides names on answers until the end.",
            numberOfCards: 0,
            estimatedTime: "~20 min",
            imageName: "",
            type: .whatWouldYouDo,
            cards: [],
            availableCategories: ["Party"]
        ),
        Deck(
            title: "Spill the Ex",
            description: "The tea is hot and nobody's past is completely safe. Each round, players share juicy relationship stories and the group tries to guess who each one belongs to. From harmless confessions to messy moments — bold, funny, and surprisingly revealing.",
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
            description: "One player holds a hidden rule and acts it out for the group to decode — without saying it outright. Everyone else watches closely and tries to crack the secret. The first to guess correctly earns a point; most points at the end wins!",
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
            description: "Players take turns acting out a word or idea without speaking while everyone else tries to guess. No talking—just gestures and movement. When someone guesses correctly, give them a point; whoever has the most points when the game ends wins.",
            numberOfCards: 556,
            estimatedTime: "15-30 min",
            imageName: "AIO 2.0",
            type: .actItOut,
            cards: allActItOutCards,
            availableCategories: ["Actions & Verbs", "Animals", "Emotions & Expressions", "Daily Activities", "Sports & Activities", "Objects & Tools", "Food & Cooking", "Famous Concepts", "Movie Genres", "Nature & Weather"]
        ),
        Deck(
            title: "Act Natural",
            description: "Players are split into 'In the Know' and 'Unknown' roles. In the Know players drop hints about a secret word without giving it away, while the Unknown tries to blend in and figure it out. Most convincing bluff wins — can the Unknown crack the secret before being exposed?",
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
            description: "Convince the group your answer is real, or call out the bluffer! One player sees a prompt and delivers their answer with confidence — truth or total bluff. The group votes to believe or call it out. Deception meets deduction!",
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
            description: "Fast-paced 'this or that' choices for couples — answer instantly without overthinking. See how often your preferences match and discover where you're totally different. Quick, honest, and surprisingly revealing for couples at any stage of their relationship.",
            numberOfCards: 408,
            estimatedTime: "15-25 min",
            imageName: "Quickfire Couples",
            type: .quickfireCouples,
            cards: allQuickfireCouplesCards,
            availableCategories: ["Light & Fun", "Preferences", "Personality", "Relationship"]
        ),
        Deck(
            title: "Closer Than Ever",
            description: "Meaningful questions designed to deepen connection and strengthen your bond. Take turns exploring love languages, shared memories, values, and future dreams together. Each card opens a real conversation that goes beyond small talk. Slow down and grow closer than ever.",
            numberOfCards: 394,
            estimatedTime: "30-45 min",
            imageName: "Closer than ever",
            type: .closerThanEver,
            cards: allCloserThanEverCards,
            availableCategories: ["Love Languages", "Memories", "Vulnerability", "Intimacy"]
        ),
        Deck(
            title: "Us After Dark",
            description: "A deeper couples game built on honesty, curiosity, and emotional closeness. Questions explore desires, boundaries, memories, and what makes your connection truly special. Designed for late nights when you're ready to go beyond the surface and rediscover each other.",
            numberOfCards: 236,
            estimatedTime: "30-45 min",
            imageName: "us after dark",
            type: .usAfterDark,
            cards: allUsAfterDarkCards,
            availableCategories: ["Memories", "Connection", "Desires", "Intimacy"]
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
                                GridGameTile(
                                    deck: deck,
                                    isLocked: isLocked(deck),
                                    useAdaptiveSocialDeckProgrammaticCovers: playGridAdaptiveSocialDeckCovers(for: deck)
                                ) {
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
                                    isLocked: isLocked(deck),
                                    useAdaptiveSocialDeckProgrammaticCovers: playGridAdaptiveSocialDeckCovers(for: deck)
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

            NavigationLink(destination: JoinRoomView(), isActive: $navigateToJoinRoom) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: PublicRoomsView(gameType: nil, gameDisplayName: "All games"),
                isActive: $navigateToBrowsePublicRooms
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(destination: SignInView(), isActive: $navigateToSignInForJoin) {
                EmptyView()
            }
            .hidden()
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
                    useAdaptiveSocialDeckProgrammaticCovers: playGridAdaptiveSocialDeckCovers(for: deck),
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    HapticManager.shared.lightImpact()
                    if authManager.isAuthenticated {
                        showJoinRoomOptionsSheet = true
                    } else {
                        navigateToSignInForJoin = true
                    }
                } label: {
                    Text("Join Game")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryAccent)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showJoinRoomOptionsSheet) {
            joinRoomOptionsSheet
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPlusPaywall, onDismiss: {
            Task { await subManager.refreshEntitlements() }
        }) {
            TheSocialDeckPlusPopUpView(onDismiss: { showPlusPaywall = false })
                .environmentObject(SubscriptionManager.shared)
        }
    }

    private var joinRoomOptionsSheet: some View {
        VStack(spacing: 20) {
            Text("Join a game")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .padding(.top, 8)

            VStack(spacing: 12) {
                Button {
                    HapticManager.shared.lightImpact()
                    showJoinRoomOptionsSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        navigateToJoinRoom = true
                    }
                } label: {
                    Text("Enter Room Code")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.primaryAccent)
                        .cornerRadius(14)
                }

                Button {
                    HapticManager.shared.lightImpact()
                    showJoinRoomOptionsSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        if subManager.isPlus {
                            navigateToBrowsePublicRooms = true
                        } else {
                            showPlusPaywall = true
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        if !subManager.isPlus {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        Text("Browse Open Rooms")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.primaryAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primaryAccent.opacity(0.12))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.primaryAccent.opacity(0.35), lineWidth: 1.5)
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
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
                QuickfireCouplesCategorySelectionView(deck: deck)
            case .closerThanEver:
                CloserThanEverCategorySelectionView(deck: deck)
            case .usAfterDark:
                UsAfterDarkCategorySelectionView(deck: deck)
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
                DeckCoverArtView(deck: deck)
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
    var useAdaptiveSocialDeckProgrammaticCovers: Bool = false
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
                    
                    // Card image — or programmatic cover for NHIE
                    DeckCoverArtView(deck: deck)
                        .environment(\.playGridAdaptiveSocialDeckCovers, useAdaptiveSocialDeckProgrammaticCovers)
                        .aspectRatio(imageAspectRatio, contentMode: .fit)
                        .frame(width: tileWidth, height: tileHeight)
                        .cornerRadius(16)
                        .opacity(isLocked ? 0.85 : 1.0)

                    // Plus + optional marketing badges (bottom-leading; same capsule metrics as PLUS)
                    if isLocked || deck.type.playGridMarketingBadge != nil {
                        VStack(alignment: .leading, spacing: 6) {
                            if let badge = deck.type.playGridMarketingBadge {
                                PlayGridGameMarketingBadgePill(label: badge.label, systemImage: badge.systemImage)
                            }
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
                            }
                        }
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
                .shadow(color: Color.cardShadowColor, radius: 9, x: 0, y: 5)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                
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
    let useAdaptiveSocialDeckProgrammaticCovers: Bool
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
    @StateObject private var onlineManager = OnlineManager.shared
    @EnvironmentObject private var subManager: SubscriptionManager
    @State private var isCreatingOnlineRoom = false
    @State private var navigateToLobby = false
    @State private var showOnlineSignInAlert = false
    @State private var showCreateRoomError = false
    @State private var createRoomErrorMessage: String?
    @State private var showDailyLimitModal = false

    // MARK: - Daily room-creation limit (free users only)

    private let kRoomLimitDate  = "com.thesocialdeck.roomCreation.date"
    private let kRoomLimitCount = "com.thesocialdeck.roomCreation.dailyCount"
    private let dailyFreeRoomLimit = 3

    private func hasReachedDailyRoomLimit() -> Bool {
        let stored = UserDefaults.standard.object(forKey: kRoomLimitDate) as? Date
        let count  = UserDefaults.standard.integer(forKey: kRoomLimitCount)
        if let stored, Calendar.current.isDateInToday(stored) {
            return count >= dailyFreeRoomLimit
        }
        return false
    }

    private func incrementDailyRoomCount() {
        let stored = UserDefaults.standard.object(forKey: kRoomLimitDate) as? Date
        if let stored, Calendar.current.isDateInToday(stored) {
            UserDefaults.standard.set(
                UserDefaults.standard.integer(forKey: kRoomLimitCount) + 1,
                forKey: kRoomLimitCount
            )
        } else {
            UserDefaults.standard.set(Date(), forKey: kRoomLimitDate)
            UserDefaults.standard.set(1, forKey: kRoomLimitCount)
        }
    }

    /// Max players for hosted online room (matches `ClassicGameOnlineView`).
    private var onlineMaxPlayersForDeck: Int {
        deck.type == .actNatural ? 12 : 8
    }

    /// Play Offline + Create Room side by side; same colors/typefaces/corner treatment; tighter vertical padding.
    @ViewBuilder
    private func playOfflineAndCreateRoomFooter(
        localTitle: String,
        localAction: @escaping () -> Void,
        createRoomAction: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 10) {
            Button(action: localAction) {
                Text(localTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.buttonBackground)
                    .cornerRadius(16)
            }
            .disabled(isCreatingOnlineRoom)

            Button {
                HapticManager.shared.lightImpact()
                createRoomAction()
            } label: {
                Group {
                    if isCreatingOnlineRoom {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryAccent))
                            .scaleEffect(0.9)
                    } else {
                        Text("Create Room")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryAccent)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color.appBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.primaryAccent, lineWidth: 2)
                )
                .clipShape(Capsule())
            }
            .disabled(isCreatingOnlineRoom)
        }
    }

    private func createOnlineRoomFromDescription() async {
        isCreatingOnlineRoom = true
        // WWYD rooms default to private so hosts explicitly opt in to public discovery.
        let defaultPrivate = deck.type == .whatWouldYouDo
        await onlineManager.createRoom(
            roomName: deck.title,
            maxPlayers: onlineMaxPlayersForDeck,
            isPrivate: defaultPrivate,
            gameType: deck.type.rawValue
        )
        await MainActor.run {
            isCreatingOnlineRoom = false
            if onlineManager.currentRoom != nil {
                // Count this successful creation toward the free daily quota.
                if !subManager.isPlus {
                    incrementDailyRoomCount()
                }
                HapticManager.shared.success()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    selectedDeck = nil
                }
                navigateToLobby = true
            }
        }
    }

    private func onCreateRoomTapped() {
        // What Would You Do requires Plus to create a room.
        // (Joining via room code / invite is unaffected — that goes through a separate path.)
        if deck.type == .whatWouldYouDo && !subManager.isPlus {
            onShowPaywall()
            return
        }

        // Free users may create up to 3 rooms per day — show the styled modal first.
        if !subManager.isPlus && hasReachedDailyRoomLimit() {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                showDailyLimitModal = true
            }
            return
        }

        if authManager.isAuthenticated {
            Task { await createOnlineRoomFromDescription() }
        } else {
            showOnlineSignInAlert = true
        }
    }


    @ViewBuilder
    private var bottomActionButtons: some View {
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
            Group {
                if deck.type.supportsOnlineMultiplayer {
                    playOfflineAndCreateRoomFooter(
                        localTitle: "Play Offline",
                        localAction: {
                            navigateToCategorySelection = deck
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                            }
                        },
                        createRoomAction: { onCreateRoomTapped() }
                    )
                } else {
                    PrimaryButton(title: "Play") {
                        navigateToCategorySelection = deck
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                        }
                    }
                }
            }
            .responsiveHorizontalPadding()
            .padding(.bottom, 40)
        } else if deck.type == .spinTheBottle {
            PrimaryButton(title: "Play") {
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
            playOfflineAndCreateRoomFooter(
                localTitle: "Play Offline",
                localAction: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedDeck = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        navigateToRiddleMeThisSetup = deck
                    }
                },
                createRoomAction: { onCreateRoomTapped() }
            )
            .responsiveHorizontalPadding()
            .padding(.bottom, 40)
        } else if deck.type == .actNatural {
            playOfflineAndCreateRoomFooter(
                localTitle: "Play Offline",
                localAction: {
                    navigateToCategorySelection = deck
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedDeck = nil
                        }
                    }
                },
                createRoomAction: { onCreateRoomTapped() }
            )
            .responsiveHorizontalPadding()
            .padding(.bottom, 40)
        } else if deck.type == .quickfireCouples {
            playOfflineAndCreateRoomFooter(
                localTitle: "Play Offline",
                localAction: {
                    navigateToCategorySelection = deck
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedDeck = nil
                        }
                    }
                },
                createRoomAction: { onCreateRoomTapped() }
            )
            .responsiveHorizontalPadding()
            .padding(.bottom, 40)
        } else if deck.type == .closerThanEver {
            playOfflineAndCreateRoomFooter(
                localTitle: "Play Offline",
                localAction: {
                    navigateToCategorySelection = deck
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedDeck = nil
                        }
                    }
                },
                createRoomAction: { onCreateRoomTapped() }
            )
            .responsiveHorizontalPadding()
            .padding(.bottom, 40)
        } else if deck.type == .usAfterDark {
            playOfflineAndCreateRoomFooter(
                localTitle: "Play Offline",
                localAction: {
                    navigateToCategorySelection = deck
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedDeck = nil
                        }
                    }
                },
                createRoomAction: { onCreateRoomTapped() }
            )
            .responsiveHorizontalPadding()
            .padding(.bottom, 40)
        } else if deck.type == .whatWouldYouDo {
            Button {
                onCreateRoomTapped()
            } label: {
                Group {
                    if isCreatingOnlineRoom {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Text("Create Room")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.buttonBackground)
                .cornerRadius(16)
            }
            .disabled(isCreatingOnlineRoom)
            .responsiveHorizontalPadding()
            .padding(.bottom, 40)
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

    var body: some View {
        ZStack {
            // Adaptive background
            Color.appBackground
                .ignoresSafeArea()

            NavigationLink(destination: LobbyView(), isActive: $navigateToLobby) {
                EmptyView()
            }
            .hidden()

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

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Spacer(minLength: 0)
                            DeckCoverArtView(deck: deck)
                                .environment(\.playGridAdaptiveSocialDeckCovers, useAdaptiveSocialDeckProgrammaticCovers)
                                .environment(\.whatWouldYouDoCoverEmbeddedPills, false)
                                .aspectRatio(420.0 / 577.0, contentMode: .fit)
                                .frame(width: min(180, UIScreen.main.bounds.width - 120))
                                .cornerRadius(12)
                                .opacity(isLocked ? 0.88 : 1.0)
                                .shadow(color: Color.cardShadowColor, radius: 11, x: 0, y: 6)
                                .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 3)
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
                            Spacer(minLength: 0)
                        }
                        .padding(.bottom, 2)

                        Text(deck.title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(deck.description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(6)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        GameDescriptionTagRow(tags: GameDescriptionLayoutContent.tags(for: deck))

                        GameDescriptionNumberedStepsView(steps: GameDescriptionLayoutContent.playSteps(for: deck))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .responsiveHorizontalPadding()
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomActionButtons
            }
            .alert("Sign in to play online", isPresented: $showOnlineSignInAlert) {
                Button("Cancel", role: .cancel) {}
                NavigationLink(destination: SignInView()) {
                    Text("Sign In")
                }
            } message: {
                Text("You need a free account to create or join online rooms.")
            }
        }
        .alert("Error", isPresented: $showCreateRoomError) {
            Button("OK", role: .cancel) { createRoomErrorMessage = nil }
        } message: {
            Text(createRoomErrorMessage ?? "Something went wrong. Please try again.")
        }
        .onChange(of: onlineManager.errorMessage) { msg in
            if let msg, !msg.isEmpty {
                createRoomErrorMessage = msg
                showCreateRoomError = true
                isCreatingOnlineRoom = false
            }
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.1).combined(with: .opacity),
            removal: .scale(scale: 0.1).combined(with: .opacity)
        ))
        .zIndex(1000)
        // ── Daily limit modal ──────────────────────────────────────────
        if showDailyLimitModal {
            DailyRoomLimitModal {
                // "Upgrade to Plus" tapped
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    showDailyLimitModal = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onShowPaywall()
                }
            } onDismiss: {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    showDailyLimitModal = false
                }
            }
            .zIndex(1001)
            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .center)))
        }
    }
}

// MARK: - Daily room-creation limit modal

private struct DailyRoomLimitModal: View {
    let onUpgrade: () -> Void
    let onDismiss: () -> Void

    private let brandRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)

    var body: some View {
        ZStack {
            // Dim scrim — tap anywhere to dismiss
            Color.black.opacity(0.52)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            // Card
            VStack(spacing: 0) {

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.primaryAccent.opacity(0.10))
                        .frame(width: 68, height: 68)
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primaryAccent)
                        .rotationEffect(.degrees(90))
                }
                .padding(.top, 28)
                .padding(.bottom, 14)

                // Title
                Text("Daily Limit Reached")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)

                // Body
                Text("You've hit your daily limit of 3 room creations. Upgrade to Plus for unlimited room creation and the full online experience.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 24)

                Divider()
                    .background(Color.primaryText.opacity(0.08))

                // Upgrade button
                Button(action: onUpgrade) {
                    Text("Upgrade to Plus")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(brandRed)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Maybe Later
                Button(action: onDismiss) {
                    Text("Maybe Later")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .padding(.vertical, 14)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.appBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.primaryText.opacity(0.07), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.22), radius: 28, x: 0, y: 10)
            .padding(.horizontal, 30)
        }
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

                    Group {
                        if game.builtInCover == .whatWouldYouDo {
                            WhatWouldYouDoCoverArtView()
                                .environment(\.playGridAdaptiveSocialDeckCovers, true)
                                .frame(width: tileWidth, height: tileHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Text(game.title)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(5)
                                .minimumScaleFactor(0.75)
                                .padding(.horizontal, 14)
                                .frame(width: tileWidth, height: tileHeight)
                        }
                    }

                    Button(action: {
                        favoritesManager.toggleFavoriteRawGameType(game.gameType)
                    }) {
                        Image(systemName: favoritesManager.isFavoriteRawGameType(game.gameType) ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(favoritesManager.isFavoriteRawGameType(game.gameType) ? .primaryAccent : .white)
                            .frame(width: 32, height: 32)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }
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
