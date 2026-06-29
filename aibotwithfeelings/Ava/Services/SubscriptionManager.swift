import Foundation
import StoreKit

/// Single source of truth for subscription and trial state via StoreKit 2.
@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var product: Product?
    @Published private(set) var accessTier: AccessTier = .none
    @Published private(set) var isLoading = false
    @Published var purchaseError: String?

    private var transactionListener: Task<Void, Never>?

    var hasActiveAccess: Bool { accessTier.canChat }
    var isPremium: Bool { accessTier.canCreateCharacters }
    var isInTrial: Bool {
        if case .trial = accessTier { return true }
        return false
    }

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProduct() }
        Task { await refreshSubscriptionStatus() }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProduct() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [SubscriptionConfig.monthlyProductID])
            product = products.first
        } catch {
            purchaseError = "Couldn't load subscription: \(error.localizedDescription)"
        }
    }

    func refreshSubscriptionStatus() async {
        isLoading = true
        defer { isLoading = false }

        var resolvedTier: AccessTier = .none
        var foundEntitlement = false

        // Prefer subscription status API for accurate intro vs paid detection.
        if let product, let subscription = product.subscription {
            do {
                let statuses = try await subscription.status
                for status in statuses {
                    guard status.state == .subscribed else { continue }
                    foundEntitlement = true

                    guard case .verified(let transaction) = status.transaction else { continue }

                    let daysRemaining = daysUntil(transaction.expirationDate)
                    let inIntro = isIntroductory(transaction: transaction, renewalInfo: status.renewalInfo)

                    if inIntro {
                        resolvedTier = .trial(daysRemaining: max(1, daysRemaining))
                    } else {
                        resolvedTier = .premium
                    }
                    markHasSubscribed()
                    break
                }
            } catch {
                purchaseError = "Couldn't check subscription: \(error.localizedDescription)"
            }
        }

        // Fallback: check current entitlements directly.
        if !foundEntitlement {
            for await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result,
                      transaction.productID == SubscriptionConfig.monthlyProductID,
                      transaction.revocationDate == nil else { continue }

                foundEntitlement = true
                let daysRemaining = daysUntil(transaction.expirationDate)

                if transaction.offerType == .introductory {
                    resolvedTier = .trial(daysRemaining: max(1, daysRemaining))
                } else {
                    resolvedTier = .premium
                }
                markHasSubscribed()
                break
            }
        }

        // If user previously subscribed but entitlement expired, mark as expired.
        if !foundEntitlement, hasPreviouslySubscribed() {
            resolvedTier = .expired
        }

        accessTier = resolvedTier
    }

    func startTrial() async -> Bool {
        await purchase()
    }

    func purchase() async -> Bool {
        guard let product else {
            purchaseError = "Subscription not available. Try again shortly."
            return false
        }

        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refreshSubscriptionStatus()
                    return accessTier.canChat
                }
                purchaseError = "Purchase could not be verified."
                return false
            case .userCancelled:
                return false
            case .pending:
                purchaseError = "Purchase is pending approval."
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
    }

    func restore() async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshSubscriptionStatus()
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }
    }

    var priceDisplay: String {
        product?.displayPrice ?? "\(SubscriptionConfig.monthlyPriceDisplay)/mo"
    }

    var trialDescription: String {
        "\(SubscriptionConfig.trialDays)-day free trial, then \(priceDisplay)"
    }

    var startTrialButtonTitle: String {
        "Start \(SubscriptionConfig.trialDays)-Day Free Trial"
    }

    // MARK: - Private

    private func isIntroductory(
        transaction: Transaction,
        renewalInfo: VerificationResult<Product.SubscriptionInfo.RenewalInfo>
    ) -> Bool {
        if transaction.offerType == .introductory { return true }

        if case .verified(let info) = renewalInfo, info.offerType == .introductory {
            return true
        }

        return false
    }

    private func daysUntil(_ date: Date?) -> Int {
        guard let date, date > Date() else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return days + 1 // inclusive of today
    }

    private func hasPreviouslySubscribed() -> Bool {
        UserDefaults.standard.bool(forKey: "has_ever_subscribed")
    }

    private func markHasSubscribed() {
        UserDefaults.standard.set(true, forKey: "has_ever_subscribed")
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await MainActor.run {
                        Task { await self?.refreshSubscriptionStatus() }
                    }
                }
            }
        }
    }
}
