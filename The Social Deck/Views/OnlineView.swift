//
//  OnlineView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct OnlineView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onlineManager = OnlineManager.shared
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Online Play")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                    
                    // Create Room Button
                    NavigationLink(destination: CreateRoomView()) {
                        Text("Create Room")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    
                    // Join Room Button
                    NavigationLink(destination: JoinRoomView()) {
                        Text("Join Room")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    
                    // Room Invites Button
                    NavigationLink(destination: RoomInvitesView()) {
                        ZStack {
                            Text("Room Invites")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            if !onlineManager.pendingRoomInvites.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("\(onlineManager.pendingRoomInvites.count)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.red)
                                        .clipShape(Capsule())
                                        .padding(.trailing, 16)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                        .frame(height: 20)
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
        .onAppear {
            Task {
                await onlineManager.loadPendingRoomInvites()
            }
        }
    }
}

#Preview {
    NavigationView {
        OnlineView()
    }
}
