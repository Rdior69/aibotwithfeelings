# AIBotWithFeelings

A SwiftUI companion app foundation that now includes:

- Onboarding for name, tone, memory, and check-in preferences.
- Chat flow with message bubbles, compose/send UI, and async bot replies.
- Emotional state tracking via a deterministic emotion engine.
- In-memory key moment storage and local profile persistence.
- Settings sheet for profile updates.

## Architecture

- `aibotwithfeelings/Models`: chat, emotion, profile, memory models.
- `aibotwithfeelings/Services`: AI service protocol + mock implementation, memory store, local profile store.
- `aibotwithfeelings/ViewModels`: app state router and chat state manager.
- `aibotwithfeelings/Views`: onboarding, chat, and settings screens.

## Development

### Xcode (macOS)

Open `aibotwithfeelings.xcodeproj` and run on a simulator or device. The shared `aibotwithfeelings` scheme is checked in for CLI and CI use:

```bash
xcodebuild test \
  -project aibotwithfeelings.xcodeproj \
  -scheme aibotwithfeelings \
  -destination 'platform=macOS'
```

### Swift Package Manager (Linux CI / headless core)

The root `Package.swift` exposes core logic as `AIBotCompanionCore` so models, services, and safety filters can be built and tested without Xcode:

```bash
swift build --target AIBotCompanionCore
swift test --filter AIBotCompanionCoreTests
```

See [AGENTS.md](AGENTS.md) for Cloud Agent and CI details.

## Next Steps

1. Swap `MockAICompanionService` for a production AI backend implementation.
2. Add safety policy checks for crisis and over-attachment boundaries.
3. Persist full conversation history and memory controls.
4. Expand UI/unit tests on macOS with Xcode.
