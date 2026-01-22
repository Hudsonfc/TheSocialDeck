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
    @State private var currentCardIndex = 0
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
    @State private var cardFlippedStates: [Bool] = []
    @State private var cardOffset: CGFloat = 0
    @State private var isDragging = false
    @AppStorage("hasSeenWelcomeView") private var hasSeenWelcomeView: Bool = false
    @State private var showWelcomeView: Bool = false
    @State private var isGridView: Bool = false // Track layout mode
    @State private var selectedDeckForDescription: Deck? = nil // Track deck for description overlay
    
    // All category names (Favorites shown dynamically when items exist)
    var categories: [String] {
        var cats = ["Classic Games", "Social Deck Games", "Date/Couples"]
        if !favoriteDecks.isEmpty {
            cats.insert("Favorites", at: 0)
        }
        return cats
    }
    
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
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
        ),
        Deck(
            title: "Truth or Dare",
            description: "Choose truth or dare and see where the night takes you. Answer revealing questions truthfully or complete fun challenges. Each player takes turns choosing their fate. The classic party game that never gets old!",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "TOD 2.0",
            type: .truthOrDare,
            cards: allTORCards,
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
        ),
        Deck(
            title: "Would You Rather",
            description: "Make tough choices and discover what your friends prefer. Face impossible dilemmas and see who would choose what. Debate your choices and learn surprising things about your friends' preferences and values.",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "WYR 2.0",
            type: .wouldYouRather,
            cards: allWYRCards,
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
        ),
        Deck(
            title: "Most Likely To",
            description: "Find out who's most likely to do crazy things. Vote on which friend is most likely to do outrageous scenarios. Funny, revealing, and perfect for groups. Discover who your friends think would do the wildest things!",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "MLT 2.0",
            type: .mostLikelyTo,
            cards: allMLTCards,
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
        )
    ]
    
    // Social Deck Games decks with 2.0 artwork
    let socialDeckGamesDecks: [Deck] = [
        Deck(
            title: "Rhyme Time",
            description: "Say a word that rhymes with the base word before time runs out! Challenge your vocabulary and quick thinking. Repeat a rhyme or hesitate and you're out. Choose your difficulty level and see how long you can last in this word battle!",
            numberOfCards: 40,
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
            numberOfCards: 75,
            estimatedTime: "5-10 min",
            imageName: "WMS 2.0",
            type: .whatsMySecret,
            cards: allWhatsMySecretCards,
            availableCategories: ["Party", "Wild", "Social", "Actions", "Behavior"]
        ),
        Deck(
            title: "Riddle Me This",
            description: "Solve riddles quickly! The first player to say the correct answer wins the round. Test your problem-solving skills with tricky riddles. Wrong answers lock you out, so think carefully. Brain teasers that challenge your logic and creativity!",
            numberOfCards: 71,
            estimatedTime: "5-10 min",
            imageName: "RMT 2.0",
            type: .riddleMeThis,
            cards: allRiddleMeThisCards,
            availableCategories: []
        ),
        Deck(
            title: "Act It Out",
            description: "Act out prompts silently while others guess! First to guess correctly wins the round. Challenge your acting skills with categories like Actions & Verbs, Animals, Emotions, Daily Activities, Sports, Objects, Food, Famous Concepts, Movie Genres, and Nature. No talking, only acting!",
            numberOfCards: 300,
            estimatedTime: "15-30 min",
            imageName: "AIO 2.0",
            type: .actItOut,
            cards: allActItOutCards,
            availableCategories: ["Actions & Verbs", "Animals", "Emotions & Expressions", "Daily Activities", "Sports & Activities", "Objects & Tools", "Food & Cooking", "Famous Concepts", "Movie Genres", "Nature & Weather"]
        ),
        Deck(
            title: "Act Natural",
            description: "One player doesn't know the secret word — can they blend in and figure it out before getting caught? Everyone else knows the secret word and tries to subtly mention it. The secret player must figure it out while acting natural. Deception meets deduction!",
            numberOfCards: 200,
            estimatedTime: "10-20 min",
            imageName: "AN 2.0",
            type: .actNatural,
            cards: [],
            availableCategories: []
        ),
        Deck(
            title: "Category Clash",
            description: "Name items in a category before time runs out! Hesitate or repeat an answer and you're out. Choose from categories like Food & Drink, Pop Culture, General, Sports & Activities, or Animals & Nature. The pace gets faster each round, turning it into a hilarious pressure game!",
            numberOfCards: 250,
            estimatedTime: "15-20 min",
            imageName: "CC 2.0",
            type: .categoryClash,
            cards: allCategoryClashCards,
            availableCategories: ["Food & Drink", "Pop Culture", "General", "Sports & Activities", "Animals & Nature"]
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
            numberOfCards: 145,
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
            numberOfCards: 300,
            estimatedTime: "15-20 min",
            imageName: "BC 2.0",
            type: .bluffCall,
            cards: allBluffCallCards,
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
        )
    ]
    
    // Date/Couples Games decks with 2.0 artwork
    let dateCouplesGamesDecks: [Deck] = [
        Deck(
            title: "Quickfire Couples",
            description: "Fast-paced \"this or that\" choices for couples. Answer instantly to reveal preferences and chemistry.",
            numberOfCards: 200,
            estimatedTime: "15-25 min",
            imageName: "Quickfire Couples",
            type: .quickfireCouples,
            cards: allQuickfireCouplesCards,
            availableCategories: []
        ),
        Deck(
            title: "Closer Than Ever",
            description: "Meaningful questions designed to deepen connection and strengthen emotional bonds. Explore love languages, shared memories, values, and future dreams through thoughtful conversation.",
            numberOfCards: 200,
            estimatedTime: "30-45 min",
            imageName: "Closer than ever",
            type: .closerThanEver,
            cards: allCloserThanEverCards,
            availableCategories: []
        ),
        Deck(
            title: "Us After Dark",
            description: "A deeper, intimate couples game focused on honesty, curiosity, and emotional closeness. Questions explore desires, boundaries, memories, and what makes your connection special.",
            numberOfCards: 200,
            estimatedTime: "30-45 min",
            imageName: "us after dark",
            type: .usAfterDark,
            cards: allUsAfterDarkCards,
            availableCategories: []
        )
    ]
    
    // Trivia Games decks with 2.0 artwork
    let triviaGamesDecks: [Deck] = [
        Deck(
            title: "Pop Culture Trivia",
            description: "Test your knowledge of movies, music, and celebrities. Challenge yourself with questions about the latest trends, classic films, chart-topping hits, and famous faces. Choose from Easy, Medium, or Hard difficulty levels. Perfect for pop culture enthusiasts!",
            numberOfCards: 1200,
            estimatedTime: "10-15 min",
            imageName: "pop culture 2.0",
            type: .popCultureTrivia,
            cards: allPopCultureTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "History Trivia",
            description: "Challenge yourself with historical facts and events. Travel through time with questions about world history, famous figures, major events, and historical moments. Choose Easy, Medium, or Hard difficulty. Perfect for history buffs and curious minds!",
            numberOfCards: 620,
            estimatedTime: "10-15 min",
            imageName: "History 2.0",
            type: .historyTrivia,
            cards: allHistoryTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "Science Trivia",
            description: "Explore the world of science and discovery. Test your knowledge of biology, chemistry, physics, space, and groundbreaking discoveries. Choose from Easy, Medium, or Hard difficulty levels. Perfect for science lovers and curious minds!",
            numberOfCards: 640,
            estimatedTime: "10-15 min",
            imageName: "science 2.0",
            type: .scienceTrivia,
            cards: allScienceTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "Sports Trivia",
            description: "Show off your sports knowledge. Challenge yourself with questions about professional sports, famous athletes, championships, records, and sports history. Choose Easy, Medium, or Hard difficulty. Perfect for sports fans and trivia enthusiasts!",
            numberOfCards: 920,
            estimatedTime: "10-15 min",
            imageName: "sports 2.0",
            type: .sportsTrivia,
            cards: allSportsTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "Movie Trivia",
            description: "Test your movie knowledge with film questions. Answer questions about classic films, blockbusters, actors, directors, quotes, and movie history. Choose from Easy, Medium, or Hard difficulty levels. Perfect for film buffs and movie lovers!",
            numberOfCards: 600,
            estimatedTime: "10-15 min",
            imageName: "movies 2.0",
            type: .movieTrivia,
            cards: allMovieTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "Music Trivia",
            description: "Guess songs, artists, and music facts. Test your knowledge of hit songs, famous artists, music genres, lyrics, and music history across decades. Choose Easy, Medium, or Hard difficulty. Perfect for music lovers and playlist creators!",
            numberOfCards: 600,
            estimatedTime: "10-15 min",
            imageName: "music 2.0",
            type: .musicTrivia,
            cards: allMusicTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
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
                                            currentCardIndex = 0
                                            cardOffset = 0
                                        }
                                        HapticManager.shared.lightImpact()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: categories)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Content area - Card view or Grid view
                if isGridView {
                    // Grid View - Show all games at once
                    ScrollView(.vertical, showsIndicators: false) {
                        if !currentDecks.isEmpty {
                            let columns = [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(Array(currentDecks.enumerated()), id: \.element.id) { index, deck in
                                    GridGameTile(deck: deck) {
                                        HapticManager.shared.lightImpact()
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedDeckForDescription = deck
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Card Deck - Simple horizontal scroll with current card only
                    ZStack {
                        if !currentDecks.isEmpty && currentCardIndex < currentDecks.count && currentCardIndex < cardFlippedStates.count {
                            GameCardView(
                                deck: currentDecks[currentCardIndex],
                                isFlipped: $cardFlippedStates[currentCardIndex],
                                onSelect: {
                                    // Reset flip state before navigating
                                    if currentCardIndex < cardFlippedStates.count {
                                        cardFlippedStates[currentCardIndex] = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        navigateToCategorySelection = currentDecks[currentCardIndex]
                                    }
                                },
                                allowInteraction: true
                            )
                            .id("\(selectedCategory)-\(currentCardIndex)") // Force view update on category change
                            .offset(x: cardOffset)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                removal: .opacity.combined(with: .scale(scale: 0.95))
                            ))
                            .gesture(
                                DragGesture(minimumDistance: 20)
                                    .onChanged { value in
                                        // Allow drag regardless of flip state
                                        isDragging = true
                                        cardOffset = value.translation.width
                                    }
                                    .onEnded { value in
                                        isDragging = false
                                        // Allow swipe regardless of flip state
                                        if value.translation.width < -80 && currentCardIndex < currentDecks.count - 1 {
                                            // Swipe left - go to next card (reset flip state)
                                            if currentCardIndex < cardFlippedStates.count {
                                                cardFlippedStates[currentCardIndex] = false
                                            }
                                            withAnimation(.easeOut(duration: 0.25)) {
                                                cardOffset = -UIScreen.main.bounds.width
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                currentCardIndex += 1
                                                cardOffset = UIScreen.main.bounds.width
                                                withAnimation(.easeOut(duration: 0.25)) {
                                                    cardOffset = 0
                                                }
                                            }
                                            HapticManager.shared.lightImpact()
                                        } else if value.translation.width > 80 && currentCardIndex > 0 {
                                            // Swipe right - go to previous card (reset flip state)
                                            cardFlippedStates[currentCardIndex] = false
                                            withAnimation(.easeOut(duration: 0.25)) {
                                                cardOffset = UIScreen.main.bounds.width
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                currentCardIndex -= 1
                                                cardOffset = -UIScreen.main.bounds.width
                                                withAnimation(.easeOut(duration: 0.25)) {
                                                    cardOffset = 0
                                                }
                                            }
                                            HapticManager.shared.lightImpact()
                                        } else {
                                            // Snap back to center
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                cardOffset = 0
                                            }
                                        }
                                    }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped() // Hide cards when they slide off screen
                    
                // Placeholder text under cards (hidden when grid view or no decks)
                if !currentDecks.isEmpty && !isGridView {
                    Text("Tap card to flip and see details")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.tertiaryText)
                        .padding(.top, 16)
                }
                
                // Card Counter (hidden when grid view)
                if !currentDecks.isEmpty && !isGridView {
                        HStack(spacing: 8) {
                            ForEach(0..<currentDecks.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentCardIndex ? Color.primaryAccent : Color.borderColor)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 30)
                    }
                }
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
        }
        .overlay {
            // Welcome View for first-time users
            if showWelcomeView {
                WelcomeView(isPresented: $showWelcomeView)
            }
            
            // Game Description Overlay for Grid View
            if isGridView, let deck = selectedDeckForDescription {
                GameDescriptionOverlay(
                    deck: deck,
                    selectedDeck: $selectedDeckForDescription,
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
        .onChange(of: selectedCategory) { oldValue, newValue in
            // Update cardFlippedStates size when category changes
            cardFlippedStates = Array(repeating: false, count: max(currentDecks.count, 1))
        }
        .task {
            // Initialize cardFlippedStates when view appears
            cardFlippedStates = Array(repeating: false, count: max(currentDecks.count, 1))
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
                Button(action: {
                    HapticManager.shared.lightImpact()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isGridView.toggle()
                        // Reset card index when switching layouts
                        if !isGridView {
                            currentCardIndex = 0
                            cardOffset = 0
                            cardFlippedStates = Array(repeating: false, count: max(currentDecks.count, 1))
                        }
                    }
                }) {
                    if isGridView {
                        // When in grid view, show rotated rectangle.stack to switch back to card view
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryAccent)
                            .rotationEffect(.degrees(90))
                    } else {
                        // When in card view, show grid icon to switch to grid view
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryAccent)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
            // Trivia Games
            case .popCultureTrivia:
                PopCultureTriviaCategorySelectionView(deck: deck)
            case .historyTrivia:
                HistoryTriviaCategorySelectionView(deck: deck)
            case .scienceTrivia:
                ScienceTriviaCategorySelectionView(deck: deck)
            case .sportsTrivia:
                SportsTriviaCategorySelectionView(deck: deck)
            case .movieTrivia:
                MovieTriviaCategorySelectionView(deck: deck)
            case .musicTrivia:
                MusicTriviaCategorySelectionView(deck: deck)
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
    let onSelect: () -> Void
    let allowInteraction: Bool
    @State private var flipDegrees: Double = 0
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    // Card dimensions based on actual image ratio (420 x 577)
    private let imageAspectRatio: CGFloat = 420.0 / 577.0
    private var cardWidth: CGFloat {
        min(UIScreen.main.bounds.width - 80, 320)
    }
    private var cardHeight: CGFloat {
        cardWidth / imageAspectRatio
    }
    
    // Check if showing front or back
    private var showingFront: Bool {
        flipDegrees < 90 || flipDegrees > 270
    }
    
    // Helper to determine if background is light colored
    private var isLightBackground: Bool {
        deck.type == .quickfireCouples || deck.type == .closerThanEver || 
        deck.type == .usAfterDark || deck.type == .wouldYouRather || 
        deck.type == .mostLikelyTo || deck.type == .tapDuel || 
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
    
    var body: some View {
        ZStack {
            // Back of card (description and select button) - behind front
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 16) {
                    Spacer()
                    
                    // Title
                    Text(deck.title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(titleColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                    
                    Text(deck.description)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(descriptionColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 28)
                    
                    // Play Button
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onSelect()
                    }) {
                        Text("Play")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.buttonBackground, Color.buttonBackground.opacity(0.85)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
                
                // Favorite button - top right
                FavoriteButton(deck: deck)
                    .padding(20)
            }
            .frame(width: cardWidth, height: cardHeight)
            .background(
                deck.type == .quickfireCouples ? Color(red: 0xFF/255.0, green: 0xB5/255.0, blue: 0xEF/255.0) :
                deck.type == .closerThanEver ? Color(red: 0xFF/255.0, green: 0x84/255.0, blue: 0x84/255.0) :
                deck.type == .usAfterDark ? Color(red: 0xA1/255.0, green: 0xC2/255.0, blue: 0xFF/255.0) :
                // Red games
                deck.type == .neverHaveIEver || deck.type == .rhymeTime || deck.type == .memoryMaster ? Color(red: 0xFF/255.0, green: 0x84/255.0, blue: 0x84/255.0) :
                // Blue games
                deck.type == .truthOrDare || deck.type == .riddleMeThis || deck.type == .actNatural ? Color(red: 0xA1/255.0, green: 0xC2/255.0, blue: 0xFF/255.0) :
                // Green games
                deck.type == .mostLikelyTo || deck.type == .actItOut ? Color(red: 0xB0/255.0, green: 0xE9/255.0, blue: 0x8D/255.0) :
                // Pink games
                deck.type == .whatsMySecret || deck.type == .categoryClash ? Color(red: 0xFF/255.0, green: 0xB5/255.0, blue: 0xEF/255.0) :
                // Yellow game
                deck.type == .wouldYouRather ? Color(red: 0xFE/255.0, green: 0xFE/255.0, blue: 0xAC/255.0) :
                // Orange game
                deck.type == .storyChain ? Color(red: 0xFE/255.0, green: 0xB1/255.0, blue: 0x87/255.0) :
                // White background games
                deck.type == .tapDuel || deck.type == .spinTheBottle || deck.type == .bluffCall ? Color.white :
                Color.cardBackground
            )
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: Color.cardShadowColor, radius: 12, x: 0, y: 6)
            .rotation3DEffect(
                .degrees(flipDegrees + 180),
                axis: (x: 0, y: -1, z: 0)
            )
            .opacity(showingFront ? 0 : 1)
            .zIndex(showingFront ? 0 : 1)
            
            // Front of card (image) - uses exact image aspect ratio
            Image(deck.imageName)
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .aspectRatio(imageAspectRatio, contentMode: .fit)
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.cardShadowColor, radius: 12, x: 0, y: 6)
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
    let onTap: () -> Void
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @State private var isPressed = false
    
    // Card dimensions based on actual image ratio (420 x 577)
    private let imageAspectRatio: CGFloat = 420.0 / 577.0
    private var tileWidth: CGFloat {
        (UIScreen.main.bounds.width - 80 - 16) / 2
    }
    private var tileHeight: CGFloat {
        tileWidth / imageAspectRatio
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
    
    var body: some View {
        ZStack {
            // Adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
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
                .padding(.horizontal, 40)
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
                    .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
                    .padding(.bottom, 20)
                
                Spacer()
                
                // Deck title
                Text(deck.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 16)
                
                Text(deck.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                
                Spacer()
                
                // Play button - handle all game types
                if deck.type == .neverHaveIEver || deck.type == .truthOrDare || deck.type == .wouldYouRather || deck.type == .mostLikelyTo || deck.type == .popCultureTrivia || deck.type == .historyTrivia || deck.type == .scienceTrivia || deck.type == .sportsTrivia || deck.type == .movieTrivia || deck.type == .musicTrivia || deck.type == .truthOrDrink || deck.type == .categoryClash || deck.type == .bluffCall || deck.type == .whatsMySecret || deck.type == .actItOut {
                        PrimaryButton(title: "Play") {
                            // Navigate first, then dismiss overlay after navigation completes
                            navigateToCategorySelection = deck
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
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
                        .padding(.horizontal, 40)
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
                        .padding(.horizontal, 40)
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
                        .padding(.horizontal, 40)
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
                        .padding(.horizontal, 40)
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
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else if deck.type == .riddleMeThis {
                        PrimaryButton(title: "Play") {
                            // Dismiss overlay immediately, then navigate
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToRiddleMeThisSetup = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
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
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else if deck.type == .quickfireCouples {
                        PrimaryButton(title: "Play") {
                            // Dismiss overlay immediately, then navigate
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToQuickfireCouplesSetup = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else if deck.type == .closerThanEver {
                        PrimaryButton(title: "Play") {
                            // Dismiss overlay immediately, then navigate
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToCloserThanEverSetup = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else if deck.type == .usAfterDark {
                        PrimaryButton(title: "Play") {
                            // Dismiss overlay immediately, then navigate
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToUsAfterDarkSetup = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else {
                        PrimaryButton(title: "Play") {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedDeck = nil
                            }
                        }
                        .padding(.horizontal, 40)
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

#Preview {
    NavigationView {
        Play2View()
    }
}
