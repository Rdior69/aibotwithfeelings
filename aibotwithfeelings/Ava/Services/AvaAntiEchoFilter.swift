import Foundation

/// Removes common mirror-style openings so Ava stays additive instead of parroting.
struct AvaAntiEchoFilter: Sendable {
    func cleanedReply(_ reply: String, userMessage: String) -> String {
        let trimmedReply = reply.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUserMessage = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUserMessage.isEmpty else {
            return trimmedReply
        }

        if startsWithUserMessage(trimmedReply, userMessage: trimmedUserMessage),
           let remainder = removingFirstSentence(from: trimmedReply) {
            return remainder
        }

        let echoOpeners = [
            "you are saying",
            "you're saying",
            "you said",
            "i hear you",
            "i hear that",
            "what i'm hearing",
            "what i am hearing",
            "it sounds like",
            "sounds like"
        ]

        let normalizedReply = normalize(trimmedReply)
        if echoOpeners.contains(where: { normalizedReply.hasPrefix($0) }),
           let remainder = removingFirstSentence(from: trimmedReply) {
            return remainder
        }

        return trimmedReply
    }

    func startsWithUserMessage(_ reply: String, userMessage: String) -> Bool {
        let normalizedReply = normalize(reply)
        let normalizedUserMessage = normalize(userMessage)

        guard normalizedUserMessage.count > 12 else {
            return false
        }

        if normalizedReply.hasPrefix(normalizedUserMessage) {
            return true
        }

        let userWords = normalizedUserMessage.split(separator: " ")
        let replyWords = normalizedReply.split(separator: " ")
        let comparisonCount = min(userWords.count, replyWords.count, 12)

        guard comparisonCount >= 5 else {
            return false
        }

        let matchingWords = zip(userWords.prefix(comparisonCount), replyWords.prefix(comparisonCount))
            .filter { $0 == $1 }
            .count

        return Double(matchingWords) / Double(comparisonCount) >= 0.8
    }

    private func removingFirstSentence(from reply: String) -> String? {
        guard let sentenceEnd = reply.firstIndex(where: { ".!?".contains($0) }) else {
            return nil
        }

        let nextIndex = reply.index(after: sentenceEnd)
        let remainder = reply[nextIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
        return remainder.isEmpty ? nil : remainder
    }

    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
