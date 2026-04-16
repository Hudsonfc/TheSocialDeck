//
//  HowToPlayCard.swift
//  The Social Deck
//

import SwiftUI

/// Dark rounded card showing 3 numbered steps on how to play.
/// Place between the main settings/slider and the Start Game button on setup screens.
struct HowToPlayCard: View {
    let steps: [String]
    var accentColor: Color = Color.primaryAccent

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("HOW TO PLAY")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(accentColor)
                .tracking(1.2)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(accentColor)
                                .frame(width: 22, height: 22)
                            Text("\(index + 1)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 1)

                        Text(step)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.tertiaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.primaryText.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HowToPlayCard(
        steps: [
            "Take turns drawing a card and reading the prompt aloud to the group.",
            "Follow the rules on the card and see how everyone responds.",
            "The player with the most points at the end wins!"
        ]
    )
    .padding(24)
    .background(Color.appBackground)
}
