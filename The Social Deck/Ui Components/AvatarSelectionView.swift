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
        "avatar 1",
        "avatar 2",
        "avatar 3",
        "avatar 4",
        "avatar 5",
        "avatar 6",
        "avatar 7"
    ]
    
    let avatarColors: [(String, Color)] = [
        ("red", Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)),
        ("blue", Color(red: 0x1E/255.0, green: 0x88/255.0, blue: 0xE5/255.0)),
        ("green", Color(red: 0x2E/255.0, green: 0x7D/255.0, blue: 0x32/255.0)),
        ("purple", Color(red: 0x9C/255.0, green: 0x27/255.0, blue: 0xB0/255.0)),
        ("orange", Color(red: 0xF5/255.0, green: 0x7C/255.0, blue: 0x00/255.0)),
        ("pink", Color(red: 0xE9/255.0, green: 0x1E/255.0, blue: 0x63/255.0)),
        ("teal", Color(red: 0x00/255.0, green: 0x96/255.0, blue: 0x88/255.0)),
        ("yellow", Color(red: 0xF9/255.0, green: 0xA8/255.0, blue: 0x25/255.0)),
        ("cyan", Color(red: 0x00/255.0, green: 0xBC/255.0, blue: 0xD4/255.0)),
        ("indigo", Color(red: 0x3F/255.0, green: 0x51/255.0, blue: 0xB5/255.0)),
        ("brown", Color(red: 0x79/255.0, green: 0x55/255.0, blue: 0x48/255.0)),
        ("mint", Color(red: 0x00/255.0, green: 0xC8/255.0, blue: 0x96/255.0)),
        ("lime", Color(red: 0xCD/255.0, green: 0xDC/255.0, blue: 0x39/255.0)),
        ("coral", Color(red: 0xFF/255.0, green: 0x7F/255.0, blue: 0x50/255.0)),
        ("lavender", Color(red: 0xE1/255.0, green: 0xBE/255.0, blue: 0xE7/255.0)),
        ("navy", Color(red: 0x00/255.0, green: 0x1F/255.0, blue: 0x3F/255.0))
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
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Choose Avatar")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .padding(.horizontal, 40)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
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
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // Colors Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Choose Color")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .padding(.horizontal, 40)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
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
                            .padding(.vertical, 4)
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
    
    private var isImageAsset: Bool {
        avatarType.hasPrefix("avatar ")
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? selectedColor.opacity(0.15) : Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                    .frame(width: 76, height: 76)
                    .shadow(color: isSelected ? selectedColor.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
                
                if isImageAsset {
                    Image(avatarType)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .opacity(isSelected ? 1.0 : 0.7)
                } else {
                    Image(systemName: avatarType)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(isSelected ? selectedColor : Color(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0))
                }
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedColor, lineWidth: 3)
                        .frame(width: 76, height: 76)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 3.5)
                        .frame(width: 64, height: 64)
                } else {
                    Circle()
                        .stroke(Color(red: 0xE5/255.0, green: 0xE5/255.0, blue: 0xE5/255.0), lineWidth: 2.5)
                        .frame(width: 64, height: 64)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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
            "yellow": Color(red: 0xF9/255.0, green: 0xA8/255.0, blue: 0x25/255.0),
            "cyan": Color(red: 0x00/255.0, green: 0xBC/255.0, blue: 0xD4/255.0),
            "indigo": Color(red: 0x3F/255.0, green: 0x51/255.0, blue: 0xB5/255.0),
            "brown": Color(red: 0x79/255.0, green: 0x55/255.0, blue: 0x48/255.0),
            "mint": Color(red: 0x00/255.0, green: 0xC8/255.0, blue: 0x96/255.0),
            "lime": Color(red: 0xCD/255.0, green: 0xDC/255.0, blue: 0x39/255.0),
            "coral": Color(red: 0xFF/255.0, green: 0x7F/255.0, blue: 0x50/255.0),
            "lavender": Color(red: 0xE1/255.0, green: 0xBE/255.0, blue: 0xE7/255.0),
            "navy": Color(red: 0x00/255.0, green: 0x1F/255.0, blue: 0x3F/255.0)
        ]
        return colors[avatarColor] ?? colors["red"]!
    }
    
    private var isImageAsset: Bool {
        avatarType.hasPrefix("avatar ")
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
            
            if isImageAsset {
                Image(avatarType)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.8, height: size * 0.8)
                    .clipShape(Circle())
            } else {
                Image(systemName: avatarType)
                    .font(.system(size: size * 0.5, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    NavigationView {
        AvatarSelectionView(
            selectedAvatarType: .constant("avatar 1"),
            selectedAvatarColor: .constant("red")
        )
    }
}

