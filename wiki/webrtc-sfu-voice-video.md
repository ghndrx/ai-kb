---
title: "WebRTC SFU — Voice & Video"
aliases: []
created: 2026-04-05
updated: 2026-04-05
source_files:
  - original webrtc decision doc
tags:
  - hearth
  - webrtc
  - livekit
  - voice
  - video
status: stable
confidence: high
summary: "Hearth uses LiveKit SFU for voice/video — SFU scales to many participants with 1 upload per client."
---

# WebRTC SFU — Voice & Video

## Decision

**SFU (Selective Forwarding Unit)** chosen for group voice/video.

| Architecture | Client Uploads | Server CPU | Scalability |
|-------------|---------------|------------|-------------|
| P2P Mesh | N-1 | None | 4-6 users |
| MCU | 1 | Very High | Poor |
| **SFU** | **1** | **Low** | **Excellent** |

Server routes packets without transcoding. Discord, Google Meet, Zoom all use SFU.

## Implementation

- **Frontend**: `VoiceConnectionManager.ts`, `LiveKitManager.ts`, `VideoCallManager.ts`
- **Backend**: LiveKit media plane integration via WebSocket gateway
- **Media plane**: LiveKit SFU handles audio/video routing

## Voice Activity Detection

Enabled for efficient bandwidth usage — only active speakers transmit.

## See Also

- [[Hearth Architecture]]
