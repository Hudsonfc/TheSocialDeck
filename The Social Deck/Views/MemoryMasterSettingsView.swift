//
//  MemoryMasterSettingsView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct MemoryMasterSettingsView: View {
    @Binding var soundEnabled: Bool
    @Binding var hapticsEnabled: Bool
    @Binding var showSettings: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        showSettings = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Spacer()
                    
                    // Invisible spacer to center title
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Sound settings
                        SettingsSection(title: "Audio") {
                            ToggleRow(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                isOn: $soundEnabled
                            )
                        }
                        
                        // Haptics settings
                        SettingsSection(title: "Feedback") {
                            ToggleRow(
                                icon: "hand.tap.fill",
                                title: "Haptic Feedback",
                                isOn: $hapticsEnabled
                            )
                        }
                        
                        // Game info
                        SettingsSection(title: "About") {
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(
                                    icon: "info.circle.fill",
                                    title: "How to Play",
                                    description: "Tap cards to flip them. Find matching pairs to clear the board. Complete as fast as possible!"
                                )
                                
                                Divider()
                                    .padding(.vertical, 8)
                                
                                InfoRow(
                                    icon: "trophy.fill",
                                    title: "Scoring",
                                    description: "Your score is based on time and number of moves. Fewer moves and faster time = better score!"
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .padding(.horizontal, 4)
            
            content
                .padding(20)
                .background(Color(red: 0xF9/255.0, green: 0xF9/255.0, blue: 0xF9/255.0))
                .cornerRadius(16)
        }
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .frame(width: 40, height: 40)
                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .frame(width: 40, height: 40)
                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

#Preview {
    MemoryMasterSettingsView(
        soundEnabled: .constant(true),
        hapticsEnabled: .constant(true),
        showSettings: .constant(true)
    )
}
