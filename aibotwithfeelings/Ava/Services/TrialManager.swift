import Foundation

/// Tracks the 5-day free trial from first app launch. Trial users get full Ava access only.
@MainActor
final class TrialManager: ObservableObject {
    @Published private(set) var tier: AccessTier = .expired

    private let firstLaunchKey = "trial_first_launch_date"
    private let trialDurationDays = SubscriptionConfig.trialDays

    func refresh(isSubscribed: Bool) {
        if isSubscribed {
            tier = .subscribed
            return
        }

        let firstLaunch = firstLaunchDate()
        let elapsed = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
        let remaining = trialDurationDays - elapsed

        if remaining > 0 {
            tier = .trial(daysRemaining: remaining)
        } else {
            tier = .expired
        }
    }

    var canChat: Bool { tier.canChat }
    var canCreateCharacters: Bool { tier.canCreateCharacters }

    private func firstLaunchDate() -> Date {
        if let stored = UserDefaults.standard.object(forKey: firstLaunchKey) as? Date {
            return stored
        }
        let now = Date()
        UserDefaults.standard.set(now, forKey: firstLaunchKey)
        return now
    }

    #if DEBUG
    func resetTrialForTesting() {
        UserDefaults.standard.removeObject(forKey: firstLaunchKey)
        refresh(isSubscribed: false)
    }
    #endif
}
