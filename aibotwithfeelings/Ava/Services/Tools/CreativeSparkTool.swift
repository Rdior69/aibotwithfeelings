import Foundation

/// Quotable API + cross-domain analogy seeds — pushes Ava past generic advice.
struct CreativeSparkTool: ExternalTool {
    let kind: AvaToolKind = .creativeSpark

    private let analogySeeds = [
        "Consider the Lindy effect: ideas that have survived longest are likely to survive longest.",
        "What would the opposite strategy look like — and is it secretly smarter?",
        "Map this problem onto a completely different field (biology, game theory, jazz improvisation).",
        "The constraint you hate might be the feature that makes the solution unique.",
        "If you had to explain this to a skeptical 12-year-old, what would you drop first?",
        "What would you do if you knew nobody would judge you for 24 hours?",
        "The second-order effect matters more than the first-order win here.",
    ]

    func isRelevant(to message: String) -> Bool {
        IntentAnalyzer().analyze(message).tools.contains(.creativeSpark)
    }

    func gather(message: String, context: ToolSelection) async throws -> ExternalIntel? {
        var parts: [String] = []

        // Random analogy seed
        if let seed = analogySeeds.randomElement() {
            parts.append("Reframe seed: \(seed)")
        }

        // Fetch a random quote for unexpected wisdom injection
        if let url = URL(string: "https://api.quotable.io/random?maxLength=120") {
            if let (data, _) = try? await URLSession.shared.data(from: url),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = json["content"] as? String,
               let author = json["author"] as? String {
                parts.append("Quote spark: \"\(content)\" — \(author)")
            }
        }

        return ExternalIntel(
            tool: kind,
            summary: parts.joined(separator: " "),
            source: "Creative Spark Module"
        )
    }
}
