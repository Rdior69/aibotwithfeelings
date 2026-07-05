# AIBotWithFeelings

A SwiftUI companion app with emotional awareness, safety boundaries, and on-device companion logic.

**Contributing:** see [CONTRIBUTING.md](CONTRIBUTING.md)  
**Roadmap & architecture:** see [ROADMAP.md](ROADMAP.md)

## Features (on `main`)

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
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -only-testing:aibotwithfeelingsTests
```

### Swift Package Manager (Linux CI / headless core)

The root `Package.swift` exposes core logic as `AIBotCompanionCore` so models, services, and safety filters can be built and tested without Xcode:

```bash
swift build --target AIBotCompanionCore
swift test --filter AIBotCompanionCoreTests
```

See [AGENTS.md](AGENTS.md) for Cloud Agent and CI details.

## Next Steps

See [ROADMAP.md](ROADMAP.md) for milestones, backlog, and technical debt. Current priorities:

1. ~~Complete repository governance (M0 — Issue #11).~~ Done
2. Establish SPM and CI foundation (M1 — Issue #20).
3. Integrate live AI backend and conversation persistence (M2 — PR #9).
4. Expand test coverage and App Store readiness (M3–M5).
