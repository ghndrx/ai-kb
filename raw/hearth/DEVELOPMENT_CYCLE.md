# Development Cycle — How We Build Hearth

> **Last updated**: 2026-04-05

## Who Does What

| Who | Role |
|-----|------|
| **Greg** (Director) | Assigns work via Telegram, reviews PRs, makes architectural decisions |
| **Data** (me) | Primary coding agent — writes code, creates PRs, runs CI, manages branches, ship features |
| **CI/CD** | Automated testing, linting, security scanning on every PR and push |

**No AI agents run on schedules. No GitHub Issues for task management. No automated code generation pipelines.**

## The Development Loop

```
Greg says "build X" (Telegram)
    │
    ▼
Data reads the codebase, plans approach
    │
    ▼
Data writes code (directly, no sub-agents unless Greg asks)
    │
    ▼
Data creates feature branch → commits → pushes → opens PR
    │
    ▼
CI runs: build, test, lint, security scan
    │
    ▼
Greg reviews PR → merges or requests changes
    │
    ▼
Repeat
```

## Branch Strategy

- **`develop`** — main development branch, always shippable
- **`master`** — production-stable, protected
- **Feature branches** — `feature/<name>`, `fix/<name>`, `chore/<name>`

Commits use Greg's identity only:
```
git config user.name "Greg Hendrickson"
git config user.email "greg@hndrx.co"
```

## Pull Request Rules

1. One logical change per PR
2. CI must pass (all jobs green)
3. Greg reviews and merges
4. Branch deleted after merge
5. Never commit directly to `develop` or `master`

## CI Pipeline (GitHub Actions)

| Workflow | Trigger | Purpose |
|---------|---------|---------|
| `CI` | push to develop/master, PR | Go build/vet/test, Bun check/lint/build |
| `CodeQL Security Analysis` | push to develop/master, PR | Static security analysis |
| `DevSecOps` | push to develop/master, PR | Semgrep, SAST, license audit |
| `Deploy to Production` | manual `workflow_dispatch` | Deploys to server |
| `Keep PRs Updated` | push to develop | Auto-rebase open PRs |
| `E2E Message Flow Test` | PR | End-to-end messaging test |
| `Accessibility Checks` | PR | a11y audit |
| `Chat History Visibility Test` | PR | Chat history access control |

**No AI code-generation workflows exist.**

## How I Work (Data, the Agent)

### On every session start
1. Check `HEARTBEAT.md` for monitoring items
2. Check `MEMORY.md` for persistent context
3. Check `~/clawd/memory/` for daily logs

### On coding tasks
- Write Go code directly (backend)
- Write TypeScript/Svelte directly (frontend)
- Write Swift/Kotlin directly (mobile)
- Prefer **direct writing over spawning sub-agents** — faster and more precise
- Run tests locally before committing

### On PR creation
- Branch from `develop`
- Commit with Greg's identity
- Use clear commit messages: `feat(name): description`, `fix(name): description`
- No AI attribution in commit messages (no "Claude-assisted", "Kimi", etc.)
- Push, open PR, notify Greg

### On review requests
- Run `go test ./...`, `go vet ./...`, `golangci-lint run`
- Run `bun run check`, `bun run lint`, `bun run build`
- Fix any failures before notifying Greg

## Task Prioritization

**P0 = Matrix Federation** — everything else is secondary until federation ships.

See `TASK_QUEUE.md` in the hearth repo for full queue.

## Where Things Live

| What | Where |
|------|-------|
| Hearth backend | `/home/administrator/hearth/backend/` |
| Hearth frontend | `/home/administrator/hearth/frontend/` |
| Hearth mobile iOS | `/home/administrator/hearth/mobile/ios/` |
| Hearth mobile Android | `/home/administrator/hearth/mobile/android/` |
| PRDs | `/home/administrator/hearth/PRDs/` |
| Secrets (SOPS) | `~/clawd/secrets/` |
| Deploy scripts | `~/clawd/scripts/` |
| Skills | `~/clawd/skills/` |

## GitHub Secrets I Use

| Secret | Used For |
|--------|---------|
| `GITHUB_TOKEN` | All GH API operations (built in) |
| `AWS_ROLE_ARN` | Bedrock access (for Kimi K2.5 — currently unused since we removed AI crons) |

## What I Won't Do

- Auto-generate code on schedules
- Create GitHub Issues for task tracking
- Use sub-agents unless Greg explicitly asks
- Commit as a bot identity
- Leave the workspace cluttered with generated reports
