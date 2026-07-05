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

## Next Steps

See [ROADMAP.md](ROADMAP.md) for milestones, backlog, and technical debt. Current priorities:

1. Complete repository governance (M0 — Issue #11).
2. Fix CI and add SPM core testing (M1 — PR #10, after M0).
3. Integrate live AI backend and conversation persistence (M2 — PR #9).
4. Expand test coverage and App Store readiness (M3–M5).
