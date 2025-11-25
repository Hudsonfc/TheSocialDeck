//
//  HomeView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct HomeView: View {
    @State private var titleOpacity: Double = 0
    @State private var featuredCardScale: CGFloat = 0.95
    @State private var featuredCardOpacity: Double = 0
    @State private var button1Offset: CGFloat = 50
    @State private var button1Opacity: Double = 0
    @State private var button2Offset: CGFloat = 50
    @State private var button2Opacity: Double = 0
    @State private var button3Offset: CGFloat = 50
    @State private var button3Opacity: Double = 0
    @State private var button4Offset: CGFloat = 50
    @State private var button4Opacity: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // White background
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                VStack(spacing: 30) {
                    // Top Header
                    Text("The Social Deck")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .opacity(titleOpacity)
                        .padding(.top, 20)
                    
                    // Featured Deck Card
                    VStack(spacing: 15) {
                        // Deck Image
                        Image("Art 1.4")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 320, height: 200)
                            .clipped()
                            .cornerRadius(16, corners: [.topLeft, .topRight])
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Featured Deck")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            }
                            
                            Spacer()
                            
                            // Play Button
                            NavigationLink(destination: PlayView()) {
                                Text("Play")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .scaleEffect(featuredCardScale)
                    .opacity(featuredCardOpacity)
                    .padding(.horizontal, 40)
                    
                    // Main Buttons
                    VStack(spacing: 16) {
                        // Play Button
                        NavigationButton(
                            title: "Play",
                            offset: button1Offset,
                            opacity: button1Opacity,
                            destination: PlayView()
                        )
                        
                        // Online Button
                        NavigationButton(
                            title: "Online",
                            offset: button2Offset,
                            opacity: button2Opacity,
                            destination: OnlineView()
                        )
                        
                        // Profile Button
                        NavigationButton(
                            title: "Profile",
                            offset: button3Offset,
                            opacity: button3Opacity,
                            destination: ProfileView()
                        )
                        
                        // Settings Button
                        NavigationButton(
                            title: "Settings",
                            offset: button4Offset,
                            opacity: button4Opacity,
                            destination: SettingsView()
                        )
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                    
                    // App Version
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                       let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        Text("Version \(version) (\(build))")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                            .padding(.bottom, 20)
                    } else {
                        Text("Version 1.0")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                            .padding(.bottom, 20)
                    }
                }
            }
            }
            .navigationBarHidden(true)
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        // Title fade in
        withAnimation(.easeIn(duration: 0.6)) {
            titleOpacity = 1.0
        }
        
        // Featured card scale animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                featuredCardScale = 1.0
                featuredCardOpacity = 1.0
            }
        }
        
        // Buttons slide up animations (staggered)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                button1Offset = 0
                button1Opacity = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                button2Offset = 0
                button2Opacity = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                button3Offset = 0
                button3Opacity = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                button4Offset = 0
                button4Opacity = 1.0
            }
        }
    }
}

// Navigation Button Component
struct NavigationButton<Destination: View>: View {
    let title: String
    let offset: CGFloat
    let opacity: Double
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .cornerRadius(16)
        }
        .offset(y: offset)
        .opacity(opacity)
    }
}

// Extension for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationView {
        HomeView()
    }
}
