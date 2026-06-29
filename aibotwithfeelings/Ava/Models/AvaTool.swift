import Foundation

enum AvaToolKind: String, CaseIterable, Sendable {
    case webSearch = "Web Search"
    case wikipedia = "Wikipedia"
    case weather = "Weather"
    case news = "News"
    case creativeSpark = "Creative Spark"
    case quoteWisdom = "Quote Wisdom"

    var icon: String {
        switch self {
        case .webSearch: return "magnifyingglass"
        case .wikipedia: return "book.closed"
        case .weather: return "cloud.sun"
        case .news: return "newspaper"
        case .creativeSpark: return "lightbulb"
        case .quoteWisdom: return "quote.bubble"
        }
    }
}

struct ExternalIntel: Sendable {
    let tool: AvaToolKind
    let summary: String
    let source: String?
}

struct ToolSelection: Sendable {
    let tools: [AvaToolKind]
    let searchQuery: String?
    let locationHint: String?
    let topicHint: String?
}

protocol ExternalTool: Sendable {
    var kind: AvaToolKind { get }
    func isRelevant(to message: String) -> Bool
    func gather(message: String, context: ToolSelection) async throws -> ExternalIntel?
}
