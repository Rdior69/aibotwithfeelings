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
    private let defaults: UserDefaults
    private let key: String
    private let maxMessages: Int

    init(
        defaults: UserDefaults = .standard,
        key: String = "aibot.conversation.v1",
        maxMessages: Int = 200
    ) {
        self.defaults = defaults
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
