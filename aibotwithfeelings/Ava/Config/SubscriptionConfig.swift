import Foundation

enum SubscriptionConfig {
    static let monthlyProductID = "com.aibotwithfeelings.premium.monthly"
    static let monthlyPriceDisplay = "$39.99"
    static let trialDays = 5
    static let maxCharacters = 20
}

/// Single access model driven entirely by StoreKit subscription state.
enum AccessTier: Equatable {
    /// No active subscription — must start the 5-day free trial.
    case none
    /// StoreKit introductory offer active — full Ava, no custom characters.
    case trial(daysRemaining: Int)
    /// Paid subscription (intro converted or direct) — full premium.
    case premium
    /// Subscription lapsed — must resubscribe.
    case expired

    var canChat: Bool {
        switch self {
        case .trial, .premium: return true
        case .none, .expired: return false
        }
    }

    var canCreateCharacters: Bool {
        self == .premium
    }

    var displayLabel: String {
        switch self {
        case .none:
            return "Start your free trial"
        case .trial(let days):
            return days == 1 ? "1 day left in free trial" : "\(days) days left in free trial"
        case .premium:
            return "Premium"
        case .expired:
            return "Subscription ended"
        }
    }
}
