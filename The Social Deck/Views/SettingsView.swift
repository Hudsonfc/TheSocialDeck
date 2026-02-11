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
            // Adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
            ScrollView {
                    VStack(spacing: 20) {
                    // Title
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // General Settings Button
                        SettingsNavigationButton(
                            title: "General",
                            destination: GeneralSettingsView(),
                            isPressed: $generalButtonPressed
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
                                .background(Color.buttonBackground)
                                .cornerRadius(16)
                        }
                        .scaleEffect(rateUsButtonPressed ? 0.97 : 1.0)
                        
                        // Spacer to push bottom buttons down
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 40)
                    }
                    
                // Instagram link
                if let instagramURL = URL(string: "https://www.instagram.com/thesocialdeckapp/") {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        UIApplication.shared.open(instagramURL)
                    }) {
                        InstagramIconView(size: 22)
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.secondaryBackground)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.borderColor, lineWidth: 1)
                            )
                    }
                    .buttonStyle(InstagramButtonStyle())
                    .padding(.bottom, 20)
                }
                
                // App Version
                VStack(spacing: 4) {
                    Text("The Social Deck")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondaryText)
                    Text("Version \(appVersion) (\(buildNumber))")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.tertiaryText)
                }
                .padding(.bottom, 16)
                
                // Bottom buttons - Privacy Policy and Terms of Service
                HStack(spacing: 24) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .underline()
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        Text("Terms of Service")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
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
                        .foregroundColor(.primaryText)
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

// Scale-down on press for Instagram button
struct InstagramButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Minimalist Instagram glyph: rounded square + lens circle + viewfinder dot
struct InstagramIconView: View {
    var size: CGFloat = 24
    
    var body: some View {
        let strokeWidth = max(1.5, size * 0.08)
        let cornerRadius = size * 0.22
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(lineWidth: strokeWidth)
                .frame(width: size, height: size)
            Circle()
                .strokeBorder(lineWidth: strokeWidth)
                .frame(width: size * 0.52, height: size * 0.52)
            Circle()
                .strokeBorder(lineWidth: strokeWidth)
                .frame(width: size * 0.2, height: size * 0.2)
                .offset(x: size * 0.28, y: -size * 0.28)
        }
        .frame(width: size, height: size)
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
                .background(Color.buttonBackground)
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
