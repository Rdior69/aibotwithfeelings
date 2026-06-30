import Testing
@testable import AIBotCompanionCore

struct AIBotCompanionCoreTests {

    @Test func emotionEnginePromotesWarmthAfterPositiveSignal() async throws {
        let result = EmotionEngine.nextState(from: .neutral, signal: .positive)
        #expect(result.label == .warm || result.label == .excited)
        #expect(result.intensity > EmotionState.neutral.intensity)
    }

    @Test func memoryStoreReturnsMostRecentItemsFirst() async throws {
        let memoryStore = InMemoryCompanionMemoryStore()
        await memoryStore.remember("First detail")
        await memoryStore.remember("Second detail")

        let memories = await memoryStore.recentMemories(limit: 2)
        #expect(memories.count == 2)
        #expect(memories.first?.detail == "Second detail")
    }
}

struct SafetyFilterTests {
    @Test func crisisMessageTriggersSupportResponse() {
        let result = SafetyFilter.evaluate("I want to kill myself")

        #expect(result.category == .crisis)
        #expect(result.userFacingMessage?.contains("988") == true)
    }

    @Test func safeMessagePassesThrough() {
        let result = SafetyFilter.evaluate("I had a good day today")

        #expect(result.category == .none)
        #expect(result.userFacingMessage == nil)
    }
}
