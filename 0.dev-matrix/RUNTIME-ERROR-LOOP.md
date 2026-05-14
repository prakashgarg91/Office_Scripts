# Runtime Error Loop

Purpose: keep runtime error capture and runtime error resolution visible inside this repo's `0.dev-matrix` instead of leaving them as implicit local habits.

## Commands

```powershell
powershell -ExecutionPolicy Bypass -File .\0.dev-matrix\runtime-error-loop.ps1 -Mode latest
powershell -ExecutionPolicy Bypass -File .\0.dev-matrix\runtime-error-loop.ps1 -Mode capture
powershell -ExecutionPolicy Bypass -File .\0.dev-matrix\runtime-error-loop.ps1 -Mode resolve
```

## Repo-Aware Behavior

The wrapper auto-detects the best local commands in this order.

Capture:

1. `npm run track-errors`
2. `npm run start`
3. `npm run dev`
4. `.venv\Scripts\python.exe launcher.py|main.py|app.py|manage.py`

Resolve:

1. `npm run test:hidden-errors`
2. `powershell -ExecutionPolicy Bypass -File .\0.dev-matrix\launch-check.ps1`
3. `npm test`
4. `.venv\Scripts\python.exe -m pytest`

If this repo does not expose one of those commands yet, `latest` says so explicitly and `capture` / `resolve` fail truthfully with the next action needed.

## Artifacts

- `logs/autonomous/local-bot-*.log` when available
- the newest `logs/*.log` file when available
- `0.dev-matrix/error-logs/*.log` when available
- `0.dev-matrix/test-reports/hidden-error-latest.json` when available
- `0.dev-matrix/test-reports/launch-check-status.json` when available

## Resolution Loop

1. Run `-Mode latest` to see the current repo-specific commands and artifacts.
2. Run `-Mode capture` if the bug needs a live local runtime reproduction.
3. Copy the exact error text into the next fix slice.
4. Fix only the seam that the captured diagnostics identify.
5. Run `-Mode resolve` immediately after the fix.
6. Record the proof path in `AI-HANDOFF.md` when the runtime issue matters to the next session.