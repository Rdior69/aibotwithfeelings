import Foundation

enum SubscriptionConfig {
    static let monthlyProductID = "com.aibotwithfeelings.premium.monthly"
    static let monthlyPriceDisplay = "$39.99"
    static let trialDays = 5
    static let maxCharacters = 20
}

enum AccessTier: Equatable {
    case trial(daysRemaining: Int)
    case subscribed
    case expired

    var canChat: Bool {
        switch self {
        case .trial, .subscribed: return true
        case .expired: return false
        }
    }

    var canCreateCharacters: Bool {
        switch self {
        case .subscribed: return true
        case .trial, .expired: return false
        }
    }

    var displayLabel: String {
        switch self {
        case .trial(let days):
            return days == 1 ? "1 day left in trial" : "\(days) days left in trial"
        case .subscribed:
            return "Premium"
        case .expired:
            return "Trial ended"
        }
    }
}
