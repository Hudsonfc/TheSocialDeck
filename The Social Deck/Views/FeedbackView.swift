//
//  FeedbackView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackMessage: String = ""
    @State private var showSuccessOverlay: Bool = false
    @State private var showSuccessAnimation: Bool = false
    @State private var submitButtonPressed = false
    
    var body: some View {
        ZStack {
            // Dark adaptive background
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Title
                        Text("Feedback")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Subtitle
                    Text("We'd love to hear from you! Your feedback helps us improve The Social Deck and create a better experience for everyone. Whether you have a suggestion, found a bug, or just want to share your thoughts, we're all ears. Please describe your feedback in detail below.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)
                    
                    // Message Input Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Your Message")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .padding(.top, 40)
                        
                        ZStack(alignment: .topLeading) {
                            if feedbackMessage.isEmpty {
                                Text("Share your thoughts, report issues, or suggest improvements...")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.tertiaryText)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                                    .allowsHitTesting(false)
                            }
                            
                            TextEditor(text: $feedbackMessage)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primaryText)
                                .frame(minHeight: 200)
                                .scrollContentBackground(.hidden)
                                .lineSpacing(4)
                        }
                        .padding(4)
                        .background(Color.secondaryBackground)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(feedbackMessage.isEmpty ? Color.borderColor : Color.buttonBackground, lineWidth: feedbackMessage.isEmpty ? 1 : 2)
                        )
                    }
                    .padding(.top, 32)
                    
                    // Submit Button
                    Button(action: {
                        HapticManager.shared.success()
                        showSuccessAnimation = true
                        feedbackMessage = ""
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                showSuccessOverlay = true
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation {
                                showSuccessAnimation = false
                            }
                        }
                    }) {
                        HStack {
                            if showSuccessAnimation {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Text("Submit Feedback")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(feedbackMessage.isEmpty ? Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0) : Color.buttonBackground)
                        .cornerRadius(16)
                    }
                    .disabled(feedbackMessage.isEmpty)
                    .scaleEffect(submitButtonPressed ? 0.97 : 1.0)
                    .padding(.top, 32)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: feedbackMessage.isEmpty)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showSuccessAnimation)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !feedbackMessage.isEmpty {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        submitButtonPressed = true
                                    }
                                    HapticManager.shared.lightImpact()
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    submitButtonPressed = false
                                }
                            }
                    )
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 40)
            }
            
            // Custom Success Overlay
            ZStack {
                if showSuccessOverlay {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack(spacing: 24) {
                        Image("star man happy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        
                        VStack(spacing: 12) {
                            Text("Thank You!")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primaryText)
                            
                            Text("Your feedback has been received. Thank you for helping us improve!")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                showSuccessOverlay = false
                            }
                            HapticManager.shared.lightImpact()
                        }) {
                            Text("OK")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 120)
                                .padding(.vertical, 14)
                                .background(Color.buttonBackground)
                                .cornerRadius(16)
                        }
                    }
                    .padding(32)
                    .background(Color.cardBackground)
                    .cornerRadius(24)
                    .shadow(color: Color.cardShadowColor, radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 40)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: showSuccessOverlay)
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
}
