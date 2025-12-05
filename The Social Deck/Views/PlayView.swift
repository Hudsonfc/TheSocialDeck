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
    // Placeholder categories with decks
    let categories: [GameCategory] = [
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
            title: "Drinking Games",
            decks: [
                Deck(title: "Kings Cup", description: "The classic card game that gets everyone involved.", numberOfCards: 52, estimatedTime: "20-30 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: []),
                Deck(title: "Never Have I Ever", description: "Reveal secrets and take drinks along the way.", numberOfCards: 50, estimatedTime: "10-15 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: []),
                Deck(title: "Most Likely To", description: "Drink when you're most likely to do something.", numberOfCards: 45, estimatedTime: "10-15 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: []),
                Deck(title: "Truth or Drink", description: "Answer truthfully or take a drink.", numberOfCards: 60, estimatedTime: "15-20 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: []),
                Deck(title: "Drunk Jenga", description: "Pull blocks and follow the drinking rules.", numberOfCards: 54, estimatedTime: "20-30 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: [])
            ]
        ),
        GameCategory(
            title: "Relationship Games",
            decks: [
                Deck(title: "Couples Questions", description: "Deepen your connection with meaningful questions.", numberOfCards: 50, estimatedTime: "10-15 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: []),
                Deck(title: "Deep Questions", description: "Explore meaningful topics and get to know each other.", numberOfCards: 40, estimatedTime: "10-15 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: []),
                Deck(title: "Relationship Goals", description: "Discuss your relationship aspirations and dreams.", numberOfCards: 35, estimatedTime: "10-15 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: []),
                Deck(title: "Love Languages", description: "Discover how you and your partner express love.", numberOfCards: 30, estimatedTime: "5-10 min", imageName: "Art 1.4", type: .other, cards: [], availableCategories: [])
            ]
        )
    ]
    
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
                ExpandedDeckOverlay(deck: deck, expandedDeck: $expandedDeck, navigateToCategorySelection: $navigateToCategorySelection)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(
                destination: Group {
                    if let deck = navigateToCategorySelection {
                        if deck.type == .neverHaveIEver {
                            NHIECategorySelectionView(deck: deck)
                        } else if deck.type == .truthOrDare {
                            TORCategorySelectionView(deck: deck)
                        } else if deck.type == .wouldYouRather {
                            WYRCategorySelectionView(deck: deck)
                        } else if deck.type == .mostLikelyTo {
                            MLTCategorySelectionView(deck: deck)
                        } else if deck.type == .popCultureTrivia {
                            PopCultureTriviaCategorySelectionView(deck: deck)
                        } else if deck.type == .historyTrivia {
                            HistoryTriviaCategorySelectionView(deck: deck)
                        } else if deck.type == .scienceTrivia {
                            ScienceTriviaCategorySelectionView(deck: deck)
                        } else if deck.type == .sportsTrivia {
                            SportsTriviaCategorySelectionView(deck: deck)
                        } else if deck.type == .movieTrivia {
                            MovieTriviaCategorySelectionView(deck: deck)
                        } else if deck.type == .musicTrivia {
                            MusicTriviaCategorySelectionView(deck: deck)
                        }
                    }
                },
                isActive: Binding(
                    get: { navigateToCategorySelection != nil },
                    set: { if !$0 { navigateToCategorySelection = nil } }
                )
            ) {
                EmptyView()
            }
        )
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
                    if deck.type == .neverHaveIEver || deck.type == .truthOrDare || deck.type == .wouldYouRather || deck.type == .mostLikelyTo || deck.type == .popCultureTrivia || deck.type == .historyTrivia || deck.type == .scienceTrivia || deck.type == .sportsTrivia || deck.type == .movieTrivia || deck.type == .musicTrivia {
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
