//
//  TermsOfServiceView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Title
                    Text("Terms of Service")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Version header
                    Text("The Social Deck – Version 1.1")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    
                    // Last Updated
                    Text("Last Updated: \(DateFormatter.monthYear.string(from: Date()))")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                    
                    // Content Card
                    VStack(spacing: 0) {
                        // Introduction
                        PolicySection(
                            title: nil,
                            content: [
                                "By using The Social Deck, you agree to the following terms."
                            ]
                        )
                        
                        Divider()
                            .background(Color.borderColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // App Usage
                        PolicySection(
                            title: "App Usage",
                            content: [
                                "The app is provided for entertainment purposes only",
                                "Gameplay is limited to local, offline card games",
                                "No accounts, profiles, or online features exist in version 1.0"
                            ]
                        )
                        
                        Divider()
                            .background(Color.borderColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // User Responsibility
                        PolicySection(
                            title: "User Responsibility",
                            content: [
                                "You agree to use the app responsibly and not for unlawful or harmful purposes."
                            ]
                        )
                        
                        Divider()
                            .background(Color.borderColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // Availability
                        PolicySection(
                            title: "Availability",
                            content: [
                                "We may update, modify, or discontinue features at any time without notice."
                            ]
                        )
                        
                        Divider()
                            .background(Color.borderColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // Liability
                        PolicySection(
                            title: "Liability",
                            content: [
                                "The Social Deck is provided \"as is.\" We are not responsible for gameplay outcomes, disputes between players, or device issues."
                            ]
                        )
                        
                        Divider()
                            .background(Color.borderColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // Intellectual Property
                        PolicySection(
                            title: "Intellectual Property",
                            content: [
                                "All app content, design, and branding belong to The Social Deck and may not be copied or redistributed without permission.",
                                "Game names and concepts used in the app (e.g. Never Have I Ever, Truth or Dare, Would You Rather) are classic party games in the public domain. The Social Deck does not claim ownership of those game ideas or names and is not affiliated with any other brand or product that may use similar names."
                            ]
                        )
                        
                        Divider()
                            .background(Color.borderColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        
                        // Entertainment & Disclaimer
                        PolicySection(
                            title: "Entertainment & Disclaimer",
                            content: [
                                "The app and all games, prompts, and content are for entertainment only. They are not professional, legal, medical, or therapeutic advice.",
                                "You use the app at your own risk. To the fullest extent permitted by law, The Social Deck shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the app or any content within it."
                            ]
                        )
                        
                        Divider()
                            .background(Color.borderColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)

                        // TheSocialDeck+ Subscriptions
                        PolicySection(
                            title: "TheSocialDeck+ Subscriptions",
                            content: [
                                "TheSocialDeck+ is an auto-renewable subscription that unlocks premium games and features.",
                                "Subscription options: Monthly ($4.99/month) and Yearly ($29.99/year). Prices may vary by region and are displayed in your local currency at checkout.",
                                "Payment is charged to your Apple ID account at confirmation of purchase.",
                                "Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period.",
                                "Your account will be charged for renewal within 24 hours prior to the end of the current period.",
                                "You can manage and cancel subscriptions in your Apple ID Account Settings at any time after purchase.",
                                "Any unused portion of a free trial period will be forfeited when a subscription is purchased.",
                                "Cancelling a subscription does not provide a refund for the current billing period."
                            ]
                        )

                        Divider()
                            .background(Color.borderColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)

                        // Updates
                        PolicySection(
                            title: "Updates",
                            content: [
                                "Future versions may introduce new features (such as online play), which may require updated terms."
                            ]
                        )
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .background(Color.secondaryBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.borderColor, lineWidth: 1)
                    )
                    .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 2)
                    
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
