//
//  ColorTheme.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

struct ColorTheme {
    // Chat bubbles
    static let userBubble = Color("UserBubble", bundle: nil)
    static let botBubble = Color("BotBubble", bundle: nil)

    // Backgrounds
    static let chatBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)

    // Accent gradient for the bot's header/avatar area
    static func emotionGradient(for emotion: EmotionState) -> LinearGradient {
        LinearGradient(
            colors: [emotion.primaryColor, emotion.secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // User message bubble gradient
    static let userGradient = LinearGradient(
        colors: [Color.blue, Color(red: 0.2, green: 0.5, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
