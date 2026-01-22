//
//  OnboardingReferralSourceView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI

private let accentRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
private let headlineBlack = Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0)
private let subtitleGray = Color(red: 0x6B/255.0, green: 0x6B/255.0, blue: 0x6B/255.0)
private let cardBackground = Color(red: 0xFA/255.0, green: 0xFA/255.0, blue: 0xFA/255.0)
private let cardBorder = Color(red: 0xEE/255.0, green: 0xEE/255.0, blue: 0xEE/255.0)
private let cardBorderActive = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
private let cardFillActive = Color(red: 0xFF/255.0, green: 0xEB/255.0, blue: 0xEB/255.0)

struct OnboardingReferralSourceView: View {
    @State private var selectedSource: String? = nil
    @Binding var iconOpacity: Double
    @Binding var iconScale: CGFloat
    @Binding var titleOpacity: Double
    @Binding var descriptionOpacity: Double
    @Binding var buttonOpacity: Double
    @Binding var buttonOffset: CGFloat
    let currentPage: Int
    let totalPages: Int
    let onContinue: () -> Void
    
    private let referralSources: [(id: String, name: String, icon: String)] = [
        ("app_store", "App Store", "apple.logo"),
        ("instagram", "Instagram", ""),
        ("tiktok", "TikTok", ""),
        ("friend_family", "Friend or Family", "person.2.fill"),
        ("advertisement", "Advertisement", "megaphone.fill"),
        ("search_engine", "Search Engine", "magnifyingglass"),
        ("other", "Other", "ellipsis.circle.fill")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top content: icon, headline, subtitle, options
            VStack(spacing: 0) {
                // Minimal icon
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(accentRed.opacity(0.5))
                    .opacity(iconOpacity)
                    .scaleEffect(iconScale)
                    .padding(.top, 32)
                
                // Headline
                Text("How did you hear about us?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(headlineBlack)
                    .opacity(titleOpacity)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                
                // Options
                VStack(spacing: 12) {
                    ForEach(referralSources, id: \.id) { source in
                        ReferralOptionButton(
                            name: source.name,
                            isSelected: selectedSource == source.id,
                            action: {
                                HapticManager.shared.lightImpact()
                                selectedSource = source.id
                                AnalyticsService.shared.trackReferralSource(source.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
            
            Spacer(minLength: 24)
            
            // Fixed bottom: Continue (only when option selected) + page indicator
            VStack(spacing: 0) {
                if selectedSource != nil {
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        onContinue()
                    }) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(accentRed)
                            .cornerRadius(16)
                    }
                    .offset(y: buttonOffset)
                    .opacity(buttonOpacity)
                    .padding(.horizontal, 24)
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeOut(duration: 0.35)).combined(with: .move(edge: .bottom)),
                        removal: .opacity.animation(.easeIn(duration: 0.25))
                    ))
                }
                
                PageIndicator(currentPage: currentPage, totalPages: totalPages)
                    .padding(.top, selectedSource != nil ? 20 : 0)
                    .animation(.easeOut(duration: 0.3), value: selectedSource != nil)
                    .padding(.bottom, 50)
            }
            .animation(.easeOut(duration: 0.35), value: selectedSource != nil)
        }
        .background(Color.white)
    }
}

// MARK: - Refined option card
private struct ReferralOptionButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 16, weight: isSelected ? .semibold : .medium, design: .rounded))
                .foregroundColor(isSelected ? headlineBlack : subtitleGray)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? cardFillActive : cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? cardBorderActive : cardBorder, lineWidth: isSelected ? 2 : 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
