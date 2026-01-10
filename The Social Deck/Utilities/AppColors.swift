//
//  AppColors.swift
//  The Social Deck
//
//  Created for Dark Mode support
//

import SwiftUI

extension Color {
    // MARK: - Background Colors
    static let appBackground = Color(light: .white, dark: Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
    static let cardBackground = Color(light: .white, dark: Color(red: 0x1C/255.0, green: 0x1C/255.0, blue: 0x1C/255.0))
    static let secondaryBackground = Color(light: Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0), dark: Color(red: 0x14/255.0, green: 0x14/255.0, blue: 0x14/255.0))
    static let tertiaryBackground = Color(light: Color(red: 0xF1/255.0, green: 0xF1/255.0, blue: 0xF1/255.0), dark: Color(red: 0x24/255.0, green: 0x24/255.0, blue: 0x24/255.0))
    
    // MARK: - Text Colors
    static let primaryText = Color(light: Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0), dark: .white)
    static let secondaryText = Color(light: Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0), dark: Color(red: 0xB0/255.0, green: 0xB0/255.0, blue: 0xB0/255.0))
    static let tertiaryText = Color(light: Color(red: 0xB0/255.0, green: 0xB0/255.0, blue: 0xB0/255.0), dark: Color(red: 0x7A/255.0, green: 0x7A/255.0, blue: 0x7A/255.0))
    
    // MARK: - Accent Colors (These stay the same in both modes)
    static let primaryAccent = Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0)
    
    // MARK: - Button Colors
    static let buttonBackground = Color(light: Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0), dark: Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
    static let buttonPressedBackground = Color(light: Color(red: 0xC9/255.0, green: 0x2A/255.0, blue: 0x2A/255.0), dark: Color(red: 0xE9/255.0, green: 0x4A/255.0, blue: 0x4A/255.0))
    
    // MARK: - Border/Divider Colors
    static let borderColor = Color(light: Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0), dark: Color(red: 0x3A/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
    
    // MARK: - Shadow Colors
    static let shadowColor = Color(light: Color.black.opacity(0.1), dark: Color.black.opacity(0.5))
    static let cardShadowColor = Color(light: Color.black.opacity(0.15), dark: Color.black.opacity(0.6))
    
    // MARK: - Helper Initializer for Light/Dark Mode
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Color Helper for UIColor conversion

