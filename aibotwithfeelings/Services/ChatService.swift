import Foundation

@MainActor
@Observable
final class ChatService {
    private(set) var messages: [ChatMessage] = []
    private(set) var memories: [EmotionalMemory] = []
    private(set) var isTyping = false

    private let store: MemoryStoring
    private var profile: UserProfile
    private var settings: AppSettings

    init(store: MemoryStoring = LocalMemoryStore()) {
        self.store = store
        self.profile = store.loadProfile()
        self.settings = store.loadSettings()
        self.messages = store.loadMessages()
        self.memories = store.loadMemories()
    }

    func refreshProfile() {
        profile = store.loadProfile()
        settings = store.loadSettings()
    }

    func startConversationIfNeeded() {
        guard messages.isEmpty else { return }
        let greeting = PersonalityEngine.greeting(for: profile)
        appendAssistantMessage(greeting)
        persist()
    }

    func sendMessage(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let safety = SafetyFilter.evaluate(trimmed)
        messages.append(ChatMessage(role: .user, content: trimmed))
        persistMessagesIfNeeded()

        if let safetyMessage = safety.userFacingMessage {
            appendAssistantMessage(
                PersonalityResponse(
                    content: safetyMessage,
                    emotion: .concerned,
                    extractedMemories: [],
                    referencedMemoryIDs: []
                )
            )
            persist()
            return
        }

        isTyping = true
        try? await Task.sleep(for: .milliseconds(650))

        let response = PersonalityEngine.respond(
            to: trimmed,
            profile: profile,
            memories: settings.memoryEnabled ? memories : [],
            recentMessages: messages
        )

        if settings.memoryEnabled {
            mergeMemories(response.extractedMemories)
            touchReferencedMemories(response.referencedMemoryIDs)
        }

        appendAssistantMessage(response)
        isTyping = false
        persist()
    }

    func clearConversation() {
        messages = []
        store.clearChatHistory()
        startConversationIfNeeded()
    }

    func deleteMemory(_ memory: EmotionalMemory) {
        memories.removeAll { $0.id == memory.id }
        store.saveMemories(memories)
    }

    private func appendAssistantMessage(_ response: PersonalityResponse) {
        messages.append(
            ChatMessage(
                role: .assistant,
                content: response.content,
                emotion: response.emotion
            )
        )
    }

    private func mergeMemories(_ newMemories: [EmotionalMemory]) {
        for memory in newMemories {
            let isDuplicate = memories.contains {
                $0.summary.lowercased() == memory.summary.lowercased()
            }
            if !isDuplicate {
                memories.append(memory)
            }
        }
        memories.sort { $0.lastReferencedAt > $1.lastReferencedAt }
        store.saveMemories(memories)
    }

    private func touchReferencedMemories(_ ids: [UUID]) {
        guard !ids.isEmpty else { return }
        let now = Date.now
        for index in memories.indices where ids.contains(memories[index].id) {
            memories[index].lastReferencedAt = now
            memories[index].emotionalWeight = min(memories[index].emotionalWeight + 0.05, 1)
        }
        store.saveMemories(memories)
    }

    private func persistMessagesIfNeeded() {
        guard settings.saveChatHistory else { return }
        store.saveMessages(messages)
    }

    private func persist() {
        persistMessagesIfNeeded()
        store.saveMemories(memories)
    }
}
