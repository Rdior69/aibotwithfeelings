//
//  Theme.swift
//  aibotwithfeelings
//
//  Centralised colours, gradients and styling so the UI stays cohesive and the
//  companion's mood can visually colour the experience.
//

#if canImport(SwiftUI)
import SwiftUI

enum Theme {
    static let corner: CGFloat = 20

    /// The accent colour associated with an emotion, used for the mood ring,
    /// chat background tint and accents.
    static func color(for emotion: EmotionKind) -> Color {
        switch emotion {
        case .joy: return Color(red: 1.0, green: 0.78, blue: 0.30)
        case .affection: return Color(red: 1.0, green: 0.45, blue: 0.62)
        case .excitement: return Color(red: 1.0, green: 0.55, blue: 0.27)
        case .calm: return Color(red: 0.40, green: 0.74, blue: 0.78)
        case .neutral: return Color(red: 0.62, green: 0.66, blue: 0.78)
        case .sadness: return Color(red: 0.45, green: 0.56, blue: 0.86)
        case .anxiety: return Color(red: 0.60, green: 0.52, blue: 0.86)
        case .anger: return Color(red: 0.90, green: 0.40, blue: 0.42)
        }
    }

    /// A soft background gradient tinted by the bot's current mood.
    static func backgroundGradient(for emotion: EmotionKind, scheme: ColorScheme) -> LinearGradient {
        let tint = color(for: emotion)
        let base = scheme == .dark ? Color.black : Color.white
        return LinearGradient(
            colors: [
                tint.opacity(scheme == .dark ? 0.28 : 0.18),
                base
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static let userBubble = LinearGradient(
        colors: [Color(red: 0.36, green: 0.45, blue: 0.95),
                 Color(red: 0.51, green: 0.36, blue: 0.93)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
#endif
