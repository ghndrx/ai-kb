---
title: "Matrix Federation Core"
aliases: []
created: 2026-04-05
updated: 2026-04-05
source_files:
  - hearth/PRDs/2026-04-05_matrix-federation-core.md
tags:
  - hearth
  - matrix
  - federation
  - p0
status: draft
confidence: high
summary: "P0 priority: cross-server DMs and room participation via Matrix protocol. 16-24 weeks. In-server chat unchanged."
---

# Matrix Federation Core

> **Status**: NOT STARTED — P0 Priority
> **Estimated**: 16-24 weeks
> **PRD**: `hearth/PRDs/2026-04-05_matrix-federation-core.md`

## Overview

**Matrix ONLY for cross-server communication.**
In-server live chat stays on Hearth WebSocket infrastructure.

Federation enables:
- DMs to users on other Hearth servers
- Joining rooms on remote Hearth servers
- Cross-server community participation

## Why Matrix

- No vendor lock-in (Synapse, Dendrite, Conduit all compatible)
- Proven at scale (governments, enterprises)
- Spec stable: Client-Server r0.6.1, Server-Server r6.0
- Room version 6

## Identity

- MXID: `@username:homeserver.example.com`
- Ed25519 server signing key at `/_matrix/key/v2`

## Implementation Phases

### Phase 1: Identity Layer (2-3 weeks)
- MXID computation, homeserver config
- `/_matrix/client/r0/account/whoami`, `/_matrix/client/r0/profile/{userId}`

### Phase 2: Client-Server Core (4-6 weeks)
- `/_matrix/client/r0/sync`, join/leave, message send/receive
- `/_matrix/client/r0/login` (password flow)

### Phase 3: Server-Server Federation (6-10 weeks)
- `/_matrix/federation/v1/send/{roomId}/{txnId}`
- Join flow, invite forwarding, backfill, state resolution v2
- Key distribution `/_matrix/key/v2`

### Phase 4: Room Directory (2-3 weeks)
- `/_matrix/federation/v1/query/directory`, public room list

### Phase 5: Cross-Server DMs (2-4 weeks)
- One-to-one DM rooms across servers, 3PID invite

## Out of Scope (v1)

- E2EE (Olm/Megolm) — DMs unencrypted for v1
- 3PID identity server
- Space rooms, room upgrades
- Federation with non-Hearth Matrix servers initially

## See Also

- [[Hearth Architecture]]
- [[Hearth Development Cycle]]
