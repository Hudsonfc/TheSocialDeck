//
//  AnalyticsService.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import Foundation
import FirebaseAnalytics

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    /// Track referral source from onboarding
    func trackReferralSource(_ source: String) {
        Analytics.logEvent("onboarding_referral_source", parameters: [
            "source": source,
            "selected_at": Date().timeIntervalSince1970
        ])
    }
    
    /// Track language selection
    func trackLanguageSelection(_ languageCode: String) {
        Analytics.logEvent("onboarding_language_selected", parameters: [
            "language": languageCode,
            "selected_at": Date().timeIntervalSince1970
        ])
    }
    
    /// Track onboarding completion
    func trackOnboardingCompleted() {
        Analytics.logEvent("onboarding_completed", parameters: [
            "completed_at": Date().timeIntervalSince1970
        ])
    }
    
    /// Track screen view
    func trackScreenView(_ screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
    }
}
