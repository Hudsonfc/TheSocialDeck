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
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Title
                    Text("General Settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Settings Sections
                    VStack(spacing: 0) {
                        // Preferences Section
                        VStack(spacing: 0) {
                            // Section Header
                            Text("Preferences")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
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
                                    .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            // Sound Effects Toggle
                            SettingsRow(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                description: "Audio feedback during gameplay"
                            ) {
                                Toggle("", isOn: $soundEffectsEnabled)
                                    .labelsHidden()
                                    .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            // Animations Toggle
                            SettingsRow(
                                icon: "sparkles",
                                title: "Animations",
                                description: "Smooth transitions and effects"
                            ) {
                                Toggle("", isOn: $animationsEnabled)
                                    .labelsHidden()
                                    .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
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
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
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
                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .frame(width: 28, height: 28)
            
            // Title and Description
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text(description)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
            }
            
            Spacer()
            
            // Content (Toggle, etc.)
            content()
        }
        .padding(.vertical, 12)
    }
}
