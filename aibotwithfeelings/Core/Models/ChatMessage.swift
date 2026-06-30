//
//  ChatMessage.swift
//  aibotwithfeelings
//
//  Foundation-only chat message model.
//

import Foundation

/// Who authored a message.
public enum MessageSender: String, Codable, Sendable {
    case user
    case bot
    /// System / safety messages (e.g. crisis resources, onboarding notes).
    case system
}

/// A single message in the conversation transcript.
public struct ChatMessage: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let sender: MessageSender
    public let text: String
    public let timestamp: Date

    /// The bot's mood at the time it produced this message (nil for user/system).
    public let moodEmoji: String?

    public init(
        id: UUID = UUID(),
        sender: MessageSender,
        text: String,
        timestamp: Date = Date(),
        moodEmoji: String? = nil
    ) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
        self.moodEmoji = moodEmoji
    }
}
