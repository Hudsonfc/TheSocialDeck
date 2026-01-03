//
//  OnboardingView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage: Int = 1
    private let totalPages: Int = 4 // Update this when adding more pages
    
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 50
    @State private var buttonOpacity: Double = 0
    
    // Page 2 animation states (now for Pass & Play - needs two icons)
    @State private var page2IconOpacity: Double = 0  // left icon
    @State private var page2IconScale: CGFloat = 0.8
    @State private var page2RightIconOpacity: Double = 0  // right icon
    @State private var page2RightIconScale: CGFloat = 0.8
    @State private var page2TitleOpacity: Double = 0
    @State private var page2DescriptionOpacity: Double = 0
    @State private var page2ButtonOffset: CGFloat = 50
    @State private var page2ButtonOpacity: Double = 0
    
    // Page 3 animation states
    @State private var page3LeftIconOpacity: Double = 0
    @State private var page3LeftIconScale: CGFloat = 0.8
    @State private var page3RightIconOpacity: Double = 0
    @State private var page3RightIconScale: CGFloat = 0.8
    @State private var page3TitleOpacity: Double = 0
    @State private var page3DescriptionOpacity: Double = 0
    @State private var page3ButtonOffset: CGFloat = 50
    @State private var page3ButtonOpacity: Double = 0
    
    // Page 4 animation states
    @State private var page4LogoOpacity: Double = 0
    @State private var page4LogoScale: CGFloat = 0.8
    @State private var page4TitleOpacity: Double = 0
    @State private var page4DescriptionOpacity: Double = 0
    @State private var page4ButtonOffset: CGFloat = 50
    @State private var page4ButtonOpacity: Double = 0
    
    @State private var dragOffset: CGFloat = 0
    @State private var navigateToHome: Bool = false
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            // Page content with swipe gesture
            ZStack {
                // Page 1
                if currentPage == 1 {
                    OnboardingPage1(
                        logoOpacity: $logoOpacity,
                        logoScale: $logoScale,
                        titleOpacity: $titleOpacity,
                        subtitleOpacity: $subtitleOpacity,
                        buttonOffset: $buttonOffset,
                        buttonOpacity: $buttonOpacity,
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
                
                // Page 2 - Pass & Play (swapped from page 3)
                if currentPage == 2 {
                    OnboardingPage3(
                        leftIconOpacity: $page2IconOpacity,
                        leftIconScale: $page2IconScale,
                        rightIconOpacity: $page2RightIconOpacity,
                        rightIconScale: $page2RightIconScale,
                        titleOpacity: $page2TitleOpacity,
                        descriptionOpacity: $page2DescriptionOpacity,
                        buttonOffset: $page2ButtonOffset,
                        buttonOpacity: $page2ButtonOpacity,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onNext: {
                            navigateToPage(3)
                        }
                    )
                    .offset(x: dragOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
                
                // Page 3 - Pick a deck (swapped from page 2)
                if currentPage == 3 {
                    OnboardingPage2(
                        iconOpacity: $page3LeftIconOpacity,
                        iconScale: $page3LeftIconScale,
                        titleOpacity: $page3TitleOpacity,
                        descriptionOpacity: $page3DescriptionOpacity,
                        buttonOffset: $page3ButtonOffset,
                        buttonOpacity: $page3ButtonOpacity,
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
                
                // Page 4
                if currentPage == 4 {
                    OnboardingPage4(
                        logoOpacity: $page4LogoOpacity,
                        logoScale: $page4LogoScale,
                        titleOpacity: $page4TitleOpacity,
                        descriptionOpacity: $page4DescriptionOpacity,
                        buttonOffset: $page4ButtonOffset,
                        buttonOpacity: $page4ButtonOpacity,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onGetStarted: {
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
            
            // Skip button (only show on pages 1-3)
            if currentPage < totalPages {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            navigateToHome = true
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 20)
                    Spacer()
                }
            }
        }
        .onAppear {
            if currentPage == 1 {
                startPage1Animations()
            }
        }
        .onChange(of: currentPage) { oldValue, newPage in
            dragOffset = 0
            if newPage == 1 {
                resetPage1Animations()
                startPage1Animations()
            } else if newPage == 2 {
                resetPage2Animations()
                startPage2Animations()
            } else if newPage == 3 {
                resetPage3Animations()
                startPage3Animations()
            } else if newPage == 4 {
                resetPage4Animations()
                startPage4Animations()
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
            resetPage1Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage1Animations()
            }
        } else if page == 2 {
            resetPage2Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage2Animations()
            }
        } else if page == 3 {
            resetPage3Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage3Animations()
            }
        } else if page == 4 {
            resetPage4Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage4Animations()
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
            resetPage1Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage1Animations()
            }
        } else if page == 2 {
            resetPage2Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage2Animations()
            }
        } else if page == 3 {
            resetPage3Animations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startPage3Animations()
            }
        }
    }
    
    private func resetPage1Animations() {
        logoOpacity = 0
        logoScale = 0.8
        titleOpacity = 0
        subtitleOpacity = 0
        buttonOffset = 50
        buttonOpacity = 0
    }
    
    private func startPage1Animations() {
        // Logo fade + scale animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            logoOpacity = 1.0
            logoScale = 1.0
        }
        
        // Title fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.6)) {
                titleOpacity = 1.0
            }
        }
        
        // Subtitle fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.6)) {
                subtitleOpacity = 1.0
            }
        }
        
        // Button slide up animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                buttonOffset = 0
                buttonOpacity = 1.0
            }
        }
    }
    
    private func resetPage2Animations() {
        // Reset for Pass & Play page (now page 2, uses two icons)
        page2IconOpacity = 0  // left icon
        page2IconScale = 0.8
        page2RightIconOpacity = 0  // right icon
        page2RightIconScale = 0.8
        page2TitleOpacity = 0
        page2DescriptionOpacity = 0
        page2ButtonOffset = 50
        page2ButtonOpacity = 0
    }
    
    private func startPage2Animations() {
        // Pass & Play page animations (now page 2, uses two icons)
        // Left icon fade + scale animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            page2IconOpacity = 1.0
            page2IconScale = 1.0
        }
        
        // Right icon fade + scale animation (slight delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                page2RightIconOpacity = 1.0
                page2RightIconScale = 1.0
            }
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
    
    private func resetPage3Animations() {
        // Reset for Pick a deck page (now page 3, uses single icon)
        page3LeftIconOpacity = 0  // single icon
        page3LeftIconScale = 0.8
        page3TitleOpacity = 0
        page3DescriptionOpacity = 0
        page3ButtonOffset = 50
        page3ButtonOpacity = 0
    }
    
    private func startPage3Animations() {
        // Pick a deck page animations (now page 3, uses single icon)
        // Icon fade + scale animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            page3LeftIconOpacity = 1.0
            page3LeftIconScale = 1.0
        }
        
        // Title fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.6)) {
                page3TitleOpacity = 1.0
            }
        }
        
        // Description fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.6)) {
                page3DescriptionOpacity = 1.0
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
    
    private func resetPage4Animations() {
        page4LogoOpacity = 0
        page4LogoScale = 0.8
        page4TitleOpacity = 0
        page4DescriptionOpacity = 0
        page4ButtonOffset = 50
        page4ButtonOpacity = 0
    }
    
    private func startPage4Animations() {
        // Logo fade + scale animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            page4LogoOpacity = 1.0
            page4LogoScale = 1.0
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

