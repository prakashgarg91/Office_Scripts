# Closing Day Hook

Run `powershell -ExecutionPolicy Bypass -File .\0.dev-matrix\close-day.ps1` from repo root before ending actual work in this light-governance repo.

For a short pause or context switch, use `0.dev-matrix/pause-work.ps1` plus a brief `AI-HANDOFF.md` update instead of the full close-day path.

The hook is handoff-first: it does not invent launch validation for a repo with no active runtime surface. It verifies a continuation-ready `0.dev-matrix/AI-HANDOFF.md` entry for today, records `git status`, and writes `0.dev-matrix/LAST-CLOSEOUT.md`.

Required close-day handoff fields in the newest `AI-HANDOFF.md` entry:
- `Changed:`
- `Verified:`
- `Operational proof:`
- `Continue from:`
- `Next step:`
- `Blockers:`

This light repo does not require `LAUNCH_CHECKLIST.md` or launch-check until it graduates into an actively validated product repo.