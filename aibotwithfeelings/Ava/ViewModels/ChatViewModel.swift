import Foundation
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isProcessing = false
    @Published var errorMessage: String?

    private let brain = AvaBrain()
    private var loadedCharacterID: UUID?

    var thinkingPhase: AvaThinkingPhase {
        brain.phase
    }

    func loadConversation(for character: AICharacter) {
        guard loadedCharacterID != character.id else { return }
        loadedCharacterID = character.id
        messages = [ChatMessage(role: .ava, content: character.greeting)]
    }

    func send(character: AICharacter, canChat: Bool) async {
        guard canChat else { return }

        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }

        inputText = ""
        errorMessage = nil
        isProcessing = true

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)

        do {
            let response = try await brain.respond(to: text, history: messages, character: character)
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
