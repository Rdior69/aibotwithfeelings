//
//  PersistenceController.swift
//  aibotwithfeelings
//
//  Foundation-only persistence. Stores the entire conversational state as a
//  single JSON snapshot on disk. Kept free of UI dependencies so it can be
//  exercised in headless unit tests.
//

import Foundation

/// A complete, codable snapshot of everything worth persisting.
public struct PersistedState: Codable, Equatable, Sendable {
    public var profile: UserProfile
    public var messages: [ChatMessage]
    public var mood: MoodState
    public var memory: MemoryStore

    public init(
        profile: UserProfile = .empty,
        messages: [ChatMessage] = [],
        mood: MoodState = .neutral,
        memory: MemoryStore = MemoryStore()
    ) {
        self.profile = profile
        self.messages = messages
        self.mood = mood
        self.memory = memory
    }

    public static var initial: PersistedState { PersistedState() }
}

/// Reads and writes `PersistedState` to a JSON file.
public final class PersistenceController: @unchecked Sendable {
    private let fileURL: URL
    private let fileManager: FileManager

    /// Create a controller writing to `fileURL`.
    public init(fileURL: URL, fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.fileManager = fileManager
    }

    /// Convenience initialiser that stores the snapshot in the app's Application
    /// Support directory (falls back to the temporary directory if unavailable).
    public convenience init(fileName: String = "aibotwithfeelings_state.json") {
        let fm = FileManager.default
        let base = (try? fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fm.temporaryDirectory
        self.init(fileURL: base.appendingPathComponent(fileName), fileManager: fm)
    }

    /// Load the saved state, or `nil` if nothing has been saved yet.
    public func load() -> PersistedState? {
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            // Default (.deferredToDate) round-trips Date exactly; ISO8601 would
            // drop sub-second precision and break state equality.
            return try decoder.decode(PersistedState.self, from: data)
        } catch {
            // Corrupt or incompatible snapshot — start fresh rather than crash.
            return nil
        }
    }

    /// Persist the state. Throws on encode / write failure.
    public func save(_ state: PersistedState) throws {
        let directory = fileURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(state)
        try data.write(to: fileURL, options: .atomic)
    }

    /// Delete the persisted snapshot (used by "clear all data").
    public func reset() {
        try? fileManager.removeItem(at: fileURL)
    }
}
