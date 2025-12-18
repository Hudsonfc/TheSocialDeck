//
//  LeaveRoomConfirmationView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct LeaveRoomConfirmationView: View {
    let isHost: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0).opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                    }
                    .padding(.top, 32)
                    
                    // Title
                    Text("Leave Room?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    // Message
                    Text(message)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 32)
                .padding(.horizontal, 32)
                
                // Buttons
                VStack(spacing: 12) {
                    // Leave button
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        onConfirm()
                    }) {
                        Text("Leave Room")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(14)
                    }
                    
                    // Cancel button
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onCancel()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    private var message: String {
        if isHost {
            return "You are the host. Leaving will transfer host to another player. Are you sure you want to leave?"
        } else {
            return "Are you sure you want to leave this room? You'll need the room code to rejoin."
        }
    }
}

