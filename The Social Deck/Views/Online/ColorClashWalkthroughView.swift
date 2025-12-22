//
//  ColorClashWalkthroughView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ColorClashWalkthroughView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    let showCloseButton: Bool
    
    init(showCloseButton: Bool = true) {
        self.showCloseButton = showCloseButton
    }
    
    private let pages: [WalkthroughPage] = [
        WalkthroughPage(
            title: "Welcome to Color Clash!",
            description: "A fast-paced card game where strategy meets speed! Match colors and numbers to play cards from your hand. The goal is simple: be the first player to empty your hand and win the game. Each turn, you can either play a card that matches the color or number of the current card, or draw a new card if you can't play. Special action cards add twists and turns to keep the game exciting!",
            icon: "color clash artwork logo",
            isImageIcon: true
        ),
        WalkthroughPage(
            title: "Basic Rules",
            description: "On your turn, you must play a card that matches either the color or number of the card in the center. For example, if there's a red 5, you can play any red card or any card with the number 5. If you don't have a matching card, you must draw one from the deck. The game continues clockwise (or counterclockwise if reversed) until someone plays their last card. Remember: you must call 'Last Card' when you have one card remaining, or you'll face a penalty!",
            icon: "info.circle.fill",
            isImageIcon: false
        ),
        WalkthroughPage(
            title: "Special Cards",
            description: "Skip cards force the next player to lose their turn. Reverse cards change the direction of play. Draw Two cards make the next player draw two cards and skip their turn. Wild cards let you choose any color to continue play. Wild Draw Four cards are powerful - they let you choose the color AND force the next player to draw four cards and skip their turn. Use these strategically to gain an advantage! If you forget what any card does, tap the info button during gameplay to see all card details.",
            icon: "sparkles",
            isImageIcon: false
        ),
        WalkthroughPage(
            title: "Last Card Rule",
            description: "This is crucial! When you have only one card left in your hand, you must tap the 'Last Card' button before your turn ends. If you forget to call 'Last Card' and another player notices, you'll be penalized by drawing 2 additional cards. This rule prevents players from winning unexpectedly and adds an extra layer of strategy. Always keep an eye on your hand count and remember to call it when you're down to your final card!",
            icon: "1.circle.fill",
            isImageIcon: false
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        walkthroughPageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Bottom buttons - anchored to bottom
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Previous")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                .cornerRadius(16)
                        }
                    }
                    
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            dismiss()
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Continue" : "Got It")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                .background(Color.white)
            }
        }
    }
    
    private func walkthroughPageView(_ page: WalkthroughPage) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                    .frame(width: 100, height: 100)
                
                if page.isImageIcon {
                    Image(page.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                } else {
                    Image(systemName: page.icon)
                        .font(.system(size: 45, weight: .medium))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                }
            }
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Description
            Text(page.description)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.bottom, 120)
    }
}

struct WalkthroughPage {
    let title: String
    let description: String
    let icon: String
    let isImageIcon: Bool
}

#Preview {
    ColorClashWalkthroughView()
}

