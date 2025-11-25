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
    let games: [String]
}

struct PlayView: View {
    @Environment(\.dismiss) private var dismiss
    // Placeholder categories
    let categories: [GameCategory] = [
        GameCategory(
            title: "Party Games",
            games: ["Never Have I Ever", "Truth or Dare", "Would You Rather", "Most Likely To", "Two Truths and a Lie"]
        ),
        GameCategory(
            title: "Challenge Games",
            games: ["Dare Challenge", "Physical Challenge", "Skill Challenge", "Speed Challenge"]
        ),
        GameCategory(
            title: "Trivia Games",
            games: ["Pop Culture Trivia", "History Trivia", "Science Trivia", "Sports Trivia", "Movie Trivia", "Music Trivia"]
        ),
        GameCategory(
            title: "Drinking Games",
            games: ["Kings Cup", "Never Have I Ever", "Most Likely To", "Truth or Drink", "Drunk Jenga"]
        ),
        GameCategory(
            title: "Relationship Games",
            games: ["Couples Questions", "Deep Questions", "Relationship Goals", "Love Languages"]
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
                            
                            // Horizontal scroll of game tiles
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(category.games, id: \.self) { gameName in
                                        GameTile(gameName: gameName)
                                    }
                                }
                                .padding(.horizontal, 40)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
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
    }
}

#Preview {
    NavigationView {
        PlayView()
    }
}
