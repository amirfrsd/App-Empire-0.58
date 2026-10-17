# App Empire — Capability Map

This map translates the reference package at `/Users/amirfarsaad/Desktop/app-empire-2.0` into independently testable modules for the new iPhone project.

| Module id | Responsibility | Depends on |
|---|---|---|
| `economy-engine` | Deterministic app income, tap-to-earn, idle income, offline catch-up, upgrades, progression, and currency rules | — |
| `local-persistence` | Versioned local saves, action journal, migrations, crash recovery, and offline-first state | `economy-engine` |
| `portfolio-experience` | Home, Products, app lifecycle, app details, contextual Founder Mode, and global Tap to Earn | `economy-engine`, `local-persistence` |
| `market-experience` | Market discovery, app opportunities, and future expansion points | `portfolio-experience` |
| `season-experience` | Season status, score presentation, leaderboard, rewards, and competition UI | `portfolio-experience`, `account-sync` |
| `account-sync` | Anonymous/account identity, cloud save, conflict handling, config delivery, and session security | `local-persistence` |
| `commerce` | StoreKit products, purchase verification, grant ledger, refunds, and revocations | `account-sync`, `economy-engine` |
| `competition-integrity` | Server-authoritative checkpoints, score rules, anti-cheat validation, tie-breaking, and settlement | `account-sync`, `economy-engine`, `season-experience` |
| `backend-platform` | API, PostgreSQL persistence, audit events, rate limits, telemetry, and operational boundaries | `account-sync`, `commerce`, `competition-integrity` |
| `design-system` | Green/lime palette, glassmorphism surfaces, typography, motion, accessibility, and portrait iPhone layout | — |

Build order: `design-system` + `economy-engine` → `local-persistence` → `portfolio-experience` → `account-sync` → `commerce` → `season-experience` → `competition-integrity` → `market-experience` → `backend-platform` hardening.

Every v1 module must have a working minimal implementation. Content breadth may start small, but no major system is deferred out of the first release.
