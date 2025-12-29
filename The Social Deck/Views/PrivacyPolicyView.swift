//
//  PrivacyPolicyView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Title
                    Text("Privacy Policy")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Version header
                    Text("The Social Deck – Version 1.0")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    
                    // Content Card
                    VStack(spacing: 0) {
                        // Introduction
                        PolicySection(
                            title: nil,
                            content: [
                                "The Social Deck respects your privacy.",
                                "This app currently operates entirely offline and only supports local play card games."
                            ]
                        )
                        
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // What We Collect
                        PolicySection(
                            title: "What We Collect",
                            content: [
                                "We do not collect personal information",
                                "We do not require accounts or sign-ins",
                                "We do not track usage or analytics",
                                "We do not store or transmit data to any servers"
                            ]
                        )
                        
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // Local Data
                        PolicySection(
                            title: "Local Data",
                            content: [
                                "Any game activity exists only on your device and is not shared, uploaded, or backed up externally."
                            ]
                        )
                        
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // Third-Party Services
                        PolicySection(
                            title: "Third-Party Services",
                            content: [
                                "The Social Deck does not use third-party analytics, advertising, or tracking services in version 1.0."
                            ]
                        )
                        
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // Children's Privacy
                        PolicySection(
                            title: "Children's Privacy",
                            content: [
                                "The app does not knowingly collect any data from children under 13."
                            ]
                        )
                        
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // Changes
                        PolicySection(
                            title: "Changes",
                            content: [
                                "If features change in future updates (such as online play), this policy will be updated accordingly."
                            ]
                        )
                        
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // Contact
                        PolicySection(
                            title: "Contact",
                            content: [
                                "For questions or concerns, contact us through the app's feedback section."
                            ]
                        )
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0xE1/255.0, green: 0xE1/255.0, blue: 0xE1/255.0), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
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

struct PolicySection: View {
    let title: String?
    let content: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title {
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    .padding(.top, title == nil ? 0 : 16)
            }
            
            ForEach(content, id: \.self) { paragraph in
                Text(paragraph)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, title == nil && paragraph == content.first ? 0 : 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
