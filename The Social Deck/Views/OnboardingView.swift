//
//  OnboardingView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var currentPage: Int = 1
    private let totalPages: Int = 5 // Referral (1), Welcome (2), Pass & Play (3), Pick Deck (4), All Set (5)
    
    // Page 1 - Referral Source animation states
    @State private var page2IconOpacity: Double = 0
    @State private var page2IconScale: CGFloat = 0.8
    @State private var page2TitleOpacity: Double = 0
    @State private var page2DescriptionOpacity: Double = 0
    @State private var page2ButtonOffset: CGFloat = 50
    @State private var page2ButtonOpacity: Double = 0
    
    // Page 2 - Welcome animation states
    @State private var page3LogoOpacity: Double = 0
    @State private var page3LogoScale: CGFloat = 0.8
    @State private var page3TitleOpacity: Double = 0
    @State private var page3SubtitleOpacity: Double = 0
    @State private var page3ButtonOffset: CGFloat = 50
    @State private var page3ButtonOpacity: Double = 0
    
    // Page 3 - Pass & Play animation states
    @State private var page4LeftIconOpacity: Double = 0
    @State private var page4LeftIconScale: CGFloat = 0.8
    @State private var page4RightIconOpacity: Double = 0
    @State private var page4RightIconScale: CGFloat = 0.8
    @State private var page4TitleOpacity: Double = 0
    @State private var page4DescriptionOpacity: Double = 0
    @State private var page4ButtonOffset: CGFloat = 50
    @State private var page4ButtonOpacity: Double = 0
    
    // Page 4 - Pick a deck animation states
    @State private var page5IconOpacity: Double = 0
    @State private var page5IconScale: CGFloat = 0.8
    @State private var page5TitleOpacity: Double = 0
    @State private var page5DescriptionOpacity: Double = 0
    @State private var page5ButtonOffset: CGFloat = 50
    @State private var page5ButtonOpacity: Double = 0
    
    // Page 5 - All Set animation states
    @State private var page6LogoOpacity: Double = 0
    @State private var page6LogoScale: CGFloat = 0.8
    @State private var page6TitleOpacity: Double = 0
    @State private var page6DescriptionOpacity: Double = 0
    @State private var page6ButtonOffset: CGFloat = 50
    @State private var page6ButtonOpacity: Double = 0
    
    @State private var dragOffset: CGFloat = 0
    @State private var navigateToHome: Bool = false
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            // Page content with swipe gesture
            ZStack {
                // Page 1 - Referral Source
                if currentPage == 1 {
                    OnboardingReferralSourceView(
                        iconOpacity: $page2IconOpacity,
                        iconScale: $page2IconScale,
                        titleOpacity: $page2TitleOpacity,
                        descriptionOpacity: $page2DescriptionOpacity,
                        buttonOpacity: $page2ButtonOpacity,
                        buttonOffset: $page2ButtonOffset,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onContinue: {
                            navigateToPage(2)
                        }
                    )
                    .offset(x: dragOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .leading)
                    ))
                }
                
                // Page 2 - Welcome
                if currentPage == 2 {
                    OnboardingPage1(
                        logoOpacity: $page3LogoOpacity,
                        logoScale: $page3LogoScale,
                        titleOpacity: $page3TitleOpacity,
                        subtitleOpacity: $page3SubtitleOpacity,
                        buttonOffset: $page3ButtonOffset,
                        buttonOpacity: $page3ButtonOpacity,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onContinue: {
                            navigateToPage(3)
                        }
                    )
                    .offset(x: dragOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
                
                // Page 3 - Pass & Play
                if currentPage == 3 {
                    OnboardingPage3(
                        leftIconOpacity: $page4LeftIconOpacity,
                        leftIconScale: $page4LeftIconScale,
                        rightIconOpacity: $page4RightIconOpacity,
                        rightIconScale: $page4RightIconScale,
                        titleOpacity: $page4TitleOpacity,
                        descriptionOpacity: $page4DescriptionOpacity,
                        buttonOffset: $page4ButtonOffset,
                        buttonOpacity: $page4ButtonOpacity,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onNext: {
                            navigateToPage(4)
                        }
                    )
                    .offset(x: dragOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
                
                // Page 4 - Pick a deck
                if currentPage == 4 {
                    OnboardingPage2(
                        iconOpacity: $page5IconOpacity,
                        iconScale: $page5IconScale,
                        titleOpacity: $page5TitleOpacity,
                        descriptionOpacity: $page5DescriptionOpacity,
                        buttonOffset: $page5ButtonOffset,
                        buttonOpacity: $page5ButtonOpacity,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onNext: {
                            navigateToPage(5)
                        }
                    )
                    .offset(x: dragOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
                
                // Page 5 - All Set
                if currentPage == 5 {
                    OnboardingPage4(
                        logoOpacity: $page6LogoOpacity,
                        logoScale: $page6LogoScale,
                        titleOpacity: $page6TitleOpacity,
                        descriptionOpacity: $page6DescriptionOpacity,
                        buttonOffset: $page6ButtonOffset,
                        buttonOpacity: $page6ButtonOpacity,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onGetStarted: {
                            AnalyticsService.shared.trackOnboardingCompleted()
                            navigateToHome = true
                        }
                    )
                    .offset(x: dragOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Allow swiping in both directions
                        if value.translation.width < 0 && currentPage < totalPages {
                            // Swiping left (next)
                            dragOffset = value.translation.width
                        } else if value.translation.width > 0 && currentPage > 1 {
                            // Swiping right (previous)
                            dragOffset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 100
                        
                        if value.translation.width < -threshold && currentPage < totalPages {
                            // Swipe left - go to next page
                            navigateToPage(currentPage + 1)
                        } else if value.translation.width > threshold && currentPage > 1 {
                            // Swipe right - go to previous page
                            navigateToPreviousPage(currentPage - 1)
                        } else {
                            // Snap back
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    }
            )
            
        }
        .onAppear {
            if currentPage == 1 {
                startPage2Animations()
            }
        }
        .onChange(of: currentPage) { oldValue, newPage in
            dragOffset = 0
            if newPage == 1 {
                resetPage2Animations()
                startPage2Animations()
            } else if newPage == 2 {
                resetPage3Animations()
                startPage3Animations()
            } else if newPage == 3 {
                resetPage4Animations()
                startPage4Animations()
            } else if newPage == 4 {
                resetPage5Animations()
                startPage5Animations()
            } else if newPage == 5 {
                resetPage6Animations()
                startPage6Animations()
            }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
        }
        .onChange(of: navigateToHome) { newValue in
            if newValue {
                // Mark onboarding as completed when navigating to home
                OnboardingManager.shared.markOnboardingCompleted()
            }
        }
    }
    
    private func navigateToPage(_ page: Int) {
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPage = page
            dragOffset = 0
        }
        
        // Trigger page-specific animations
        if page == 1 {
            resetPage2Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage2Animations()
            }
        } else if page == 2 {
            resetPage3Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage3Animations()
            }
        } else if page == 3 {
            resetPage4Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage4Animations()
            }
        } else if page == 4 {
            resetPage5Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage5Animations()
            }
        } else if page == 5 {
            resetPage6Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage6Animations()
            }
        }
    }
    
    private func navigateToPreviousPage(_ page: Int) {
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPage = page
            dragOffset = 0
        }
        
        // Trigger page-specific animations for going back
        if page == 1 {
            resetPage2Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage2Animations()
            }
        } else if page == 2 {
            resetPage3Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage3Animations()
            }
        } else if page == 3 {
            resetPage4Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage4Animations()
            }
        } else if page == 4 {
            resetPage5Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage5Animations()
            }
        }
    }
    
    // Page 1 - Referral Source animations
    private func resetPage2Animations() {
        page2IconOpacity = 0
        page2IconScale = 0.8
        page2TitleOpacity = 0
        page2DescriptionOpacity = 0
        page2ButtonOffset = 50
        page2ButtonOpacity = 0
    }
    
    private func startPage2Animations() {
        // Icon fade + scale animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            page2IconOpacity = 1.0
            page2IconScale = 1.0
        }
        
        // Title fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.6)) {
                page2TitleOpacity = 1.0
            }
        }
        
        // Description fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.6)) {
                page2DescriptionOpacity = 1.0
            }
        }
        
        // Button slide up animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                page2ButtonOffset = 0
                page2ButtonOpacity = 1.0
            }
        }
    }
    
    // Page 2 - Welcome animations
    private func resetPage3Animations() {
        page3LogoOpacity = 0
        page3LogoScale = 0.8
        page3TitleOpacity = 0
        page3SubtitleOpacity = 0
        page3ButtonOffset = 50
        page3ButtonOpacity = 0
    }
    
    private func startPage3Animations() {
        // Logo fade + scale animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            page3LogoOpacity = 1.0
            page3LogoScale = 1.0
        }
        
        // Title fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.6)) {
                page3TitleOpacity = 1.0
            }
        }
        
        // Subtitle fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.6)) {
                page3SubtitleOpacity = 1.0
            }
        }
        
        // Button slide up animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                page3ButtonOffset = 0
                page3ButtonOpacity = 1.0
            }
        }
    }
    
    // Page 3 - Pass & Play animations
    private func resetPage4Animations() {
        page4LeftIconOpacity = 0
        page4LeftIconScale = 0.8
        page4RightIconOpacity = 0
        page4RightIconScale = 0.8
        page4TitleOpacity = 0
        page4DescriptionOpacity = 0
        page4ButtonOffset = 50
        page4ButtonOpacity = 0
    }
    
    private func startPage4Animations() {
        // Left icon fade + scale animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            page4LeftIconOpacity = 1.0
            page4LeftIconScale = 1.0
        }
        
        // Right icon fade + scale animation (slight delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                page4RightIconOpacity = 1.0
                page4RightIconScale = 1.0
            }
        }
        
        // Title fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.6)) {
                page4TitleOpacity = 1.0
            }
        }
        
        // Description fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.6)) {
                page4DescriptionOpacity = 1.0
            }
        }
        
        // Button slide up animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                page4ButtonOffset = 0
                page4ButtonOpacity = 1.0
            }
        }
    }
    
    // Page 5 - Pick a deck animations
    private func resetPage5Animations() {
        page5IconOpacity = 0
        page5IconScale = 0.8
        page5TitleOpacity = 0
        page5DescriptionOpacity = 0
        page5ButtonOffset = 50
        page5ButtonOpacity = 0
    }
    
    private func startPage5Animations() {
        // Icon fade + scale animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            page5IconOpacity = 1.0
            page5IconScale = 1.0
        }
        
        // Title fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.6)) {
                page5TitleOpacity = 1.0
            }
        }
        
        // Description fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.6)) {
                page5DescriptionOpacity = 1.0
            }
        }
        
        // Button slide up animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                page5ButtonOffset = 0
                page5ButtonOpacity = 1.0
            }
        }
    }
    
    // Page 5 - All Set animations
    private func resetPage6Animations() {
        page6LogoOpacity = 0
        page6LogoScale = 0.8
        page6TitleOpacity = 0
        page6DescriptionOpacity = 0
        page6ButtonOffset = 50
        page6ButtonOpacity = 0
    }
    
    private func startPage6Animations() {
        // Logo fade + scale animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            page6LogoOpacity = 1.0
            page6LogoScale = 1.0
        }
        
        // Title fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.6)) {
                page6TitleOpacity = 1.0
            }
        }
        
        // Description fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.6)) {
                page6DescriptionOpacity = 1.0
            }
        }
        
        // Button slide up animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                page6ButtonOffset = 0
                page6ButtonOpacity = 1.0
            }
        }
    }
}

struct OnboardingPage1: View {
    @Binding var logoOpacity: Double
    @Binding var logoScale: CGFloat
    @Binding var titleOpacity: Double
    @Binding var subtitleOpacity: Double
    @Binding var buttonOffset: CGFloat
    @Binding var buttonOpacity: Double
    let currentPage: Int
    let totalPages: Int
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App logo
            Image("TheSocialDeckLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .opacity(logoOpacity)
                .scaleEffect(logoScale)
            
            // Title
            Text("Welcome to The Social Deck")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .opacity(titleOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Subtitle
            Text("The ultimate card game for parties, groups, and good times.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                .opacity(subtitleOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Continue button
            Button(action: {
                onContinue()
            }) {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(12)
            }
            .offset(y: buttonOffset)
            .opacity(buttonOpacity)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            
            // Page indicator
            PageIndicator(currentPage: currentPage, totalPages: totalPages)
                .padding(.bottom, 50)
        }
    }
}

struct OnboardingPage2: View {
    @Binding var iconOpacity: Double
    @Binding var iconScale: CGFloat
    @Binding var titleOpacity: Double
    @Binding var descriptionOpacity: Double
    @Binding var buttonOffset: CGFloat
    @Binding var buttonOpacity: Double
    let currentPage: Int
    let totalPages: Int
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Card icon
            Image(systemName: "rectangle.fill.on.rectangle.fill")
                .font(.system(size: 100))
                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                .opacity(iconOpacity)
                .scaleEffect(iconScale)
            
            // Title
            Text("Pick a deck. Flip a card. Have fun.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .opacity(titleOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Description
            Text("Choose from tons of party decks designed to keep the group laughing, talking, and competing.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                .opacity(descriptionOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .frame(maxWidth: 350)
            
            Spacer()
            
            // Next button
            Button(action: {
                onNext()
            }) {
                Text("Next")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(12)
            }
            .offset(y: buttonOffset)
            .opacity(buttonOpacity)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            
            // Page indicator
            PageIndicator(currentPage: currentPage, totalPages: totalPages)
                .padding(.bottom, 50)
        }
    }
}

struct OnboardingPage3: View {
    @Binding var leftIconOpacity: Double
    @Binding var leftIconScale: CGFloat
    @Binding var rightIconOpacity: Double
    @Binding var rightIconScale: CGFloat
    @Binding var titleOpacity: Double
    @Binding var descriptionOpacity: Double
    @Binding var buttonOffset: CGFloat
    @Binding var buttonOpacity: Double
    let currentPage: Int
    let totalPages: Int
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon row - person.3.fill and arrow.right.circle.fill (passing)
            HStack(spacing: 60) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .opacity(leftIconOpacity)
                    .scaleEffect(leftIconScale)
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .opacity(rightIconOpacity)
                    .scaleEffect(rightIconScale)
            }
            
            // Title
            Text("Pass & Play with Friends")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .opacity(titleOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Description
            Text("Gather around and pass the device. Everyone takes turns, making it easy to play together in the same room.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                .opacity(descriptionOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .frame(maxWidth: 350)
            
            Spacer()
            
            // Next button
            Button(action: {
                onNext()
            }) {
                Text("Next")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(12)
            }
            .offset(y: buttonOffset)
            .opacity(buttonOpacity)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            
            // Page indicator
            PageIndicator(currentPage: currentPage, totalPages: totalPages)
                .padding(.bottom, 50)
        }
    }
}

struct OnboardingPage4: View {
    @Binding var logoOpacity: Double
    @Binding var logoScale: CGFloat
    @Binding var titleOpacity: Double
    @Binding var descriptionOpacity: Double
    @Binding var buttonOffset: CGFloat
    @Binding var buttonOpacity: Double
    let currentPage: Int
    let totalPages: Int
    let onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Art 1.4 image
            Image("Art 1.4")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .opacity(logoOpacity)
                .scaleEffect(logoScale)
            
            // Title
            Text("You're all set!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                .opacity(titleOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Description
            Text("Start exploring decks, play with friends, and enjoy The Social Deck.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                .opacity(descriptionOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .frame(maxWidth: 350)
            
            Spacer()
            
            // Get Started button
            Button(action: {
                onGetStarted()
            }) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    .cornerRadius(12)
            }
            .offset(y: buttonOffset)
            .opacity(buttonOpacity)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            
            // Page indicator
            PageIndicator(currentPage: currentPage, totalPages: totalPages)
                .padding(.bottom, 50)
        }
    }
}

// Page Indicator Component
struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color.gray.opacity(0.3))
                    .frame(width: page == currentPage ? 10 : 8, height: page == currentPage ? 10 : 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView()
}

