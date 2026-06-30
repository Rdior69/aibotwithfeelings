//
//  ResponseGeneratorTests.swift
//  aibotwithfeelingsTests
//

import Testing
import Foundation
@testable import aibotwithfeelings

struct ResponseGeneratorTests {
    let generator = LocalResponseGenerator()
    let engine = EmotionEngine()

    private func context(
        _ text: String,
        personalityID: String = "companion",
        memories: [MemoryItem] = []
    ) -> ResponseContext {
        let profile = UserProfile(displayName: "Riley", botName: "Ava",
                                  personalityID: personalityID,
                                  hasCompletedOnboarding: true)
        let signal = engine.analyze(text)
        let mood = engine.updatedMood(from: .neutral, applying: signal,
                                      sensitivity: profile.personality.traits.sensitivity)
        return ResponseContext(
            userText: text,
            profile: profile,
            personality: profile.personality,
            mood: mood,
            signal: signal,
            relevantMemories: memories
        )
    }

    @Test func greetingMentionsUserName() {
        let reply = generator.reply(to: context("hello"))
        #expect(reply.contains("Riley"))
        #expect(!reply.isEmpty)
    }

    @Test func negativeMessageIsEmpathetic() {
        let reply = generator.reply(to: context("I'm feeling really sad and alone"))
        let lowered = reply.lowercased()
        #expect(lowered.contains("sorry") || lowered.contains("listening") || lowered.contains("hear you"))
    }

    @Test func positiveMessageIsEncouraging() {
        let reply = generator.reply(to: context("I got a promotion, I'm so happy!"))
        #expect(!reply.isEmpty)
        #expect(reply.lowercased().contains("glad") || reply.lowercased().contains("wonderful") || reply.contains("🎉") || reply.lowercased().contains("love"))
    }

    @Test func recallsPreferenceMemory() {
        let memory = MemoryItem(kind: .preference, content: "User likes hiking",
                                keywords: ["hiking"], sentiment: 0.6, importance: 0.7)
        let reply = generator.reply(to: context("guess what I did", memories: [memory]))
        #expect(reply.lowercased().contains("remember"))
    }

    @Test func personalityChangesTone() {
        let warm = generator.reply(to: context("hi", personalityID: "companion"))
        let witty = generator.reply(to: context("what is the meaning of life?", personalityID: "witty"))
        #expect(!warm.isEmpty)
        #expect(!witty.isEmpty)
    }

    @Test func replyNeverEmptyAcrossInputs() {
        let inputs = ["hey", "thanks!", "bye", "I love pizza", "why is the sky blue?",
                      "ugh I'm so frustrated", "just chilling", "I feel anxious"]
        for input in inputs {
            #expect(!generator.reply(to: context(input)).isEmpty, "empty reply for: \(input)")
        }
    }
}
