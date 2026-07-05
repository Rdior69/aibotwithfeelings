# AIBotWithFeelings Task Board

> **Deprecated:** This file is no longer the source of truth for project status.
> Use **[ROADMAP.md](ROADMAP.md)** for architecture, milestones, backlog, and technical debt.
> Use **[CONTRIBUTING.md](CONTRIBUTING.md)** for the development workflow.
>
> This file is retained temporarily for historical reference and will be removed in a future chore issue.

## Already Built
- Xcode app target + unit/UI test targets.
- SwiftUI app entrypoint and project wiring.

## Working
- App launches and renders root screen.
- Test targets are connected to the app target.

## Broken
- Product functionality was missing (no onboarding, chat flow, memory, settings).
- Tests were placeholders with no meaningful assertions.

## Missing
- User onboarding and profile preferences.
- Chat experience and emotional response behavior.
- Memory handling for key user context.
- Settings management and profile persistence.

## Needs Refactor
- None of the original code needed deep refactor; only the placeholder `ContentView` needed replacement with routed feature views.

## Next Build Priority
1. Integrate a real AI provider behind `AICompanionServing`.
2. Add safety policy interception before response generation.
3. Add persistent conversation history (beyond in-memory key moments).
4. Expand QA with model/service failure-path tests.

## Testing Required
- Unit tests for emotion transition and memory ordering.
- UI tests for onboarding to chat transition and settings presentation.
- Device-level validation on macOS with Xcode/iOS Simulator.

## Deployment Prep
- Add App Store icon set assets.
- Confirm signing/team settings for release pipeline.
- Add shared scheme + CI `xcodebuild test` execution.
