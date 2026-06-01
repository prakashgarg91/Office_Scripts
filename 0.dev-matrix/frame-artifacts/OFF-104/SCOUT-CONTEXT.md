# OFF-104 Scout: Captured Office Automation Evidence

Generated: 2026-05-31 18:23
Task: OFF-104 — Capture normalized Office automation evidence
Tool chain: Roo Index → Graphify → code-review-graph (per FRAME-PORTFOLIO-RULES.md)

---

## Step 1 — Roo Index (semantic search)

**Query:** `"Office automation scripts Excel macro VBA PowerShell automation"`

| Rank | File | Score | Relevance |
|------|------|-------|-----------|
| 1 | `README.md` | 0.759 | Repo identity: "Script VBA, Power Query, Automate script excel etc" |
| 2 | `0.dev-matrix/LAUNCH_CHECKLIST.md` | 0.626 | Outcome: reusable automation pack for VBA/Power Query/Office Scripts |
| 3 | `0.dev-matrix/AI-TASKS.json` (OFF-101) | 0.606 | First shippable bundle: ExcelReportPipeline |
| 4 | `2-task.md` | 0.574 | Active tasks OFF-101, OFF-102; OFF-104 queued |
| 5 | `0.dev-matrix/NEXT-2-TASKS.md` | 0.570 | Same active+queued task layout |
| 6 | `0.dev-matrix/LAST-CLOSEOUT.md` | 0.487 | Handoff: next step was group scripts by type (VBA, Office Scripts, Power Query) |

**Key insight:** Roo Index confirms the repo is organized around an ExcelReportPipeline bundle as the first shippable automation asset. The semantic surface is thin — only README and governance files carry Office automation meaning. Actual `.bas` and `.m` source files are not vector-indexed.

---

## Step 2 — Graphify (knowledge graph)

**Graph stats:** 46 nodes, 52 edges, 13 communities, 96% extracted, 4% inferred.

**God nodes (top connected):**
- `buildOpenRouterPopularityFallbacks()` — 5 edges
- `Require-Python()` — 4 edges
- `log()` — 4 edges
- `Require-Graph()` — 3 edges
- `Invoke-GraphifyWiki()` / `Invoke-GraphifyHtml()` — 3 edges each
- `matchOpenRouterRankedModelId()` / `getMostPopularOpenRouterFreeModel()` — 3 edges each

**Full BFS traversal (depth 5) revealed 20 nodes — all in Shared-scripts/:**

| Community | File | Language | Purpose |
|-----------|------|----------|---------|
| 1 | `Shared-scripts/openrouter-free-model-fallbacks.ts` | TypeScript | OpenRouter model fallback logic |
| 3 | `Shared-scripts/github-copilot-bridge/vscode-copilot-bridge/extension.js` | JavaScript | VS Code Copilot bridge |
| 4 | `Shared-scripts/github-copilot-bridge/ask-github-model.mjs` | JavaScript | CLI bridge to GitHub Models |

**Critical gap:** The Graphify graph does not contain any nodes from `src/bundles/`. The VBA `.bas` and Power Query `.m` files are unparsed by the graph extractor (language support limited to TypeScript, JavaScript, and PowerShell in this graph).

---

## Step 3 — code-review-graph (blast radius & communities)

**Graph stats:** 12 files, 19 nodes, 60 edges (53 CALLS, 7 CONTAINS). Languages: powershell, typescript. 0 embeddings.

**Only community detected:**
- `shared-scripts-open` (id=5, cohesion=0.1167, size=7)
- Members: 7 TypeScript functions in `openrouter-free-model-fallbacks.ts`

**Semantic search** for `"excel report pipeline VBA Power Query automation"` returned **0 results**. The ExcelReportPipeline bundle is invisible to code-review-graph because the graph was built from `.ts`, `.js`, `.mjs`, and `.ps1` files only — `.bas` and `.m` extensions are not indexed.

**Blast radius assessment:**
- The ExcelReportPipeline bundle (`src/bundles/excel-report-pipeline/`) has **zero code dependencies** on `Shared-scripts/`
- The bundle is isolated to its own directory tree with no imports/calls across to the copilot bridge or OpenRouter code
- Any change to the bundle only affects: `vba/orchestrator.bas`, `power-query/load-and-transform.m`, `validate.ps1`, `sample/`, and `SPEC.json`

---

## Office Automation Evidence Inventory

### Bundle: ExcelReportPipeline v0.1.0

| Evidence | Location | Status |
|----------|----------|--------|
| VBA orchestrator | `src/bundles/excel-report-pipeline/vba/orchestrator.bas` (389 lines) | Present, validated |
| Power Query M script | `src/bundles/excel-report-pipeline/power-query/load-and-transform.m` (74 lines) | Present, validated |
| Sample data (CSV, 6 cols, 12 rows) | `src/bundles/excel-report-pipeline/sample/input/sample-data.csv` | Present, validated |
| Validation script | `src/bundles/excel-report-pipeline/validate.ps1` (245 lines) | Present, run |
| Validation result | `src/bundles/excel-report-pipeline/validation/result.txt` | PASS: 29/29, 2 warnings |
| Contract (SPEC.json) | `0.dev-matrix/SPEC.json` | Accepted, references bundle |
| README contract | `src/bundles/excel-report-pipeline/README.md` | Documents structure, usage, dependencies |
| Top-level README | `README.md` | Names ExcelReportPipeline as current delivery target |
| State tracking | `0.dev-matrix/STATE.md` | OFF-104 is sole active task |
| Task queue | `0.dev-matrix/AI-TASKS.json` | OFF-104: P1, prove phase, planned |

### Bundle pipeline stages (verified):

```
raw CSV/Excel input
    ↓ [VBA: PreFlightCheck → ImportSource]
Power Query transform (load-and-transform.m)
    ↓ [steps: SourcePathParam → RawData → PromotedHeaders → NoBlanks → Normalized → Output]
VBA post-processing (freeze panes, print area, named ranges)
    ↓ [PostProcess → SaveOutput → PostFlightCheck]
Formatted Excel report (.xlsx / .xlsm / .pdf)
    ↓ [DistributeOutput]
Local / Email (Outlook) / SharePoint (future)
```

### Validation surface: 29 checks across 6 categories

| Category | Checks | Pass |
|----------|--------|------|
| File existence | 3 | 3/3 |
| VBA orchestrator quality | 11 | 11/11 |
| Power Query M quality | 8 | 8/8 |
| Sample data integrity | 4 | 4/4 |
| SPEC.json contract alignment | 3 | 3/3 |
| Excel COM smoke test | skipped by flag | n/a |

---

## Gaps Identified

1. **VBA / Power Query code is invisible to both Graphify and code-review-graph.** Neither tool parses `.bas` or `.m` files. Semantic search surfaces only governance/README text. The actual automation logic has no structural graph representation.

2. **Only one Office bundle exists.** The repo name implies VBA, Power Query, and Office Scripts, but only VBA + Power Query are present. No Office Scripts (TypeScript-based Excel automation) exist yet.

3. **No automated test for the bundle without Excel COM.** The validation script requires Excel COM to run the full smoke test. `-SkipComTest` is needed in CI/headless environments, which skips 5 checks.

4. **SharePoint distribution is unimplemented** (stub in `DistributeOutput`).

---

## Summary

The repo has one validated Office automation bundle (`ExcelReportPipeline`) with full code, contract, sample data, and validation. The tool chain (Roo Index + Graphify + code-review-graph) confirms:
- Semantic intent: aligned (README, SPEC, task queue all agree)
- Structural map: limited to Shared-scripts; bundle code is invisible to graph tools
- Blast radius: isolated to bundle directory — zero cross-dependency on Shared-scripts

The gap is tooling coverage: the primary Office automation assets (VBA, Power Query M) are not parseable by the current knowledge graph infrastructure, so structural analysis relies on file-level inventory rather than call-graph or community detection.
