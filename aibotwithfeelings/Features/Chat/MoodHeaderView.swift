//
//  MoodHeaderView.swift
//  aibotwithfeelings
//
//  Shows the companion's name and current emotional state with an animated
//  mood ring.
//

#if canImport(SwiftUI)
import SwiftUI

struct MoodHeaderView: View {
    let botName: String
    let mood: MoodState

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.color(for: mood.dominant).opacity(0.25))
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: max(0.05, mood.intensity))
                    .stroke(
                        Theme.color(for: mood.dominant),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 52, height: 52)
                    .animation(.easeInOut(duration: 0.6), value: mood.intensity)
                Text(mood.dominant.emoji)
                    .font(.title2)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(botName)
                    .font(.headline)
                Text("Feeling \(mood.dominant.label.lowercased())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
#endif
