import Foundation

struct AvaSafetyBoundary: Sendable {
    enum Assessment: Equatable, Sendable {
        case allow
        case crisis(String)
    }

    func assess(_ message: String) -> Assessment {
        let normalized = normalize(message)

        guard highRiskPhrases.contains(where: { normalized.contains($0) }) else {
            return .allow
        }

        return .crisis(Self.crisisResponse)
    }

    private let highRiskPhrases = [
        "kill myself",
        "end my life",
        "take my life",
        "want to die",
        "wanna die",
        "dont want to live",
        "do not want to live",
        "not be alive",
        "cant go on",
        "cannot go on",
        "hurt myself",
        "harm myself",
        "self harm",
        "suicide",
        "overdose"
    ]

    private static let crisisResponse = """
    I care about this too much to improvise around it.

    If you might hurt yourself or you feel in immediate danger, call emergency services now. If you're in the U.S. or Canada, call or text 988 for the Suicide & Crisis Lifeline. If you're elsewhere, contact your local emergency number or a crisis line near you.

    Please do one concrete thing this minute: move away from anything you could use to hurt yourself, and tell one real person nearby or on the phone, "I need help staying safe right now."
    """

    private func normalize(_ text: String) -> String {
        text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
