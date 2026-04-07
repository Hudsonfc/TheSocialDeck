//
//  OnlineNavigationNotifications.swift
//  The Social Deck
//

import Foundation

extension Notification.Name {
    /// Posted when Act Natural online end screen requests leaving the game container (avoids stale NavigationLink state).
    static let onlineDismissGameContainerAfterActNaturalEnd = Notification.Name("onlineDismissGameContainerAfterActNaturalEnd")
}
