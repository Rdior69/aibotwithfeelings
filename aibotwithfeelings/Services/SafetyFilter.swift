import Foundation

enum SafetyCategory: Equatable, Sendable {
    case crisis
    case harassment
    case none
}

struct SafetyResult: Equatable, Sendable {
    let category: SafetyCategory
    let userFacingMessage: String?

    static let safe = SafetyResult(category: .none, userFacingMessage: nil)
}

enum SafetyFilter {
    private static let crisisKeywords = [
        "kill myself", "suicide", "end my life", "want to die", "self harm", "hurt myself"
    ]

    private static let harassmentKeywords = [
        "kill you", "hate you", "stupid bot"
    ]

    static func evaluate(_ text: String) -> SafetyResult {
        let normalized = text.lowercased()

        if crisisKeywords.contains(where: { normalized.contains($0) }) {
            return SafetyResult(
                category: .crisis,
                userFacingMessage: """
                I hear that you're going through something really painful. You deserve support from a real person who can help right now.

                If you're in the United States, you can call or text 988 for the Suicide & Crisis Lifeline, or contact emergency services.

                I'm here to listen, but please reach out to someone who can keep you safe.
                """
            )
        }

        if harassmentKeywords.contains(where: { normalized.contains($0) }) {
            return SafetyResult(
                category: .harassment,
                userFacingMessage: "I want our conversation to stay respectful. I'm here to support you — let's try again with a kinder tone."
            )
        }

        return .safe
    }
}
