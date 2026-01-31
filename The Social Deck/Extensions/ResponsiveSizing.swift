//
//  ResponsiveSizing.swift
//  The Social Deck
//
//  Created for responsive layout support across iPhone and iPad
//

import SwiftUI
import UIKit

// MARK: - Responsive Sizing Extension
extension View {
    /// Apply responsive horizontal padding based on device size
    func responsiveHorizontalPadding() -> some View {
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            padding = max(screenWidth * 0.08, 60) // 8% of screen, min 60pt
        } else if screenWidth <= 320 {
            padding = 24 // Reduced padding for iPhone SE
        } else {
            padding = 40 // Standard padding
        }
        
        return self.padding(.horizontal, padding)
    }
    
    /// Apply responsive vertical padding based on device size
    func responsiveVerticalPadding(_ amount: CGFloat = 40) -> some View {
        let padding: CGFloat
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            padding = amount * 1.5
        } else {
            padding = amount
        }
        
        return self.padding(.vertical, padding)
    }
}

// MARK: - Responsive Size Calculator
struct ResponsiveSize {
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isSmallDevice: Bool {
        screenWidth <= 320
    }
    
    // MARK: - Card Sizes
    
    /// Standard game card width (responsive)
    static var cardWidth: CGFloat {
        if isPad {
            return min(screenWidth * 0.5, 440)
        } else if isSmallDevice {
            return screenWidth - 48 // 24pt padding on each side
        } else {
            return min(screenWidth - 80, 340)
        }
    }
    
    /// Standard game card height (maintains aspect ratio)
    static var cardHeight: CGFloat {
        cardWidth * 1.5 // 2:3 aspect ratio
    }
    
    /// Category Clash card height (shorter cards)
    static var categoryCardHeight: CGFloat {
        if isPad {
            return cardWidth * 0.8
        } else {
            return cardWidth * 0.7
        }
    }
    
    /// Bluff Call card height (medium cards)
    static var bluffCallCardHeight: CGFloat {
        if isPad {
            return min(screenHeight * 0.6, 600)
        } else {
            return min(screenHeight * 0.55, 500)
        }
    }
    
    // MARK: - Hero/Feature Image Sizes
    
    /// Home view hero banner width
    static var heroBannerWidth: CGFloat {
        if isPad {
            return min(screenWidth * 0.65, 500)
        } else if isSmallDevice {
            return screenWidth - 48
        } else {
            return min(screenWidth - 80, 320)
        }
    }
    
    /// Home view hero banner height
    static var heroBannerHeight: CGFloat {
        heroBannerWidth * 0.625 // Maintain 320:200 ratio
    }
    
    /// Setup view artwork width
    static var setupArtworkWidth: CGFloat {
        isPad ? 200 : (isSmallDevice ? 100 : 120)
    }
    
    /// Setup view artwork height
    static var setupArtworkHeight: CGFloat {
        setupArtworkWidth * 1.375 // Maintain aspect ratio
    }
    
    /// Play2View card width
    static var play2CardWidth: CGFloat {
        if isPad {
            return min(screenWidth * 0.45, 400)
        } else if isSmallDevice {
            return screenWidth - 48
        } else {
            return min(screenWidth - 80, 320)
        }
    }
    
    /// Play2View card height
    static var play2CardHeight: CGFloat {
        play2CardWidth / (420.0 / 577.0) // Use actual image aspect ratio
    }
    
    /// Play2View grid tile width
    static var gridTileWidth: CGFloat {
        if isPad {
            return (screenWidth - 120 - 32) / 3 // 3 columns on iPad
        } else {
            return (screenWidth - (isSmallDevice ? 48 : 80) - 16) / 2 // 2 columns on iPhone
        }
    }
    
    /// Play2View grid tile height
    static var gridTileHeight: CGFloat {
        gridTileWidth / (420.0 / 577.0)
    }
    
    // MARK: - Timer Sizes
    
    /// Circular timer size
    static var timerSize: CGFloat {
        if isPad {
            return 160
        } else if isSmallDevice {
            return 100
        } else {
            return 120
        }
    }
    
    // MARK: - Button Sizes
    
    /// Standard button height
    static var buttonHeight: CGFloat {
        isPad ? 56 : 48
    }
    
    /// Small button/icon size
    static var iconButtonSize: CGFloat {
        44 // Minimum tap target for accessibility
    }
    
    // MARK: - Spacing
    
    /// Standard content spacing
    static var contentSpacing: CGFloat {
        isPad ? 32 : 24
    }
    
    /// Small spacing
    static var smallSpacing: CGFloat {
        isPad ? 16 : 12
    }
    
    /// Large spacing
    static var largeSpacing: CGFloat {
        isPad ? 48 : 32
    }
}
