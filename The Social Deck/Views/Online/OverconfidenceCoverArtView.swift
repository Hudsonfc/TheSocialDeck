//
//  OverconfidenceCoverArtView.swift
//  The Social Deck
//
//  Programmatic cover for "Overconfidence" (Online Only). Dark-panel editorial style:
//  red confidence gauge graphic, bold stacked type, accent underline rule.
//

import SwiftUI

struct OverconfidenceCoverArtView: View {
    @Environment(\.playGridAdaptiveSocialDeckCovers) private var playGridAdaptiveSocialDeckCovers
    @Environment(\.overconfidenceCoverEmbeddedPills) private var showEmbeddedPills

    private var ink: ProgrammaticSocialDeckCoverInk {
        ProgrammaticSocialDeckCoverInk(adaptive: playGridAdaptiveSocialDeckCovers)
    }

    var body: some View {
        GeometryReader { geo in
            let u = min(geo.size.width, geo.size.height)
            let barW = max(3, u * 0.038)
            let kicker = max(8, u * 0.068)
            let hero = max(15, u * 0.160)
            let ruleW = u * 0.44
            let ruleH = max(2, u * 0.013)

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
                    // Crimson accent rail
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.92, green: 0.22, blue: 0.22),
                                    Color(red: 0.62, green: 0.10, blue: 0.14)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: barW, height: u * 0.52)

                    VStack(alignment: .leading, spacing: u * 0.020) {
                        Text("OVER")
                            .font(.system(size: kicker, weight: .heavy, design: .rounded))
                            .foregroundStyle(ink.caption(Color(red: 0.36, green: 0.10, blue: 0.14)))
                            .tracking(3.0)

                        Text("confidence")
                            .font(.system(size: hero, weight: .heavy, design: .rounded))
                            .foregroundStyle(ink.hero(Color(red: 0.06, green: 0.08, blue: 0.14)))
                            .tracking(-0.5)
                            .minimumScaleFactor(0.4)
                            .lineLimit(1)

                        RoundedRectangle(cornerRadius: ruleH * 0.5, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.92, green: 0.22, blue: 0.22),
                                        Color(red: 0.62, green: 0.10, blue: 0.14)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: ruleW, height: ruleH)
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
    OverconfidenceCoverArtView()
        .environment(\.playGridAdaptiveSocialDeckCovers, true)
        .frame(width: 180, height: 247)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.appBackground)
}
