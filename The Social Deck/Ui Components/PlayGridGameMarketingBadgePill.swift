//
//  PlayGridGameMarketingBadgePill.swift
//  The Social Deck
//
//  Bottom-leading marketing capsule for Play grid tiles. Matches the layout
//  metrics of the existing PLUS pill on the same tiles (icon + label, 9pt bold
//  rounded, horizontal 7 / vertical 4 padding, Capsule).
//

import SwiftUI

struct PlayGridGameMarketingBadgePill: View {
    let label: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: systemImage)
                .font(.system(size: 9, weight: .bold))
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.55))
        .clipShape(Capsule())
    }
}
