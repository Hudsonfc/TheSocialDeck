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
    @EnvironmentObject private var subManager: SubscriptionManager
    @EnvironmentObject private var avatarStore: AvatarStoreManager
    
    @State private var purchaseSheetAvatar: PremiumAvatarDefinition?
    @State private var showPurchaseError = false
    
    private let freeColors: Set<String> = ["red", "blue", "green"]
    
    private func isLocked(_ colorName: String) -> Bool {
        !freeColors.contains(colorName) && !subManager.isPlus
    }
    
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
                    
                    // Premium avatars
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Premium Avatars")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            .padding(.horizontal, 40)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(PremiumAvatarDefinition.allCases) { definition in
                                    PremiumAvatarPickerButton(
                                        definition: definition,
                                        isSelected: selectedAvatarType == definition.imageAssetName,
                                        selectedColor: getColorFromString(selectedAvatarColor),
                                        isUnlocked: avatarStore.isUnlocked(definition),
                                        displayPrice: avatarStore.displayPrice(for: definition)
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedAvatarType = definition.imageAssetName
                                        }
                                    } onLockedTap: {
                                        purchaseSheetAvatar = definition
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.vertical, 4)
                        }
                        
                        Button(action: {
                            Task { await avatarStore.restorePurchases() }
                        }) {
                            Text("Restore Purchases")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        }
                        .padding(.horizontal, 40)
                        .disabled(avatarStore.isRestoring)
                    }
                    
                    // Colors Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 8) {
                            Text("Choose Color")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                            if !subManager.isPlus {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 10, weight: .bold))
                                    Text("More with Plus")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(avatarColors, id: \.0) { colorName, color in
                                    if isLocked(colorName) {
                                        LockedColorButton(color: color)
                                    } else {
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
        .onAppear {
            Task { await avatarStore.loadProducts() }
        }
        .sheet(item: $purchaseSheetAvatar) { definition in
            PremiumAvatarPurchaseSheet(
                definition: definition,
                displayPrice: avatarStore.displayPrice(for: definition),
                ringColor: getColorFromString(selectedAvatarColor),
                avatarStore: avatarStore,
                onPurchased: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedAvatarType = definition.imageAssetName
                    }
                },
                onDismissSheet: { purchaseSheetAvatar = nil }
            )
            .presentationDetents([.height(410)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .alert("Purchase", isPresented: $showPurchaseError) {
            Button("OK", role: .cancel) {
                avatarStore.clearLastError()
            }
        } message: {
            Text(avatarStore.lastErrorMessage ?? "")
        }
        .onChange(of: avatarStore.lastErrorMessage) { _, newValue in
            showPurchaseError = newValue != nil
        }
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
        avatarType.hasPrefix("avatar ") || PremiumAvatarDefinition.isPremiumImageAssetName(avatarType)
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

// MARK: - Premium avatar picker cell
private struct PremiumAvatarPickerButton: View {
    let definition: PremiumAvatarDefinition
    let isSelected: Bool
    let selectedColor: Color
    let isUnlocked: Bool
    let displayPrice: String
    let onSelect: () -> Void
    let onLockedTap: () -> Void
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                onSelect()
            } else {
                onLockedTap()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? selectedColor.opacity(0.15) : Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                    .frame(width: 76, height: 76)
                    .shadow(color: isSelected ? selectedColor.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
                
                Image(definition.imageAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .opacity(isUnlocked ? (isSelected ? 1.0 : 0.7) : 0.5)
                
                if !isUnlocked {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.32))
                        .frame(width: 76, height: 76)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    VStack {
                        Spacer()
                        Text(displayPrice)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(6)
                            .padding(.bottom, 6)
                    }
                    .frame(width: 76, height: 76)
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

// MARK: - Premium purchase confirmation (compact bottom sheet)
private struct PremiumAvatarPurchaseSheet: View {
    let definition: PremiumAvatarDefinition
    let displayPrice: String
    let ringColor: Color
    @ObservedObject var avatarStore: AvatarStoreManager
    var onPurchased: () -> Void
    var onDismissSheet: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private let accentRed = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
    private let ink = Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0)
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.96, blue: 0.97),
                    Color(red: 0.97, green: 0.97, blue: 0.99),
                    Color.white.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(ringColor.opacity(0.35), lineWidth: 4)
                            .frame(width: 136, height: 136)
                        Circle()
                            .stroke(ringColor, lineWidth: 4)
                            .frame(width: 120, height: 120)
                        Image(definition.imageAssetName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 104, height: 104)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 2))
                    }
                    .padding(.top, 4)
                    .shadow(color: ringColor.opacity(0.25), radius: 12, x: 0, y: 6)
                    
                    Text("Premium Avatar")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(accentRed)
                        .clipShape(Capsule())
                    
                    Text(definition.displayTitle)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(ink)
                        .multilineTextAlignment(.center)
                    
                    Text(displayPrice)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.38))
                }
                
                Spacer(minLength: 12)
                
                VStack(spacing: 14) {
                    Button(action: {
                        Task { @MainActor in
                            let ok = await avatarStore.purchase(definition)
                            if ok {
                                onPurchased()
                                onDismissSheet()
                                dismiss()
                            }
                        }
                    }) {
                        Text("Buy for \(displayPrice)")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(accentRed)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(avatarStore.isPurchasing)
                    .opacity(avatarStore.isPurchasing ? 0.65 : 1)
                    
                    Button(action: {
                        Task { @MainActor in
                            await avatarStore.restorePurchases()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(avatarStore.isRestoring)
                    
                    Button(action: {
                        onDismissSheet()
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color.secondary.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 22)
        }
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

// MARK: - Locked Color Button (Plus only)
struct LockedColorButton: View {
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.35))
                .frame(width: 64, height: 64)
            
            Circle()
                .stroke(Color(red: 0xE5/255.0, green: 0xE5/255.0, blue: 0xE5/255.0), lineWidth: 2.5)
                .frame(width: 64, height: 64)
            
            Image(systemName: "crown.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
        }
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
        avatarType.hasPrefix("avatar ") || PremiumAvatarDefinition.isPremiumImageAssetName(avatarType)
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
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(AvatarStoreManager.shared)
    }
}

