import Foundation
import SwiftUI

/// Central access control — entirely driven by StoreKit subscription state.
@MainActor
final class AppState: ObservableObject {
    let subscriptionManager = SubscriptionManager()
    let characterStore = CharacterStore()

    @Published var showPaywall = false

    var accessTier: AccessTier { subscriptionManager.accessTier }
    var canChat: Bool { subscriptionManager.accessTier.canChat }
    var canCreateCharacters: Bool { subscriptionManager.accessTier.canCreateCharacters }
    var isPremium: Bool { subscriptionManager.isPremium }
    var isInTrial: Bool { subscriptionManager.isInTrial }
    var needsOnboarding: Bool {
        switch subscriptionManager.accessTier {
        case .none: return true
        case .trial, .premium, .expired: return false
        }
    }

    init() {
        Task { await refreshAccess() }
    }

    func refreshAccess() async {
        await subscriptionManager.refreshSubscriptionStatus()

        // If user lost premium, fall back to Ava.
        if !isPremium && !characterStore.activeCharacter.isBuiltIn {
            characterStore.select(.ava)
        }
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
