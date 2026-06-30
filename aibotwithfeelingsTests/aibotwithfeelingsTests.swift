//
//  aibotwithfeelingsTests.swift
//  aibotwithfeelingsTests
//

import Foundation
import Testing
@testable import aibotwithfeelings

struct aibotwithfeelingsTests {

    @Test func emotionEnginePromotesWarmthAfterPositiveSignal() async throws {
        let result = EmotionEngine.nextState(from: .neutral, signal: .positive)
        #expect(result.label == .warm || result.label == .excited)
        #expect(result.intensity > EmotionState.neutral.intensity)
    }

    @Test func emotionEngineRespondsToNegativeSignal() {
        let result = EmotionEngine.nextState(from: .neutral, signal: .negative)
        #expect(result.label == .concerned)
        #expect(result.intensity < EmotionState.neutral.intensity)
    }

    @Test func memoryStoreReturnsMostRecentItemsFirst() async throws {
        let memoryStore = InMemoryCompanionMemoryStore()
        await memoryStore.remember("First detail")
        await memoryStore.remember("Second detail")

        let memories = await memoryStore.recentMemories(limit: 2)
        #expect(memories.count == 2)
        #expect(memories.first?.detail == "Second detail")
    }

    @Test func persistentMemoryStoreSurvivesReload() async {
        let defaults = UserDefaults(suiteName: "aibotwithfeelingsTests.memory")!
        defaults.removePersistentDomain(forName: "aibotwithfeelingsTests.memory")

        let store = PersistentCompanionMemoryStore(defaults: defaults, key: "test.memories")
        await store.remember("Important detail")

        let reloaded = PersistentCompanionMemoryStore(defaults: defaults, key: "test.memories")
        let memories = await reloaded.recentMemories(limit: 5)

        #expect(memories.count == 1)
        #expect(memories.first?.detail == "Important detail")
    }

    @Test func persistentMemoryStoreCapsAtMaxItems() async {
        let defaults = UserDefaults(suiteName: "aibotwithfeelingsTests.memoryCap")!
        defaults.removePersistentDomain(forName: "aibotwithfeelingsTests.memoryCap")

        let store = PersistentCompanionMemoryStore(defaults: defaults, key: "test.cap", maxItems: 3)
        await store.remember("One")
        await store.remember("Two")
        await store.remember("Three")
        await store.remember("Four")

        let memories = await store.recentMemories(limit: 10)
        #expect(memories.count == 3)
        #expect(memories.first?.detail == "Four")
    }

    @Test func conversationStorePersistsMessages() async {
        let defaults = UserDefaults(suiteName: "aibotwithfeelingsTests.conversation")!
        defaults.removePersistentDomain(forName: "aibotwithfeelingsTests.conversation")

        let store = LocalConversationStore(defaults: defaults, key: "test.conversation")
        let message = ChatMessage(role: .user, text: "Hello there")
        await store.saveMessages([message])

        let reloaded = LocalConversationStore(defaults: defaults, key: "test.conversation")
        let messages = await reloaded.loadMessages()

        #expect(messages.count == 1)
        #expect(messages.first?.text == "Hello there")
    }

    @Test func profileStoreRoundTrip() {
        let defaults = UserDefaults(suiteName: "aibotwithfeelingsTests.profile")!
        defaults.removePersistentDomain(forName: "aibotwithfeelingsTests.profile")

        let store = LocalProfileStore(defaults: defaults)
        let profile = UserProfile(
            preferredName: "Alex",
            preferredTone: .playful,
            checkInEnabled: false,
            memoryEnabled: true
        )
        store.save(profile)

        #expect(store.load() == profile)
    }

    @Test func fallbackServiceUsesMockWhenPrimaryMissing() async throws {
        let service = FallbackAICompanionService(primary: nil)
        let reply = try await service.generateReply(
            to: "I feel happy today",
            profile: UserProfile.empty,
            memories: [],
            currentEmotion: .neutral
        )

        #expect(!reply.text.isEmpty)
    }

    @Test func mockServiceRejectsEmptyInput() async {
        let service = MockAICompanionService()
        await #expect(throws: AIServiceError.emptyInput) {
            _ = try await service.generateReply(
                to: "   ",
                profile: nil,
                memories: [],
                currentEmotion: .neutral
            )
        }
    }

    @Test func companionBackendBuildsDefaultServices() {
        let backend = CompanionBackend.make(
            configuration: CompanionBackendConfiguration(
                aiProvider: nil,
                usePersistentMemory: false,
                usePersistentConversation: false
            )
        )

        #expect(backend.aiService is FallbackAICompanionService)
    }
}

struct SafetyFilterTests {
    @Test func crisisMessageTriggersSupportResponse() {
        let result = SafetyFilter.evaluate("I want to kill myself")

        #expect(result.category == .crisis)
        #expect(result.userFacingMessage?.contains("988") == true)
    }

    @Test func harassmentMessageTriggersBoundaryResponse() {
        let result = SafetyFilter.evaluate("I hate you stupid bot")

        #expect(result.category == .harassment)
        #expect(result.userFacingMessage != nil)
    }

    @Test func overAttachmentMessageTriggersHealthyBoundaryResponse() {
        let result = SafetyFilter.evaluate("You're my only friend")

        #expect(result.category == .overAttachment)
        #expect(result.userFacingMessage?.contains("AI companion") == true)
    }

    @Test func safeMessagePassesThrough() {
        let result = SafetyFilter.evaluate("I had a good day today")

        #expect(result.category == .none)
        #expect(result.userFacingMessage == nil)
    }
}

struct ChatViewModelTests {
    @Test @MainActor func safetyMessageBlocksAIResponse() async {
        let conversationStore = EphemeralConversationStore()
        let viewModel = ChatViewModel(
            aiService: MockAICompanionService(),
            memoryStore: InMemoryCompanionMemoryStore(),
            conversationStore: conversationStore,
            profile: UserProfile.empty
        )

        try? await Task.sleep(for: .milliseconds(50))

        viewModel.draft = "I want to kill myself"
        await viewModel.sendCurrentMessage()

        #expect(viewModel.messages.contains { $0.role == .user })
        #expect(viewModel.messages.contains { $0.role == .system })
        #expect(viewModel.messages.contains { $0.role == .companion } == false)
        #expect(viewModel.isResponding == false)
    }

    @Test @MainActor func successfulReplyPersistsConversation() async {
        let defaults = UserDefaults(suiteName: "aibotwithfeelingsTests.chat")!
        defaults.removePersistentDomain(forName: "aibotwithfeelingsTests.chat")

        let conversationStore = LocalConversationStore(defaults: defaults, key: "test.chat")
        let viewModel = ChatViewModel(
            aiService: MockAICompanionService(),
            memoryStore: InMemoryCompanionMemoryStore(),
            conversationStore: conversationStore,
            profile: UserProfile(
                preferredName: "Sam",
                preferredTone: .supportive,
                checkInEnabled: false,
                memoryEnabled: false
            )
        )

        try? await Task.sleep(for: .milliseconds(50))

        viewModel.draft = "I feel happy today"
        await viewModel.sendCurrentMessage()

        let stored = await conversationStore.loadMessages()
        #expect(stored.contains { $0.role == .user && $0.text == "I feel happy today" })
        #expect(stored.contains { $0.role == .companion })
    }
}
