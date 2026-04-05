---
title: "Hearth Architecture"
aliases: []
created: 2026-04-05
updated: 2026-04-05
source_files:
  - hearth/SPEC.md
  - hearth/TASK_QUEUE.md
  - hearth/README.md
tags:
  - hearth
  - architecture
  - backend
  - frontend
  - mobile
status: stable
confidence: high
summary: "Hearth is a self-hosted Discord alternative with Go backend, SvelteKit frontend, PostgreSQL/Redis, and Matrix Federation as P0."
---

# Hearth Architecture

## Overview

**Goal**: Self-hosted Discord alternative that federates via Matrix protocol. Users run their own Hearth instances.

**In-server live chat uses WebSocket infrastructure, NOT Matrix.** Matrix is only for cross-server communication.

**Repo**: https://github.com/ghndrx/hearth

## Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | Go, PostgreSQL, Redis, WebSocket gateway, LiveKit |
| Frontend | SvelteKit, TypeScript, Bun |
| Mobile iOS | Swift |
| Mobile Android | Kotlin |

## Directory Structure

```
hearth/
├── backend/internal/
│   ├── api/handlers/     # HTTP handlers per feature
│   ├── websocket/        # Gateway, voice, video signaling
│   ├── services/         # Business logic
│   ├── models/          # Data models
│   ├── database/postgres/
│   └── migrations/      # SQL migrations
├── frontend/src/
│   ├── lib/components/   # Svelte UI components
│   ├── lib/stores/      # App state (auth, messages, channels)
│   ├── lib/voice/       # VoiceConnectionManager, LiveKitManager
│   └── routes/          # SvelteKit pages
└── mobile/{ios,android}
```

## Core Systems

### 1. Matrix Federation (P0 — NOT STARTED)
Cross-server communication via Matrix protocol. See [[Matrix Federation Core]].

### 2. Messaging (Shipped)
- Real-time WebSocket
- Reactions, threads, editing
- Rich embeds, link previews
- E2EE (future: Signal Protocol + MLS)

### 3. Voice & Video (Shipped)
- LiveKit SFU for group calls
- VoiceConnectionManager, LiveKitManager
- Screen sharing, video calls

### 4. Server Management (Shipped)
- RBAC roles and permissions
- Channels, categories, threads
- Moderation, invites, bans

## CI/CD

| Workflow | Trigger | Purpose |
|---------|---------|---------|
| CI | push, PR | Go build/vet/test, Bun check/lint |
| CodeQL | push, PR | Static security analysis |
| DevSecOps | push, PR | Semgrep, SAST, license audit |
| Deploy | manual | Deploy to production |

**No AI code-generation workflows.**

## Test Coverage (Mar 2026)

| Package | Coverage |
|---------|----------|
| postgres | 89% |
| ai | 95% |
| handlers | 85% |
| services | 86% |
| websocket | 91% |
| cache | 91% |
| config | 94% |
| events | 97% |
| metrics | 99% |
| api | 100% |

## See Also

- [[Matrix Federation Core]]
- [[Hearth Development Cycle]]
- [[WebRTC SFU — Voice & Video]]
