//
//  HelpFAQView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct HelpFAQView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedQuestions: Set<String> = []
    
    struct FAQItem: Identifiable {
        let id: String
        let question: String
        let answer: String
    }
    
    let faqItems: [FAQItem] = [
        FAQItem(
            id: "what-is",
            question: "What is The Social Deck?",
            answer: "The Social Deck is a collection of fun, interactive card games designed for groups. It's perfect for parties, family gatherings, or just hanging out with friends. Play locally by passing the device around."
        ),
        FAQItem(
            id: "how-to-play",
            question: "How do I play?",
            answer: "Simply choose a game, gather your friends, and pass the device around. Each player takes their turn on the same device. No internet connection required!"
        ),
        FAQItem(
            id: "simple-question-1",
            question: "Do I need an internet connection?",
            answer: "No! The Social Deck works completely offline. All games are played locally on your device by passing it around with friends."
        ),
        FAQItem(
            id: "simple-question-2",
            question: "How do I start a game?",
            answer: "Tap the Play button on the home screen, choose a game, and follow the on-screen instructions. Then pass the device to the next player when it's their turn."
        ),
        FAQItem(
            id: "simple-question-3",
            question: "Can multiple people play at once?",
            answer: "Yes! The Social Deck is designed for groups. Simply pass the device around and each person takes their turn when they have it."
        ),
        FAQItem(
            id: "troubleshooting",
            question: "The app isn't working properly. What should I do?",
            answer: "Try force-closing and reopening the app. If issues persist, restart your device. For further assistance, please submit feedback through the Settings menu."
        )
    ]
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Title
                    Text("Help & FAQ")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Introduction
                    Text("Find answers to common questions about The Social Deck.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                    
                    // FAQ Items Container
                    VStack(spacing: 0) {
                        ForEach(faqItems) { item in
                            FAQRow(
                                item: item,
                                isExpanded: expandedQuestions.contains(item.id)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    if expandedQuestions.contains(item.id) {
                                        expandedQuestions.remove(item.id)
                                    } else {
                                        expandedQuestions.insert(item.id)
                                    }
                                }
                            }
                            
                            if item.id != faqItems.last?.id {
                                Divider()
                                    .padding(.leading, 20)
                            }
                        }
                    }
                    .padding(.top, 32)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: 1)
                    )
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .padding(.top, 48)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("The Social Deck is a local-only card game app designed for playing with friends in person.")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .lineSpacing(4)
                            
                            Text("More settings and features will be added in future updates.")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                .lineSpacing(4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 40)
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

struct FAQRow: View {
    let item: HelpFAQView.FAQItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.question)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if isExpanded {
                            Text(item.answer)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4)
                                .padding(.top, 20)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                }
                .padding(.vertical, 28)
                .padding(.horizontal, 24)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
