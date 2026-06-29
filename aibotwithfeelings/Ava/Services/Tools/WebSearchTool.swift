import Foundation

/// DuckDuckGo Instant Answer API — free, no API key required.
struct WebSearchTool: ExternalTool {
    let kind: AvaToolKind = .webSearch

    func isRelevant(to message: String) -> Bool {
        IntentAnalyzer().analyze(message).tools.contains(.webSearch)
    }

    func gather(message: String, context: ToolSelection) async throws -> ExternalIntel? {
        guard let query = context.searchQuery?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }

        let urlString = "https://api.duckduckgo.com/?q=\(query)&format=json&no_html=1&skip_disambig=1"
        guard let url = URL(string: urlString) else { return nil }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        var parts: [String] = []

        if let abstract = json?["AbstractText"] as? String, !abstract.isEmpty {
            parts.append(abstract)
        }
        if let answer = json?["Answer"] as? String, !answer.isEmpty {
            parts.append("Direct answer: \(answer)")
        }
        if let related = json?["RelatedTopics"] as? [[String: Any]] {
            let snippets = related.prefix(3).compactMap { $0["Text"] as? String }
            parts.append(contentsOf: snippets)
        }

        guard !parts.isEmpty else { return nil }

        let source = json?["AbstractSource"] as? String
        return ExternalIntel(
            tool: kind,
            summary: parts.joined(separator: " | "),
            source: source ?? "DuckDuckGo"
        )
    }
}
