import Foundation

struct IntentAnalyzer: Sendable {
    func analyze(_ message: String) -> ToolSelection {
        let lower = message.lowercased()
        var tools: [AvaToolKind] = []

        if needsWebSearch(lower) { tools.append(.webSearch) }
        if needsWikipedia(lower) { tools.append(.wikipedia) }
        if needsWeather(lower) { tools.append(.weather) }
        if needsNews(lower) { tools.append(.news) }
        if needsCreativeSpark(lower) { tools.append(.creativeSpark) }
        if needsQuoteWisdom(lower) { tools.append(.quoteWisdom) }

        // Ava always reaches outward on substantive messages — never rely on stale training alone.
        if tools.isEmpty && message.count > 12 {
            tools.append(.creativeSpark)
            if looksFactual(lower) {
                tools.append(.webSearch)
            }
        }

        return ToolSelection(
            tools: tools,
            searchQuery: extractSearchQuery(from: message),
            locationHint: extractLocation(from: lower),
            topicHint: extractTopic(from: message)
        )
    }

    private func needsWebSearch(_ lower: String) -> Bool {
        let triggers = ["what is", "who is", "how does", "why does", "when did", "latest", "current",
                        "today", "right now", "explain", "define", "tell me about", "search"]
        return triggers.contains { lower.contains($0) }
    }

    private func needsWikipedia(_ lower: String) -> Bool {
        let triggers = ["history of", "who was", "what was", "biography", "origin of", "invented",
                        "discovered", "founded", "ancient", "century", "era", "movement"]
        return triggers.contains { lower.contains($0) }
    }

    private func needsWeather(_ lower: String) -> Bool {
        let triggers = ["weather", "temperature", "rain", "forecast", "sunny", "cold outside", "hot outside"]
        return triggers.contains { lower.contains($0) }
    }

    private func needsNews(_ lower: String) -> Bool {
        let triggers = ["news", "headlines", "happening in the world", "what's going on", "current events",
                        "breaking", "politics today", "stock market"]
        return triggers.contains { lower.contains($0) }
    }

    private func needsCreativeSpark(_ lower: String) -> Bool {
        let triggers = ["stuck", "bored", "idea", "creative", "inspire", "brainstorm", "help me think",
                        "what should i", "advice", "opinion", "feel", "feeling", "lonely", "anxious",
                        "sad", "happy", "excited", "worried", "relationship", "career", "life"]
        return triggers.contains { lower.contains($0) }
    }

    private func needsQuoteWisdom(_ lower: String) -> Bool {
        let triggers = ["motivat", "quote", "wisdom", "meaning of life", "perspective", "philosophy",
                        "inspiration", "encourage"]
        return triggers.contains { lower.contains($0) }
    }

    private func looksFactual(_ lower: String) -> Bool {
        lower.contains("?") || lower.split(separator: " ").count > 6
    }

    private func extractSearchQuery(from message: String) -> String? {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func extractLocation(from lower: String) -> String? {
        let patterns = ["in ", "at ", "near "]
        for pattern in patterns {
            if let range = lower.range(of: pattern) {
                let after = String(lower[range.upperBound...])
                let words = after.split(separator: " ").prefix(3).joined(separator: " ")
                if words.count > 2 { return words }
            }
        }
        return nil
    }

    private func extractTopic(from message: String) -> String? {
        let words = message.split(separator: " ").filter { $0.count > 3 }
        return words.prefix(4).joined(separator: " ")
    }
}
