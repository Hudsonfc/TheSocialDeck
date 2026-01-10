//
//  GeneralSettingsView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("shuffleCardsEnabled") private var shuffleCardsEnabled = true
    @AppStorage("swipeNavigationEnabled") private var swipeNavigationEnabled = false
    
    var body: some View {
        ZStack {
            // Adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Title
                    Text("General Settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Settings Sections
                    VStack(spacing: 0) {
                        // Preferences Section
                        VStack(spacing: 0) {
                            // Section Header
                            Text("Preferences")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 32)
                                .padding(.bottom, 12)
                            
                            // Haptics Toggle
                            SettingsRow(
                                icon: "hand.tap.fill",
                                title: "Haptic Feedback",
                                description: "Vibration feedback for interactions"
                            ) {
                                Toggle("", isOn: $hapticsEnabled)
                                    .labelsHidden()
                                    .tint(Color.primaryAccent)
                            }
                            
                            Divider()
                                .background(Color.borderColor)
                                .padding(.leading, 56)
                            
                            // Shuffle Cards Toggle
                            SettingsRow(
                                icon: "shuffle",
                                title: "Shuffle Cards",
                                description: "Randomize card order in games"
                            ) {
                                Toggle("", isOn: $shuffleCardsEnabled)
                                    .labelsHidden()
                                    .tint(Color.primaryAccent)
                            }
                            
                            Divider()
                                .background(Color.borderColor)
                                .padding(.leading, 56)
                            
                            // Swipe Navigation Toggle
                            SettingsRow(
                                icon: "hand.draw.fill",
                                title: "Swipe Navigation",
                                description: "Swipe left/right to navigate cards instead of using Next button (only for some games)"
                            ) {
                                Toggle("", isOn: $swipeNavigationEnabled)
                                    .labelsHidden()
                                    .tint(Color.primaryAccent)
                            }
                        }
                    }
                    .padding(.top, 32)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryText)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let description: String
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color.primaryAccent)
                .frame(width: 28, height: 28)
            
            // Title and Description
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.primaryText)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            // Content (Toggle, etc.)
            content()
        }
        .padding(.vertical, 12)
    }
}
