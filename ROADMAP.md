# AIBotWithFeelings — Technical Roadmap

Living document maintained by the project CTO after every merged feature.
Last updated: 2026-07-05 (M1 complete; repository hygiene for M2 prep)

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

Package.swift        AIBotCompanionCore (Models + Services; UI excluded)
Tests/               AIBotCompanionCoreTests (SPM / Linux headless)
```

| Layer | Technology |
|-------|------------|
| UI | SwiftUI |
| Build | Xcode project + root `Package.swift` (`AIBotCompanionCore`) |
| AI | `MockAICompanionService` (production backend planned — M2) |
| Memory | In-memory key moments + local profile persistence |
| Tests | XCTest in Xcode + Swift Testing via SPM on Linux |
| CI | Dual pipeline: Linux SPM + iOS Simulator `xcodebuild` |
| Docs | `AGENTS.md`, shared Xcode scheme |

**Not on `main`:** Ava/Gemini line, SwiftData, Apple Intelligence, live HTTP AI.

---

## Release Stage

| Stage | Status | Exit criteria |
|-------|--------|---------------|
| **Pre-Alpha** | **Current** | M0 + M1 complete; M2 backend (M2A–M2D) |
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
- [x] Repository governance foundation (M0 — PR #12): ROADMAP, CONTRIBUTING, issue/PR templates
- [x] SPM core library + dual CI pipeline (M1 — PR #21): `Package.swift`, Linux tests, shared scheme, `AGENTS.md`

---

## Active GitHub Issues

| Issue | Title | Status |
|-------|-------|--------|
| #13 | chore: enable branch protection on main | Open |
| #14 | chore: apply GitHub label taxonomy | Open |
| #15 | chore: create GitHub milestones M0-M5 | Open |
| #16 | chore: close superseded open pull requests | Open — #4–#8 pending manual close |
| #17 | chore: cleanup stale remote branches | Open — 12 branches deleted; verify complete |
| #22 | refactor: resolve MainActor isolation warning in InMemoryCompanionMemoryStore | Open (M2 backlog) |

**Recently completed:** #20 (M1 SPM + CI — PR #21), #11 (M0 governance — PR #12)

> Prior work (PRs #1–#8, #10) has no linked standalone issues. Retroactive issues remain a backlog item.

---

## Open Pull Requests

| PR | Branch | Purpose | Status |
|----|--------|---------|--------|
| #24 | `cursor/repository-hygiene-m2-prep-51b6` | ROADMAP hygiene + M2 phase plan | Open — merge pending approval |
| #9 | `cursor/backend-framework-0c56` | Full backend (reference) | Open — port via M2A–M2D; close in M2D |

**Pending manual close** (branches deleted; Issue #16): #4, #5, #6, #8  
**Closed:** #10 (superseded by PR #21)

---

## Milestones

| Milestone | Goal | Key deliverables |
|-----------|------|------------------|
| **M0: Governance** | Enforce Issue → PR workflow | ✅ ROADMAP, CONTRIBUTING, templates (PR #12) |
| **M1: Infra + CI** | Green CI, SPM core | ✅ PR #21 + PR #23 |
| **M2: Backend** | Live AI + persistence | M2A → M2B → M2C → M2D (see below) |
| **M3: App polish** | Memories, test coverage | Salvage from archived PR #6 (closed) |
| **M4: Production prep** | App Store readiness | Icons, privacy manifest, security audit |
| **M5: v1.0** | Public release | Release checklist complete |

### M2 sub-milestones (sequential PRs)

| Phase | Scope | Delivery |
|-------|-------|----------|
| **M2A** | AI backend foundation — `CompanionBackend`, provider abstraction, API configuration | PR + Issue |
| **M2B** | Conversation persistence, persistent memory, prompt builder | PR + Issue |
| **M2C** | ViewModel integration, Settings, UI wiring | PR + Issue |
| **M2D** | Tests, documentation, ROADMAP updates; close PR #9 as superseded | PR + Issue |

Each phase follows: Issue → Discovery → Planning → Approval → Branch → Commits → PR → Merge Readiness Report → explicit merge approval.

**Reference only:** PR #9 — port approved files; do not merge directly.

---

## Backlog

| Priority | Issue / work |
|----------|----------------|
| P0 | #14 — apply GitHub label taxonomy |
| P0 | #15 — create GitHub milestones M0-M5 |
| P0 | #13 — enable branch protection on main |
| P1 | #16 — close superseded PRs #4, #5, #6, #8 (manual) |
| P1 | Merge PR #24 — ROADMAP hygiene for Release Prep |
| P1 | M2A — AI backend foundation (after hygiene + Discovery approval) |
| P2 | #22 — MainActor isolation warning in InMemoryCompanionMemoryStore |
| P2 | `feature: port Memories tab from archived core-engine-v1` |
| P3 | Orphaned Ava product line — product decision (Option A active) |

---

## Technical Debt

| Item | Severity | Owner milestone |
|------|----------|-----------------|
| No branch protection | P0 | #13 |
| `TASK_BOARD.md` stale | P1 | Deprecated → ROADMAP (removal backlog) |
| MainActor warning in memory store (#22) | P2 | M2 backlog |
| Mock-only AI | P2 | M2A |
| No conversation persistence on `main` | P2 | M2B |
| Competing archived architectures | P2 | Closed (PRs #4–#6) |
| Orphaned Ava product line | P3 | Product decision (Option A) |

---

## Security Concerns

- Crisis/harassment safety filter present on `main`
- Over-attachment policy exists only on PR #9 branch (port in M2B/M2C)
- No privacy manifest on `main` (exists on archived Ava branch)
- API keys: `COMPANION_AI_API_KEY` env var — document in M2A/M2D before enabling live AI
- Ava branch: Gemini model quota issues documented in PR #1

---

## Performance Improvements (backlog)

- Persist full conversation history (M2B)
- Expand AI service failure-path tests (M2D)
- Profile emotion engine under long conversations

---

## Repository Health

| Dimension | Pre-M0 (audit) | Post-M0 | Post-M1 | Post-hygiene (2026-07-05) |
|-----------|----------------|---------|---------|---------------------------|
| Commit message quality | 68% | 68% | 72% | 72% |
| Branch organization | 28% | 35% | 40% | **55%** |
| Issue tracking | 8% | 45% | 55% | 55% |
| PR hygiene | 42% | 55% | 62% | **68%** |
| Naming consistency | 12% | 15% | 18% | 18% |
| **Overall** | **33%** | **45%** | **58%** | **62%** |

---

## Architectural Decisions

| Decision | Status | Notes |
|----------|--------|-------|
| Canonical app architecture = PR #2 (`main`) | **Active** | Models/Services/ViewModels/Views |
| Mood UI hidden from users | **Active** | PR #7 merged |
| Ava product line | **Deferred** | Option A — canonical `main` architecture |
| SPM core + dual CI | **Complete** | PR #21 merged 2026-07-05 |
| Repository governance (M0) | **Complete** | PR #12 merged 2026-07-05 |
| M2 delivery model | **Active** | Four sequential PRs (M2A–M2D); PR #9 as port reference |
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
