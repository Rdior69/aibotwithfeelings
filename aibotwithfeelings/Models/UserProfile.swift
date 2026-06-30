import Foundation

struct UserProfile: Codable, Equatable, Sendable {
    var displayName: String
    var hasCompletedOnboarding: Bool
    var preferredBot: BotPersonality
    var createdAt: Date

    static let guest = UserProfile(
        displayName: "",
        hasCompletedOnboarding: false,
        preferredBot: .defaultBot,
        createdAt: .now
    )
}

struct AppSettings: Codable, Equatable, Sendable {
    var hapticsEnabled: Bool
    var saveChatHistory: Bool
    var memoryEnabled: Bool

    static let `default` = AppSettings(
        hapticsEnabled: true,
        saveChatHistory: true,
        memoryEnabled: true
    )
}
