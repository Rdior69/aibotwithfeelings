import Foundation

/// ZenQuotes API — philosophical counterweight to empty chatbot affirmation.
struct QuoteWisdomTool: ExternalTool {
    let kind: AvaToolKind = .quoteWisdom

    func isRelevant(to message: String) -> Bool {
        IntentAnalyzer().analyze(message).tools.contains(.quoteWisdom)
    }

    func gather(message: String, context: ToolSelection) async throws -> ExternalIntel? {
        guard let url = URL(string: "https://zenquotes.io/api/random") else { return nil }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }

        guard let quotes = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let quote = quotes.first,
              let text = quote["q"] as? String,
              let author = quote["a"] as? String else { return nil }

        return ExternalIntel(
            tool: kind,
            summary: "\"\(text)\" — \(author). Use this as a lens, not a bumper sticker.",
            source: "ZenQuotes"
        )
    }
}
