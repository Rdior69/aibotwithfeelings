# AIBotWithFeelings — Technical Roadmap

Living document maintained by the project CTO after every merged feature.
Last updated: 2026-07-05 (M0 governance foundation in progress)

---

## Product Vision

**AIBotWithFeelings** is a production-quality, on-device-first AI companion with emotional awareness, safety boundaries, memory, and a path to live AI backends.

**Release target:** Pre-Alpha → Alpha → Beta → v1.0 (App Store)

---

## Current Architecture (canonical: `main`)

```
aibotwithfeelings/
├── Models/          CompanionModels, EmotionEngine (5-label engine)
├── Services/        AICompanionService (mock), SafetyFilter, memory, profile stores
├── ViewModels/      AppViewModel, ChatViewModel (@Observable)
├── Views/           Onboarding, Chat (mood hidden per PR #7), Settings
└── ContentView      Onboarding → Chat → Settings sheet
```

| Layer | Technology |
|-------|------------|
| UI | SwiftUI |
| Build | Xcode project (`aibotwithfeelings.xcodeproj`) |
| AI | `MockAICompanionService` (production backend in PR #9, not merged) |
| Memory | In-memory key moments + local profile persistence |
| Tests | XCTest / Swift Testing in Xcode targets |

**Not on `main`:** Ava/Gemini line, SwiftData, Apple Intelligence, SPM `Package.swift`, live HTTP AI, shared Xcode scheme, `AGENTS.md`.

---

## Release Stage

| Stage | Status | Exit criteria |
|-------|--------|---------------|
| **Pre-Alpha** | **Current** | Governance (M0), CI green, backend merged |
| Alpha | Planned | Live AI optional, persistence, CI green on all paths |
| Beta | Planned | Test coverage, privacy manifest, security review |
| v1.0 | Planned | App Store assets, performance audit, release checklist |

---

## Completed Features (on `main`)

- [x] Xcode app target + unit/UI test targets
- [x] Onboarding (name, tone, memory, check-in preferences)
- [x] Chat flow with message bubbles and async mock replies
- [x] Emotion engine (internal; mood UI hidden per PR #7)
- [x] In-memory key moments + local profile persistence
- [x] Safety filter (crisis / harassment boundaries)
- [x] Settings sheet for profile updates
- [x] Basic unit and UI tests

---

## Active GitHub Issues

| Issue | Title | Status |
|-------|-------|--------|
| #11 | chore: establish repository governance foundation | In progress (M0) |

> Prior work (PRs #1–#10) has no linked standalone issues. Retroactive issues are a post-M0 follow-up.

---

## Open Pull Requests

| PR | Branch | Purpose | CTO disposition |
|----|--------|---------|-----------------|
| #10 | `cursor/configure-repository-0744` | SPM + CI + scheme + AGENTS.md | Merge **after M0** |
| #9 | `cursor/backend-framework-0c56` | AI backend + persistence | Rebase after #10 |
| #8 | `cursor/add-package-swift-0029` | SPM (stale) | Close — superseded by #10 |
| #6 | `cursor/aibot-feelings-core-and-ui-1bbc` | Alternate Core architecture | Close — conflicts with main |
| #5 | `cursor/aibotfeelings-full-implementation-bea8` | Apple Intelligence rewrite | Close — conflicts with main |
| #4 | `cursor/aibot-add-on-86cd` | Ava integration | Close (Option A) or recreate scoped |

**Merge order (after M0):** #10 → rebase #9 → #9

---

## Milestones

| Milestone | Goal | Key deliverables |
|-----------|------|------------------|
| **M0: Governance** | Enforce Issue → PR workflow | ROADMAP, CONTRIBUTING, templates (this issue) |
| **M1: Infra + CI** | Green CI, SPM core | PR #10 + consolidated workflow |
| **M2: Backend** | Live AI + persistence | PR #9 |
| **M3: App polish** | Memories, test coverage | Salvage from archived PR #6 |
| **M4: Production prep** | App Store readiness | Icons, privacy manifest, security audit |
| **M5: v1.0** | Public release | Release checklist complete |

---

## Backlog (proposed — create as issues after M0)

| Priority | Proposed issue |
|----------|----------------|
| P0 | `chore: apply GitHub labels and milestones` |
| P0 | `chore: enable branch protection on main` |
| P0 | `chore: close superseded open pull requests` |
| P1 | `chore: cleanup stale remote branches` |
| P1 | `chore: SPM core library + dual CI pipeline` (PR #10) |
| P1 | `feature: AI backend framework + persistence` (PR #9) |
| P2 | `feature: port Memories tab from archived core-engine-v1` |
| P2 | `feature: Apple Intelligence integration` (from archived PR #5) |
| P3 | `docs: port AGENTS.md from Ava branch to main` |

---

## Technical Debt

| Item | Severity | Owner milestone |
|------|----------|-----------------|
| CI broken on `main` (`Package.swift` missing) | P0 | M1 |
| No branch protection | P0 | M0 follow-up |
| No standalone issues before M0 | P0 | M0 (this issue) |
| 12+ stale remote branches | P1 | M0 follow-up |
| `TASK_BOARD.md` stale | P1 | M0 (deprecated → ROADMAP) |
| No shared Xcode scheme on `main` | P1 | M1 |
| Mock-only AI | P2 | M2 |
| No conversation persistence on `main` | P2 | M2 |
| Competing archived architectures (PR #5, #6) | P2 | Backlog |
| Orphaned Ava product line | P3 | Product decision (Option A/B/C) |

---

## Security Concerns

- Crisis/harassment safety filter present on `main`
- Over-attachment policy exists only on PR #9 branch (not merged)
- No privacy manifest on `main` (exists on Ava add-on branch)
- API keys: PR #9 uses `COMPANION_AI_API_KEY` env var — document before enabling live AI
- Ava branch: Gemini model quota issues documented in PR #1

---

## Performance Improvements (backlog)

- Persist full conversation history (PR #9)
- SPM core for Linux headless testing (PR #10)
- Expand AI service failure-path tests
- Profile emotion engine under long conversations

---

## Repository Health

| Dimension | Score (2026-07-05 audit) | Target after M0+M1 |
|-----------|--------------------------|---------------------|
| Commit message quality | 68% | 75% |
| Branch organization | 28% | 60% |
| Issue tracking | 8% | 80% |
| PR hygiene | 42% | 70% |
| Naming consistency | 12% | 50% |
| **Overall** | **33%** | **65%** |

---

## Architectural Decisions

| Decision | Status | Notes |
|----------|--------|-------|
| Canonical app architecture = PR #2 (`main`) | **Active** | Models/Services/ViewModels/Views |
| Mood UI hidden from users | **Active** | PR #7 merged |
| Ava product line | **Deferred** | Awaiting Option A/B/C product decision |
| SPM core + dual CI | **Planned** | PR #10 after M0 |
| CODEOWNERS | **Deferred** | Follow-up with branch protection |

---

## How to Update This Document

After every merged feature, the CTO updates:

1. Completed features checklist
2. Active issues and open PRs tables
3. Technical debt (added / removed)
4. Repository health estimate
5. Backlog and milestone progress
6. `Last updated` date

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow.
