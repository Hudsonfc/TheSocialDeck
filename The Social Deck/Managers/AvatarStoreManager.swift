//
//  AvatarStoreManager.swift
//  The Social Deck
//

import Foundation
import StoreKit

// MARK: - Premium avatar catalog (product id ↔ asset name)

enum PremiumAvatarDefinition: String, CaseIterable, Identifiable {
    case blindfoldedTurtle = "com.thesocialdeck.avatar.blindfoldedturtle"
    case greyCat = "com.thesocialdeck.avatar.greycat"
    case coolFox = "com.thesocialdeck.avatar.coolfox"
    case regularBear = "com.thesocialdeck.avatar.regularbear"
    case alien = "com.thesocialdeck.avatar.alien"

    var id: String { rawValue }

    /// Must match imageset names in Assets.xcassets.
    var imageAssetName: String {
        switch self {
        case .blindfoldedTurtle: return "blind folded turtle avatar"
        case .greyCat: return "grey cat avatar"
        case .coolFox: return "cool fox avatar"
        case .regularBear: return "regular bear avatar"
        case .alien: return "alien artwork"
        }
    }

    var displayTitle: String {
        switch self {
        case .blindfoldedTurtle: return "Blindfolded Turtle"
        case .greyCat: return "Grey Cat"
        case .coolFox: return "Cool Fox"
        case .regularBear: return "Regular Bear"
        case .alien: return "Alien"
        }
    }

    static let allProductIDs: Set<String> = Set(allCases.map(\.rawValue))

    static func isPremiumImageAssetName(_ name: String) -> Bool {
        allCases.contains { $0.imageAssetName == name }
    }
}

// MARK: - StoreKit 2 manager (non-consumable avatar IAPs)

@MainActor
final class AvatarStoreManager: ObservableObject {

    static let shared = AvatarStoreManager()

    /// Unlocked premium avatar product IDs (Firestore ∪ UserDefaults ∪ StoreKit).
    @Published private(set) var unlockedProductIDs: Set<String> = []

    @Published private(set) var productsByID: [String: Product] = [:]
    @Published var isLoadingProducts: Bool = false
    @Published var isPurchasing: Bool = false
    @Published var isRestoring: Bool = false
    @Published var lastErrorMessage: String?

    func clearLastError() {
        lastErrorMessage = nil
    }

    private var activeUserId: String?
    private var transactionListenerTask: Task<Void, Never>?

    private static func storageKey(userId: String) -> String {
        "purchasedAvatarProductIDs_\(userId)"
    }

    static let fallbackPrice = "$1.99"

    init() {
        transactionListenerTask = startTransactionListener()
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    /// Call when auth user id changes (sign-in / sign-out).
    func setActiveUserId(_ userId: String?) {
        activeUserId = userId
        unlockedProductIDs.removeAll()
        if userId != nil {
            loadFromUserDefaults()
            Task {
                await loadProducts()
                await refreshEntitlementsFromStoreKit()
            }
        }
    }

    func mergeFirestorePurchases(_ ids: [String]?) {
        guard let ids else { return }
        var changed = false
        for id in ids where PremiumAvatarDefinition.allProductIDs.contains(id) {
            if unlockedProductIDs.insert(id).inserted { changed = true }
        }
        if changed { persistToUserDefaults() }
    }

    func loadProducts() async {
        isLoadingProducts = true
        lastErrorMessage = nil
        defer { isLoadingProducts = false }

        do {
            let list = try await Product.products(for: Array(PremiumAvatarDefinition.allProductIDs))
            var map: [String: Product] = [:]
            for p in list { map[p.id] = p }
            productsByID = map
        } catch {
            lastErrorMessage = "Could not load avatar prices. Check your connection."
        }
    }

    func displayPrice(for definition: PremiumAvatarDefinition) -> String {
        productsByID[definition.rawValue]?.displayPrice ?? Self.fallbackPrice
    }

    func isUnlocked(_ definition: PremiumAvatarDefinition) -> Bool {
        unlockedProductIDs.contains(definition.rawValue)
    }

    func refreshEntitlementsFromStoreKit() async {
        var found: [String] = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let t) = result else { continue }
            if PremiumAvatarDefinition.allProductIDs.contains(t.productID) {
                found.append(t.productID)
            }
        }
        var changed = false
        for id in found {
            if unlockedProductIDs.insert(id).inserted { changed = true }
        }
        if changed { persistToUserDefaults() }
        await syncNewUnlocksToFirestore(found)
    }

    func restorePurchases() async {
        isRestoring = true
        lastErrorMessage = nil
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
        } catch {
            lastErrorMessage = "Restore failed. Try again later."
            return
        }
        await refreshEntitlementsFromStoreKit()
    }

    /// Completes purchase flow; returns true if the avatar is now unlocked.
    func purchase(_ definition: PremiumAvatarDefinition) async -> Bool {
        guard let product = productsByID[definition.rawValue] else {
            lastErrorMessage = "This avatar is not available right now."
            await loadProducts()
            return false
        }

        guard !isPurchasing else { return false }
        isPurchasing = true
        lastErrorMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await applyUnlock(productID: transaction.productID)
                    return true
                case .unverified:
                    lastErrorMessage = "Purchase could not be verified."
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                lastErrorMessage = "Purchase is pending approval."
                return false
            @unknown default:
                return false
            }
        } catch {
            lastErrorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Private

    private func loadFromUserDefaults() {
        guard let uid = activeUserId else { return }
        let saved = UserDefaults.standard.stringArray(forKey: Self.storageKey(userId: uid)) ?? []
        for id in saved where PremiumAvatarDefinition.allProductIDs.contains(id) {
            unlockedProductIDs.insert(id)
        }
    }

    private func persistToUserDefaults() {
        guard let uid = activeUserId else { return }
        let avatarOnly = unlockedProductIDs.intersection(PremiumAvatarDefinition.allProductIDs)
        UserDefaults.standard.set(Array(avatarOnly), forKey: Self.storageKey(userId: uid))
    }

    private func applyUnlock(productID: String) async {
        guard PremiumAvatarDefinition.allProductIDs.contains(productID) else { return }
        unlockedProductIDs.insert(productID)
        persistToUserDefaults()
        await AuthManager.shared.mergePurchasedAvatarProductIds([productID])
    }

    private func syncNewUnlocksToFirestore(_ storeKitIDs: [String]) async {
        let profileIds = Set(AuthManager.shared.userProfile?.purchasedAvatars ?? [])
        let missing = storeKitIDs.filter { !profileIds.contains($0) }
        guard !missing.isEmpty else { return }
        await AuthManager.shared.mergePurchasedAvatarProductIds(missing)
    }

    private func startTransactionListener() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                guard case .verified(let transaction) = result else { continue }
                guard PremiumAvatarDefinition.allProductIDs.contains(transaction.productID) else { continue }
                await transaction.finish()
                await self.handleTransactionUpdate(productID: transaction.productID)
            }
        }
    }

    private func handleTransactionUpdate(productID: String) async {
        await applyUnlock(productID: productID)
    }
}
