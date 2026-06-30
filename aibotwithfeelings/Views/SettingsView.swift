//
//  SettingsView.swift
//  aibotwithfeelings
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appViewModel: AppViewModel

    @State private var name: String = ""
    @State private var tone: CompanionTone = .supportive
    @State private var memoryEnabled = true
    @State private var checkInEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Companion profile") {
                    TextField("Name", text: $name)
                    Picker("Tone", selection: $tone) {
                        ForEach(CompanionTone.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    Toggle("Remember key moments", isOn: $memoryEnabled)
                    Toggle("Daily check-ins", isOn: $checkInEnabled)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        appViewModel.updateProfile(
                            UserProfile(
                                preferredName: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                preferredTone: tone,
                                checkInEnabled: checkInEnabled,
                                memoryEnabled: memoryEnabled
                            )
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                let profile = appViewModel.profile ?? .empty
                name = profile.preferredName
                tone = profile.preferredTone
                memoryEnabled = profile.memoryEnabled
                checkInEnabled = profile.checkInEnabled
            }
        }
    }
}

#Preview {
    SettingsView(appViewModel: AppViewModel())
}
