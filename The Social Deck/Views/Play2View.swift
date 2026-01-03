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
    @State private var cardFlippedStates: [Bool] = Array(repeating: false, count: 10) // Max 10 cards per category
    @State private var cardOffset: CGFloat = 0
    @State private var isDragging = false
    
    // All category names (Favorites shown dynamically when items exist)
    var categories: [String] {
        var cats = ["Classic Games", "Social Deck Games", "Trivia", "Party Games"]
        if !favoriteDecks.isEmpty {
            cats.insert("Favorites", at: 0)
        }
        return cats
    }
    
    // Get all decks
    private var allDecks: [Deck] {
        classicGamesDecks + socialDeckGamesDecks + triviaGamesDecks + partyGamesDecks
    }
    
    // Get favorite decks
    private var favoriteDecks: [Deck] {
        allDecks.filter { favoritesManager.isFavorite($0.type) }
    }
    
    // Classic Games decks with 2.0 artwork
    let classicGamesDecks: [Deck] = [
        Deck(
            title: "Never Have I Ever",
            description: "Reveal your wildest experiences and learn about your friends.",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "NHIE 2.0",
            type: .neverHaveIEver,
            cards: allNHIECards,
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
        ),
        Deck(
            title: "Truth or Dare",
            description: "Choose truth or dare and see where the night takes you.",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "TOD 2.0",
            type: .truthOrDare,
            cards: allTORCards,
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
        ),
        Deck(
            title: "Would You Rather",
            description: "Make tough choices and discover what your friends prefer.",
            numberOfCards: 330,
            estimatedTime: "30-45 min",
            imageName: "WYR 2.0",
            type: .wouldYouRather,
            cards: allWYRCards,
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
        ),
        Deck(
            title: "Most Likely To",
            description: "Find out who's most likely to do crazy things.",
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
            description: "Pass the phone quickly as the heat builds! The player holding it when time expires loses.",
            numberOfCards: 50,
            estimatedTime: "10-15 min",
            imageName: "HP 2.0",
            type: .hotPotato,
            cards: [],
            availableCategories: []
        ),
        Deck(
            title: "Rhyme Time",
            description: "Say a word that rhymes with the base word before time runs out!",
            numberOfCards: 40,
            estimatedTime: "10-15 min",
            imageName: "RT 2.0",
            type: .rhymeTime,
            cards: allRhymeTimeCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "Tap Duel",
            description: "Fast head-to-head reaction game. Wait for GO, then tap first to win!",
            numberOfCards: 999,
            estimatedTime: "2-5 min",
            imageName: "TD 2.0",
            type: .tapDuel,
            cards: [],
            availableCategories: []
        ),
        Deck(
            title: "What's My Secret?",
            description: "One player gets a secret rule to follow. Can the group figure out what it is?",
            numberOfCards: 75,
            estimatedTime: "5-10 min",
            imageName: "WMS 2.0",
            type: .whatsMySecret,
            cards: allWhatsMySecretCards,
            availableCategories: ["Party", "Wild", "Social", "Actions", "Behavior"]
        ),
        Deck(
            title: "Riddle Me This",
            description: "Solve riddles quickly! The first player to say the correct answer wins the round.",
            numberOfCards: 71,
            estimatedTime: "5-10 min",
            imageName: "RMT 2.0",
            type: .riddleMeThis,
            cards: allRiddleMeThisCards,
            availableCategories: []
        ),
        Deck(
            title: "Act It Out",
            description: "Act out prompts silently while others guess! First to guess correctly wins the round.",
            numberOfCards: 300,
            estimatedTime: "15-30 min",
            imageName: "AIO 2.0",
            type: .actItOut,
            cards: allActItOutCards,
            availableCategories: ["Actions & Verbs", "Animals", "Emotions & Expressions", "Daily Activities", "Sports & Activities", "Objects & Tools", "Food & Cooking", "Famous Concepts", "Movie Genres", "Nature & Weather"]
        )
    ]
    
    // Trivia Games decks with 2.0 artwork
    let triviaGamesDecks: [Deck] = [
        Deck(
            title: "Pop Culture Trivia",
            description: "Test your knowledge of movies, music, and celebrities.",
            numberOfCards: 1200,
            estimatedTime: "10-15 min",
            imageName: "pop culture 2.0",
            type: .popCultureTrivia,
            cards: allPopCultureTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "History Trivia",
            description: "Challenge yourself with historical facts and events.",
            numberOfCards: 620,
            estimatedTime: "10-15 min",
            imageName: "History 2.0",
            type: .historyTrivia,
            cards: allHistoryTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "Science Trivia",
            description: "Explore the world of science and discovery.",
            numberOfCards: 640,
            estimatedTime: "10-15 min",
            imageName: "science 2.0",
            type: .scienceTrivia,
            cards: allScienceTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "Sports Trivia",
            description: "Show off your sports knowledge.",
            numberOfCards: 920,
            estimatedTime: "10-15 min",
            imageName: "sports 2.0",
            type: .sportsTrivia,
            cards: allSportsTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "Movie Trivia",
            description: "Test your movie knowledge with film questions.",
            numberOfCards: 600,
            estimatedTime: "10-15 min",
            imageName: "movies 2.0",
            type: .movieTrivia,
            cards: allMovieTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        ),
        Deck(
            title: "Music Trivia",
            description: "Guess songs, artists, and music facts.",
            numberOfCards: 600,
            estimatedTime: "10-15 min",
            imageName: "music 2.0",
            type: .musicTrivia,
            cards: allMusicTriviaCards,
            availableCategories: ["Easy", "Medium", "Hard"]
        )
    ]
    
    // Party Games decks with 2.0 artwork (excluding Truth or Drink)
    let partyGamesDecks: [Deck] = [
        Deck(
            title: "Act Natural",
            description: "One player doesn't know the secret word — can they blend in and figure it out before getting caught?",
            numberOfCards: 150,
            estimatedTime: "10-20 min",
            imageName: "AN 2.0",
            type: .actNatural,
            cards: [],
            availableCategories: []
        ),
        Deck(
            title: "Category Clash",
            description: "Name items in a category before time runs out! Hesitate or repeat an answer and you're out.",
            numberOfCards: 250,
            estimatedTime: "15-20 min",
            imageName: "CC 2.0",
            type: .categoryClash,
            cards: allCategoryClashCards,
            availableCategories: ["Food & Drink", "Pop Culture", "General", "Sports & Activities", "Animals & Nature"]
        ),
        Deck(
            title: "Spin the Bottle",
            description: "Tap to spin and let the bottle decide everyone's fate. No strategy, no mercy, just pure chaos.",
            numberOfCards: 40,
            estimatedTime: "20-30 min",
            imageName: "STB 2.0",
            type: .spinTheBottle,
            cards: [],
            availableCategories: []
        ),
        Deck(
            title: "Story Chain",
            description: "Add one sentence to continue the story. Pass the phone and watch the chaos unfold.",
            numberOfCards: 145,
            estimatedTime: "15-25 min",
            imageName: "SC 2.0",
            type: .storyChain,
            cards: allStoryChainCards,
            availableCategories: []
        ),
        Deck(
            title: "Memory Master",
            description: "A timed card-matching game. Flip cards to find pairs and clear the board as fast as possible!",
            numberOfCards: 55,
            estimatedTime: "5-10 min",
            imageName: "MM 2.0",
            type: .memoryMaster,
            cards: [],
            availableCategories: []
        ),
        Deck(
            title: "Bluff Call",
            description: "Convince the group your answer is true, or call their bluff!",
            numberOfCards: 300,
            estimatedTime: "15-20 min",
            imageName: "BC 2.0",
            type: .bluffCall,
            cards: allBluffCallCards,
            availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
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
        case "Trivia":
            return triviaGamesDecks
        case "Party Games":
            return partyGamesDecks
        default:
            return classicGamesDecks
        }
    }
    
    var body: some View {
        ZStack {
            // White background
            Color.white
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
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Card Deck - Simple horizontal scroll with current card only
                ZStack {
                    // Current card
                    if currentCardIndex < currentDecks.count {
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
                
                // Placeholder text under cards
                Text("Tap card to flip and see details")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0xB0/255.0, green: 0xB0/255.0, blue: 0xB0/255.0))
                    .padding(.top, 16)
                
                // Card Counter
                HStack(spacing: 8) {
                    ForEach(0..<currentDecks.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentCardIndex ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            
            // Navigation link for category selection
            NavigationLink(
                destination: categorySelectionView,
                isActive: Binding(
                    get: { navigateToCategorySelection != nil },
                    set: { if !$0 { navigateToCategorySelection = nil } }
                )
            ) {
                EmptyView()
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
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
            // Party Games
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
                .foregroundColor(isSelected ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            
            Rectangle()
                .fill(isSelected ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color.clear)
                .frame(height: 3)
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
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .multilineTextAlignment(.center)
                    
                    Text(deck.description)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                    
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onSelect()
                    }) {
                        Text("Select")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 180)
                            .padding(.vertical, 14)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(14)
                    }
                    .padding(.top, 12)
                    
                    Spacer()
                }
                
                // Favorite button - top right
                Button(action: {
                    favoritesManager.toggleFavorite(deck.type)
                }) {
                    Image(systemName: favoritesManager.isFavorite(deck.type) ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(favoritesManager.isFavorite(deck.type) ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .frame(width: 40, height: 40)
                        .background(Color(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0))
                        .clipShape(Circle())
                }
                .padding(16)
            }
            .frame(width: cardWidth, height: cardHeight)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
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
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
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

#Preview {
    NavigationView {
        Play2View()
    }
}
