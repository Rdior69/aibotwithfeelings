//
//  PersistenceTests.swift
//  aibotwithfeelingsTests
//

import Testing
import Foundation
@testable import aibotwithfeelings

struct PersistenceTests {

    private func tempURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("aibot_test_\(UUID().uuidString).json")
    }

    @Test func savesAndLoadsRoundTrip() throws {
        let url = tempURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let controller = PersistenceController(fileURL: url)

        var memory = MemoryStore()
        memory.learn(from: "my name is Quinn", sentiment: 0.1)
        let state = PersistedState(
            profile: UserProfile(displayName: "Quinn", botName: "Ava", hasCompletedOnboarding: true),
            messages: [ChatMessage(sender: .user, text: "hello")],
            mood: MoodState(scores: [.joy: 0.5]),
            memory: memory
        )

        try controller.save(state)
        let loaded = controller.load()
        #expect(loaded == state)
    }

    @Test func loadReturnsNilWhenMissing() {
        let controller = PersistenceController(fileURL: tempURL())
        #expect(controller.load() == nil)
    }

    @Test func resetRemovesFile() throws {
        let url = tempURL()
        let controller = PersistenceController(fileURL: url)
        try controller.save(.initial)
        #expect(controller.load() != nil)
        controller.reset()
        #expect(controller.load() == nil)
    }

    @Test func brainEndToEndConversationPersists() throws {
        let url = tempURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let controller = PersistenceController(fileURL: url)
        let brain = BotBrain()
        var profile = UserProfile(displayName: "Dana", botName: "Ava", hasCompletedOnboarding: true)
        var mood = MoodState.neutral
        var memory = MemoryStore()
        var messages: [ChatMessage] = []

        for line in ["my name is Dana", "I love painting", "I had an amazing day!"] {
            messages.append(ChatMessage(sender: .user, text: line))
            let result = brain.process(userText: line, profile: profile, mood: mood, memory: memory)
            mood = result.updatedMood
            memory = result.updatedMemory
            messages.append(result.reply)
        }
        _ = profile // profile unchanged here

        try controller.save(PersistedState(profile: profile, messages: messages, mood: mood, memory: memory))
        let loaded = try #require(controller.load())
        #expect(loaded.memory.knownFacts.contains { $0.content.contains("Dana") })
        #expect(loaded.memory.items.contains { $0.content.contains("painting") })
        #expect(loaded.messages.count == messages.count)
    }
}
