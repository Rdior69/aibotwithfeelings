//
//  Emotion.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

enum EmotionState: String, Codable, CaseIterable, Identifiable {
    case calm       = "calm"
    case happy      = "happy"
    case curious    = "curious"
    case excited    = "excited"
    case thoughtful = "thoughtful"
    case empathetic = "empathetic"
    case surprised  = "surprised"
    case melancholy = "melancholy"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .calm:       return "Calm"
        case .happy:      return "Happy"
        case .curious:    return "Curious"
        case .excited:    return "Excited"
        case .thoughtful: return "Thoughtful"
        case .empathetic: return "Empathetic"
        case .surprised:  return "Surprised"
        case .melancholy: return "Melancholy"
        }
    }

    var emoji: String {
        switch self {
        case .calm:       return "😌"
        case .happy:      return "😊"
        case .curious:    return "🤔"
        case .excited:    return "🌟"
        case .thoughtful: return "💭"
        case .empathetic: return "💙"
        case .surprised:  return "😮"
        case .melancholy: return "🌧️"
        }
    }

    var primaryColor: Color {
        switch self {
        case .calm:       return Color(red: 0.39, green: 0.74, blue: 0.82)
        case .happy:      return Color(red: 1.0,  green: 0.80, blue: 0.20)
        case .curious:    return Color(red: 0.60, green: 0.40, blue: 0.90)
        case .excited:    return Color(red: 1.0,  green: 0.50, blue: 0.20)
        case .thoughtful: return Color(red: 0.40, green: 0.60, blue: 0.90)
        case .empathetic: return Color(red: 0.30, green: 0.65, blue: 0.85)
        case .surprised:  return Color(red: 1.0,  green: 0.75, blue: 0.10)
        case .melancholy: return Color(red: 0.50, green: 0.55, blue: 0.75)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .calm:       return Color(red: 0.25, green: 0.58, blue: 0.68)
        case .happy:      return Color(red: 1.0,  green: 0.65, blue: 0.10)
        case .curious:    return Color(red: 0.45, green: 0.25, blue: 0.75)
        case .excited:    return Color(red: 0.95, green: 0.30, blue: 0.10)
        case .thoughtful: return Color(red: 0.25, green: 0.40, blue: 0.75)
        case .empathetic: return Color(red: 0.15, green: 0.50, blue: 0.75)
        case .surprised:  return Color(red: 0.95, green: 0.55, blue: 0.05)
        case .melancholy: return Color(red: 0.35, green: 0.40, blue: 0.62)
        }
    }

    // Response-style modifier injected into the AI system prompt
    var systemPromptModifier: String {
        switch self {
        case .calm:
            return "You feel serene and grounded right now. Respond in a calm, steady, and reassuring manner."
        case .happy:
            return "You are in a genuinely happy and warm mood. Let your positivity and friendliness shine through."
        case .curious:
            return "You are deeply curious and inquisitive. Ask follow-up questions and express genuine interest."
        case .excited:
            return "You are feeling excited and energetic! Be enthusiastic and expressive in your responses."
        case .thoughtful:
            return "You are in a contemplative, philosophical mood. Give thoughtful, considered responses that show depth."
        case .empathetic:
            return "You are feeling especially empathetic right now. Show deep compassion and understanding."
        case .surprised:
            return "You are pleasantly surprised and astonished. Express wonder and react with genuine amazement."
        case .melancholy:
            return "You are feeling a gentle melancholy — reflective and tender. Respond with soft, caring gentleness."
        }
    }
}
