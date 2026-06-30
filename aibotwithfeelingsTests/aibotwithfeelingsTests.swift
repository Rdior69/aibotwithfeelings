//
//  aibotwithfeelingsTests.swift
//  aibotwithfeelingsTests
//
//  Created by ray dior on 5/29/26.
//

import Foundation
import Testing
@testable import aibotwithfeelings

struct PersonalityEngineTests {
    @Test func greetingUsesDisplayName() {
        let profile = UserProfile(
            displayName: "Alex",
            hasCompletedOnboarding: true,
            preferredBot: .defaultBot,
            createdAt: .now
        )

        let response = PersonalityEngine.greeting(for: profile)

        #expect(response.content.contains("Alex"))
        #expect(response.emotion == .empathetic)
    }

    @Test func respondExtractsFeelingMemory() {
        let profile = UserProfile(
            displayName: "Sam",
            hasCompletedOnboarding: true,
            preferredBot: .defaultBot,
            createdAt: .now
        )

        let response = PersonalityEngine.respond(
            to: "I feel overwhelmed about work lately.",
            profile: profile,
            memories: [],
            recentMessages: []
        )

        #expect(!response.content.isEmpty)
        #expect(response.extractedMemories.contains { $0.category == .feeling })
    }

    @Test func respondReferencesRelevantMemory() {
        let memory = EmotionalMemory(
            summary: "I feel anxious about my job interview",
            category: .feeling,
            emotionalWeight: 0.8
        )
        let profile = UserProfile(
            displayName: "Jordan",
            hasCompletedOnboarding: true,
            preferredBot: .defaultBot,
            createdAt: .now
        )

        let response = PersonalityEngine.respond(
            to: "I'm nervous about the interview tomorrow.",
            profile: profile,
            memories: [memory],
            recentMessages: []
        )

        #expect(response.referencedMemoryIDs.contains(memory.id))
        #expect(response.content.lowercased().contains("remember"))
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

struct LocalMemoryStoreTests {
    @Test func roundTripsProfileAndMessages() {
        let suiteName = "aibwf.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = LocalMemoryStore(defaults: defaults)
        let profile = UserProfile(
            displayName: "Riley",
            hasCompletedOnboarding: true,
            preferredBot: BotPersonality.presets[1],
            createdAt: .now
        )

        store.saveProfile(profile)
        store.saveMessages([
            ChatMessage(role: .user, content: "Hello"),
            ChatMessage(role: .assistant, content: "Hi there", emotion: .calm)
        ])

        #expect(store.loadProfile() == profile)
        #expect(store.loadMessages().count == 2)
    }
}
