//
//  OnlineGameSelectionScreen.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

// Placeholder game model for online selection
struct OnlineGamePlaceholder: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let hasCategories: Bool
    let availableCategories: [String]
    
    static func == (lhs: OnlineGamePlaceholder, rhs: OnlineGamePlaceholder) -> Bool {
        lhs.id == rhs.id
    }
}

// Placeholder category for online games (similar to GameCategory)
struct OnlineGameCategory: Identifiable {
    let id = UUID()
    let title: String
    let games: [OnlineGamePlaceholder]
}

struct OnlineGameSelectionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    @State private var expandedGame: OnlineGamePlaceholder? = nil
    @State private var selectedGame: OnlineGamePlaceholder? = nil
    @State private var selectedCategory: String? = nil
    @State private var showCategorySelection = false
    @State private var navigateToRoom = false
    
    // Placeholder categories with games
    let categories: [OnlineGameCategory] = [
        OnlineGameCategory(
            title: "Multiplayer Games",
            games: [
                OnlineGamePlaceholder(
                    title: "Online Game 1",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: true,
                    availableCategories: ["Quick", "Standard", "Extended"]
                ),
                OnlineGamePlaceholder(
                    title: "Online Game 2",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: false,
                    availableCategories: []
                ),
                OnlineGamePlaceholder(
                    title: "Online Game 3",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: true,
                    availableCategories: ["Easy", "Medium", "Hard"]
                ),
                OnlineGamePlaceholder(
                    title: "Online Game 4",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: false,
                    availableCategories: []
                )
            ]
        ),
        OnlineGameCategory(
            title: "Coming Soon",
            games: [
                OnlineGamePlaceholder(
                    title: "Online Game 5",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: true,
                    availableCategories: ["Casual", "Competitive"]
                ),
                OnlineGamePlaceholder(
                    title: "Online Game 6",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: false,
                    availableCategories: []
                )
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
                            
                            // Horizontal scroll of game cards
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(category.games) { game in
                                        OnlineGameCardView(game: game, expandedGame: $expandedGame)
                                    }
                                }
                                .padding(.horizontal, 40)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            
            // Expanded game overlay
            if let game = expandedGame {
                ExpandedGameOverlay(
                    game: game,
                    expandedGame: $expandedGame,
                    selectedGame: $selectedGame,
                    selectedCategory: $selectedCategory,
                    showCategorySelection: $showCategorySelection
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
        .background(
            NavigationLink(
                destination: OnlineRoomView(),
                isActive: $navigateToRoom
            ) {
                EmptyView()
            }
        )
        .sheet(isPresented: $showCategorySelection) {
            if let game = selectedGame, game.hasCategories {
                OnlineCategorySelectionSheet(
                    game: game,
                    selectedCategory: $selectedCategory,
                    onSelect: { category in
                        selectedCategory = category
                        showCategorySelection = false
                        // TODO: Save game selection to room
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToRoom = true
                        }
                    }
                )
            }
        }
        .onChange(of: selectedGame) { oldValue, newValue in
            // If game selected without categories, navigate directly
            if let game = newValue, (!game.hasCategories || game.availableCategories.isEmpty) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    navigateToRoom = true
                }
            }
        }
    }
}

// MARK: - Online Game Card View (similar to CardFlipView)

struct OnlineGameCardView: View {
    let game: OnlineGamePlaceholder
    @Binding var expandedGame: OnlineGamePlaceholder?
    
    var body: some View {
        VStack(spacing: 8) {
            // Game artwork
            Image(game.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipped()
                .cornerRadius(12)
            
            // Game title
            Text(game.title)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 140)
        }
        .frame(width: 140, height: 180)
        .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
        .cornerRadius(16)
        .onTapGesture {
            expandCard()
        }
    }
    
    private func expandCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            expandedGame = game
        }
    }
}

// MARK: - Expanded Game Overlay (similar to ExpandedDeckOverlay)

struct ExpandedGameOverlay: View {
    let game: OnlineGamePlaceholder
    @Binding var expandedGame: OnlineGamePlaceholder?
    @Binding var selectedGame: OnlineGamePlaceholder?
    @Binding var selectedCategory: String?
    @Binding var showCategorySelection: Bool
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                expandedGame = nil
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
                    
                    // Game artwork
                    Image(game.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 260, height: 260)
                        .clipped()
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    
                    // Game title
                    Text(game.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    
                    // Description
                    Text(game.description)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)
                    
                    // Select button
                    PrimaryButton(title: "Select") {
                        // Close overlay and select game
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            expandedGame = nil
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            selectedGame = game
                            selectedCategory = nil
                            
                            // Show category selection if game has categories
                            if game.hasCategories && !game.availableCategories.isEmpty {
                                showCategorySelection = true
                            }
                            // If no categories, onChange will handle navigation
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
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

// MARK: - Online Category Selection Sheet

struct OnlineCategorySelectionSheet: View {
    let game: OnlineGamePlaceholder
    @Binding var selectedCategory: String?
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Game info
                        VStack(spacing: 8) {
                            Text(game.title)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Text("Select a category")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 8)
                        
                        // Category buttons
                        VStack(spacing: 12) {
                            ForEach(game.availableCategories, id: \.self) { category in
                                Button(action: {
                                    onSelect(category)
                                }) {
                                    HStack {
                                        Text(category)
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundColor(selectedCategory == category ? .white : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                        
                                        Spacer()
                                        
                                        if selectedCategory == category {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(selectedCategory == category ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                }
            }
        }
    }
}

// MARK: - Selected Game Display Card (for non-host players)

struct SelectedGameDisplayCard: View {
    let gameType: DeckType
    let category: String?
    
    private var gameTitle: String {
        switch gameType {
        case .neverHaveIEver: return "Never Have I Ever"
        case .truthOrDare: return "Truth or Dare"
        case .wouldYouRather: return "Would You Rather"
        case .mostLikelyTo: return "Most Likely To"
        case .twoTruthsAndALie: return "Two Truths and a Lie"
        case .popCultureTrivia: return "Pop Culture Trivia"
        case .historyTrivia: return "History Trivia"
        case .scienceTrivia: return "Science Trivia"
        case .sportsTrivia: return "Sports Trivia"
        case .movieTrivia: return "Movie Trivia"
        case .musicTrivia: return "Music Trivia"
        case .truthOrDrink: return "Truth or Drink"
        case .categoryClash: return "Category Clash"
        case .spinTheBottle: return "Spin the Bottle"
        case .storyChain: return "Story Chain"
        case .memoryMaster: return "Memory Master"
        case .bluffCall: return "Bluff Call"
        case .hotPotato: return "Hot Potato"
        case .rhymeTime: return "Rhyme Time"
        case .tapDuel: return "Tap Duel"
        case .whatsMySecret: return "What's My Secret?"
        case .riddleMeThis: return "Riddle Me This"
        case .other: return "Game"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Game")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            
            HStack(spacing: 16) {
                // Game icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(gameTitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    if let category = category {
                        HStack(spacing: 6) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            Text(category)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        }
                    } else {
                        Text("Waiting for host to start...")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationView {
        OnlineGameSelectionScreen()
    }
}
