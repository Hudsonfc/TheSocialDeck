//
//  WhatWouldYouDoEndView.swift
//  The Social Deck
//
//  End-of-game screen aligned with RiddleMeThisEndView layout.
//

import SwiftUI

struct WhatWouldYouDoEndView: View {
    let winnerNames: [String]
    let winnerScore: Int
    let totalRounds: Int

    @State private var navigateToHome: Bool = false
    @State private var navigateToPlayAgain: Bool = false
    @Environment(\.dismiss) private var dismiss

    private var winnerSubtitle: String {
        guard !winnerNames.isEmpty else { return "Game over!" }
        if winnerNames.count == 1 {
            return "\(winnerNames[0]) wins!"
        }
        return "Tie: \(winnerNames.joined(separator: ", "))"
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button(action: {
                        navigateToHome = true
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.tertiaryBackground)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                VStack(spacing: 32) {
                    Image("what would you do ui")
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFit()
                        .frame(width: 160, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.cardShadowColor, radius: 15, x: 0, y: 8)

                    VStack(spacing: 12) {
                        Text("Great Game!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)

                        Text(winnerSubtitle)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }

                    VStack(spacing: 16) {
                        summaryRow(label: "Rounds played", value: "\(totalRounds)")
                        summaryRow(label: "Winning score", value: "\(winnerScore) pts")
                    }
                    .padding(20)
                    .background(Color.secondaryBackground)
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        navigateToPlayAgain = true
                    }) {
                        Text("Play Again")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.buttonBackground)
                            .cornerRadius(16)
                    }

                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        navigateToHome = true
                    }) {
                        Text("Home")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color.buttonBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.secondaryBackground)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHome
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: WhatWouldYouDoView(),
                isActive: $navigateToPlayAgain
            ) {
                EmptyView()
            }
        )
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.secondaryText)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primaryText)
        }
    }
}

#Preview {
    NavigationStack {
        WhatWouldYouDoEndView(
            winnerNames: ["Jake", "Mia"],
            winnerScore: 12,
            totalRounds: 1
        )
    }
}
