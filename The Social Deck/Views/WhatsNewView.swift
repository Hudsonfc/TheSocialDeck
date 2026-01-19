//
//  WhatsNewView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    
    struct UpdateCard: Identifiable {
        let id: UUID
        let title: String
        let description: String
        let date: Date?
        let hasAccent: Bool
    }
    
    // Update cards - newest first
    private let allUpdateCards: [UpdateCard] = [
        UpdateCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            title: "Welcome to The Social Deck!",
            description: "Welcome to The Social Deck! We're so excited to have you here. Get ready to enjoy fun card games with friends, create lasting memories, and bring people together through laughter and connection. Gather around and pass the device—no accounts needed, just pure fun.",
            date: Date(),
            hasAccent: true
        ),
        UpdateCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            title: "Why We Built The Social Deck",
            description: "We built The Social Deck to bring people together through fun card games and create lasting memories with friends. Our goal is to make gathering with friends more engaging and enjoyable.",
            date: Date(),
            hasAccent: true
        ),
        UpdateCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            title: "Welcome to The Social Deck!",
            description: "Thanks for downloading The Social Deck! Get ready to enjoy fun card games with friends. Gather around and pass the device—no accounts needed, just pure fun.",
            date: Date(timeIntervalSinceNow: -86400), // Yesterday
            hasAccent: true
        )
    ]
    
    @State private var updateCards: [UpdateCard] = []
    
    private func getDeletedCardIds() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: "deletedUpdateCardIds") ?? [])
    }
    
    private func saveDeletedCardIds(_ ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: "deletedUpdateCardIds")
    }
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            if updateCards.isEmpty {
                // Empty State - Centered
                VStack(spacing: 24) {
                    Image("woman confused")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    VStack(spacing: 12) {
                        Text("No Updates Yet")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        
                        Text("New features and announcements will appear here when available.")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 40)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Title
                        Text("What's New")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Update Cards
                        ForEach(updateCards) { card in
                            UpdateCardView(
                                title: card.title,
                                description: card.description,
                                date: card.date,
                                hasAccent: card.hasAccent,
                                showDeleteButton: card.id.uuidString != "00000000-0000-0000-0000-000000000001" && card.id.uuidString != "00000000-0000-0000-0000-000000000003",
                                onDelete: {
                                    deleteCard(card.id)
                                }
                            )
                            .padding(.top, 32)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .onAppear {
            refreshCards()
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
                        .foregroundColor(.primaryText)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func refreshCards() {
        let deletedIds = getDeletedCardIds()
        updateCards = allUpdateCards.filter { !deletedIds.contains($0.id.uuidString) }
    }
    
    private func deleteCard(_ id: UUID) {
        HapticManager.shared.lightImpact()
        var deleted = getDeletedCardIds()
        deleted.insert(id.uuidString)
        saveDeletedCardIds(deleted)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            updateCards.removeAll { $0.id == id }
        }
    }
}

struct UpdateCardView: View {
    let title: String
    let description: String
    let date: Date?
    let hasAccent: Bool
    let showDeleteButton: Bool
    let onDelete: () -> Void
    
    private var dateString: String? {
        guard let date = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Red accent line at top (optional)
            if hasAccent {
                Rectangle()
                    .fill(Color.buttonBackground)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
            
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        // Title
                        Text(title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        
                        Spacer()
                        
                        // Delete Button (only if showDeleteButton is true)
                        if showDeleteButton {
                            Button(action: {
                                HapticManager.shared.lightImpact()
                                onDelete()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.secondaryText)
                            }
                        }
                    }
                    .padding(.top, hasAccent ? 16 : 0)
                    
                    // Description
                    Text(description)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Date
                    if let dateString = dateString {
                        Text(dateString)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .padding(.top, 4)
                    }
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationView {
        WhatsNewView()
    }
}
