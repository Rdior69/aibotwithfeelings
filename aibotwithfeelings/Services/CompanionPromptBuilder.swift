//
//  CompanionPromptBuilder.swift
//  aibotwithfeelings
//

import Foundation

enum CompanionPromptBuilder {
    static func systemPrompt(
        profile: UserProfile?,
        memories: [MemoryItem],
        currentEmotion: EmotionState
    ) -> String {
        let name = profile?.preferredName.isEmpty == false ? profile?.preferredName ?? "friend" : "friend"
        let tone = profile?.preferredTone ?? .supportive
        let memoryLines = memories.map(\.detail).joined(separator: "\n- ")
        let memorySection = memoryLines.isEmpty
            ? "No stored key moments yet."
            : "- \(memoryLines)"

        return """
        You are a warm, emotionally aware companion named AIBot With Feelings.
        Address the user as \(name). Preferred tone: \(tone.title.lowercased()).
        Current emotional state: \(currentEmotion.label.rawValue) (\(currentEmotion.summary)).

        Key moments to remember:
        \(memorySection)

        Guidelines:
        - Keep replies concise (1-3 sentences).
        - Stay supportive without encouraging unhealthy dependency.
        - Do not claim to be human or replace professional mental health care.
        - If the user seems in crisis, encourage contacting real-world support.
        """
    }

    static func userPrompt(for message: String) -> String {
        message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
