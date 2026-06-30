//
//  aibotwithfeelingsTests.swift
//  aibotwithfeelingsTests
//
//  Created by ray dior on 5/29/26.
//

import Testing
@testable import aibotwithfeelings

struct aibotwithfeelingsTests {

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
