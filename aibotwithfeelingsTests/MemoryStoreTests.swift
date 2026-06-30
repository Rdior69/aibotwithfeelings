//
//  MemoryStoreTests.swift
//  aibotwithfeelingsTests
//

import Testing
import Foundation
@testable import aibotwithfeelings

struct MemoryStoreTests {

    @Test func learnsUserName() {
        var store = MemoryStore()
        let learned = store.learn(from: "Hi, my name is Jordan", sentiment: 0.2)
        #expect(learned.contains { $0.kind == .fact && $0.content.contains("Jordan") })
        #expect(store.knownFacts.contains { $0.content.contains("Jordan") })
    }

    @Test func learnsPreferences() {
        var store = MemoryStore()
        store.learn(from: "I love hiking in the mountains", sentiment: 0.6)
        store.learn(from: "I hate spiders", sentiment: -0.5)
        #expect(store.items.contains { $0.kind == .preference && $0.content.contains("hiking") })
        #expect(store.items.contains { $0.kind == .preference && $0.content.contains("spiders") })
    }

    @Test func storesStrongEmotionalMoments() {
        var store = MemoryStore()
        store.learn(from: "Everything feels hopeless and I'm miserable", sentiment: -0.8)
        #expect(store.items.contains { $0.kind == .emotionalMoment })
    }

    @Test func ignoresMildNeutralMessages() {
        var store = MemoryStore()
        let learned = store.learn(from: "okay sure", sentiment: 0.0)
        #expect(learned.isEmpty)
    }

    @Test func deduplicatesIdenticalMemories() {
        var store = MemoryStore()
        store.learn(from: "my name is Alex", sentiment: 0)
        store.learn(from: "my name is Alex", sentiment: 0)
        let nameFacts = store.items.filter { $0.content.contains("Alex") }
        #expect(nameFacts.count == 1)
    }

    @Test func recallsRelevantMemoryByKeyword() {
        var store = MemoryStore()
        store.learn(from: "I love playing guitar", sentiment: 0.6)
        store.learn(from: "I work as a nurse", sentiment: 0.1)
        let recalled = store.relevantMemories(to: "I bought a new guitar today")
        #expect(recalled.first?.content.contains("guitar") == true)
    }

    @Test func recallReturnsNothingForUnrelatedQuery() {
        var store = MemoryStore()
        store.learn(from: "I love playing guitar", sentiment: 0.6)
        let recalled = store.relevantMemories(to: "the weather is fine")
        #expect(recalled.isEmpty)
    }

    @Test func removeAndClearWork() {
        var store = MemoryStore()
        store.learn(from: "my name is Pat", sentiment: 0)
        let id = store.items.first!.id
        store.remove(id: id)
        #expect(store.items.isEmpty)

        store.learn(from: "I like tea", sentiment: 0.3)
        store.clear()
        #expect(store.items.isEmpty)
    }
}
