//
//  CompanionBackend.swift
//  aibotwithfeelings
//

import Foundation

struct CompanionBackendConfiguration: Sendable {
    var aiProvider: AIProviderConfiguration?
    var usePersistentMemory: Bool
    var usePersistentConversation: Bool

    static func current() -> CompanionBackendConfiguration {
        CompanionBackendConfiguration(
            aiProvider: AIProviderConfiguration.current(),
            usePersistentMemory: true,
            usePersistentConversation: true
        )
    }
}

struct CompanionBackend {
    let aiService: AICompanionServing
    let memoryStore: CompanionMemoryStoring
    let conversationStore: ConversationStoring
    let profileStore: LocalProfileStore

    static func make(
        configuration: CompanionBackendConfiguration = .current(),
        profileStore: LocalProfileStore = LocalProfileStore()
    ) -> CompanionBackend {
        let primaryAI = configuration.aiProvider.map { HTTPAICompanionService(configuration: $0) }
        let aiService = FallbackAICompanionService(primary: primaryAI)

        let memoryStore: CompanionMemoryStoring = configuration.usePersistentMemory
            ? PersistentCompanionMemoryStore()
            : InMemoryCompanionMemoryStore()

        let conversationStore: ConversationStoring = configuration.usePersistentConversation
            ? LocalConversationStore()
            : EphemeralConversationStore()

        return CompanionBackend(
            aiService: aiService,
            memoryStore: memoryStore,
            conversationStore: conversationStore,
            profileStore: profileStore
        )
    }
}

actor EphemeralConversationStore: ConversationStoring {
    private var messages: [ChatMessage] = []

    func loadMessages() -> [ChatMessage] { messages }

    func saveMessages(_ messages: [ChatMessage]) {
        self.messages = messages
    }

    func clear() {
        messages.removeAll()
    }
}
