//
//  ColorClashCardView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

enum CardSize {
    case small
    case medium
    
    var width: CGFloat {
        switch self {
        case .small: return 60
        case .medium: return 100
        }
    }
    
    var height: CGFloat {
        switch self {
        case .small: return 90
        case .medium: return 150
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 12
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 20
        case .medium: return 32
        }
    }
}

struct ColorClashCardView: View {
    let card: ColorClashCard
    let size: CardSize
    let isHighlighted: Bool
    let onTap: (() -> Void)?
    
    init(card: ColorClashCard, size: CardSize, isHighlighted: Bool = false, onTap: (() -> Void)? = nil) {
        self.card = card
        self.size = size
        self.isHighlighted = isHighlighted
        self.onTap = onTap
    }
    
    private var cardColor: Color {
        if let selectedColor = card.selectedColor {
            return colorForCardColor(selectedColor)
        } else if let color = card.color {
            return colorForCardColor(color)
        } else {
            return .black // Wild cards default to black
        }
    }
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(Color.white)
                    .frame(width: size.width, height: size.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: size.cornerRadius)
                            .stroke(cardColor, lineWidth: size == .medium ? 4 : 2.5)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Card content
                VStack(spacing: 4) {
                    if card.type == .number, let number = card.number {
                        // Number card
                        Text("\(number)")
                            .font(.system(size: size.fontSize, weight: .black, design: .rounded))
                            .foregroundColor(cardColor)
                    } else {
                        // Action card or wild
                        switch card.type {
                        case .skip:
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: size.fontSize * 0.7, weight: .bold))
                                .foregroundColor(cardColor)
                        case .reverse:
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: size.fontSize * 0.7, weight: .bold))
                                .foregroundColor(cardColor)
                        case .drawTwo:
                            Text("+2")
                                .font(.system(size: size.fontSize * 0.8, weight: .black, design: .rounded))
                                .foregroundColor(cardColor)
                        case .wild:
                            Image(systemName: "paintbrush.fill")
                                .font(.system(size: size.fontSize * 0.7, weight: .bold))
                                .foregroundColor(cardColor)
                        case .wildDrawFour:
                            Image("color clash artwork logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: size == .medium ? 50 : 35, height: size == .medium ? 50 : 35)
                                .opacity(0.9)
                        case .number:
                            EmptyView()
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHighlighted)
    }
    
    private func colorForCardColor(_ cardColor: CardColor) -> Color {
        switch cardColor {
        case .red:
            return Color(red: 0xE5/255.0, green: 0x39/255.0, blue: 0x46/255.0)
        case .blue:
            return Color(red: 0x21/255.0, green: 0x96/255.0, blue: 0xF3/255.0)
        case .yellow:
            return Color(red: 0xFF/255.0, green: 0xC1/255.0, blue: 0x07/255.0)
        case .green:
            return Color(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x50/255.0)
        }
    }
}

// MARK: - Card Back View (face down)
struct ColorClashCardBackView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0x1E/255.0, green: 0x3A/255.0, blue: 0x8E/255.0),
                        Color(red: 0x2E/255.0, green: 0x5A/255.0, blue: 0xAE/255.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

