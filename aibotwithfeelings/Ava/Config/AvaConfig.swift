import Foundation

enum AvaConfig {
    /// Set your Gemini API key in Info.plist under `GEMINI_API_KEY`, or as an environment variable.
    static var geminiAPIKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
           !key.isEmpty, key != "YOUR_GEMINI_API_KEY_HERE" {
            return key
        }
        if let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"], !key.isEmpty {
            return key
        }
        return ""
    }

    static var hasAPIKey: Bool { !geminiAPIKey.isEmpty }

    static let geminiModel = "gemini-2.0-flash"
    static let geminiEndpoint = "https://generativelanguage.googleapis.com/v1beta/models"
    static let maxHistoryMessages = 24
}
