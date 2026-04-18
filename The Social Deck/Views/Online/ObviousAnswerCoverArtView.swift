//
//  ObviousAnswerCoverArtView.swift
//  The Social Deck
//
//  Programmatic cover for "The Obvious Answer" (Online Only). Matches Social Deck
//  cover language: ink panel, accent rail, editorial type — adapts on the Play grid.
//

import SwiftUI

struct ObviousAnswerCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers
    @Environment(\.obviousAnswerCoverEmbeddedPills) private var showEmbeddedPills

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let barW = max(3, u * 0.038)
            let kicker = max(8, u * 0.072)
            let mid = max(10, u * 0.088)
            let hero = max(15, u * 0.152)
            let ruleW = u * 0.42
            let ruleH = max(2, u * 0.014)

            ZStack {
                ink.panel

                if showEmbeddedPills {
                    VStack {
                        HStack {
                            PlayGridGameMarketingBadgePill(label: "New")
                            Spacer(minLength: 0)
                        }
                        .padding(.leading, u * 0.055)
                        .padding(.top, u * 0.048)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .allowsHitTesting(false)
                }

                HStack(alignment: .center, spacing: u * 0.065) {
                    // Amber accent rail
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.99, green: 0.84, blue: 0.20),
                                    Color(red: 0.96, green: 0.60, blue: 0.10)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: barW, height: u * 0.54)

                    VStack(alignment: .leading, spacing: u * 0.028) {
                        Text("THE")
                            .font(.system(size: kicker, weight: .semibold, design: .rounded))
                            .foregroundStyle(ink.caption(Color(red: 0.38, green: 0.42, blue: 0.48)))
                            .tracking(2.0)

                        Text("obvious")
                            .font(.system(size: mid, weight: .medium, design: .rounded))
                            .foregroundStyle(ink.caption(Color(red: 0.45, green: 0.48, blue: 0.52)))
                            .tracking(0.5)

                        RoundedRectangle(cornerRadius: ruleH * 0.45, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.99, green: 0.84, blue: 0.20),
                                        Color(red: 0.96, green: 0.60, blue: 0.10)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: ruleW, height: ruleH)

                        Text("answer.")
                            .font(.system(size: hero, weight: .heavy, design: .rounded))
                            .foregroundStyle(ink.hero(Color(red: 0.06, green: 0.10, blue: 0.16)))
                            .tracking(0.15)
                            .minimumScaleFactor(0.42)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, u * 0.09)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if showEmbeddedPills {
                    VStack {
                        Spacer(minLength: 0)
                        HStack {
                            PlayGridGameMarketingBadgePill(label: "Online matchmaking")
                            Spacer(minLength: 0)
                        }
                        .padding(.leading, u * 0.055)
                        .padding(.bottom, u * 0.048)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .allowsHitTesting(false)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview {
    ObviousAnswerCoverArtView()
        .environment(\.playGridAdaptiveSocialDeckCovers, true)
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}
