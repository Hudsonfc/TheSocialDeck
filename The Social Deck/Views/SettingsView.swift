//
//  SettingsView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var generalButtonPressed = false
    @State private var helpButtonPressed = false
    @State private var whatsNewButtonPressed = false
    @State private var feedbackButtonPressed = false
    @State private var rateUsButtonPressed = false
    
    // App version info
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
            ScrollView {
                    VStack(spacing: 20) {
                    // Title
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // General Settings Button
                        SettingsNavigationButton(
                            title: "General",
                            destination: GeneralSettingsView(),
                            isPressed: $generalButtonPressed
                        )
                        
                        // Help / FAQ Button
                        SettingsNavigationButton(
                            title: "Help / FAQ",
                            destination: HelpFAQView(),
                            isPressed: $helpButtonPressed
                        )
                        
                        // What's New Button
                        SettingsNavigationButton(
                            title: "What's New",
                            destination: WhatsNewView(),
                            isPressed: $whatsNewButtonPressed
                        )
                        
                        // Feedback Button
                        SettingsNavigationButton(
                            title: "Feedback",
                            destination: FeedbackView(),
                            isPressed: $feedbackButtonPressed
                        )
                        
                        // Rate Us Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                rateUsButtonPressed = true
                            }
                            HapticManager.shared.mediumImpact()
                            requestReview()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    rateUsButtonPressed = false
                                }
                            }
                        }) {
                            Text("Rate Us")
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width * 0.85, height: 60)
                                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .cornerRadius(16)
                        }
                        .scaleEffect(rateUsButtonPressed ? 0.97 : 1.0)
                        
                        // Spacer to push bottom buttons down
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 40)
                    }
                    
                // App Version
                VStack(spacing: 4) {
                    Text("The Social Deck")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    Text("Version \(appVersion) (\(buildNumber))")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0xB0/255.0, green: 0xB0/255.0, blue: 0xB0/255.0))
                }
                .padding(.bottom, 16)
                
                // Bottom buttons - Privacy Policy and Terms of Service
                HStack(spacing: 24) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .underline()
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        Text("Terms of Service")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                            .underline()
                    }
                }
                .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    HapticManager.shared.lightImpact()
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
    
    private func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

struct SettingsNavigationButton<Destination: View>: View {
    let title: String
    let destination: Destination
    @Binding var isPressed: Bool
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width * 0.85, height: 60)
                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .cornerRadius(16)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                    HapticManager.shared.lightImpact()
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
