# Graph Report - .  (2026-05-11)

## Corpus Check
- 7 files · ~17,771 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 23 nodes · 23 edges · 7 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]

## God Nodes (most connected - your core abstractions)
1. `Require-Python()` - 4 edges
2. `Require-Graph()` - 3 edges
3. `Invoke-GraphifyWiki()` - 3 edges
4. `Invoke-GraphifyHtml()` - 3 edges
5. `Log()` - 2 edges
6. `Gate()` - 2 edges
7. `ConvertTo-RepoRelativePath()` - 2 edges
8. `Get-StatusPath()` - 2 edges
9. `Invoke-Graphify()` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities

### Community 0 - "Community 0"
Cohesion: 0.28
Nodes (4): ConvertTo-RepoRelativePath(), Gate(), Get-StatusPath(), Log()

### Community 1 - "Community 1"
Cohesion: 0.52
Nodes (5): Invoke-Graphify(), Invoke-GraphifyHtml(), Invoke-GraphifyWiki(), Require-Graph(), Require-Python()

### Community 2 - "Community 2"
Cohesion: 0.67
Nodes (0): 

### Community 3 - "Community 3"
Cohesion: 1.0
Nodes (0): 

### Community 4 - "Community 4"
Cohesion: 1.0
Nodes (0): 

### Community 5 - "Community 5"
Cohesion: 1.0
Nodes (0): 

### Community 6 - "Community 6"
Cohesion: 1.0
Nodes (0): 

## Knowledge Gaps
- **Thin community `Community 3`** (1 nodes): `openharness.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 4`** (1 nodes): `project-progress.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 5`** (1 nodes): `resume-work.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 6`** (1 nodes): `session-start-maintenance.ps1`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Not enough signal to generate questions. This usually means the corpus has no AMBIGUOUS edges, no bridge nodes, no INFERRED relationships, and all communities are tightly cohesive. Add more files or run with --mode deep to extract richer edges._