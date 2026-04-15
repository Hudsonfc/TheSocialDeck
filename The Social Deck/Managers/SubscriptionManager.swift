//
//  SubscriptionManager.swift
//  The Social Deck
//

import StoreKit

// MARK: - Plan enum (shared with the paywall view)
enum PlusPlan: Equatable {
    case weekly, yearly
}

// MARK: - Product IDs
enum SubscriptionProductID {
    /// Previous App Store subscription (monthly). Kept for reference; app uses `weekly` below.
    // static let monthly = "com.thesocialdeck.plus.monthly"
    static let weekly = "com.thesocialdeck.plus.weekly"
    static let yearly = "com.thesocialdeck.plus.yearly"
    static var allIDs: Set<String> { [weekly, yearly] }
}

// MARK: - Manager
@MainActor
final class SubscriptionManager: ObservableObject {

    // Shared instance used app-wide as an @EnvironmentObject
    static let shared = SubscriptionManager()

    // MARK: - Published state
    @Published var isPlus: Bool = false
    @Published var weeklyProduct: Product?
    @Published var yearlyProduct: Product?
    @Published var selectedPlan: PlusPlan = .yearly
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private
    private var transactionListenerTask: Task<Void, Never>?

    // MARK: - Init / deinit
    init() {
        transactionListenerTask = startTransactionListener()
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    // MARK: - Load products
    func loadProducts() async {
        do {
            let fetched = try await Product.products(for: SubscriptionProductID.allIDs)
            for product in fetched {
                switch product.id {
                case SubscriptionProductID.weekly: weeklyProduct = product
                case SubscriptionProductID.yearly:  yearlyProduct  = product
                default: break
                }
            }
        } catch {
            errorMessage = "Could not load plans. Check your connection and try again."
        }
    }

    // MARK: - Purchase selected plan
    func purchaseSelectedPlan() async {
        let product: Product?
        switch selectedPlan {
        case .weekly: product = weeklyProduct
        case .yearly:  product = yearlyProduct
        }

        guard let product else {
            errorMessage = "Plan unavailable. Please try again."
            return
        }

        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await refreshEntitlements()
                case .unverified:
                    errorMessage = "Purchase could not be verified. Please contact support."
                }
            case .userCancelled:
                break   // Silent — user chose to cancel, not an error
            case .pending:
                errorMessage = "Purchase is pending approval."
            @unknown default:
                break
            }

        } catch {
            if case StoreKitError.userCancelled = error {
                // User cancelled — do nothing
            } else {
                errorMessage = "Something went wrong. Please try again."
            }
        }

        isLoading = false
    }

    // MARK: - Restore purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = "Could not restore purchases. Please try again."
        }

        isLoading = false
    }

    // MARK: - Entitlement check
    func refreshEntitlements() async {
        var hasActive = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard SubscriptionProductID.allIDs.contains(transaction.productID) else { continue }
            guard transaction.revocationDate == nil else { continue }

            if let expiry = transaction.expirationDate {
                if expiry > .now { hasActive = true; break }
            } else {
                hasActive = true; break
            }
        }

        isPlus = DeveloperAccountOverride.isActive || hasActive
    }

    // MARK: - Background transaction listener
    private func startTransactionListener() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    guard SubscriptionProductID.allIDs.contains(transaction.productID) else { continue }
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }
}
