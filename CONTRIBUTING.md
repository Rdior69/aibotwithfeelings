# Contributing to AIBotWithFeelings

Thank you for contributing. This project follows a strict workflow to protect architecture, traceability, and long-term maintainability.

Read the [Technical Roadmap](ROADMAP.md) for architecture, milestones, and backlog.

---

## Development Workflow

Every change follows this pipeline:

```
GitHub Issue
      ↓
Feature Branch
      ↓
Small Commits
      ↓
Pull Request
      ↓
Code Review
      ↓
Merge to main
      ↓
Delete Branch
```

**Never commit directly to `main`.** Direct pushes bypass review and break traceability.

---

## Step 1 — GitHub Issue (required)

Before writing code:

1. Search existing [issues](https://github.com/Rdior69/aibotwithfeelings/issues) and [pull requests](https://github.com/Rdior69/aibotwithfeelings/pulls) for duplicate work.
2. Open an issue using the appropriate template (feature, bug, chore, or docs).
3. Include clear **acceptance criteria**.
4. Wait for approval on large or architectural changes before starting.

### Issue title prefixes

| Prefix | Use for |
|--------|---------|
| `feature:` | New capability |
| `bugfix:` | Defect fix |
| `chore:` | Tooling, CI, repo hygiene |
| `docs:` | Documentation only |

---

## Step 2 — Feature Branch

| Rule | Value |
|------|-------|
| Branch from | Latest `main` |
| Naming | `<type>/<short-description>` |
| Examples | `feature/ai-backend`, `chore/spm-ci-setup`, `bugfix/chat-scroll-regression` |
| One issue | One branch |

```bash
git checkout main
git pull origin main
git checkout -b feature/your-feature-name
```

**Do not use** `cursor/*-<hash>` branch names for new work.

---

## Step 3 — Small Commits

- One logical change per commit.
- Use imperative, descriptive messages.

```
feat: add LocalConversationStore for chat persistence
test: add safety filter crisis detection tests
docs: update ROADMAP with M1 completion
chore: add Linux CI job for SPM core tests
```

**Avoid vague messages:** `update`, `fix`, `changes`, `WIP`, `testing`.

**Never mix unrelated changes** in a single commit or pull request.

Keep your branch synchronized with `main`:

```bash
git fetch origin
git rebase origin/main   # or merge, per team preference
```

---

## Step 4 — Pull Request

Open a PR against `main` when acceptance criteria are met.

### PR requirements

- Title matches the issue scope.
- Body includes **`Fixes #<issue-number>`** on the first line (auto-closes issue on merge).
- Single responsibility — one issue per PR.
- Test plan completed.
- CI expected to pass (or failure explained with fix plan).

Use the [pull request template](.github/pull_request_template.md).

### Review

- At least one approving review required before merge (once branch protection is enabled).
- Address review feedback with additional commits on the same branch.
- Do not merge your own PR without review unless explicitly authorized.

---

## Step 5 — Merge

- Prefer **squash merge** for feature branches (clean history).
- Ensure merge commit / PR title preserves `Fixes #N`.
- Confirm CI is green on `main` after merge.

---

## Step 6 — Delete Branch

- Delete the remote feature branch immediately after merge.
- Enable "Automatically delete head branches" in repository settings (recommended).

---

## Code Standards

- Follow **SOLID** principles and keep modules focused.
- Avoid duplicate logic — check for existing implementations first.
- Do not introduce competing architectures without CTO / maintainer approval.
- Flag technical debt in the PR or issue rather than silent workarounds.
- Document significant architectural decisions in `ROADMAP.md`.

---

## Labels (target taxonomy)

Existing GitHub default labels are being migrated to this taxonomy (apply via follow-up issue):

| Label | Purpose |
|-------|---------|
| `type:feature` | New capability |
| `type:bugfix` | Defect |
| `type:chore` | Tooling, CI, governance |
| `type:docs` | Documentation |
| `type:refactor` | No behavior change |
| `priority:p0` | Blocker |
| `priority:p1` | Next up |
| `priority:p2` | Backlog |
| `status:blocked` | Waiting on dependency |
| `status:ready-for-review` | PR ready |
| `area:ci` | CI / GitHub Actions |
| `area:backend` | Services / AI / persistence |
| `area:ui` | SwiftUI views |

Legacy mapping: `enhancement` → `type:feature`, `bug` → `type:bugfix`, `documentation` → `type:docs`.

---

## Milestones

| Milestone | Focus |
|-----------|-------|
| M0 | Repository governance |
| M1 | Infra + CI |
| M2 | Backend / live AI |
| M3 | App polish |
| M4 | Production prep |
| M5 | v1.0 release |

---

## Repository Settings (follow-up — not yet enabled)

The following require separate approved issues:

- Branch protection on `main`
- CODEOWNERS file
- GitHub label and milestone creation
- Stale branch and PR cleanup

See [ROADMAP.md](ROADMAP.md) backlog for tracking.

---

## Questions

Open a `question:` issue or discuss in the PR linked to your issue.
