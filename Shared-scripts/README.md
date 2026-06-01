# Shared Scripts

Canonical shared capability home for cross-repo reusable building blocks in `D:\Github`.

## Purpose

Keep product repos separate while reusing generic capabilities.

Put shared plumbing here:

- website monitoring
- RSS/feed ingestion
- dedupe helpers
- normalized source-item contracts
- provider fallbacks
- thin wrappers over official APIs and maintained open-source tools

Keep product-specific business logic out of this folder.

## First Canonical Capability

`source-watch/`

Scope:

- website monitoring
- RSS/feed polling
- dedupe
- normalized items for downstream repos

Target consumers:

- Blogger-MCP
- Telegram-MCP
- Opportunity Gap finder
- future monitoring, research, and alerting repos

## Build Rule

Before adding new shared plumbing here, check for an existing solution in this order:

1. current repo
2. this folder
3. other owned repos in `D:\Github`
4. official vendor SDKs and maintained open-source projects online

Reuse or wrap an existing solution when it is good enough. Build bespoke code only for missing domain logic or contract glue.

## Current Contents

- `source-watch/`
- `github-copilot-bridge/`
- `openrouter-free-model-fallbacks.ts`
- `Skills/`