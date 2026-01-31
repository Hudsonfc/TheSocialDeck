//
//  HomeView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
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
    @State private var featuredPlayButtonPressed = false
    @State private var mainPlayButtonPressed = false
    @State private var settingsButtonPressed = false
    @State private var currentSlideIndex = 0
    @State private var slideshowTimer: Timer?
    @State private var currentQuote: String = ""
    @State private var gameOfTheDay: GameOfTheDayInfo = GameOfTheDayManager.shared.getTodaysGame()
    @State private var showShareTooltip: Bool = false
    @State private var tooltipTimer: Timer?
    @AppStorage("hasSeenRateUsView") private var hasSeenRateUsView: Bool = false
    @State private var showRateUsView: Bool = false
    
    // Curated quotes for The Social Deck
    private let quotes = [
        "The game is just the excuse.",
        "Good cards. Better company.",
        "One table. One deck. Everyone in.",
        "Shuffle the deck. Start the moment.",
        "No phones. Just cards.",
        "Laughs guaranteed. Rules optional.",
        "Every card is a conversation.",
        "Less scrolling. More shuffling."
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Adaptive background
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                VStack(spacing: 30) {
                    // Top Header
                    Text("The Social Deck")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .opacity(titleOpacity)
                        .padding(.top, 20)
                    
                    // Featured Deck Card
                    VStack(spacing: 15) {
                        // Hero Banner
                        ZStack {
                            TabView(selection: $currentSlideIndex) {
                                // Welcome Card Slide (Index 0)
                                NavigationLink(destination: WhatsNewView()) {
                                    HeroWelcomeSlide()
                                }
                                .buttonStyle(PlainButtonStyle())
                                .tag(0)
                                
                                // Why We Built Slide (Index 1)
                                NavigationLink(destination: WhatsNewView()) {
                                    HeroWhyWeBuiltSlide()
                                }
                                .buttonStyle(PlainButtonStyle())
                                .tag(1)
                                
                                // Quote Slide (Index 2)
                                NavigationLink(destination: WhatsNewView()) {
                                    HeroQuoteSlide(quote: currentQuote)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .tag(2)
                                
                                // Game of the Day Slide (Index 3)
                                NavigationLink(destination: Play2View()) {
                                    HeroGameOfTheDaySlide(game: gameOfTheDay)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .tag(3)
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(width: ResponsiveSize.heroBannerWidth, height: ResponsiveSize.heroBannerHeight)
                            .cornerRadius(16, corners: [.topLeft, .topRight])
                            .onAppear {
                                startSlideshow()
                            }
                            .onDisappear {
                                stopSlideshow()
                            }
                            .simultaneousGesture(
                                // Allow wrapping from last slide to first
                                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                                    .onEnded { value in
                                        // Right swipe on last slide wraps to first
                                        if currentSlideIndex == 3 && value.translation.width > 80 {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                currentSlideIndex = 0
                                            }
                                        }
                                    }
                            )
                            
                            // Slide Counter
                            VStack {
                                Spacer()
                                HStack(spacing: 6) {
                                    ForEach(0..<4, id: \.self) { index in
                                        Circle()
                                            .fill(index == currentSlideIndex ? Color(light: Color.black, dark: Color.black) : Color(light: Color.black.opacity(0.4), dark: Color.black.opacity(0.4)))
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .padding(.bottom, 12)
                            }
                        }
                        .frame(width: ResponsiveSize.heroBannerWidth, height: ResponsiveSize.heroBannerHeight)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Featured Deck")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primaryText)
                            }
                            
                            Spacer()
                            
                            // Play Button
                            NavigationLink(destination: Play2View()) {
                                Text("Play")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(Color.buttonBackground)
                                    .cornerRadius(20)
                            }
                            .scaleEffect(featuredPlayButtonPressed ? 0.95 : 1.0)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            featuredPlayButtonPressed = true
                                        }
                                        HapticManager.shared.lightImpact()
                                    }
                                    .onEnded { _ in
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            featuredPlayButtonPressed = false
                                        }
                                    }
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
                    .scaleEffect(featuredCardScale)
                    .opacity(featuredCardOpacity)
                    .padding(.horizontal, 40)
                    
                    // Separator
                    Rectangle()
                        .fill(Color.borderColor)
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 8)
                    
                    // Main Buttons
                    VStack(spacing: 16) {
                        // Play Button
                        NavigationButton(
                            title: "Play",
                            offset: button1Offset,
                            opacity: button1Opacity,
                            destination: Play2View(),
                            isPressed: $mainPlayButtonPressed
                        )
                        
                        // Settings Button (moved directly under Play)
                        NavigationButton(
                            title: "Settings",
                            offset: button2Offset,
                            opacity: button2Opacity,
                            destination: SettingsView(),
                            isPressed: $settingsButtonPressed
                        )
                        
                        // Online Button (Hidden for first version)
                        NavigationButton(
                            title: "Online",
                            offset: button3Offset,
                            opacity: button3Opacity,
                            destination: OnlineView(),
                            isPressed: .constant(false)
                        )
                        .hidden()
                        
                        // Profile Button (Hidden for first version)
                        NavigationButton(
                            title: "Profile",
                            offset: button4Offset,
                            opacity: button4Opacity,
                            destination: ProfileView(),
                            isPressed: .constant(false)
                        )
                        .hidden()
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                    
                    // App Version
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                       let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        Text("Version \(version) (\(build))")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.tertiaryText)
                            .padding(.bottom, 20)
                    } else {
                        Text("Version 1.0")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.tertiaryText)
                            .padding(.bottom, 20)
                    }
                }
            }
            }
            .overlay(alignment: .topTrailing) {
                // User Avatar Button in top right (Hidden for first version)
                if authManager.isAuthenticated {
                    NavigationLink(destination: ProfileView()) {
                        AvatarView(
                            avatarType: authManager.userProfile?.avatarType ?? "person.fill",
                            avatarColor: authManager.userProfile?.avatarColor ?? "red",
                            size: 44
                        )
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 20)
                    .hidden()
                }
            }
            .overlay(alignment: .bottomTrailing) {
                ZStack(alignment: .bottomTrailing) {
                    // Share Button Tooltip
                    if showShareTooltip {
                        ShareButtonTooltip(onDismiss: {
                            showShareTooltip = false
                        })
                        .padding(.trailing, 80)
                        .padding(.bottom, 20)
                    }
                    
                    // Share Button
                    ShareButton()
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                startAnimations()
                // Select random quote
                currentQuote = quotes.randomElement() ?? quotes[0]
                // Get today's game of the day
                gameOfTheDay = GameOfTheDayManager.shared.getTodaysGame()
                
                // Show tooltip on first load
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showShareTooltip = true
                }
                
                // Start timer to show tooltip every minute
                startTooltipTimer()
                
                // Show rate us view for new users after onboarding
                if OnboardingManager.shared.hasCompletedOnboarding && !hasSeenRateUsView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showRateUsView = true
                    }
                }
            }
            .onDisappear {
                stopTooltipTimer()
            }
            .onChange(of: showRateUsView) { oldValue, newValue in
                if !newValue && !hasSeenRateUsView {
                    hasSeenRateUsView = true
                }
            }
        }
    }
    
    private func startSlideshow() {
        stopSlideshow() // Stop any existing timer
        slideshowTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                currentSlideIndex = (currentSlideIndex + 1) % 4
            }
        }
    }
    
    private func stopSlideshow() {
        slideshowTimer?.invalidate()
        slideshowTimer = nil
    }
    
    private func startTooltipTimer() {
        stopTooltipTimer() // Stop any existing timer
        // Show tooltip after 2 minutes
        tooltipTimer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true) { _ in
            showShareTooltip = true
        }
    }
    
    private func stopTooltipTimer() {
        tooltipTimer?.invalidate()
        tooltipTimer = nil
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
    @Binding var isPressed: Bool
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.buttonBackground)
                .cornerRadius(16)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .offset(y: offset)
        .opacity(opacity)
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

// Share Button Tooltip Component
struct ShareButtonTooltip: View {
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0
    @State private var arrowOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Share our deck with others here!")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // Arrow pointing to the right with animation
            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .offset(x: arrowOffset)
        }
        .scaleEffect(scale)
        .onAppear {
            // Reset state
            scale = 0
            arrowOffset = 0
            
            // Bounce in animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
            }
            
            // Arrow animation (bounce left and right)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    arrowOffset = 4
                }
            }
            
            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    scale = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

// Share Button Component
struct ShareButton: View {
    @State private var showShareSheet = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            showShareSheet = true
            HapticManager.shared.lightImpact()
        }) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .frame(width: 44, height: 44)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(isPressed ? 0.92 : 1.0)
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
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: ["Playing card games on The Social Deck ♠️ Pass & play with friends — no accounts needed."])
        }
    }
}

// Hero Banner Welcome Slide
struct HeroWelcomeSlide: View {
    var body: some View {
        ZStack {
            // Background with red accent at top
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .frame(height: 4)
                
                Color.white
            }
            
            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                
                Text("The Social Deck")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                
                Text("Pass & play with friends")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 8)
        }
        .frame(width: ResponsiveSize.heroBannerWidth, height: ResponsiveSize.heroBannerHeight)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

// Hero Banner Why We Built Slide
struct HeroWhyWeBuiltSlide: View {
    var body: some View {
        ZStack {
            // Light gray background
            Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0)
            
            HStack(spacing: 0) {
                // Red accent bar on the left
                Rectangle()
                    .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .frame(width: 4)
                
                HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                    Text("Why We Built")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            
                            // Logo on the right side of "Why We Built" text
                            Image("TheSocialDeckLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    
                    Text("The Social Deck")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    Text("To bring people together through fun card games and create lasting memories with friends.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x5A/255.0, green: 0x5A/255.0, blue: 0x5A/255.0))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.vertical, 20)
            }
        }
        .frame(width: ResponsiveSize.heroBannerWidth, height: ResponsiveSize.heroBannerHeight)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

// Hero Banner Quote Slide
struct HeroQuoteSlide: View {
    let quote: String
    
    var body: some View {
        ZStack {
            // Warm off-white background
            Color(red: 0xFD/255.0, green: 0xFB/255.0, blue: 0xF8/255.0)
            
            VStack(spacing: 12) {
                // Quote Content
                VStack(spacing: 8) {
                    // Quotation mark accent
                    Text("\u{201C}")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.5))
                        .frame(height: 20)
                    
                    // Quote text
                    Text(quote)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 32)
                    
                    // Signature
                    Text("- thesocialdeck")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding(.vertical, 32)
        }
        .frame(width: ResponsiveSize.heroBannerWidth, height: ResponsiveSize.heroBannerHeight)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

// Hero Banner Game of the Day Slide
struct HeroGameOfTheDaySlide: View {
    let game: GameOfTheDayInfo
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0),
                    Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 16) {
                // Game Image
                Image(game.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 140)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.leading, 20)
                
                // Game Info
                VStack(alignment: .leading, spacing: 8) {
                    // Badge
                    Text("GAME OF THE DAY")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                    
                    // Game Title
                    Text(game.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white)
                        .lineLimit(2)
                    
                    // Game Description
                    Text(game.description)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.9))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                .padding(.trailing, 20)
                .padding(.top, 16)
                
                Spacer()
            }
        }
        .frame(width: ResponsiveSize.heroBannerWidth, height: ResponsiveSize.heroBannerHeight)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

#Preview {
    NavigationView {
        HomeView()
    }
}
