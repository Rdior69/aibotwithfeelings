//
//  BotBrainTests.swift
//  aibotwithfeelingsTests
//

import Testing
import Foundation
@testable import aibotwithfeelings

struct BotBrainTests {
    let brain = BotBrain()

    private var profile: UserProfile {
        UserProfile(displayName: "Sam", botName: "Ava",
                    personalityID: "companion", hasCompletedOnboarding: true)
    }

    @Test func remembersAcrossTurns() {
        var mood = MoodState.neutral
        var memory = MemoryStore()

        let first = brain.process(userText: "my name is Sam and I love astronomy",
                                  profile: profile, mood: mood, memory: memory)
        mood = first.updatedMood
        memory = first.updatedMemory

        let second = brain.process(userText: "I just got a new telescope for astronomy!",
                                   profile: profile, mood: mood, memory: memory)
        // The recalled preference should surface in the reply.
        #expect(second.reply.text.lowercased().contains("remember"))
    }

    @Test func moodCarriesBetweenTurns() {
        var mood = MoodState.neutral
        let memory = MemoryStore()
        let happy = brain.process(userText: "I'm so happy and excited!!!",
                                  profile: profile, mood: mood, memory: memory)
        mood = happy.updatedMood
        #expect(mood.dominant.isPositive)
        #expect(happy.reply.moodEmoji != nil)
    }

    @Test func sensitivePersonalityShiftsMoodMore() {
        let sensitive = UserProfile(displayName: "Sam", botName: "Ava",
                                    personalityID: "companion", hasCompletedOnboarding: true) // sensitivity 0.9
        let stoic = UserProfile(displayName: "Sam", botName: "Ava",
                                personalityID: "witty", hasCompletedOnboarding: true) // sensitivity 0.5
        let text = "I'm devastated and heartbroken"
        let a = brain.process(userText: text, profile: sensitive, mood: .neutral, memory: MemoryStore())
        let b = brain.process(userText: text, profile: stoic, mood: .neutral, memory: MemoryStore())
        #expect(a.updatedMood.score(for: .sadness) >= b.updatedMood.score(for: .sadness))
    }

    @Test func everyTurnReturnsNonEmptyReply() {
        let conversation = ["hello", "I feel anxious about tomorrow", "thanks for listening",
                            "I love my dog", "why do I feel this way?", "goodnight"]
        var mood = MoodState.neutral
        var memory = MemoryStore()
        for line in conversation {
            let r = brain.process(userText: line, profile: profile, mood: mood, memory: memory)
            mood = r.updatedMood
            memory = r.updatedMemory
            #expect(!r.reply.text.isEmpty)
            #expect(r.reply.sender == .bot)
        }
    }
}
