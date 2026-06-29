import Foundation

/// Orchestrates intent analysis, parallel external module calls, and Gemini synthesis.
@MainActor
final class AvaBrain: ObservableObject {
    @Published private(set) var phase: AvaThinkingPhase = .idle

    private let intentAnalyzer = IntentAnalyzer()
    private let gemini = GeminiService()
    private let tools: [any ExternalTool] = [
        WebSearchTool(),
        WikipediaTool(),
        WeatherTool(),
        NewsHeadlinesTool(),
        CreativeSparkTool(),
        QuoteWisdomTool()
    ]

    func respond(to userMessage: String, history: [ChatMessage]) async throws -> ChatMessage {
        phase = .analyzing

        let selection = intentAnalyzer.analyze(userMessage)
        let activeTools = tools.filter { selection.tools.contains($0.kind) }

        phase = .gatheringExternalIntel(tools: activeTools.map(\.kind.rawValue))

        let intel = await gatherIntel(inParallel: activeTools, message: userMessage, context: selection)

        phase = .synthesizing

        let responseText: String
        if AvaConfig.hasAPIKey {
            responseText = try await gemini.generate(
                systemPrompt: AvaPersonality.systemPrompt,
                history: history,
                userMessage: userMessage,
                externalIntel: intel
            )
        } else {
            responseText = offlineResponse(for: userMessage, intel: intel)
        }

        phase = .idle

        return ChatMessage(
            role: .ava,
            content: responseText,
            toolsUsed: intel.map(\.tool.rawValue)
        )
    }

    private func gatherIntel(
        inParallel activeTools: [any ExternalTool],
        message: String,
        context: ToolSelection
    ) async -> [ExternalIntel] {
        await withTaskGroup(of: ExternalIntel?.self) { group in
            for tool in activeTools {
                group.addTask {
                    try? await tool.gather(message: message, context: context)
                }
            }

            var results: [ExternalIntel] = []
            for await result in group {
                if let intel = result {
                    results.append(intel)
                }
            }
            return results
        }
    }

    /// Fallback when no API key — still uses external modules, never mirrors.
    private func offlineResponse(for message: String, intel: [ExternalIntel]) -> String {
        guard let first = intel.first else {
            return """
            I'm running without a Gemini API key, but here's the move: don't wait for permission.

            Whatever you're sitting with — the interesting version starts when you ask \
            "what would I do if I already knew the answer?" and then do the opposite for 10 minutes.

            Add GEMINI_API_KEY to Info.plist to unlock my full brain.
            """
        }

        let hook: String
        switch first.tool {
        case .weather:
            hook = "Weather's data, not destiny. \(first.summary) — but the real question is what you're avoiding by talking about the sky."
        case .news:
            hook = "The headlines are noise until you pick a signal. \(first.summary.prefix(200))... What actually matters to *you* in that flood?"
        case .wikipedia:
            hook = "History's already written the footnote you're living. \(first.summary.prefix(250))..."
        case .quoteWisdom, .creativeSpark:
            hook = first.summary
        default:
            hook = "Here's what the outside world says: \(first.summary.prefix(300))"
        }

        return hook + "\n\n(Add GEMINI_API_KEY to Info.plist for Ava's full synthesis engine.)"
    }
}
