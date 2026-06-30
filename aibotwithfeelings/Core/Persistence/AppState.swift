//
//  AppState.swift
//  aibotwithfeelings
//
//  The app-wide observable state that binds the SwiftUI views to the BotBrain
//  engine and persistence. Guarded so the rest of the Core compiles on any
//  platform (including headless Linux test runs).
//

#if canImport(Combine)
import Foundation
import Combine

@MainActor
public final class AppState: ObservableObject {
    @Published public private(set) var profile: UserProfile
    @Published public private(set) var messages: [ChatMessage]
    @Published public private(set) var mood: MoodState
    @Published public private(set) var memory: MemoryStore
    @Published public private(set) var isTyping: Bool = false

    private let brain: BotBrain
    private let persistence: PersistenceController

    public init(
        brain: BotBrain = BotBrain(),
        persistence: PersistenceController = PersistenceController()
    ) {
        self.brain = brain
        self.persistence = persistence
        let loaded = persistence.load() ?? .initial
        self.profile = loaded.profile
        self.messages = loaded.messages
        self.mood = loaded.mood
        self.memory = loaded.memory
    }

    public var personality: Personality { profile.personality }

    public var hasCompletedOnboarding: Bool { profile.hasCompletedOnboarding }

    // MARK: - Onboarding

    public func completeOnboarding(displayName: String, botName: String, personalityID: String) {
        profile.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.botName = botName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Ava" : botName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.personalityID = personalityID
        profile.hasCompletedOnboarding = true

        if messages.isEmpty {
            let greeting = ChatMessage(
                sender: .bot,
                text: "Hi \(profile.displayName.isEmpty ? "there" : profile.displayName)! I'm \(profile.botName), and I'm really happy to meet you. I'm here to listen whenever you need me. How are you feeling today?",
                moodEmoji: EmotionKind.joy.emoji
            )
            messages.append(greeting)
            mood = mood.adjusting(.joy, by: 0.4).adjusting(.affection, by: 0.2)
        }
        persist()
    }

    public func updatePersonality(_ id: String) {
        profile.personalityID = id
        persist()
    }

    public func updateNames(displayName: String, botName: String) {
        profile.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBot = botName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedBot.isEmpty { profile.botName = trimmedBot }
        persist()
    }

    // MARK: - Chat

    public func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMessage = ChatMessage(sender: .user, text: trimmed)
        messages.append(userMessage)
        persist()

        isTyping = true
        let snapshotProfile = profile
        let snapshotMood = mood
        let snapshotMemory = memory

        Task { [weak self] in
            guard let self else { return }
            let result = self.brain.process(
                userText: trimmed,
                profile: snapshotProfile,
                mood: snapshotMood,
                memory: snapshotMemory
            )
            // A short, natural typing delay scaled to reply length.
            let delay = min(1.6, 0.4 + Double(result.reply.text.count) * 0.004)
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

            self.mood = result.updatedMood
            self.memory = result.updatedMemory
            self.messages.append(result.reply)
            self.isTyping = false
            self.persist()
        }
    }

    // MARK: - Memory management

    public func deleteMemory(id: UUID) {
        memory.remove(id: id)
        persist()
    }

    public func clearMemories() {
        memory.clear()
        persist()
    }

    /// Wipe everything and return to onboarding.
    public func resetAll() {
        profile = .empty
        messages = []
        mood = .neutral
        memory = MemoryStore()
        persistence.reset()
    }

    // MARK: - Persistence

    private func persist() {
        let state = PersistedState(
            profile: profile,
            messages: messages,
            mood: mood,
            memory: memory
        )
        try? persistence.save(state)
    }
}
#endif
