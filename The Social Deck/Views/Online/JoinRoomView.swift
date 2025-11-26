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
                VStack(spacing: 24) {
                    // Top Title
                    Text("Join Room")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                    
                    // Room Code Input Placeholder
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .frame(height: 60)
                        .overlay(
                            Text("Enter Code")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        )
                        .padding(.horizontal, 40)
                    
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
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .frame(height: 160)
                        .overlay(
                            Text("Room preview will appear here")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        )
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
        JoinRoomView()
    }
}

