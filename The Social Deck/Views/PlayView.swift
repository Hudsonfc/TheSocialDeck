//
//  PlayView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

// Temporary Category struct
struct GameCategory {
    let id = UUID()
    let title: String
    let decks: [Deck]
}

struct PlayView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var expandedDeck: Deck? = nil
    @State private var navigateToCategorySelection: Deck? = nil
    @State private var navigateToPlayView: Deck? = nil
    @State private var navigateToStoryChainSetup: Deck? = nil
    @State private var navigateToMemoryMasterSetup: Deck? = nil
    @State private var navigateToHotPotatoSetup: Deck? = nil
    @State private var navigateToRhymeTimeSetup: Deck? = nil
    @State private var navigateToTapDuelSetup: Deck? = nil
    @State private var navigateToRiddleMeThisSetup: Deck? = nil
    // Placeholder categories with decks
    let categories: [GameCategory] = [
        GameCategory(
            title: "The Social Deck Games",
            decks: [
                Deck(title: "Hot Potato", description: "Pass the phone quickly as the heat builds! The player holding it when time expires loses. Watch out for random perks that can help or hurt!", numberOfCards: 50, estimatedTime: "10-15 min", imageName: "HP artwork", type: .hotPotato, cards: [], availableCategories: []),
                Deck(title: "Rhyme Time", description: "Say a word that rhymes with the base word before time runs out! Repeat a rhyme or hesitate and you lose.", numberOfCards: 40, estimatedTime: "10-15 min", imageName: "RT artwork", type: .rhymeTime, cards: allRhymeTimeCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "Tap Duel", description: "Fast head-to-head reaction game. Wait for GO, then tap first to win! Tap too early and you lose.", numberOfCards: 999, estimatedTime: "2-5 min", imageName: "TD artwork", type: .tapDuel, cards: [], availableCategories: []),
                Deck(title: "What's My Secret?", description: "One player gets a secret rule to follow. Can the group figure out what it is before time runs out?", numberOfCards: 75, estimatedTime: "5-10 min", imageName: "WMS artwork", type: .whatsMySecret, cards: allWhatsMySecretCards, availableCategories: ["Party", "Wild", "Social", "Actions", "Behavior"]),
                Deck(title: "Riddle Me This", description: "Solve riddles quickly! The first player to say the correct answer wins the round. Wrong answers lock you out.", numberOfCards: 71, estimatedTime: "5-10 min", imageName: "RMT artwork", type: .riddleMeThis, cards: allRiddleMeThisCards, availableCategories: [])
            ]
        ),
        GameCategory(
            title: "Classic Games",
            decks: [
                Deck(
                    title: "Never Have I Ever",
                    description: "Reveal your wildest experiences and learn about your friends.",
                    numberOfCards: 330,
                    estimatedTime: "30-45 min",
                    imageName: "NHIE artwork",
                    type: .neverHaveIEver,
                    cards: allNHIECards,
                    availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
                ),
                Deck(
                    title: "Truth or Dare",
                    description: "Choose truth or dare and see where the night takes you.",
                    numberOfCards: 330,
                    estimatedTime: "30-45 min",
                    imageName: "TOD artwork",
                    type: .truthOrDare,
                    cards: allTORCards,
                    availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
                ),
                Deck(
                    title: "Would You Rather",
                    description: "Make tough choices and discover what your friends prefer.",
                    numberOfCards: 330,
                    estimatedTime: "30-45 min",
                    imageName: "WYR artwork",
                    type: .wouldYouRather,
                    cards: allWYRCards,
                    availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"]
                ),
                Deck(title: "Most Likely To", description: "Find out who's most likely to do crazy things.", numberOfCards: 330, estimatedTime: "30-45 min", imageName: "MLT artwork", type: .mostLikelyTo, cards: allMLTCards, availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"])
            ]
        ),
        GameCategory(
            title: "Trivia Games",
            decks: [
                Deck(title: "Pop Culture Trivia", description: "Test your knowledge of movies, music, and celebrities.", numberOfCards: 1200, estimatedTime: "10-15 min", imageName: "Pop Culture Art", type: .popCultureTrivia, cards: allPopCultureTriviaCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "History Trivia", description: "Challenge yourself with historical facts and events.", numberOfCards: 620, estimatedTime: "10-15 min", imageName: "History Art", type: .historyTrivia, cards: allHistoryTriviaCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "Science Trivia", description: "Explore the world of science and discovery.", numberOfCards: 640, estimatedTime: "10-15 min", imageName: "Science Art", type: .scienceTrivia, cards: allScienceTriviaCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "Sports Trivia", description: "Show off your sports knowledge.", numberOfCards: 920, estimatedTime: "10-15 min", imageName: "Sports Art", type: .sportsTrivia, cards: allSportsTriviaCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "Movie Trivia", description: "Test your movie knowledge with film questions.", numberOfCards: 600, estimatedTime: "10-15 min", imageName: "Movies Art", type: .movieTrivia, cards: allMovieTriviaCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "Music Trivia", description: "Guess songs, artists, and music facts.", numberOfCards: 600, estimatedTime: "10-15 min", imageName: "Music Art", type: .musicTrivia, cards: allMusicTriviaCards, availableCategories: ["Easy", "Medium", "Hard"])
            ]
        ),
        GameCategory(
            title: "Party Games",
            decks: [
                Deck(title: "Act Natural", description: "One player doesn't know the secret word — can they blend in and figure it out before getting caught?", numberOfCards: 150, estimatedTime: "10-20 min", imageName: "AN 2.0", type: .actNatural, cards: [], availableCategories: []),
                Deck(title: "Truth or Drink", description: "A question appears on the screen — answer honestly or take a drink.", numberOfCards: 480, estimatedTime: "15-20 min", imageName: "TOD artwork 2", type: .truthOrDrink, cards: allTruthOrDrinkCards, availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends", "Work", "Family"]),
                Deck(title: "Category Clash", description: "The phone shows a category (like \"types of beers\" or \"things that are red\"). Players take turns naming something that fits. You hesitate, repeat an answer, or freeze? You drink. The pace gets faster each round, turning it into a hilarious pressure game.", numberOfCards: 250, estimatedTime: "15-20 min", imageName: "CC artwork", type: .categoryClash, cards: allCategoryClashCards, availableCategories: ["Food & Drink", "Pop Culture", "General", "Sports & Activities", "Animals & Nature"]),
                Deck(title: "Spin the Bottle", description: "Tap to spin and let the bottle decide everyone's fate. No strategy, no mercy, just pure chaos. If it points at you… well, take it up with the bottle.", numberOfCards: 40, estimatedTime: "20-30 min", imageName: "STB artwork", type: .spinTheBottle, cards: [], availableCategories: []),
                Deck(title: "Story Chain", description: "Add one sentence to continue the story. Pass the phone and watch the chaos unfold.", numberOfCards: 145, estimatedTime: "15-25 min", imageName: "SC artwork", type: .storyChain, cards: allStoryChainCards, availableCategories: []),
                Deck(title: "Memory Master", description: "A timed card-matching game. Flip cards to find pairs and clear the board as fast as possible!", numberOfCards: 55, estimatedTime: "5-10 min", imageName: "MM artwork", type: .memoryMaster, cards: [], availableCategories: []),
                Deck(title: "Bluff Call", description: "One player sees a prompt and must convince the group their answer is true. The group decides whether to believe them or call the bluff. If the group calls correctly, the bluffer drinks extra; if wrong, everyone who doubted drinks.", numberOfCards: 300, estimatedTime: "15-20 min", imageName: "BC artwork", type: .bluffCall, cards: allBluffCallCards, availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"])
            ]
        )
    ]
    
    // Get all favorite decks
    private var favoriteDecks: [Deck] {
        var allDecks: [Deck] = []
        for category in categories {
            allDecks.append(contentsOf: category.decks)
        }
        return allDecks.filter { favoritesManager.isFavorite($0.type) }
    }
    
    // Helper computed properties to break up complex expressions
    @ViewBuilder
    private var categorySelectionDestination: some View {
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
    
    @ViewBuilder
    private var categorySelectionView: some View {
        if let deck = navigateToCategorySelection {
            switch deck.type {
            case .neverHaveIEver:
                NHIECategorySelectionView(deck: deck)
            case .truthOrDare:
                TORCategorySelectionView(deck: deck)
            case .wouldYouRather:
                WYRCategorySelectionView(deck: deck)
            case .mostLikelyTo:
                MLTCategorySelectionView(deck: deck)
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
            case .truthOrDrink:
                TruthOrDrinkCategorySelectionView(deck: deck)
            case .categoryClash:
                CategoryClashCategorySelectionView(deck: deck)
            case .bluffCall:
                BluffCallCategorySelectionView(deck: deck)
            case .whatsMySecret:
                WhatsMySecretSetupView(deck: deck)
            case .actNatural:
                ActNaturalLoadingView(deck: deck)
            default:
                EmptyView()
            }
        }
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
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    // Favorites Section
                    if !favoriteDecks.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            // Favorites title with heart icon
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                Text("Favorites")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            }
                            .padding(.horizontal, 40)
                            
                            // Horizontal scroll of favorite deck cards
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(favoriteDecks) { deck in
                                        CardFlipView(deck: deck, expandedDeck: $expandedDeck)
                                    }
                                }
                                .padding(.horizontal, 40)
                            }
                        }
                    }
                    
                    ForEach(categories, id: \.id) { category in
                        VStack(alignment: .leading, spacing: 16) {
                            // Category title
                            Text(category.title)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .padding(.horizontal, 40)
                            
                            // Horizontal scroll of deck cards
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(category.decks) { deck in
                                        CardFlipView(deck: deck, expandedDeck: $expandedDeck)
                                    }
                                }
                                .padding(.horizontal, 40)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            
            // Expanded card overlay
            if let deck = expandedDeck {
                ExpandedDeckOverlay(deck: deck, expandedDeck: $expandedDeck, navigateToCategorySelection: $navigateToCategorySelection, navigateToPlayView: $navigateToPlayView, navigateToStoryChainSetup: $navigateToStoryChainSetup, navigateToMemoryMasterSetup: $navigateToMemoryMasterSetup, navigateToHotPotatoSetup: $navigateToHotPotatoSetup, navigateToRhymeTimeSetup: $navigateToRhymeTimeSetup, navigateToTapDuelSetup: $navigateToTapDuelSetup, navigateToRiddleMeThisSetup: $navigateToRiddleMeThisSetup)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(categorySelectionDestination)
        .background(playViewDestination)
        .background(storyChainSetupDestination)
        .background(memoryMasterSetupDestination)
        .background(hotPotatoSetupDestination)
        .background(rhymeTimeSetupDestination)
        .background(tapDuelSetupDestination)
        .background(riddleMeThisSetupDestination)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// Expanded Deck Overlay
struct ExpandedDeckOverlay: View {
    let deck: Deck
    @Binding var expandedDeck: Deck?
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
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Top bar with favorite and close buttons
                    HStack {
                        // Favorite button
                        Button(action: {
                            favoritesManager.toggleFavorite(deck.type)
                        }) {
                            Image(systemName: favoritesManager.isFavorite(deck.type) ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(favoritesManager.isFavorite(deck.type) ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .frame(width: 44, height: 44)
                                .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Close button
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .frame(width: 44, height: 44)
                                .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                    
                    // Deck artwork
                    Image(deck.imageName)
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFill()
                        .frame(width: 260, height: 260)
                        .clipped()
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    
                    // Deck title
                    Text(deck.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    
                    // Description
                    Text(deck.description)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)
                    
                    // Play button
                    if deck.type == .neverHaveIEver || deck.type == .truthOrDare || deck.type == .wouldYouRather || deck.type == .mostLikelyTo || deck.type == .popCultureTrivia || deck.type == .historyTrivia || deck.type == .scienceTrivia || deck.type == .sportsTrivia || deck.type == .movieTrivia || deck.type == .musicTrivia || deck.type == .truthOrDrink || deck.type == .categoryClash || deck.type == .bluffCall || deck.type == .whatsMySecret {
                        PrimaryButton(title: "Play") {
                            // Close overlay and navigate
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToCategorySelection = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    } else if deck.type == .spinTheBottle {
                        PrimaryButton(title: "Play") {
                            // Close overlay and navigate
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToPlayView = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    } else if deck.type == .storyChain {
                        PrimaryButton(title: "Play") {
                            // Close overlay and navigate
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToStoryChainSetup = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    } else if deck.type == .memoryMaster {
                        PrimaryButton(title: "Play") {
                            // Close overlay and navigate
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToMemoryMasterSetup = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    } else if deck.type == .hotPotato {
                        PrimaryButton(title: "Play") {
                            // Close overlay and navigate
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToHotPotatoSetup = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    } else if deck.type == .rhymeTime {
                        PrimaryButton(title: "Play") {
                            // Close overlay and navigate
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToRhymeTimeSetup = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    } else if deck.type == .tapDuel {
                        PrimaryButton(title: "Play") {
                            // Close overlay and navigate
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToTapDuelSetup = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    } else if deck.type == .whatsMySecret {
                        PrimaryButton(title: "Play") {
                            // Close overlay and navigate directly to setup (no category selection)
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToCategorySelection = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    } else if deck.type == .riddleMeThis {
                        PrimaryButton(title: "Play") {
                            // Close overlay and navigate
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToRiddleMeThisSetup = deck
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    } else {
                        PrimaryButton(title: "Play") {
                            print("Play tapped for: \(deck.title)")
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
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
        PlayView()
    }
}
