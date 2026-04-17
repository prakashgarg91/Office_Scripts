# Graph Report - .  (2026-04-16)

## Corpus Check
- 4 files · ~11,580 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 26 nodes · 29 edges · 4 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]

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
Cohesion: 0.29
Nodes (0): 

### Community 3 - "Community 3"
Cohesion: 0.67
Nodes (0): 

## Suggested Questions
_Not enough signal to generate questions. This usually means the corpus has no AMBIGUOUS edges, no bridge nodes, no INFERRED relationships, and all communities are tightly cohesive. Add more files or run with --mode deep to extract richer edges._