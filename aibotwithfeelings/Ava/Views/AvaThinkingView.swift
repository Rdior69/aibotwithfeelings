import SwiftUI

struct AvaThinkingView: View {
    let phase: AvaThinkingPhase

    var body: some View {
        if phase != .idle {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text(phase.displayText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
            .padding(.horizontal)
            .transition(.opacity)
        }
    }
}
