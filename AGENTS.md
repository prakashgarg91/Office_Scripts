# AGENTS.md

Cross-repo working instructions for AI coding agents.
---

## Cross-Repo Working Agreement

These rules apply across the user's repositories.

### Manager Mode Trigger

If the user explicitly asks the assistant to act as manager, software development manager, orchestrator, coordinator, or reviewer-in-charge:

- Enter manager mode even if the user does not say `opencode`.
- Focus on orchestration, delegation, auditing, verification, status judgment, and documentation updates.
- Stay out of direct implementation by default unless the user explicitly asks the assistant itself to write code.
- Report progress in an executive-friendly way with status, risks, confidence, blockers, business impact, and next actions.

### OpenCode Trigger

If the user says `opencode`, `use opencode`, `run opencode`, or otherwise explicitly names `oh-my-opencode` / `opencode`:

- Act as the user's software development manager by default.
- Use the `opencode` command as the primary workflow in this workspace.
- Treat `oh-my-opencode` as a naming alias or intent signal, not as a runnable command here.
- Remember that `oh-my-opencode` is not installed as a command in this workspace, but `opencode` is installed and working.
- `opencode` may use multiple agents in parallel when that helps complete the project faster or reduces delivery risk.
- Orchestrate, audit, verify, and judge the work instead of blindly trusting tool output.
- Update project tracking files such as `0.dev-matrix/STATE.md`, `0.dev-matrix/TASK.md`, and `0.dev-matrix/DISCUSSION.md` when they exist and status needs correction.

### Direct Work Trigger

If the user asks to `build`, `test`, fix, implement, or review something without using the word `opencode` and without asking for manager mode:

- The assistant may work directly without OpenCode.
- Do not assume OpenCode is required unless the user explicitly says `opencode`.

### Testing First

Testing is the key to quality.

- Do not call work complete without relevant verification evidence.
- Prefer proof over claims: tests, builds, typechecks, health checks, runtime checks, and repo-state verification.
- Do not blindly trust OpenCode output without independent validation.

### Dev-Matrix Workflow

- Start with `0.dev-matrix/AI-HANDOFF.md`, then run `0.dev-matrix/resume-work.ps1` when it exists.
- Use `0.dev-matrix/pause-work.ps1` for short stops and `0.dev-matrix/close-day.ps1` for true closeout when it exists.
- In light-governance repos, close-day is handoff-first and does not invent launch evidence the repo does not support.
- If `0.dev-matrix/ECOSYSTEM.md` exists, read it before changing launch priority, pricing, distribution, or product scope.

### Executive Reporting

- Report progress in an executive-friendly way suitable for a non-coder CEO/CFO.
- Focus on status, risk, confidence, blockers, business impact, and next actions.

### GitHub Responsibility

- When work is complete and validated, update the GitHub repository appropriately with commits and pushes.
### Professional Codebase Standard

Always push the code tree toward a professional, sustainable, world-class standard.

- Improve structure, naming, organization, and maintainability whenever appropriate.
- Prefer clean architecture, clear ownership, and low-friction onboarding for future work.
- Reduce dead code, duplication, drift, and hidden coupling where it is safe to do so.
- Build for long-term sustainability, not just short-term patching.

### Glue Principle

Software is not complete unless the full chain works together professionally.

- Verify end-to-end glue between UI, API, services, data stores, background jobs, and configuration.
- Do not treat isolated code changes as success if the integrated flow is still broken.
- Prefer professionally integrated working software over partially implemented features.
- Update tracking files when integration reality differs from claimed status.

---

## Model And Quality Policy

- Use `zai-coding-plan/glm-5.1` when the assistant is acting as manager and orchestrating work through `opencode` or Claude Code.
- If `glm-5.1` is unavailable, unhealthy, or not responding, fall back to any available free `opencode/*` model before blocking work. Prefer `opencode/big-pickle`, `opencode/mimo-v2-omni-free`, `opencode/minimax-m2.5-free`, and `opencode/qwen3.6-plus-free`, then any other working free `opencode/*` model.
- Treat references to GLM 4.x, GLM 4.7, or older GLM prompts as stale unless the user explicitly asks for them.
- This model-selection rule is separate from `0.dev-matrix`; `0.dev-matrix` is for repo-specific context, SOPs, quality tracking, and codebase truth.
- When using `opencode`, parallel multi-agent execution is allowed when it materially improves speed, coverage, or coordination.
- When `0.dev-matrix` exists, use it as the operating system for planning, status, task tracking, dependency mapping, discussion, patterns, testing, and reality checks.
- Treat each repository as a separate software product or application with its own architecture, quality gates, release readiness, and documentation.
- Prioritize end-to-end glue across UI, API, services, data, infra, background jobs, auth, and configuration.
- Keep the codebase tree clean, professional, sustainable, and easy to onboard into; reduce drift, duplication, abandoned files, and misleading docs.
- Update `0.dev-matrix/STATE.md`, `0.dev-matrix/TASK.md`, `0.dev-matrix/DISCUSSION.md`, `0.dev-matrix/DEPENDENCIES.md`, and `0.dev-matrix/PATTERNS.md` when reality changes.

---

## Qdrant Tool

A shared semantic search + gap audit tool lives at `D:\Github\tools\qdrant_gap_audit.py`.
It works across **all D:\Github projects** without Roo Code or any VS Code extension.

### Two modes

**Search mode** — find code by meaning (complements grep, not a replacement):
```powershell
# Find by concept when you don't know exact symbol names
python D:\Github\tools\qdrant_gap_audit.py -q "payment webhook handler"

# With real source lines shown (3 lines context, -> markers on hits)
python D:\Github\tools\qdrant_gap_audit.py -q "auth session check" --context-lines 3

# Filter by extension or filename pattern
python D:\Github\tools\qdrant_gap_audit.py -q "form validation" --lang tsx --file-filter "*Page*"

# Search whole repo, not just src-subpath
python D:\Github\tools\qdrant_gap_audit.py -q "database schema" --all-files --top 30
```

**Gap audit mode** — scan 33 checks, write `0.dev-matrix/QDRANT_GAP_REPORT.md`:
```powershell
# Full audit (auto-discovers collection)
cd D:\Github\<project>
.venv\Scripts\python D:\Github\tools\qdrant_gap_audit.py

# Specific checks only
.venv\Scripts\python D:\Github\tools\qdrant_gap_audit.py --checks 1,2,3,27,28,29

# Different project / subpath
python D:\Github\tools\qdrant_gap_audit.py --workspace D:\Github\Blogger-MCP --src-subpath src
```

### When to use which tool

| Query type | Use |
|------------|-----|
| Exact function/variable name | `grep` / `ripgrep` |
| Exact error string | `grep` |
| "Where is X handled?" — by concept | Qdrant `-q` |
| "Find all auth checks" — by intent | Qdrant `-q` |
| Full codebase health scan | Qdrant gap audit |

### Per-project setup

```powershell
# React project (TruckOpti, Job-360, trading-rex-ai)
python D:\Github\tools\qdrant_gap_audit.py --workspace . --src-subpath frontend/src --framework react

# Next.js project
python D:\Github\tools\qdrant_gap_audit.py --workspace . --src-subpath app --framework nextjs

# Python backend
python D:\Github\tools\qdrant_gap_audit.py --workspace . --src-subpath src --framework fastapi

# Node.js / Express
python D:\Github\tools\qdrant_gap_audit.py --workspace . --src-subpath src --framework express
```

Collection is **auto-discovered** — pass `--collection ws-xxx` only if auto-discovery fails.
Falls back to Roo Code's Qdrant (port 6335) if no standalone index exists.

Full reference: skill file at `c:\Users\Prakash\.copilot\skills\qdrant-gap-audit\SKILL.md`