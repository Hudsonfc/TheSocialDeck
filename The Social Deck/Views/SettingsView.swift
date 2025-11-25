//
//  SettingsView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                    
                    // Theme Button
                    Button(action: {
                        // no action yet
                    }) {
                        Text("Theme")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width * 0.85, height: 60)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    
                    // Sound Settings Button
                    Button(action: {
                        // no action yet
                    }) {
                        Text("Sound Settings")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width * 0.85, height: 60)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    
                    // Help / FAQ Button
                    Button(action: {
                        // no action yet
                    }) {
                        Text("Help / FAQ")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width * 0.85, height: 60)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    
                    // About Button
                    Button(action: {
                        // no action yet
                    }) {
                        Text("About")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width * 0.85, height: 60)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    
                    // Bottom placeholder text
                    Text("More settings will be added later.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color.gray)
                        .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
