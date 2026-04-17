# Office_Scripts â€” Watch Context

**Repo**: `Office_Scripts` | **Priority**: P2 | **Collection**: `office-scripts-context`
**Stack**: TypeScript + Microsoft Office Scripts | **Role**: Office automation scripts

## Session Start

1. Read `0.dev-matrix/AI-HANDOFF.md` (latest entry)
2. Read `0.dev-matrix/STATE.md`

\
## Roo Bridge MCP
Use the workspace MCP server `roo-index-bridge` as the default semantic retrieval surface before falling back to grep or regex.

- `search_roo_index`: primary code-first semantic search for this repo and sibling repos under `D:\Github`
- `detect_roo_index_collection`: verify workspace mapping when results look suspicious or the repo is newly onboarded
- `list_roo_index_collections`: backend sanity check only

Preferred retrieval stack for code work:

1. Roo bridge targeted search
2. Graphify structure map
3. code-review-graph exact blast radius
4. grep or regex for exact confirmation and registry cleanup

Validation:
```powershell
node D:\Github\tools\roo-index-smoke.mjs --workspace D:\Github\Office_Scripts
node D:\Github\tools\roo-index-sync-mcp.mjs --all --apply
```

> Docs-mode can still rely partly on the shared local markdown fallback when vector recall misses the best chunk, so confirm hits against real files before editing.

## Close-Day
```powershell
npm run close-day
```

## code-review-graph (AST Graph - active MCP server)

Graph is pre-built at .code-review-graph/graph.db. Query it BEFORE reading files.

| Step | Tool / Command |
|------|----------------|
| 1. Get context | `get_minimal_context(task="<description>")` - start every task here |
| 2. Look up symbol | `query_graph` with specific target |
| 3. Blast radius | `get_call_graph` before changing any function/class |
| 4. Review PR | `review_changes` - full diff with impact context |
| 5. Risk check | `detect_changes` - scored risk before merging |

**Daily CLI** (auto-runs at session start):
```powershell
code-review-graph update          # incremental refresh (<2s)
code-review-graph watch           # live auto-update in background
code-review-graph detect-changes  # risk analysis before PR
```
