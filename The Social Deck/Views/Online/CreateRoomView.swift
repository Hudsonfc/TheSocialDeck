//
//  CreateRoomView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct CreateRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var roomName: String = ""
    @State private var maxPlayers: Int = 4
    @State private var isPrivate: Bool = false
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Top Title
                    Text("Create Room")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                    
                    // Room Settings
                    VStack(spacing: 20) {
                        // Room Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Room Name")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            TextField("Enter room name", text: $roomName)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                .cornerRadius(12)
                        }
                        
                        // Max Players
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Max Players")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            HStack(spacing: 12) {
                                ForEach([2, 4, 6, 8], id: \.self) { count in
                                    Button(action: {
                                        maxPlayers = count
                                    }) {
                                        Text("\(count)")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(maxPlayers == count ? .white : Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                                            .frame(width: 60, height: 44)
                                            .background(maxPlayers == count ? Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) : Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        
                        // Privacy Toggle
                        HStack {
                            Text("Private Room")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            
                            Spacer()
                            
                            Toggle("", isOn: $isPrivate)
                                .tint(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 40)
                    
                    // Create Button
                    NavigationLink(destination: OnlineRoomView()) {
                        Text("Create Room")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            .cornerRadius(16)
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
        CreateRoomView()
    }
}

