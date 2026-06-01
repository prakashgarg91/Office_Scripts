# Source Watch

Shared cross-repo capability for source monitoring and normalized item output.

## Scope

`Source Watch` is the canonical shared capability for:

- website monitoring
- RSS/feed polling
- source dedupe
- normalized source-item output for downstream repos

It is intentionally generic. Product-specific business logic stays in each product repo.

## Design Rules

- Product repos stay separate.
- Shared source plumbing lives here.
- Reuse existing internal or open-source solutions before building bespoke code.
- Promote this folder into a small service only when runtime/state needs outgrow a folder-level contract.

## Consumers

- `D:\Github\Blogger-MCP`
- `D:\Github\Telegram-MCP`
- `D:\Github\Opportunity Gap finder`

## Contract Files

- `SOURCE_WATCH_ITEM.schema.json` - canonical normalized item schema
- `CONTRACT.md` - field semantics, ID rules, and dedupe policy
- `REPO_FIELD_MAPPINGS.md` - current repo-to-contract mapping notes

## What Source Watch Owns

- source kind classification (`website`, `rss`, `api`, etc.)
- normalized URLs and timestamps
- content hash and dedupe key generation
- common metadata envelope

## What Source Watch Does Not Own

- Blogger publishing rules
- Telegram channel routing and signatures
- GapFinder opportunity analysis
- per-product storage, UI, and post-processing state