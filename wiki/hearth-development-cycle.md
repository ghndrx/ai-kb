---
title: "Hearth Development Cycle"
aliases: []
created: 2026-04-05
updated: 2026-04-05
source_files:
  - clawd/docs/DEVELOPMENT_CYCLE.md
tags:
  - hearth
  - development
  - workflow
  - git
status: stable
confidence: high
summary: "Greg assigns via Telegram, Data writes code directly, creates PR, CI runs, Greg merges. No AI crons, no GitHub Issues."
---

# Hearth Development Cycle

## Who Does What

| Who | Role |
|-----|------|
| **Greg** (Director) | Assigns work via Telegram, reviews PRs, makes decisions |
| **Data** | Primary coding agent — writes code, creates PRs, ships features |
| **CI/CD** | Automated testing, linting, security scanning |

**Rules**:
- No AI agents on schedules
- No GitHub Issues for task management
- No automated code generation pipelines
- Commits as Greg Hendrickson <greg@hndrx.co> only

## The Loop

```
Greg says "build X" (Telegram)
    → Data writes code directly (no sub-agents)
    → Feature branch → commit → push → PR
    → CI: build, test, lint, security
    → Greg reviews → merges
```

## Branch Strategy

- `develop` — main development, always shippable
- `master` — production-stable, protected
- `feature/<name>`, `fix/<name>`, `chore/<name>`

## Commit Rules

```
feat(scope): description
fix(auth): resolve token expiry
chore(tests): increase coverage
```

- No AI attribution ("Claude-assisted", etc.)
- Describe WHAT code does, not how it was built
- Blocked authors: Data, Hearth Bot, CI Bot, github-actions[bot]

## PR Rules

1. One logical change per PR
2. CI must pass
3. Greg reviews and merges
4. Branch deleted after merge
5. Never commit directly to `develop` or `master`

## What Data Won't Do

- Auto-generate code on schedules
- Create GitHub Issues
- Use sub-agents unless Greg asks
- Commit as bot identity

## See Also

- [[Hearth Architecture]]
- [[Matrix Federation Core]]
