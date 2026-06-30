import Foundation

protocol MemoryStoring: Sendable {
    func loadMemories() -> [EmotionalMemory]
    func saveMemories(_ memories: [EmotionalMemory])
    func loadMessages() -> [ChatMessage]
    func saveMessages(_ messages: [ChatMessage])
    func loadProfile() -> UserProfile
    func saveProfile(_ profile: UserProfile)
    func loadSettings() -> AppSettings
    func saveSettings(_ settings: AppSettings)
    func clearChatHistory()
}

final class LocalMemoryStore: MemoryStoring, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadMemories() -> [EmotionalMemory] {
        load([EmotionalMemory].self, forKey: StorageKey.emotionalMemories) ?? []
    }

    func saveMemories(_ memories: [EmotionalMemory]) {
        save(memories, forKey: StorageKey.emotionalMemories)
    }

    func loadMessages() -> [ChatMessage] {
        load([ChatMessage].self, forKey: StorageKey.chatHistory) ?? []
    }

    func saveMessages(_ messages: [ChatMessage]) {
        save(messages, forKey: StorageKey.chatHistory)
    }

    func loadProfile() -> UserProfile {
        load(UserProfile.self, forKey: StorageKey.userProfile) ?? .guest
    }

    func saveProfile(_ profile: UserProfile) {
        save(profile, forKey: StorageKey.userProfile)
    }

    func loadSettings() -> AppSettings {
        load(AppSettings.self, forKey: StorageKey.appSettings) ?? .default
    }

    func saveSettings(_ settings: AppSettings) {
        save(settings, forKey: StorageKey.appSettings)
    }

    func clearChatHistory() {
        defaults.removeObject(forKey: StorageKey.chatHistory)
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
