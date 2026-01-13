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
    @State private var navigateToHotPotatoSetup: Deck? = nil
    @State private var navigateToRhymeTimeSetup: Deck? = nil
    @State private var navigateToTapDuelSetup: Deck? = nil
    @State private var navigateToRiddleMeThisSetup: Deck? = nil
    @State private var cardFlippedStates: [Bool] = Array(repeating: false, count: 10) // Max 10 cards per category
    @State private var cardOffset: CGFloat = 0
    @State private var isDragging = false
    @AppStorage("hasSeenWelcomeView") private var hasSeenWelcomeView: Bool = false
    @State private var showWelcomeView: Bool = false
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
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
            title: "Hot Potato",
            description: "Pass the phone quickly as the heat builds! Random timers create chaos as players frantically pass the device. Watch out for random perks and penalties! The player holding it when time expires loses. Fast-paced and hilarious!",
            numberOfCards: 50,
            estimatedTime: "10-15 min",
            imageName: "HP 2.0",
            type: .hotPotato,
            cards: [],
            availableCategories: []
        ),
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
            description: "Fast-paced \"this or that\" choices for couples. Answer instantly to reveal preferences and chemistry. 200+ questions included.",
            numberOfCards: 200,
            estimatedTime: "15-25 min",
            imageName: "Quickfire Couples",
            type: .quickfireCouples,
            cards: allQuickfireCouplesCards,
            availableCategories: []
        ),
        Deck(
            title: "Closer Than Ever",
            description: "Meaningful questions designed to deepen connection and strengthen emotional bonds. Explore love languages, shared memories, values, and future dreams through thoughtful conversation. 150+ questions included.",
            numberOfCards: 200,
            estimatedTime: "30-45 min",
            imageName: "Closer than ever",
            type: .closerThanEver,
            cards: allCloserThanEverCards,
            availableCategories: []
        ),
        Deck(
            title: "Us After Dark",
            description: "A deeper, intimate couples game focused on honesty, curiosity, and emotional closeness. Questions explore desires, boundaries, memories, and what makes your connection special. 200+ intimate questions included.",
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
    
    
    // Filtered decks based on search
    var filteredDecks: [Deck] {
        if searchText.isEmpty {
            return []
        }
        let searchLower = searchText.lowercased()
        return allDecks.filter { deck in
            deck.title.lowercased().contains(searchLower) ||
            deck.description.lowercased().contains(searchLower)
        }
    }
    
    // Current decks based on selected category or search
    var currentDecks: [Deck] {
        if !searchText.isEmpty {
            return filteredDecks
        }
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
                // Search Bar
                HStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondaryText)
                        
                        TextField("Search games...", text: $searchText)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.primaryText)
                            .onChange(of: searchText) { oldValue, newValue in
                                withAnimation {
                                    currentCardIndex = 0
                                    cardOffset = 0
                                    cardFlippedStates = Array(repeating: false, count: 10)
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                withAnimation {
                                    searchText = ""
                                    currentCardIndex = 0
                                    cardOffset = 0
                                }
                                HapticManager.shared.lightImpact()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.secondaryText)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.secondaryBackground)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Category Tabs (hidden when searching)
                if searchText.isEmpty {
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
                                            // Reset flipped states when switching category
                                            cardFlippedStates = Array(repeating: false, count: 10)
                                        }
                                        HapticManager.shared.lightImpact()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: categories)
                    .padding(.bottom, 16)
                } else {
                    // Search results count
                    if !filteredDecks.isEmpty {
                        Text("\(filteredDecks.count) game\(filteredDecks.count == 1 ? "" : "s") found")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                .padding(.bottom, 16)
                    }
                }
                
                // Content area - Card view or Grid view
                if isGridView {
                    // Grid View - Show all games at once
                    ScrollView(.vertical, showsIndicators: false) {
                        // Empty state for search
                        if !searchText.isEmpty && filteredDecks.isEmpty {
                            VStack(spacing: 24) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50, weight: .light))
                                    .foregroundColor(.tertiaryText)
                                
                                VStack(spacing: 8) {
                                    Text("No Games Found")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    
                                    Text("Try searching with different keywords")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondaryText)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else if !currentDecks.isEmpty {
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
                        // Empty state for search
                        if !searchText.isEmpty && filteredDecks.isEmpty {
                            VStack(spacing: 24) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50, weight: .light))
                                    .foregroundColor(.tertiaryText)
                                
                                VStack(spacing: 8) {
                                    Text("No Games Found")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.primaryText)
                                    
                                    Text("Try searching with different keywords")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondaryText)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        // Current card
                        else if !currentDecks.isEmpty && currentCardIndex < currentDecks.count {
                            GameCardView(
                                deck: currentDecks[currentCardIndex],
                                isFlipped: $cardFlippedStates[currentCardIndex],
                                onSelect: {
                                    // Reset flip state before navigating
                                    cardFlippedStates[currentCardIndex] = false
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
                                            cardFlippedStates[currentCardIndex] = false
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
                    
                // Placeholder text under cards (hidden when searching or grid view)
                if searchText.isEmpty && !isGridView {
                    Text("Tap card to flip and see details")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.tertiaryText)
                            .padding(.top, 16)
                    }
                    
                    // Card Counter (hidden when searching with no results or grid view)
                    if !currentDecks.isEmpty && !(!searchText.isEmpty && filteredDecks.isEmpty) && !isGridView {
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
                destination: playViewDestination,
                isActive: Binding(
                    get: { navigateToPlayView != nil },
                    set: { if !$0 { navigateToPlayView = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: storyChainSetupDestination,
                isActive: Binding(
                    get: { navigateToStoryChainSetup != nil },
                    set: { if !$0 { navigateToStoryChainSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: memoryMasterSetupDestination,
                isActive: Binding(
                    get: { navigateToMemoryMasterSetup != nil },
                    set: { if !$0 { navigateToMemoryMasterSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: hotPotatoSetupDestination,
                isActive: Binding(
                    get: { navigateToHotPotatoSetup != nil },
                    set: { if !$0 { navigateToHotPotatoSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: rhymeTimeSetupDestination,
                isActive: Binding(
                    get: { navigateToRhymeTimeSetup != nil },
                    set: { if !$0 { navigateToRhymeTimeSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: tapDuelSetupDestination,
                isActive: Binding(
                    get: { navigateToTapDuelSetup != nil },
                    set: { if !$0 { navigateToTapDuelSetup = nil } }
                )
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: riddleMeThisSetupDestination,
                isActive: Binding(
                    get: { navigateToRiddleMeThisSetup != nil },
                    set: { if !$0 { navigateToRiddleMeThisSetup = nil } }
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
                    navigateToHotPotatoSetup: $navigateToHotPotatoSetup,
                    navigateToRhymeTimeSetup: $navigateToRhymeTimeSetup,
                    navigateToTapDuelSetup: $navigateToTapDuelSetup,
                    navigateToRiddleMeThisSetup: $navigateToRiddleMeThisSetup
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
                Button(action: {
                    HapticManager.shared.lightImpact()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isGridView.toggle()
                        // Reset card index when switching layouts
                        if !isGridView {
                            currentCardIndex = 0
                            cardOffset = 0
                            cardFlippedStates = Array(repeating: false, count: 10)
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
    private var playViewDestination: some View {
        NavigationLink(
            destination: playView,
            isActive: Binding(
                get: { navigateToPlayView != nil },
                set: { if !$0 { navigateToPlayView = nil } }
            )
        ) {
            EmptyView()
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
    private var storyChainSetupDestination: some View {
        NavigationLink(
            destination: storyChainSetupView,
            isActive: Binding(
                get: { navigateToStoryChainSetup != nil },
                set: { if !$0 { navigateToStoryChainSetup = nil } }
            )
        ) {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var storyChainSetupView: some View {
        if let deck = navigateToStoryChainSetup {
            StoryChainSetupView(deck: deck)
        }
    }
    
    @ViewBuilder
    private var memoryMasterSetupDestination: some View {
        NavigationLink(
            destination: memoryMasterSetupView,
            isActive: Binding(
                get: { navigateToMemoryMasterSetup != nil },
                set: { if !$0 { navigateToMemoryMasterSetup = nil } }
            )
        ) {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var memoryMasterSetupView: some View {
        if let deck = navigateToMemoryMasterSetup {
            MemoryMasterSetupView(deck: deck)
        }
    }
    
    @ViewBuilder
    private var hotPotatoSetupDestination: some View {
        NavigationLink(
            destination: hotPotatoSetupView,
            isActive: Binding(
                get: { navigateToHotPotatoSetup != nil },
                set: { if !$0 { navigateToHotPotatoSetup = nil } }
            )
        ) {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var hotPotatoSetupView: some View {
        if let deck = navigateToHotPotatoSetup {
            HotPotatoSetupView(deck: deck)
        }
    }
    
    @ViewBuilder
    private var rhymeTimeSetupDestination: some View {
        NavigationLink(
            destination: rhymeTimeSetupView,
            isActive: Binding(
                get: { navigateToRhymeTimeSetup != nil },
                set: { if !$0 { navigateToRhymeTimeSetup = nil } }
            )
        ) {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var rhymeTimeSetupView: some View {
        if let deck = navigateToRhymeTimeSetup {
            RhymeTimeSetupView(deck: deck)
        }
    }
    
    @ViewBuilder
    private var tapDuelSetupDestination: some View {
        NavigationLink(
            destination: tapDuelSetupView,
            isActive: Binding(
                get: { navigateToTapDuelSetup != nil },
                set: { if !$0 { navigateToTapDuelSetup = nil } }
            )
        ) {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var tapDuelSetupView: some View {
        if let deck = navigateToTapDuelSetup {
            TapDuelSetupView(deck: deck)
        }
    }
    
    @ViewBuilder
    private var riddleMeThisSetupDestination: some View {
        NavigationLink(
            destination: riddleMeThisSetupView,
            isActive: Binding(
                get: { navigateToRiddleMeThisSetup != nil },
                set: { if !$0 { navigateToRiddleMeThisSetup = nil } }
            )
        ) {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var riddleMeThisSetupView: some View {
        if let deck = navigateToRiddleMeThisSetup {
            RiddleMeThisSetupView(deck: deck)
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
            case .hotPotato:
                HotPotatoSetupView(deck: deck)
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
                ActNaturalLoadingView(deck: deck)
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
    
    var body: some View {
        ZStack {
            // Back of card (description and select button) - behind front
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text(deck.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                    
                    // Description with question count highlighted for couples games
                    if deck.type == .quickfireCouples || deck.type == .closerThanEver || deck.type == .usAfterDark {
                        let parts = deck.description.components(separatedBy: ". ")
                        let mainDescription = parts.dropLast().joined(separator: ". ")
                        let questionCount = parts.last ?? ""
                        
                        VStack(spacing: 4) {
                            if !mainDescription.isEmpty {
                                Text(mainDescription + ".")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            Text(questionCount)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color.buttonBackground)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                    } else {
                        Text(deck.description)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 24)
                    }
                    
                    // Estimated time on back of card
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondaryText)
                        Text(deck.estimatedTime)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                    }
                    .padding(.top, 4)
                    
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onSelect()
                    }) {
                        Text("Select")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 180)
                            .padding(.vertical, 14)
                            .background(Color.buttonBackground)
                            .cornerRadius(14)
                    }
                    .padding(.top, 12)
                    
                    Spacer()
                }
                
                // Favorite button - top right
                FavoriteButton(deck: deck)
                .padding(16)
            }
            .frame(width: cardWidth, height: cardHeight)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
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
                
                // Game stats - Estimated time only
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondaryText)
                    Text(deck.estimatedTime)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
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
    @Binding var navigateToHotPotatoSetup: Deck?
    @Binding var navigateToRhymeTimeSetup: Deck?
    @Binding var navigateToTapDuelSetup: Deck?
    @Binding var navigateToRiddleMeThisSetup: Deck?
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
                    .padding(.horizontal, 40)
                    .padding(.bottom, 16)
                
                // Description with question count highlighted for couples games
                if deck.type == .quickfireCouples || deck.type == .closerThanEver || deck.type == .usAfterDark {
                    let parts = deck.description.components(separatedBy: ". ")
                    let mainDescription = parts.dropLast().joined(separator: ". ")
                    let questionCount = parts.last ?? ""
                    
                    VStack(spacing: 6) {
                        if !mainDescription.isEmpty {
                            Text(mainDescription + ".")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                        }
                        Text(questionCount)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color.buttonBackground)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                } else {
                    Text(deck.description)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)
                }
                
                // Game stats - Estimated time only
                VStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondaryText)
                    Text(deck.estimatedTime)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                    Text("Estimated Time")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                .padding(.bottom, 32)
                
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
                            // Navigate first, then dismiss overlay after navigation completes
                            navigateToStoryChainSetup = deck
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else if deck.type == .memoryMaster {
                        PrimaryButton(title: "Play") {
                            // Navigate first, then dismiss overlay after navigation completes
                            navigateToMemoryMasterSetup = deck
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else if deck.type == .hotPotato {
                        PrimaryButton(title: "Play") {
                            // Navigate first, then dismiss overlay after navigation completes
                            navigateToHotPotatoSetup = deck
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else if deck.type == .rhymeTime {
                        PrimaryButton(title: "Play") {
                            // Navigate first, then dismiss overlay after navigation completes
                            navigateToRhymeTimeSetup = deck
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else if deck.type == .tapDuel {
                        PrimaryButton(title: "Play") {
                            // Navigate first, then dismiss overlay after navigation completes
                            navigateToTapDuelSetup = deck
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else if deck.type == .riddleMeThis {
                        PrimaryButton(title: "Play") {
                            // Navigate first, then dismiss overlay after navigation completes
                            navigateToRiddleMeThisSetup = deck
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDeck = nil
                                }
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
