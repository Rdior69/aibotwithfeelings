//
//  SettingsView.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var nameInput: String = ""
    @State private var showResetAlert = false

    var body: some View {
        @Bindable var s = settings

        NavigationStack {
            Form {
                // Companion
                Section {
                    HStack {
                        BotAvatarView(emotion: .happy, size: 52)

                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Companion name", text: $nameInput)
                                .font(.headline)
                                .onSubmit { applyName() }
                                .onChange(of: nameInput) { _, _ in applyName() }

                            Text("Your AI companion's name")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Companion")
                } footer: {
                    Text("This name appears in chat and reflects their identity.")
                }

                // Appearance
                Section("Appearance") {
                    Picker("Color Scheme", selection: $s.colorSchemePreference) {
                        ForEach(AppSettings.ColorSchemePreference.allCases, id: \.self) { scheme in
                            Text(scheme.displayName).tag(scheme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 2)

                    Toggle("Show Emotion Indicator", isOn: $s.showEmotionIndicator)
                }

                // Behavior
                Section("Behavior") {
                    Toggle("Haptic Feedback", isOn: $s.useHaptics)
                }

                // AI Engine
                Section {
                    Toggle(isOn: $s.useAppleIntelligence) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("Apple Intelligence", systemImage: "apple.intelligence")
                                .font(.body)
                            Text("On-device, private AI. Requires Apple Intelligence to be enabled.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !settings.useAppleIntelligence {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                            Text("Using demo mode with pre-written responses.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("AI Engine")
                }

                // About
                Section("About") {
                    LabeledContent("App", value: "AIBotWithFeelings")
                    LabeledContent("Version", value: "1.0")
                    LabeledContent("AI Framework", value: "Apple Foundation Models")

                    Button("Show Welcome Screen") {
                        showResetAlert = true
                    }
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear { nameInput = settings.botName }
            .alert("Show Welcome Screen?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    settings.hasCompletedOnboarding = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You'll see the welcome flow again on next launch.")
            }
        }
    }

    private func applyName() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            settings.botName = trimmed
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings())
}
