//
//  OnlineRoomView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct OnlineRoomView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Room Code Header
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .frame(height: 60)
                        .overlay(
                            Text("Room Code: ABCD")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        )
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                    
                    // Player List
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .frame(height: 200)
                        .overlay(
                            Text("Players in room")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        )
                        .padding(.horizontal, 40)
                    
                    // Placeholder Card Area
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .frame(height: 220)
                        .overlay(
                            Text("Card will appear here")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        )
                        .padding(.horizontal, 40)
                    
                    // Bottom Buttons
                    VStack(spacing: 16) {
                        // Leave Room Button
                        Button(action: {
                            // No action yet
                        }) {
                            Text("Leave Room")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .cornerRadius(16)
                        }
                        
                        // Ready Button
                        Button(action: {
                            // No action yet
                        }) {
                            Text("Ready")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), lineWidth: 2)
                                )
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
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

#Preview {
    NavigationView {
        OnlineRoomView()
    }
}

