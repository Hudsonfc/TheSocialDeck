//
//  SplashView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct SplashView: View {
    /// When set (e.g. from Settings), the animation runs without writing `hasCompletedFirstLaunchSplash`; called when the sequence finishes.
    var onPreviewComplete: (() -> Void)? = nil

    private var isPreviewMode: Bool { onPreviewComplete != nil }

    @AppStorage("hasCompletedFirstLaunchSplash") private var hasCompletedFirstLaunchSplash = false

    @State private var logoOpacity: Double = 0
    /// Vertical slide: starts below final position, animates to 0 (slide up into place).
    @State private var logoSlideOffsetY: CGFloat = 200
    @State private var logoExitOffset: CGFloat = 0
    let words = ["The", "Social", "Deck"]
    @State private var wordOpacities: [Double] = [0, 0, 0]
    @State private var wordOffsets: [CGFloat] = [36, 36, 36]
    @State private var wordExitOffsets: [CGFloat] = [0, 0, 0]
    @State private var previewDidFinish = false

    private func finishPreviewIfNeeded() {
        guard isPreviewMode, !previewDidFinish else { return }
        previewDidFinish = true
        onPreviewComplete?()
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Splash screen content
            ZStack {
                // White background
                Color.white
                    .ignoresSafeArea()

                // Logo and text
                VStack(spacing: 20) {
                    // App icon art from `Applcon` imageset (replace PNG in Applcon.imageset to update splash + keep name)
                    Image("Applcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
                        .opacity(logoOpacity)
                        .offset(y: logoSlideOffsetY + logoExitOffset)

                    // Text under logo — slide up in sequence
                    HStack(spacing: 8) {
                        ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                            Text(word)
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.black)
                                .opacity(wordOpacities[index])
                                .offset(y: wordOffsets[index] + wordExitOffsets[index])
                        }
                    }
                }
            }
            .opacity(isPreviewMode ? 1 : (hasCompletedFirstLaunchSplash ? 0 : 1))

            if isPreviewMode {
                Button {
                    HapticManager.shared.lightImpact()
                    finishPreviewIfNeeded()
                } label: {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.black.opacity(0.55))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                }
                .padding(.top, 12)
                .padding(.trailing, 16)
            }
        }
        .onAppear {
            // Icon: slide up into place + fade in
            withAnimation(.spring(response: 0.85, dampingFraction: 0.82)) {
                logoOpacity = 1.0
                logoSlideOffsetY = 0
            }

            // Words: slide up one by one (lighter stagger)
            for index in 0..<words.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55 + Double(index) * 0.12) {
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                        wordOpacities[index] = 1.0
                        wordOffsets[index] = 0
                    }
                }
            }

            // Exit and hand off after full read
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                // Icon: slide up and fade out
                withAnimation(.easeIn(duration: 0.45)) {
                    logoOpacity = 0
                    logoExitOffset = -100
                }

                // Words: slide up and fade (staggered)
                for index in (0..<words.count).reversed() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(words.count - 1 - index) * 0.08) {
                        withAnimation(.easeIn(duration: 0.4)) {
                            wordOpacities[index] = 0
                            wordExitOffsets[index] = -28
                        }
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if onPreviewComplete != nil {
                        finishPreviewIfNeeded()
                    } else {
                        withAnimation(.easeIn(duration: 0.3)) {
                            hasCompletedFirstLaunchSplash = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
