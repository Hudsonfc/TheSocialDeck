//
//  LanguageManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    private let selectedLanguageKey = "selectedLanguage"
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: selectedLanguageKey)
            updateBundle()
        }
    }
    
    private var bundle: Bundle?
    
    private init() {
        // Load saved language or default to system language
        if let savedLanguage = UserDefaults.standard.string(forKey: selectedLanguageKey) {
            self.currentLanguage = savedLanguage
        } else {
            // Get system language
            let systemLanguage = Locale.preferredLanguages.first ?? "en"
            // Extract language code (e.g., "en-US" -> "en")
            let langCode = String(systemLanguage.prefix(2))
            // Check if we support this language, otherwise default to English
            if Self.availableLanguages.contains(where: { $0.code == langCode }) {
                self.currentLanguage = langCode
            } else {
                self.currentLanguage = "en"
            }
        }
        updateBundle()
    }
    
    private func updateBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback to main bundle if language not found
            self.bundle = Bundle.main
            return
        }
        self.bundle = bundle
    }
    
    /// Get localized string for key
    func localizedString(for key: String) -> String {
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
    
    /// Set language and update bundle
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }
    
    /// Get available languages
    static let availableLanguages: [(code: String, name: String)] = [
        ("en", "English"),
        ("es", "Español"),
        ("fr", "Français"),
        ("de", "Deutsch"),
        ("pt", "Português"),
        ("it", "Italiano"),
        ("ja", "日本語"),
        ("ko", "한국어"),
        ("zh", "中文"),
        ("ru", "Русский")
    ]
    
    /// Get display name for language code
    func displayName(for languageCode: String) -> String {
        return Self.availableLanguages.first(where: { $0.code == languageCode })?.name ?? languageCode
    }
}

// MARK: - LocalizedStringKey Extension
extension String {
    var localized: String {
        return LanguageManager.shared.localizedString(for: self)
    }
}
