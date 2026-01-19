//
//  OnboardingReferralSourceView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import SwiftUI

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
    
    private let referralSources: [(id: String, name: String)] = [
        ("app_store", "App Store"),
        ("social_media", "Social Media"),
        ("friend_family", "Friend or Family"),
        ("advertisement", "Advertisement"),
        ("search_engine", "Search Engine"),
        ("other", "Other")
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Question mark icon
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .opacity(iconOpacity)
                .scaleEffect(iconScale)
            
            // Title
            Text("How did you hear about us?")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .opacity(titleOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Description
            Text("Help us understand how you found The Social Deck")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                .opacity(descriptionOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .frame(maxWidth: 350)
            
            // Referral source options
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(referralSources, id: \.id) { source in
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            selectedSource = source.id
                            AnalyticsService.shared.trackReferralSource(source.id)
                        }) {
                            HStack {
                                Text(source.name)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                
                                Spacer()
                                
                                if selectedSource == source.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                selectedSource == source.id ?
                                Color(red: 0xFF/255.0, green: 0xE5/255.0, blue: 0xE5/255.0) :
                                Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0)
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedSource == source.id ?
                                        Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) :
                                        Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 40)
            }
            .frame(maxHeight: 280)
            
            Spacer()
            
            // Continue button
            Button(action: {
                HapticManager.shared.mediumImpact()
                // Track skip if no selection
                if selectedSource == nil {
                    AnalyticsService.shared.trackReferralSource("skipped")
                }
                onContinue()
            }) {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(12)
            }
            .offset(y: buttonOffset)
            .opacity(buttonOpacity)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            
            // Page indicator
            PageIndicator(currentPage: currentPage, totalPages: totalPages)
                .padding(.bottom, 50)
        }
    }
}
