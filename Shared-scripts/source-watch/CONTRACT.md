# Source Watch Contract

## Purpose

Emit one normalized source item shape that multiple repos can consume independently.

The contract is designed from current code in:

- `D:\Github\Blogger-MCP\server\src\services\source-monitor.ts`
- `D:\Github\Blogger-MCP\server\src\services\source-discovery.ts`
- `D:\Github\Telegram-MCP\lib\website-monitor.js`
- `D:\Github\Telegram-MCP\lib\source-registry.js`
- `D:\Github\Opportunity Gap finder\src\gapfinder\models.py`

## Canonical Entity

`SourceWatchItem`

This is the shared output of website monitoring, RSS/feed polling, and related source discovery flows.

## Required Fields

- `item_id`: stable internal item identifier for Source Watch
- `source_id`: stable source identifier from the upstream source registry or source template
- `source_kind`: one of `website`, `rss`, `api`, `forum`, `manual_import`, `social`, `unknown`
- `source_label`: human-readable source name
- `source_url`: source or feed URL that produced the item
- `canonical_url`: absolute canonical item URL
- `title`: normalized item title
- `detected_at`: when this item was observed by Source Watch
- `content_hash`: hash of normalized content used for change detection
- `dedupe_key`: stable dedupe key used across repos
- `metadata`: open metadata object for source-specific details

## Optional Fields

- `endpoint_id`: source endpoint identifier when a source has multiple monitored paths
- `provider_item_id`: upstream provider/post identifier when available
- `source_platform`: upstream platform label such as `reddit`, `hackernews`, or `web_search`
- `source_query`: source query that surfaced the item
- `summary`: short normalized summary
- `content_text`: normalized body text
- `author`: author or publisher label
- `community_label`: subreddit, feed label, channel label, or community bucket
- `published_at`: original upstream publish timestamp when known
- `tags`: normalized tags or topic labels

## ID Rules

Generate fields in this order:

1. `provider_item_id` keeps the raw upstream ID if one exists.
2. `item_id` should be deterministic and stable across reruns.
3. Prefer `source_id + provider_item_id` when the provider ID is stable.
4. Otherwise prefer a hash of `source_id + canonical_url`.
5. If no canonical URL exists, fall back to a hash of `source_id + title + published_at`.

## Dedupe Rules

Generate `dedupe_key` in this order:

1. normalized canonical URL when stable
2. `source_id + provider_item_id`
3. `source_id + content_hash`
4. `source_id + normalized title + published day`

`content_hash` should be based on normalized text, not raw HTML, so minor markup drift does not create false positives.

## Normalization Rules

- All URLs must be absolute.
- Titles and summaries must be whitespace-normalized.
- `content_text` should be plain text, not raw HTML.
- `published_at` and `detected_at` use ISO 8601 UTC timestamps.
- `metadata` is the place for source-specific fields that should not pollute the core contract.

## Consumer Rules

- Consumers may extend `metadata`, but must not rename or reinterpret core fields.
- Consumer-specific workflow state must remain in the product repo.
- If Source Watch is unavailable, product repos should degrade gracefully rather than failing to boot.