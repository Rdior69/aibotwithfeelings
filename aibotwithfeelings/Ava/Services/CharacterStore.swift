import Foundation

@MainActor
final class CharacterStore: ObservableObject {
    @Published private(set) var customCharacters: [AICharacter] = []
    @Published var activeCharacter: AICharacter = .ava

    private let storageKey = "saved_custom_characters"
    private let activeCharacterKey = "active_character_id"

    init() {
        load()
    }

    var canCreateMore: Bool {
        customCharacters.count < AICharacter.maxPremiumCharacters
    }

    var remainingSlots: Int {
        max(0, AICharacter.maxPremiumCharacters - customCharacters.count)
    }

    func select(_ character: AICharacter) {
        activeCharacter = character
        UserDefaults.standard.set(character.id.uuidString, forKey: activeCharacterKey)
    }

    func save(_ character: AICharacter) throws {
        guard character.isValid else {
            throw CharacterStoreError.invalidCharacter
        }
        guard !character.isBuiltIn else { return }

        if let index = customCharacters.firstIndex(where: { $0.id == character.id }) {
            customCharacters[index] = character
        } else {
            guard canCreateMore else {
                throw CharacterStoreError.limitReached
            }
            customCharacters.append(character)
        }

        persist()
        select(character)
    }

    func delete(_ character: AICharacter) {
        guard !character.isBuiltIn else { return }
        customCharacters.removeAll { $0.id == character.id }
        if activeCharacter.id == character.id {
            select(.ava)
        }
        persist()
    }

    func allCharacters(includeAva: Bool = true) -> [AICharacter] {
        if includeAva {
            return [.ava] + customCharacters
        }
        return customCharacters
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([AICharacter].self, from: data) {
            customCharacters = decoded
        }

        if let activeID = UserDefaults.standard.string(forKey: activeCharacterKey),
           let uuid = UUID(uuidString: activeID) {
            if uuid == AICharacter.ava.id {
                activeCharacter = .ava
            } else if let match = customCharacters.first(where: { $0.id == uuid }) {
                activeCharacter = match
            }
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(customCharacters) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

enum CharacterStoreError: LocalizedError {
    case invalidCharacter
    case limitReached
    case premiumRequired

    var errorDescription: String? {
        switch self {
        case .invalidCharacter:
            return "Give your character a name and appearance description first."
        case .limitReached:
            return "You've reached the 20 character limit. Delete one to create another."
        case .premiumRequired:
            return "Subscribe to create custom characters."
        }
    }
}
