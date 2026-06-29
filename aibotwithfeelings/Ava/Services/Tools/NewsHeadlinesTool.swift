import Foundation

/// Hacker News Firebase API — real headlines for current-events grounding.
struct NewsHeadlinesTool: ExternalTool {
    let kind: AvaToolKind = .news

    func isRelevant(to message: String) -> Bool {
        IntentAnalyzer().analyze(message).tools.contains(.news)
    }

    func gather(message: String, context: ToolSelection) async throws -> ExternalIntel? {
        let urlString = "https://hacker-news.firebaseio.com/v0/topstories.json"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let ids = try JSONSerialization.jsonObject(with: data) as? [Int] else { return nil }

        var headlines: [String] = []
        for id in ids.prefix(5) {
            let itemURL = "https://hacker-news.firebaseio.com/v0/item/\(id).json"
            guard let itemURLObj = URL(string: itemURL) else { continue }
            let (itemData, _) = try await URLSession.shared.data(from: itemURLObj)
            guard let item = try JSONSerialization.jsonObject(with: itemData) as? [String: Any],
                  let title = item["title"] as? String else { continue }
            headlines.append(title)
        }

        guard !headlines.isEmpty else { return nil }

        return ExternalIntel(
            tool: kind,
            summary: "Top stories right now: " + headlines.joined(separator: " • "),
            source: "Hacker News"
        )
    }
}
