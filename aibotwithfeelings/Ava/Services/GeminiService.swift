import Foundation

enum GeminiError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your GEMINI_API_KEY to Info.plist to unlock Ava's full brain."
        case .invalidResponse:
            return "Ava got a garbled signal back. Try again."
        case .apiError(let message):
            return message
        }
    }
}

struct GeminiService: Sendable {
    func generate(
        systemPrompt: String,
        history: [ChatMessage],
        userMessage: String,
        externalIntel: [ExternalIntel]
    ) async throws -> String {
        guard AvaConfig.hasAPIKey else { throw GeminiError.missingAPIKey }

        var intelBlock = ""
        if !externalIntel.isEmpty {
            let lines = externalIntel.map { "[\($0.tool.rawValue)] \($0.summary)" }
            intelBlock = """

            EXTERNAL INTEL (live modules — use at least one concrete fact):
            \(lines.joined(separator: "\n"))
            """
        }

        let augmentedUserMessage = userMessage + intelBlock

        var contents: [[String: Any]] = []

        for msg in history.suffix(AvaConfig.maxHistoryMessages) where msg.role != .system {
            let role = msg.role == .user ? "user" : "model"
            contents.append([
                "role": role,
                "parts": [["text": msg.content]]
            ])
        }

        contents.append([
            "role": "user",
            "parts": [["text": augmentedUserMessage]]
        ])

        let body: [String: Any] = [
            "system_instruction": [
                "parts": [["text": systemPrompt]]
            ],
            "contents": contents,
            "generationConfig": [
                "temperature": 0.95,
                "topP": 0.92,
                "maxOutputTokens": 1024
            ],
            "safetySettings": [
                [
                    "category": "HARM_CATEGORY_HARASSMENT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                ],
                [
                    "category": "HARM_CATEGORY_HATE_SPEECH",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                ],
                [
                    "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                ],
                [
                    "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                ]
            ]
        ]

        let urlString = "\(AvaConfig.geminiEndpoint)/\(AvaConfig.geminiModel):generateContent?key=\(AvaConfig.geminiAPIKey)"
        guard let url = URL(string: urlString) else { throw GeminiError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw GeminiError.invalidResponse }

        if http.statusCode != 200 {
            if let errJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errJSON["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GeminiError.apiError(message)
            }
            throw GeminiError.apiError("HTTP \(http.statusCode)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw GeminiError.invalidResponse
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
