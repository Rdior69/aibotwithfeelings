import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject var appState: AppState
    @State private var showCreator = false
    @State private var editingCharacter: AICharacter?

    var body: some View {
        List {
            Section("Ava — Included in Your Trial") {
                characterRow(.ava)
            }

            if appState.isPremium {
                Section {
                    ForEach(appState.characterStore.customCharacters) { character in
                        characterRow(character)
                    }
                    .onDelete(perform: deleteCharacters)
                } header: {
                    HStack {
                        Text("Your Custom Characters")
                        Spacer()
                        Text("\(appState.characterStore.customCharacters.count)/\(AICharacter.maxPremiumCharacters)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Section {
                    lockedPremiumRow
                } header: {
                    Text("Custom Characters — Premium")
                } footer: {
                    if appState.isInTrial, case .trial(let days) = appState.accessTier {
                        Text("Your free trial (\(days) day\(days == 1 ? "" : "s") left) includes full Ava access. Custom characters unlock automatically when your trial converts to \(SubscriptionConfig.monthlyPriceDisplay)/mo.")
                    } else {
                        Text("Start your \(SubscriptionConfig.trialDays)-day free trial to chat with Ava. Custom characters unlock with premium.")
                    }
                }
            }

            if appState.isPremium && appState.characterStore.canCreateMore {
                Section {
                    Button {
                        editingCharacter = AICharacter.blank()
                        showCreator = true
                    } label: {
                        Label("Create New Character", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        .navigationTitle("Characters")
        .sheet(isPresented: $showCreator) {
            if let character = editingCharacter {
                CharacterCreatorView(character: character, isNew: true)
                    .environmentObject(appState)
            }
        }
    }

    private var lockedPremiumRow: some View {
        Button {
            appState.showPaywall = true
        } label: {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create up to \(AICharacter.maxPremiumCharacters) characters")
                        .font(.subheadline.bold())
                    Text("Appearance, personality, feelings — exactly how you want.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func characterRow(_ character: AICharacter) -> some View {
        HStack(spacing: 14) {
            Button {
                appState.selectCharacter(character)
            } label: {
                HStack(spacing: 14) {
                    Text(character.avatarEmoji)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color(.secondarySystemBackground)))

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(character.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            if character.isBuiltIn {
                                Text("Trial")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.accentColor.opacity(0.2)))
                            }
                        }
                        Text(character.appearanceDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    if appState.characterStore.activeCharacter.id == character.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.tint)
                    }
                }
            }
            .buttonStyle(.plain)

            if !character.isBuiltIn && appState.isPremium {
                Button {
                    editingCharacter = character
                    showCreator = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private func deleteCharacters(at offsets: IndexSet) {
        for index in offsets {
            let character = appState.characterStore.customCharacters[index]
            appState.characterStore.delete(character)
        }
    }
}

#Preview {
    NavigationStack {
        CharacterListView()
            .environmentObject(AppState())
    }
}
