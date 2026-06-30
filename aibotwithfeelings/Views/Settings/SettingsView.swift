import SwiftUI

struct SettingsView: View {
    @Bindable var appModel: AppModel
    @State private var selectedBotName: String

    init(appModel: AppModel) {
        self.appModel = appModel
        _selectedBotName = State(initialValue: appModel.profile.preferredBot.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    LabeledContent("Name", value: appModel.profile.displayName.isEmpty ? "Guest" : appModel.profile.displayName)
                }

                Section("Companion") {
                    Picker("Personality", selection: $selectedBotName) {
                        ForEach(BotPersonality.presets, id: \.name) { bot in
                            Text(bot.name).tag(bot.name)
                        }
                    }
                    .onChange(of: selectedBotName) {
                        if let bot = BotPersonality.presets.first(where: { $0.name == selectedBotName }) {
                            appModel.updateBotPersonality(bot)
                        }
                    }

                    if let bot = BotPersonality.presets.first(where: { $0.name == selectedBotName }) {
                        Text(bot.toneDescription)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Privacy & Memory") {
                    Toggle("Save chat history", isOn: binding(\.saveChatHistory))
                    Toggle("Emotional memory", isOn: binding(\.memoryEnabled))
                    Toggle("Haptics", isOn: binding(\.hapticsEnabled))
                }

                Section("About") {
                    LabeledContent("App", value: AppTheme.botName)
                    LabeledContent("Version", value: "1.0.0")
                    Text("Responses are generated on-device for now. Cloud AI and account sync are planned next.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button("Replay onboarding", role: .destructive) {
                        appModel.resetOnboarding()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func binding(_ keyPath: WritableKeyPath<AppSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { appModel.settings[keyPath: keyPath] },
            set: { newValue in
                var settings = appModel.settings
                settings[keyPath: keyPath] = newValue
                appModel.updateSettings(settings)
            }
        )
    }
}

#Preview {
    SettingsView(appModel: AppModel())
}
