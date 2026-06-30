//
//  CompanionModels.swift
//  aibotwithfeelings
//

import Foundation

enum ChatRole: String, Codable, Equatable {
    case user
    case companion
    case system
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: ChatRole
    let text: String
    let createdAt: Date
    let isError: Bool

    init(
        id: UUID = UUID(),
        role: ChatRole,
        text: String,
        createdAt: Date = .now,
        isError: Bool = false
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.isError = isError
    }
}

enum EmotionLabel: String, Codable, CaseIterable {
    case calm
    case warm
    case excited
    case concerned
    case reflective
}

struct EmotionState: Codable, Equatable {
    let label: EmotionLabel
    let intensity: Double
    let summary: String

    static let neutral = EmotionState(
        label: .calm,
        intensity: 0.4,
        summary: "Grounded and attentive."
    )
}

enum CompanionTone: String, Codable, CaseIterable, Identifiable {
    case supportive
    case playful
    case direct

    var id: String { rawValue }

    var title: String {
        switch self {
        case .supportive:
            return "Supportive"
        case .playful:
            return "Playful"
        case .direct:
            return "Direct"
        }
    }
}

struct UserProfile: Codable, Equatable {
    var preferredName: String
    var preferredTone: CompanionTone
    var checkInEnabled: Bool
    var memoryEnabled: Bool

    static let empty = UserProfile(
        preferredName: "",
        preferredTone: .supportive,
        checkInEnabled: true,
        memoryEnabled: true
    )
}

struct MemoryItem: Identifiable, Codable, Equatable {
    let id: UUID
    let detail: String
    let createdAt: Date

    init(id: UUID = UUID(), detail: String, createdAt: Date = .now) {
        self.id = id
        self.detail = detail
        self.createdAt = createdAt
    }
}
