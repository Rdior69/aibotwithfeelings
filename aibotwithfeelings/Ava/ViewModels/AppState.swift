import Foundation
import SwiftUI

/// Central access control: 5-day Ava trial OR $39.99/mo premium for custom characters.
@MainActor
final class AppState: ObservableObject {
    let subscriptionManager = SubscriptionManager()
    let trialManager = TrialManager()
    let characterStore = CharacterStore()

    @Published var showPaywall = false

    var accessTier: AccessTier { trialManager.tier }
    var canChat: Bool { trialManager.canChat }
    var canCreateCharacters: Bool { trialManager.canCreateCharacters }
    var isPremium: Bool { trialManager.tier == .subscribed }

    init() {
        Task { await refreshAccess() }
    }

    func refreshAccess() async {
        await subscriptionManager.refreshSubscriptionStatus()
        trialManager.refresh(isSubscribed: subscriptionManager.isSubscribed)
    }

    func requireChatAccess() -> Bool {
        if canChat { return true }
        showPaywall = true
        return false
    }

    func requireCharacterCreation() -> Bool {
        if canCreateCharacters && characterStore.canCreateMore { return true }
        showPaywall = true
        return false
    }

    func selectCharacter(_ character: AICharacter) {
        if character.isBuiltIn || isPremium {
            characterStore.select(character)
        } else {
            showPaywall = true
        }
    }
}

private struct AppStateKey: EnvironmentKey {
    static let defaultValue = AppState()
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}
