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
    @State private var expandedDeck: Deck? = nil
    @State private var navigateToCategorySelection: Deck? = nil
    @State private var navigateToPlayView: Deck? = nil
    @State private var navigateToStoryChainSetup: Deck? = nil
    @State private var navigateToMemoryMasterSetup: Deck? = nil
    @State private var navigateToHotPotatoSetup: Deck? = nil
    @State private var navigateToRhymeTimeSetup: Deck? = nil
    // Placeholder categories with decks
    let categories: [GameCategory] = [
        GameCategory(
            title: "The Social Deck Games",
            decks: [
                Deck(title: "Hot Potato", description: "Pass the phone quickly as the heat builds! The player holding it when time expires loses. Watch out for random perks that can help or hurt!", numberOfCards: 50, estimatedTime: "10-15 min", imageName: "HP artwork", type: .hotPotato, cards: [], availableCategories: []),
                Deck(title: "Rhyme Time", description: "Say a word that rhymes with the base word before time runs out! Repeat a rhyme or hesitate and you lose.", numberOfCards: 40, estimatedTime: "10-15 min", imageName: "Art 1.4", type: .rhymeTime, cards: allRhymeTimeCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "What Would I Do?", description: "Describe a scenario. Others guess what you'd do. Wrong guessers drink.", numberOfCards: 35, estimatedTime: "10-15 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: []),
                Deck(title: "What's My Secret?", description: "Share a secret about yourself. Others guess if it's true. Wrong guessers drink.", numberOfCards: 30, estimatedTime: "5-10 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: []),
                Deck(title: "Riddle Me This", description: "Solve riddles to progress. Can't solve? Drink.", numberOfCards: 30, estimatedTime: "5-10 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: [])
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
                Deck(title: "Pop Culture Trivia", description: "Test your knowledge of movies, music, and celebrities.", numberOfCards: 20, estimatedTime: "10-15 min", imageName: "Pop Culture Art", type: .popCultureTrivia, cards: allPopCultureTriviaCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "History Trivia", description: "Challenge yourself with historical facts and events.", numberOfCards: 20, estimatedTime: "10-15 min", imageName: "History Art", type: .historyTrivia, cards: allHistoryTriviaCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "Science Trivia", description: "Explore the world of science and discovery.", numberOfCards: 20, estimatedTime: "10-15 min", imageName: "Science Art", type: .scienceTrivia, cards: allScienceTriviaCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "Sports Trivia", description: "Show off your sports knowledge.", numberOfCards: 20, estimatedTime: "10-15 min", imageName: "Sports Art", type: .sportsTrivia, cards: allSportsTriviaCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "Movie Trivia", description: "Test your movie knowledge with film questions.", numberOfCards: 20, estimatedTime: "10-15 min", imageName: "Movies Art", type: .movieTrivia, cards: allMovieTriviaCards, availableCategories: ["Easy", "Medium", "Hard"]),
                Deck(title: "Music Trivia", description: "Guess songs, artists, and music facts.", numberOfCards: 20, estimatedTime: "10-15 min", imageName: "Music Art", type: .musicTrivia, cards: allMusicTriviaCards, availableCategories: ["Easy", "Medium", "Hard"])
            ]
        ),
        GameCategory(
            title: "Party Games",
            decks: [
                Deck(title: "Truth or Drink", description: "A question appears on the screen — answer honestly or take a drink.", numberOfCards: 480, estimatedTime: "15-20 min", imageName: "TOD artwork 2", type: .truthOrDrink, cards: allTruthOrDrinkCards, availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends", "Work", "Family"]),
                Deck(title: "Category Clash", description: "The phone shows a category (like \"types of beers\" or \"things that are red\"). Players take turns naming something that fits. You hesitate, repeat an answer, or freeze? You drink. The pace gets faster each round, turning it into a hilarious pressure game.", numberOfCards: 250, estimatedTime: "15-20 min", imageName: "CC artwork", type: .categoryClash, cards: allCategoryClashCards, availableCategories: ["Food & Drink", "Pop Culture", "General", "Sports & Activities", "Animals & Nature"]),
                Deck(title: "Spin the Bottle", description: "Tap to spin and let the bottle decide everyone's fate. No strategy, no mercy, just pure chaos. If it points at you… well, take it up with the bottle.", numberOfCards: 40, estimatedTime: "20-30 min", imageName: "STB artwork", type: .spinTheBottle, cards: [], availableCategories: []),
                Deck(title: "Story Chain", description: "Add one sentence to continue the story. Pass the phone and watch the chaos unfold.", numberOfCards: 145, estimatedTime: "15-25 min", imageName: "SC artwork", type: .storyChain, cards: allStoryChainCards, availableCategories: []),
                Deck(title: "Memory Master", description: "A timed card-matching game. Flip cards to find pairs and clear the board as fast as possible!", numberOfCards: 55, estimatedTime: "5-10 min", imageName: "MM artwork", type: .memoryMaster, cards: [], availableCategories: []),
                Deck(title: "Bluff Call", description: "One player sees a prompt and must convince the group their answer is true. The group decides whether to believe them or call the bluff. If the group calls correctly, the bluffer drinks extra; if wrong, everyone who doubted drinks.", numberOfCards: 300, estimatedTime: "15-20 min", imageName: "BC artwork", type: .bluffCall, cards: allBluffCallCards, availableCategories: ["Party", "Wild", "Couples", "Teens", "Dirty", "Friends"])
            ]
        )
    ]
    
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
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
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
                ExpandedDeckOverlay(deck: deck, expandedDeck: $expandedDeck, navigateToCategorySelection: $navigateToCategorySelection, navigateToPlayView: $navigateToPlayView, navigateToStoryChainSetup: $navigateToStoryChainSetup, navigateToMemoryMasterSetup: $navigateToMemoryMasterSetup, navigateToHotPotatoSetup: $navigateToHotPotatoSetup, navigateToRhymeTimeSetup: $navigateToRhymeTimeSetup)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(categorySelectionDestination)
        .background(playViewDestination)
        .background(storyChainSetupDestination)
        .background(memoryMasterSetupDestination)
        .background(hotPotatoSetupDestination)
        .background(rhymeTimeSetupDestination)
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
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Close button - minimalist
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedDeck = nil
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
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
                    if deck.type == .neverHaveIEver || deck.type == .truthOrDare || deck.type == .wouldYouRather || deck.type == .mostLikelyTo || deck.type == .popCultureTrivia || deck.type == .historyTrivia || deck.type == .scienceTrivia || deck.type == .sportsTrivia || deck.type == .movieTrivia || deck.type == .musicTrivia || deck.type == .truthOrDrink || deck.type == .categoryClash || deck.type == .bluffCall {
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
