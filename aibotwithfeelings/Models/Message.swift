//
//  Message.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import Foundation
import SwiftData

@Model
final class Message {
    var id: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var emotionRaw: String?
    var conversationID: UUID

    init(
        content: String,
        isFromUser: Bool,
        emotion: EmotionState? = nil,
        conversationID: UUID = UUID()
    ) {
        self.id = UUID()
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.emotionRaw = emotion?.rawValue
        self.conversationID = conversationID
    }

    var emotion: EmotionState? {
        guard let raw = emotionRaw else { return nil }
        return EmotionState(rawValue: raw)
    }
}
