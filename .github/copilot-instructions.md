# Office_Scripts â€” Watch Context

**Repo**: `Office_Scripts` | **Priority**: P2 | **Collection**: `office-scripts-context`
**Stack**: TypeScript + Microsoft Office Scripts | **Role**: Office automation scripts

## Session Start

1. Read `0.dev-matrix/AI-HANDOFF.md` (latest entry)
2. Read `0.dev-matrix/STATE.md`

## Qdrant Search

**Collection**: `office-scripts-context` | Use `/qdrant` prompt for full reference.

```powershell
# Semantic search (intent-based â€” better than grep for concepts)
cd D:\Github\Office_Scripts
python D:\Github\tools\qdrant_gap_audit.py -q "YOUR QUERY" --context-lines 3

# Index this repo (required before first search)
python D:\Github\tools\qdrant_gap_audit.py --auto-index

# Full 33-check gap audit (run before deploy)
python D:\Github\tools\qdrant_gap_audit.py
# â†’ writes 0.dev-matrix/QDRANT_GAP_REPORT.md

# Critical security checks only (C1 auth, C11/C12 RLS, C14 N+1, C21 secrets, C27 unguarded write)
python D:\Github\tools\qdrant_gap_audit.py --checks 1,11,12,14,21,27
```

> Use `/qdrant` in chat for the complete guide with score interpretation and check catalog.
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