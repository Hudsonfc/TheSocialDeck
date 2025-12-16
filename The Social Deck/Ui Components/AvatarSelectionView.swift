//
//  AvatarSelectionView.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

struct AvatarSelectionView: View {
    @Binding var selectedAvatarType: String
    @Binding var selectedAvatarColor: String
    @Environment(\.dismiss) private var dismiss
    
    let avatarTypes = [
        "person.fill",
        "person.circle.fill",
        "person.2.fill",
        "star.fill",
        "heart.fill",
        "gamecontroller.fill",
        "flame.fill",
        "crown.fill",
        "sparkles",
        "bolt.fill",
        "trophy.fill",
        "sun.max.fill"
    ]
    
    let avatarColors: [(String, Color)] = [
        ("red", Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)),
        ("blue", Color(red: 0x1E/255.0, green: 0x88/255.0, blue: 0xE5/255.0)),
        ("green", Color(red: 0x2E/255.0, green: 0x7D/255.0, blue: 0x32/255.0)),
        ("purple", Color(red: 0x9C/255.0, green: 0x27/255.0, blue: 0xB0/255.0)),
        ("orange", Color(red: 0xF5/255.0, green: 0x7C/255.0, blue: 0x00/255.0)),
        ("pink", Color(red: 0xE9/255.0, green: 0x1E/255.0, blue: 0x63/255.0)),
        ("teal", Color(red: 0x00/255.0, green: 0x96/255.0, blue: 0x88/255.0)),
        ("yellow", Color(red: 0xF9/255.0, green: 0xA8/255.0, blue: 0x25/255.0))
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Title
                    Text("Choose Your Avatar")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                        .padding(.top, 20)
                    
                    // Preview
                    VStack(spacing: 16) {
                        Text("Preview")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.gray)
                        
                        AvatarView(
                            avatarType: selectedAvatarType,
                            avatarColor: selectedAvatarColor,
                            size: 100
                        )
                    }
                    .padding(.vertical, 20)
                    
                    // Avatar Types Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Icon")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .padding(.horizontal, 40)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(avatarTypes, id: \.self) { avatarType in
                                    AvatarTypeButton(
                                        avatarType: avatarType,
                                        isSelected: selectedAvatarType == avatarType,
                                        selectedColor: getColorFromString(selectedAvatarColor)
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedAvatarType = avatarType
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    
                    // Colors Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Color")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .padding(.horizontal, 40)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(avatarColors, id: \.0) { colorName, color in
                                    ColorButton(
                                        color: color,
                                        isSelected: selectedAvatarColor == colorName
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedAvatarColor = colorName
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    
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
    }
    
    private func getColorFromString(_ colorName: String) -> Color {
        return avatarColors.first { $0.0 == colorName }?.1 ?? avatarColors[0].1
    }
}

// MARK: - Avatar Type Button
struct AvatarTypeButton: View {
    let avatarType: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? selectedColor.opacity(0.2) : Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0))
                    .frame(width: 70, height: 70)
                
                Image(systemName: avatarType)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(isSelected ? selectedColor : Color.gray)
                
                if isSelected {
                    Circle()
                        .stroke(selectedColor, lineWidth: 3)
                        .frame(width: 70, height: 70)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Color Button
struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 56, height: 56)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 56, height: 56)
                } else {
                    Circle()
                        .stroke(Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0), lineWidth: 2)
                        .frame(width: 56, height: 56)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Avatar View Component
struct AvatarView: View {
    let avatarType: String
    let avatarColor: String
    let size: CGFloat
    
    private var color: Color {
        let colors: [String: Color] = [
            "red": Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0),
            "blue": Color(red: 0x1E/255.0, green: 0x88/255.0, blue: 0xE5/255.0),
            "green": Color(red: 0x2E/255.0, green: 0x7D/255.0, blue: 0x32/255.0),
            "purple": Color(red: 0x9C/255.0, green: 0x27/255.0, blue: 0xB0/255.0),
            "orange": Color(red: 0xF5/255.0, green: 0x7C/255.0, blue: 0x00/255.0),
            "pink": Color(red: 0xE9/255.0, green: 0x1E/255.0, blue: 0x63/255.0),
            "teal": Color(red: 0x00/255.0, green: 0x96/255.0, blue: 0x88/255.0),
            "yellow": Color(red: 0xF9/255.0, green: 0xA8/255.0, blue: 0x25/255.0)
        ]
        return colors[avatarColor] ?? colors["red"]!
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
            
            Image(systemName: avatarType)
                .font(.system(size: size * 0.5, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    NavigationView {
        AvatarSelectionView(
            selectedAvatarType: .constant("person.fill"),
            selectedAvatarColor: .constant("red")
        )
    }
}

