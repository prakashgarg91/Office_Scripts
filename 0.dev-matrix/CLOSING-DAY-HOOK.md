# Closing Day Hook

Run `powershell -ExecutionPolicy Bypass -File .\0.dev-matrix\close-day.ps1` from repo root before ending actual work in this light-governance repo.

For a short pause or context switch, use `0.dev-matrix/pause-work.ps1` plus a brief `AI-HANDOFF.md` update instead of the full close-day path.

The hook is handoff-first: it does not invent launch validation for a repo with no active runtime surface. It verifies a continuation-ready `0.dev-matrix/AI-HANDOFF.md` entry for today, records `git status`, and writes `0.dev-matrix/LAST-CLOSEOUT.md`.

Close-day or task-complete handoff should also surface a project progress snapshot from `0.dev-matrix/project-progress.ps1` when it exists:
- `Date:` today's date for the snapshot
- `Working since:` first recorded repo work date
- `Working days:` elapsed days since first commit
- `Completion:` exact completion percentage plus completed/total task counts when `TASK.md` supports it
- `Pending days at current pace:` projected days remaining when progress can be computed
- `Next:` the next 3 concrete tasks to move the project forward

If this repo does not yet have a usable `TASK.md`, close-day should report completion as unavailable and explicitly call out that the task board must be added before exact project percentage can be reported.

Required close-day handoff fields in the newest `AI-HANDOFF.md` entry:
- `Changed:`
- `Verified:`
- `Operational proof:`
- `Continue from:`
- `Next step:`
- `Blockers:`

This light repo does not require `LAUNCH_CHECKLIST.md` or launch-check until it graduates into an actively validated product repo.