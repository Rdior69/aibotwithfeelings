import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var product: Product?
    @Published private(set) var isSubscribed = false
    @Published private(set) var isLoading = false
    @Published var purchaseError: String?

    private var transactionListener: Task<Void, Never>?

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
        var hasActive = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == SubscriptionConfig.monthlyProductID,
               transaction.revocationDate == nil {
                hasActive = true
                break
            }
        }

        isSubscribed = hasActive
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
                    return true
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
