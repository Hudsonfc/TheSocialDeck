//
//  JoinRoomView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct JoinRoomView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Top Title
                    VStack(spacing: 8) {
                        Text("Join Room")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        Text("Enter the room code to join")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                    .multilineTextAlignment(.center)
                    
                    // Room Code Input Section
                    VStack(spacing: 16) {
                        // Icon
                        Image(systemName: "key.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .padding(.bottom, 8)
                        
                        // Room Code Input Placeholder
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .frame(height: 60)
                            .overlay(
                                HStack {
                                    Text("Enter Code")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundColor(Color.gray)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            )
                            .padding(.horizontal, 40)
                    }
                    
                    // Join Button
                    NavigationLink(destination: OnlineRoomView()) {
                        Text("Join Room")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    
                    // Placeholder Lobby Area
                    VStack(spacing: 12) {
                        Text("Room Preview")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .frame(height: 160)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color.gray.opacity(0.6))
                                    Text("Room preview will appear here")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(Color.gray)
                                }
                            )
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    Spacer()
                        .frame(height: 40)
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
        JoinRoomView()
    }
}

