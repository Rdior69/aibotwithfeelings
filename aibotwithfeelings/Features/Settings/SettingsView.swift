//
//  SettingsView.swift
//  aibotwithfeelings
//
//  Profile, personality selection, privacy controls, safety information and
//  about section.
//

#if canImport(SwiftUI)
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    @State private var displayName = ""
    @State private var botName = ""
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                profileSection
                personalitySection
                privacySection
                safetySection
                aboutSection
            }
            .navigationTitle("Settings")
            .onAppear {
                displayName = appState.profile.displayName
                botName = appState.profile.botName
            }
        }
    }

    private var profileSection: some View {
        Section("Profile") {
            TextField("Your name", text: $displayName)
            TextField("Companion name", text: $botName)
            Button("Save") {
                appState.updateNames(displayName: displayName, botName: botName)
            }
            .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    private var personalitySection: some View {
        Section("Personality") {
            ForEach(Personality.presets) { preset in
                Button {
                    appState.updatePersonality(preset.id)
                } label: {
                    HStack {
                        Text(preset.emoji)
                        VStack(alignment: .leading) {
                            Text(preset.displayName).foregroundStyle(.primary)
                            Text(preset.tagline)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if preset.id == appState.profile.personalityID {
                            Image(systemName: "checkmark").foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
    }

    private var privacySection: some View {
        Section {
            NavigationLink {
                MemoriesView()
            } label: {
                Label("Review what I remember", systemImage: "brain.head.profile")
            }
            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Label("Delete all data", systemImage: "trash")
            }
        } header: {
            Text("Privacy")
        } footer: {
            Text("Everything you share is stored only on this device. Nothing leaves your phone.")
        }
        .confirmationDialog(
            "Delete everything?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete all data", role: .destructive) {
                appState.resetAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This erases your profile, our entire conversation and all memories, then restarts onboarding.")
        }
    }

    private var safetySection: some View {
        Section {
            Text("I care about you, but I'm an AI companion — not a substitute for professional help. If you're ever in crisis, please reach out to a trained human.")
                .font(.callout)
            Link("Find a helpline near you",
                 destination: URL(string: "https://findahelpline.com")!)
        } header: {
            Text("Safety")
        }
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("App", value: "AI Bot With Feelings")
            LabeledContent("Version", value: appVersion)
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return v
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
#endif
