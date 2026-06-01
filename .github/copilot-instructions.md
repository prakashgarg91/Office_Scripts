# Office_Scripts â€” Watch Context

**Repo**: `Office_Scripts` | **Priority**: P2 | **Collection**: `office-scripts-context`
**Stack**: TypeScript + Microsoft Office Scripts | **Role**: Office automation scripts

## Session Start

1. Read `0.dev-matrix/AI-HANDOFF.md` (latest entry)
2. Read `0.dev-matrix/STATE.md`

\
## Roo Code Index Bridge MCP
Use the global MCP server `roo-code-index-bridge` as the default semantic retrieval surface before falling back to grep or regex.
Do not register legacy `roo-index-bridge` alongside it.

Before planning or coding in this repo, read `0.dev-matrix/INDEX.md` and the newest `0.dev-matrix/AI-HANDOFF.md`.

- `roo-code-index-search`: primary semantic search - pass `workspace_path="D:/Github/Office_Scripts"`
- `roo-code-index-resolve-collection`: verify workspace mapping when results look suspicious
- `roo-code-index-health`: check index health on unfamiliar repos

Preferred retrieval stack for code work:

1. `roo-code-index-bridge_roo-code-index-search` for broad discovery
2. Graphify `graphify_query_graph`, `graphify_graph_stats`, `graphify_get_community`, `graphify_god_nodes`, or `graphify_shortest_path` for structural orientation
3. code-review-graph `code-review-graph_get_minimal_context_tool`, `code-review-graph_get_impact_radius_tool`, `code-review-graph_get_affected_flows_tool`, or `code-review-graph_query_graph_tool` (always pass `repo_root`)
4. grep or regex for exact confirmation

Use only the exact MCP tool names listed above, including the required prefixes and suffixes.

### Knowledge Ledger Gate
Before non-trivial edits:

1. use Graphify or `graphify-out/GRAPH_REPORT.md` to map the owning structure
2. use code-review-graph to assess blast radius and impacted flows
3. return a short `CONTEXT AUDIT` before implementation with:
    - `Slice:`
    - `Files:`
    - `Dependencies:`
    - `Test first:`
    - `Proof:`

### Test-First Gate
For behavior changes, bug fixes, or refactors that change behavior:

1. write or update the narrow automated test first
2. run it and confirm it fails for the expected reason
3. implement the minimum change required
4. rerun the same test until it passes
5. only then widen to the next narrow validation

For parallel isolated subtasks, use `agent-delegator` (`delegate_task` / `batch_tasks`) - not one-liners.

Validation:
```powershell
node D:\Github\tools\roo-index-smoke.mjs --workspace D:\Github\Office_Scripts
node D:\Github\tools\roo-index-sync-mcp.mjs --all --apply
```

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
