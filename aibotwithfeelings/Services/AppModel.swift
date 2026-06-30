import Foundation

@MainActor
@Observable
final class AppModel {
    var profile: UserProfile
    var settings: AppSettings
    let chatService: ChatService
    private let store: MemoryStoring

    init(store: MemoryStoring = LocalMemoryStore()) {
        self.store = store
        self.profile = store.loadProfile()
        self.settings = store.loadSettings()
        self.chatService = ChatService(store: store)
    }

    var needsOnboarding: Bool {
        !profile.hasCompletedOnboarding
    }

    func completeOnboarding(displayName: String, bot: BotPersonality) {
        profile.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.preferredBot = bot
        profile.hasCompletedOnboarding = true
        store.saveProfile(profile)
        chatService.refreshProfile()
        chatService.startConversationIfNeeded()
    }

    func updateSettings(_ settings: AppSettings) {
        self.settings = settings
        store.saveSettings(settings)
        chatService.refreshProfile()
    }

    func updateBotPersonality(_ bot: BotPersonality) {
        profile.preferredBot = bot
        store.saveProfile(profile)
        chatService.refreshProfile()
    }

    func resetOnboarding() {
        profile = .guest
        store.saveProfile(profile)
        chatService.refreshProfile()
    }
}
