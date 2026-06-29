import Foundation

/// Wikipedia REST API — enriches responses with encyclopedic depth.
struct WikipediaTool: ExternalTool {
    let kind: AvaToolKind = .wikipedia

    func isRelevant(to message: String) -> Bool {
        IntentAnalyzer().analyze(message).tools.contains(.wikipedia)
    }

    func gather(message: String, context: ToolSelection) async throws -> ExternalIntel? {
        let query = (context.topicHint ?? context.searchQuery ?? message)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? message

        let searchURL = "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=\(query)&format=json&srlimit=1"
        guard let url = URL(string: searchURL) else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let queryObj = json["query"] as? [String: Any],
              let results = queryObj["search"] as? [[String: Any]],
              let first = results.first,
              let pageId = first["pageid"] as? Int else { return nil }

        let extractURL = "https://en.wikipedia.org/w/api.php?action=query&prop=extracts&exintro=1&explaintext=1&pageids=\(pageId)&format=json"
        guard let extractURLObj = URL(string: extractURL) else { return nil }

        let (extractData, _) = try await URLSession.shared.data(from: extractURLObj)
        guard let extractJSON = try JSONSerialization.jsonObject(with: extractData) as? [String: Any],
              let pages = extractJSON["query"] as? [String: Any],
              let pageDict = pages["pages"] as? [String: Any],
              let page = pageDict[String(pageId)] as? [String: Any],
              let extract = page["extract"] as? String, !extract.isEmpty else { return nil }

        let title = first["title"] as? String ?? "Wikipedia"
        let trimmed = String(extract.prefix(600))

        return ExternalIntel(
            tool: kind,
            summary: trimmed,
            source: "Wikipedia: \(title)"
        )
    }
}
