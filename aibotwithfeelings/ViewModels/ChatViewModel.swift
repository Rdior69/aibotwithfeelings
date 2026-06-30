//
//  ChatViewModel.swift
//  aibotwithfeelings
//

import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var draft: String = ""
    @Published var isResponding: Bool = false
    @Published var currentEmotion: EmotionState = .neutral

    private var profile: UserProfile?
    private let aiService: AICompanionServing
    private let memoryStore: CompanionMemoryStoring

    init(
        aiService: AICompanionServing,
        memoryStore: CompanionMemoryStoring,
        profile: UserProfile?
    ) {
        self.aiService = aiService
        self.memoryStore = memoryStore
        self.profile = profile

        if profile != nil {
            addWelcomeMessage()
        }
    }

    func updateProfile(_ profile: UserProfile?) {
        self.profile = profile
        if messages.isEmpty, profile != nil {
            addWelcomeMessage()
        }
    }

    func sendCurrentMessage() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        draft = ""
        messages.append(ChatMessage(role: .user, text: text))
        isResponding = true

        do {
            let memories = await memoryStore.recentMemories(limit: 3)
            let reply = try await aiService.generateReply(
                to: text,
                profile: profile,
                memories: memories,
                currentEmotion: currentEmotion
            )

            messages.append(ChatMessage(role: .companion, text: reply.text))
            currentEmotion = reply.emotion

            if profile?.memoryEnabled == true, let memoryCandidate = reply.memoryCandidate {
                await memoryStore.remember(memoryCandidate)
            }
        } catch {
            messages.append(
                ChatMessage(
                    role: .system,
                    text: "I hit a snag and could not respond. Please try again.",
                    isError: true
                )
            )
        }

        isResponding = false
    }

    private func addWelcomeMessage() {
        guard messages.isEmpty else { return }
        let name = profile?.preferredName.isEmpty == false ? profile?.preferredName ?? "friend" : "friend"
        let welcome = "Hi \(name)! I can chat, track your emotional tone, and remember key moments."
        messages.append(ChatMessage(role: .companion, text: welcome))
    }
}
