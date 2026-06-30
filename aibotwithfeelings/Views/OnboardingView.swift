//
//  OnboardingView.swift
//  aibotwithfeelings
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appViewModel: AppViewModel

    @State private var name: String = ""
    @State private var tone: CompanionTone = .supportive
    @State private var memoryEnabled = true
    @State private var checkInEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Welcome") {
                    Text("Build your AI companion so it matches how you like to talk.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Section("Your profile") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier("onboarding.nameField")

                    Picker("Companion tone", selection: $tone) {
                        ForEach(CompanionTone.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .accessibilityIdentifier("onboarding.tonePicker")

                    Toggle("Remember key moments", isOn: $memoryEnabled)
                        .accessibilityIdentifier("onboarding.memoryToggle")

                    Toggle("Daily check-ins", isOn: $checkInEnabled)
                        .accessibilityIdentifier("onboarding.checkInToggle")
                }

                Section {
                    Button("Start chatting") {
                        let profile = UserProfile(
                            preferredName: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            preferredTone: tone,
                            checkInEnabled: checkInEnabled,
                            memoryEnabled: memoryEnabled
                        )
                        appViewModel.completeOnboarding(profile: profile)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("onboarding.startButton")
                }
            }
            .navigationTitle("Get started")
        }
    }
}

#Preview {
    OnboardingView(appViewModel: AppViewModel())
}
