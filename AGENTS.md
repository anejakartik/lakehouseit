# AGENTS.md — instructions for AI coding agents

## Before you touch code

1. Read [PRODUCT.md](./PRODUCT.md) — who this is for, what we're building
2. Read the top of [ROADMAP.md](./ROADMAP.md)
3. Check open issues + PRs

## Conventions

- **dbt models:** lowercase snake_case; bronze prefix `bronze__`, silver `silver__`, gold `gold__`
- **docker-compose:** explicit service names, named volumes, healthchecks where useful
- **Shell scripts:** POSIX `sh` when possible, `set -euo pipefail`
- Keep services in `docker-compose.yml` to the official upstream images where possible — avoid custom Dockerfiles unless needed

## Repo-specific guardrails

- **`docker compose up` must succeed on a clean machine in < 5 min.** Anything that breaks this is a regression.
- **No paid SaaS dependencies.** Everything in `docker-compose.yml` must run free locally.
- **Real seed data** — synthetic SaaS schema, not toy `users(name VARCHAR)`. Sample size ~100K rows minimum.
- **One model per dbt file**, descriptive naming. No "stg_thing" — be explicit about what's being staged.

## Commits & PRs

- Imperative-mood, *why*-focused commit messages
- PR: problem + change + how-to-verify
- Squash on merge

## Deployment

- CI: `.github/workflows/ci.yml` (currently tolerant; tightens after first working compose)
- "Deployment" = GitHub Codespace launch template + DuckDB-WASM playground on Vercel
- Free tier only

## Companion doc

[.github/copilot-instructions.md](./.github/copilot-instructions.md)
