# Graph Report - .  (2026-05-31)

## Corpus Check
- 13 files · ~29,000 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 46 nodes · 52 edges · 13 communities detected
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]

## God Nodes (most connected - your core abstractions)
1. `buildOpenRouterPopularityFallbacks()` - 5 edges
2. `Require-Python()` - 4 edges
3. `log()` - 4 edges
4. `Require-Graph()` - 3 edges
5. `Invoke-GraphifyWiki()` - 3 edges
6. `Invoke-GraphifyHtml()` - 3 edges
7. `matchOpenRouterRankedModelId()` - 3 edges
8. `getMostPopularOpenRouterFreeModel()` - 3 edges
9. `printUsage()` - 3 edges
10. `callBridge()` - 3 edges

## Surprising Connections (you probably didn't know these)
- `printUsage()` --calls--> `log()`  [INFERRED]
  Shared-scripts\github-copilot-bridge\ask-github-model.mjs → Shared-scripts\github-copilot-bridge\vscode-copilot-bridge\extension.js
- `callBridge()` --calls--> `log()`  [INFERRED]
  Shared-scripts\github-copilot-bridge\ask-github-model.mjs → Shared-scripts\github-copilot-bridge\vscode-copilot-bridge\extension.js

## Communities

### Community 0 - "Community 0"
Cohesion: 0.28
Nodes (4): ConvertTo-RepoRelativePath(), Gate(), Get-StatusPath(), Log()

### Community 1 - "Community 1"
Cohesion: 0.43
Nodes (5): buildOpenRouterPopularityFallbacks(), getMostPopularOpenRouterFreeModel(), matchOpenRouterRankedModelId(), parseOpenRouterRankingHistory(), parseOpenRouterWeeklyLeaderboard()

### Community 2 - "Community 2"
Cohesion: 0.52
Nodes (5): Invoke-Graphify(), Invoke-GraphifyHtml(), Invoke-GraphifyWiki(), Require-Graph(), Require-Python()

### Community 3 - "Community 3"
Cohesion: 0.43
Nodes (5): activate(), callCopilot(), createRequestHandler(), getBridgeSettings(), log()

### Community 4 - "Community 4"
Cohesion: 0.6
Nodes (4): callBridge(), parseArgs(), printUsage(), readStdin()

### Community 5 - "Community 5"
Cohesion: 0.67
Nodes (0): 

### Community 6 - "Community 6"
Cohesion: 1.0
Nodes (0): 

### Community 7 - "Community 7"
Cohesion: 1.0
Nodes (0): 

### Community 8 - "Community 8"
Cohesion: 1.0
Nodes (0): 

### Community 9 - "Community 9"
Cohesion: 1.0
Nodes (0): 

### Community 10 - "Community 10"
Cohesion: 1.0
Nodes (0): 

### Community 11 - "Community 11"
Cohesion: 1.0
Nodes (0): 

### Community 12 - "Community 12"
Cohesion: 1.0
Nodes (0): 

## Knowledge Gaps
- **Thin community `Community 6`** (1 nodes): `openharness.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 7`** (1 nodes): `project-progress.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 8`** (1 nodes): `repo-layout-index.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 9`** (1 nodes): `resume-work.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 10`** (1 nodes): `runtime-error-loop.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 11`** (1 nodes): `session-start-maintenance.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 12`** (1 nodes): `sync-two-task-loop.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `log()` connect `Community 3` to `Community 4`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Why does `printUsage()` connect `Community 4` to `Community 3`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **Why does `callBridge()` connect `Community 4` to `Community 3`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `log()` (e.g. with `printUsage()` and `callBridge()`) actually correct?**
  _`log()` has 2 INFERRED edges - model-reasoned connections that need verification._