import Foundation
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isProcessing = false
    @Published var errorMessage: String?

    private let brain = AvaBrain()

    var thinkingPhase: AvaThinkingPhase {
        brain.phase
    }

    init() {
        messages.append(ChatMessage(
            role: .ava,
            content: """
            Hey — I'm Ava. I don't do the chatbot thing where I repeat your words back \
            with a question mark glued on.

            I pull live intel from the outside world and connect dots you didn't ask for. \
            What's actually on your mind?
            """
        ))
    }

    func send() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }

        inputText = ""
        errorMessage = nil
        isProcessing = true

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)

        do {
            let response = try await brain.respond(to: text, history: messages)
            messages.append(response)
        } catch {
            errorMessage = error.localizedDescription
            messages.append(ChatMessage(
                role: .ava,
                content: "Signal dropped: \(error.localizedDescription)"
            ))
        }

        isProcessing = false
    }
}
