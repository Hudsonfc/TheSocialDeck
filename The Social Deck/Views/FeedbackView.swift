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
    @State private var showSubmittedAlert: Bool = false
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Title
                    Text("Feedback")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Subtitle
                    Text("We'd love to hear from you! Your feedback helps us improve The Social Deck and create a better experience for everyone. Whether you have a suggestion, found a bug, or just want to share your thoughts, we're all ears. Please describe your feedback in detail below.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)
                    
                    // Message Input Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Your Message")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .padding(.top, 40)
                        
                        ZStack(alignment: .topLeading) {
                            if feedbackMessage.isEmpty {
                                Text("Share your thoughts, report issues, or suggest improvements...")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                                    .allowsHitTesting(false)
                            }
                            
                            TextEditor(text: $feedbackMessage)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                .frame(minHeight: 200)
                                .scrollContentBackground(.hidden)
                                .lineSpacing(4)
                        }
                        .padding(4)
                        .background(Color(red: 0xF9/255.0, green: 0xF9/255.0, blue: 0xF9/255.0))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(feedbackMessage.isEmpty ? Color(red: 0xE1/255.0, green: 0xE1/255.0, blue: 0xE1/255.0) : Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: feedbackMessage.isEmpty ? 1 : 2)
                        )
                    }
                    .padding(.top, 32)
                    
                    // Submit Button
                    Button(action: {
                        // Placeholder - no backend yet
                        showSubmittedAlert = true
                        feedbackMessage = ""
                    }) {
                        Text("Submit Feedback")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(feedbackMessage.isEmpty ? Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0) : Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    .disabled(feedbackMessage.isEmpty)
                    .padding(.top, 32)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: feedbackMessage.isEmpty)
                    
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
        .alert("Thank You!", isPresented: $showSubmittedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your feedback has been received. Thank you for helping us improve!")
        }
    }
}
