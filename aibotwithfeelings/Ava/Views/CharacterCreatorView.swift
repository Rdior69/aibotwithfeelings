import SwiftUI

struct CharacterCreatorView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State var character: AICharacter
    let isNew: Bool

    @State private var step = 0
    @State private var saveError: String?

    private let emojiOptions = ["🙂", "😎", "🦊", "🌙", "🔥", "💜", "🎭", "🌸", "⚡️", "🐉", "👻", "🎸"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(step + 1), total: 4)
                    .padding()

                TabView(selection: $step) {
                    appearanceStep.tag(0)
                    personalityStep.tag(1)
                    depthStep.tag(2)
                    previewStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: step)

                HStack {
                    if step > 0 {
                        Button("Back") { step -= 1 }
                    }
                    Spacer()
                    if step < 3 {
                        Button("Next") { step += 1 }
                            .buttonStyle(.borderedProminent)
                            .disabled(!canAdvance)
                    } else {
                        Button("Save Character") { save() }
                            .buttonStyle(.borderedProminent)
                            .disabled(!character.isValid)
                    }
                }
                .padding()
            }
            .navigationTitle(isNew ? "New Character" : "Edit Character")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Couldn't Save", isPresented: .init(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK") { saveError = nil }
            } message: {
                Text(saveError ?? "")
            }
        }
    }

    // MARK: - Steps

    private var appearanceStep: some View {
        Form {
            Section("Identity") {
                TextField("Name", text: $character.name)
                Picker("Avatar", selection: $character.avatarEmoji) {
                    ForEach(emojiOptions, id: \.self) { emoji in
                        Text(emoji).tag(emoji)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("How They Look") {
                TextField("Describe their appearance in detail", text: $character.appearanceDescription, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Age / presence (e.g. mid-20s, wise elder)", text: $character.agePresentation)
                TextField("Voice style (e.g. soft Southern drawl)", text: $character.voiceStyle)
            }
        }
    }

    private var personalityStep: some View {
        Form {
            Section("Personality Sliders") {
                sliderRow("Warmth", value: $character.warmth, low: "Reserved", high: "Warm")
                sliderRow("Humor", value: $character.humor, low: "Serious", high: "Playful")
                sliderRow("Directness", value: $character.directness, low: "Gentle", high: "Blunt")
                sliderRow("Empathy", value: $character.empathy, low: "Logical", high: "Deeply caring")
                sliderRow("Creativity", value: $character.creativity, low: "Practical", high: "Wild")
            }

            Section("Relationship") {
                TextField("Who are they to you? (best friend, mentor, partner...)", text: $character.relationshipToUser)
            }
        }
    }

    private var depthStep: some View {
        Form {
            Section("Backstory & Interests") {
                TextField("Backstory", text: $character.backstory, axis: .vertical)
                    .lineLimit(2...5)
                TextField("Interests & passions", text: $character.interests, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("How They Express Feelings") {
                TextField("Emotional style (e.g. wears heart on sleeve, quiet but deep)", text: $character.emotionalExpression, axis: .vertical)
                    .lineLimit(2...4)
                TextField("Speaking style", text: $character.speakingStyle, axis: .vertical)
                    .lineLimit(2...3)
            }

            Section("Custom Rules") {
                TextField("Anything they always or never do", text: $character.customRules, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("Greeting") {
                TextField("First message when chat opens", text: $character.greeting, axis: .vertical)
                    .lineLimit(2...5)
            }
        }
    }

    private var previewStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(character.avatarEmoji).font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text(character.name.isEmpty ? "Unnamed" : character.name)
                            .font(.title2.bold())
                        Text(character.relationshipToUser)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Group {
                    previewBlock("Appearance", character.appearanceDescription)
                    previewBlock("Backstory", character.backstory)
                    previewBlock("Feelings", character.emotionalExpression)
                    previewBlock("Greeting", character.greeting.isEmpty ? "Hey. I'm \(character.name). Good to meet you." : character.greeting)
                }
            }
            .padding()
        }
    }

    // MARK: - Helpers

    private var canAdvance: Bool {
        switch step {
        case 0: return !character.name.isEmpty && !character.appearanceDescription.isEmpty
        default: return true
        }
    }

    private func sliderRow(_ title: String, value: Binding<Double>, low: String, high: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(value.wrappedValue < 0.35 ? low : (value.wrappedValue > 0.65 ? high : "Balanced"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Slider(value: value, in: 0...1)
        }
    }

    private func previewBlock(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            Text(text.isEmpty ? "—" : text).font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    private func save() {
        if character.greeting.isEmpty {
            character.greeting = "Hey. I'm \(character.name). I've been waiting to talk to you."
        }
        do {
            try appState.characterStore.save(character)
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#Preview {
    CharacterCreatorView(character: .blank(), isNew: true)
        .environmentObject(AppState())
}
