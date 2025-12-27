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
    let gameType: String? // Game type string (e.g., "colorClash")
    let minPlayers: Int
    let maxPlayers: Int
    
    init(title: String, description: String, imageName: String, hasCategories: Bool, availableCategories: [String], gameType: String? = nil, minPlayers: Int = 2, maxPlayers: Int = 8) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.hasCategories = hasCategories
        self.availableCategories = availableCategories
        self.gameType = gameType
        self.minPlayers = minPlayers
        self.maxPlayers = maxPlayers
    }
    
    static func == (lhs: OnlineGamePlaceholder, rhs: OnlineGamePlaceholder) -> Bool {
        lhs.id == rhs.id
    }
}

// Placeholder category for online games (similar to GameCategory)
struct OnlineGameCategory: Identifiable {
    let id: UUID
    let title: String
    let games: [OnlineGamePlaceholder]
    
    init(id: UUID = UUID(), title: String, games: [OnlineGamePlaceholder]) {
        self.id = id
        self.title = title
        self.games = games
    }
}

struct OnlineGameSelectionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    @State private var expandedGame: OnlineGamePlaceholder? = nil
    @State private var selectedGame: OnlineGamePlaceholder? = nil
    @State private var selectedCategory: String? = nil
    @State private var showCategorySelection = false
    @State private var navigateToRoom = false
    @State private var searchText: String = ""
    let isChangingGame: Bool
    
    init(isChangingGame: Bool = false) {
        self.isChangingGame = isChangingGame
    }
    
    // Placeholder categories with games
    let categories: [OnlineGameCategory] = [
        OnlineGameCategory(
            title: "Multiplayer Games",
            games: [
                OnlineGamePlaceholder(
                    title: "Color Clash",
                    description: "A fast-paced card game where players match colors and numbers. Be the first to empty your hand!",
                    imageName: "color clash artwork logo",
                    hasCategories: false,
                    availableCategories: [],
                    gameType: "colorClash",
                    minPlayers: 2,
                    maxPlayers: 6
                ),
                OnlineGamePlaceholder(
                    title: "Flip 21",
                    description: "A classic card game where players compete against the dealer. Get as close to 21 as possible without going over!",
                    imageName: "Art 1.4",
                    hasCategories: false,
                    availableCategories: [],
                    gameType: "flip21",
                    minPlayers: 2,
                    maxPlayers: 8
                ),
                OnlineGamePlaceholder(
                    title: "Online Game 1",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: true,
                    availableCategories: ["Quick", "Standard", "Extended"],
                    minPlayers: 2,
                    maxPlayers: 8
                ),
                OnlineGamePlaceholder(
                    title: "Online Game 2",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: false,
                    availableCategories: [],
                    minPlayers: 2,
                    maxPlayers: 8
                ),
                OnlineGamePlaceholder(
                    title: "Online Game 3",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: true,
                    availableCategories: ["Easy", "Medium", "Hard"],
                    minPlayers: 2,
                    maxPlayers: 8
                ),
                OnlineGamePlaceholder(
                    title: "Online Game 4",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: false,
                    availableCategories: [],
                    minPlayers: 2,
                    maxPlayers: 8
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
                    availableCategories: ["Casual", "Competitive"],
                    gameType: nil,
                    minPlayers: 2,
                    maxPlayers: 8
                ),
                OnlineGamePlaceholder(
                    title: "Online Game 6",
                    description: "Placeholder game description for online multiplayer gameplay",
                    imageName: "Art 1.4",
                    hasCategories: false,
                    availableCategories: [],
                    gameType: nil,
                    minPlayers: 2,
                    maxPlayers: 8
                )
            ]
        )
    ]
    
    private var filteredCategories: [OnlineGameCategory] {
        if searchText.isEmpty {
            return categories
        }
        
        let searchLower = searchText.lowercased()
        return categories.compactMap { category -> OnlineGameCategory? in
            let filteredGames = category.games.filter { game in
                game.title.lowercased().contains(searchLower) ||
                game.description.lowercased().contains(searchLower)
            }
            
            if filteredGames.isEmpty {
                return nil
            }
            
            return OnlineGameCategory(
                id: category.id,
                title: category.title,
                games: filteredGames
            )
        }
    }
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .font(.system(size: 18, weight: .medium))
                    
                    TextField("Search games...", text: $searchText)
                        .font(.system(size: 16, design: .rounded))
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            withAnimation(.spring(response: 0.3)) {
                                searchText = ""
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.gray.opacity(0.6))
                                .font(.system(size: 18))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0xE5/255.0, green: 0xE5/255.0, blue: 0xE5/255.0), lineWidth: 1)
                )
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        ForEach(filteredCategories, id: \.id) { category in
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
                        
                        // Empty state for search
                        if !searchText.isEmpty && filteredCategories.isEmpty {
                            VStack(spacing: 24) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 50, weight: .light))
                                        .foregroundColor(Color.gray.opacity(0.5))
                                }
                                
                                VStack(spacing: 8) {
                                    Text("No Games Found")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                    
                                    Text("Try searching with different keywords")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(Color.gray)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.top, 60)
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
                            // Save game selection to room
                            if let game = selectedGame, let gameType = game.gameType {
                                Task {
                                    if let deckType = DeckType(stringValue: gameType) {
                                        await onlineManager.selectGameType(deckType)
                                        
                                        // If changing game, dismiss after selection
                                        if isChangingGame {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                dismiss()
                                            }
                                        } else {
                                            // Creating new room, navigate to it
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                navigateToRoom = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                )
            }
        }
        .onChange(of: selectedGame) { oldValue, newValue in
            // Save game selection to room
            if let game = newValue, let gameType = game.gameType {
                Task {
                    if let deckType = DeckType(stringValue: gameType) {
                        await onlineManager.selectGameType(deckType)
                        
                        // If changing game (not creating new room), dismiss the sheet
                        if isChangingGame {
                            if !game.hasCategories || game.availableCategories.isEmpty {
                                // No categories, dismiss immediately
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    dismiss()
                                }
                            }
                            // If has categories, will dismiss after category selection
                        }
                    }
                }
            }
            
            // If creating new room and game selected without categories, navigate to room
            if !isChangingGame, let game = newValue, (!game.hasCategories || game.availableCategories.isEmpty) {
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
        HapticManager.shared.lightImpact()
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
    @State private var navigateToRoom = false
    
    init(game: OnlineGamePlaceholder, expandedGame: Binding<OnlineGamePlaceholder?>, selectedGame: Binding<OnlineGamePlaceholder?>, selectedCategory: Binding<String?>, showCategorySelection: Binding<Bool>) {
        self.game = game
        self._expandedGame = expandedGame
        self._selectedGame = selectedGame
        self._selectedCategory = selectedCategory
        self._showCategorySelection = showCategorySelection
    }
    
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
                    
                    // Continue button
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        // Set selected game to trigger onChange handler
                        selectedGame = game
                        // Close overlay
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            expandedGame = nil
                        }
                        // For Color Clash, navigate to settings; for others, onChange will handle navigation
                        if game.gameType == "colorClash" {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToRoom = true
                            }
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .background(
                        Group {
                            if game.gameType == "colorClash" {
                                NavigationLink(
                                    destination: ColorClashGameSettingsScreen(game: game),
                                    isActive: $navigateToRoom
                                ) {
                                    EmptyView()
                                }
                                .hidden()
                            }
                        }
                    )
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

