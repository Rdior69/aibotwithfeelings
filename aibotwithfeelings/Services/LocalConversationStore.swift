//
//  LocalConversationStore.swift
//  aibotwithfeelings
//

import Foundation

protocol ConversationStoring: Sendable {
    func loadMessages() async -> [ChatMessage]
    func saveMessages(_ messages: [ChatMessage]) async
    func clear() async
}

actor LocalConversationStore: ConversationStoring {
    private nonisolated(unsafe) let defaults: UserDefaults
    private let key: String
    private let maxMessages: Int

    init(
        suiteName: String = "com.aibotwithfeelings.conversation",
        key: String = "aibot.conversation.v1",
        maxMessages: Int = 200
    ) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
        self.key = key
        self.maxMessages = maxMessages
    }

    func loadMessages() -> [ChatMessage] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([ChatMessage].self, from: data)) ?? []
    }

    func saveMessages(_ messages: [ChatMessage]) {
        let trimmed = Array(messages.suffix(maxMessages))
        guard let data = try? JSONEncoder().encode(trimmed) else { return }
        defaults.set(data, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
