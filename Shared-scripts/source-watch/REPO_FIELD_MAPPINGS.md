# Repo Field Mappings

These notes capture the current field overlap used to define the shared `SourceWatchItem` contract.

## Blogger-MCP

Anchors:

- `D:\Github\Blogger-MCP\server\src\services\source-monitor.ts`
- `D:\Github\Blogger-MCP\server\src\services\source-discovery.ts`

Observed fields:

- `OfficialSource.id` -> `source_id`
- `OfficialSource.name` -> `source_label`
- `OfficialSource.base_url` -> `source_url`
- `SourceEndpoint.id` -> `endpoint_id`
- `DiscoveredContent.id` -> `item_id`
- `DiscoveredContent.url` -> `canonical_url`
- `DiscoveredContent.title` -> `title`
- `DiscoveredContent.content` -> `content_text`
- `DiscoveredContent.summary` -> `summary`
- `DiscoveredContent.publishedAt` -> `published_at`
- `DiscoveredContent.discoveredAt` -> `detected_at`
- `DiscoveredContent.contentHash` -> `content_hash`
- `DiscoveredContent.metadata` -> `metadata`

Notes:

- Blogger already has the closest shape to the shared contract.
- Website and RSS discovery both appear inside the source-monitor/source-discovery service layer.

## Telegram-MCP

Anchors:

- `D:\Github\Telegram-MCP\lib\website-monitor.js`
- `D:\Github\Telegram-MCP\lib\source-registry.js`

Observed fields and behaviors:

- monitored URL -> `source_url` and sometimes `canonical_url`
- `buildAnnouncementFingerprint(...)` -> strong input for `dedupe_key`
- normalized announcement text -> input for `content_hash`
- channel usernames, niche, signatures -> `metadata`

Notes:

- Telegram's source monitoring is more publish-routing-oriented than Blogger's.
- Channel routing and publishing signatures should stay in Telegram-specific metadata or downstream logic, not in the shared contract.

## Opportunity Gap finder

Anchors:

- `D:\Github\Opportunity Gap finder\src\gapfinder\models.py`
- `D:\Github\Opportunity Gap finder\src\gapfinder\ingestion\scraper\platforms.py`

Observed fields:

- `RawPost.post_id` -> `provider_item_id`
- `RawPost.title` -> `title`
- `RawPost.body` -> `content_text`
- `RawPost.url` -> `canonical_url`
- `RawPost.author` -> `author`
- `RawPost.subreddit` -> `community_label`
- `RawPost.timestamp` or `created_utc` -> `published_at`
- `RawPost.scraped_at` -> `detected_at`
- `RawPost.source_platform` -> `source_platform`
- `RawPost.source_query` -> `source_query`

Notes:

- GapFinder already produces a normalized ingestion object, but it is focused on posts rather than general monitored source items.
- The shared contract preserves GapFinder's platform/query traceability without forcing all repos into social-style naming.