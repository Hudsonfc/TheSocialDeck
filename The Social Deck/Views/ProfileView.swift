//
//  ProfileView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Your Profile")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                    
                    // Avatar Placeholder
                    ZStack {
                        Circle()
                            .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                            .frame(width: 120, height: 120)
                        
                        Text("Avatar")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                    
                    // Username Placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .frame(width: UIScreen.main.bounds.width * 0.7, height: 50)
                        .overlay(
                            Text("Username")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        )
                    
                    // Stats Placeholder Section
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 150)
                        .overlay(
                            Text("Stats Coming Soon")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.gray)
                        )
                    
                    // Bottom placeholder text
                    Text("Profile features will be added later.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color.gray)
                        .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
