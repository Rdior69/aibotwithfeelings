//
//  ChatViewModel.swift
//  aibotwithfeelings
//

import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var draft: String = ""
    var isResponding: Bool = false
    var currentEmotion: EmotionState = .neutral

    private var profile: UserProfile?
    private let aiService: AICompanionServing
    private let memoryStore: CompanionMemoryStoring
    private let conversationStore: ConversationStoring
    private var didRestoreConversation = false

    init(
        aiService: AICompanionServing,
        memoryStore: CompanionMemoryStoring,
        conversationStore: ConversationStoring,
        profile: UserProfile?
    ) {
        self.aiService = aiService
        self.memoryStore = memoryStore
        self.conversationStore = conversationStore
        self.profile = profile

        Task {
            await restoreConversation()
        }
    }

    func updateProfile(_ profile: UserProfile?) {
        self.profile = profile
    }

    func sendCurrentMessage() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        draft = ""
        await appendMessage(ChatMessage(role: .user, text: text))
        isResponding = true

        let safety = SafetyFilter.evaluate(text)
        if let safetyMessage = safety.userFacingMessage {
            await appendMessage(ChatMessage(role: .system, text: safetyMessage))
            isResponding = false
            return
        }

        do {
            let memories = await memoryStore.recentMemories(limit: 3)
            let reply = try await aiService.generateReply(
                to: text,
                profile: profile,
                memories: memories,
                currentEmotion: currentEmotion
            )

            await appendMessage(ChatMessage(role: .companion, text: reply.text))
            currentEmotion = reply.emotion

            if profile?.memoryEnabled == true, let memoryCandidate = reply.memoryCandidate {
                await memoryStore.remember(memoryCandidate)
            }
        } catch {
            await appendMessage(
                ChatMessage(
                    role: .system,
                    text: "I hit a snag and could not respond. Please try again.",
                    isError: true
                )
            )
        }

        isResponding = false
    }

    func clearConversation() async {
        messages.removeAll()
        await conversationStore.clear()
        addWelcomeMessage()
    }

    private func restoreConversation() async {
        guard !didRestoreConversation else { return }
        didRestoreConversation = true

        let stored = await conversationStore.loadMessages()
        if stored.isEmpty {
            if profile != nil {
                addWelcomeMessage()
            }
        } else {
            messages = stored
        }
    }

    private func appendMessage(_ message: ChatMessage) async {
        messages.append(message)
        await conversationStore.saveMessages(messages)
    }

    private func addWelcomeMessage() {
        guard messages.isEmpty else { return }
        let name = profile?.preferredName.isEmpty == false ? profile?.preferredName ?? "friend" : "friend"
        let welcome = "Hi \(name)! I can chat and remember key moments from our conversations."
        messages.append(ChatMessage(role: .companion, text: welcome))
        Task {
            await conversationStore.saveMessages(messages)
        }
    }
}
