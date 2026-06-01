# 2 Tasks Remaining

This file is auto-generated from 0.dev-matrix/AI-TASKS.json.

## Current 2 Active Tasks

1. OFF-104 - Capture normalized Office automation evidence
- Priority: P1 | Phase: prove | Status: active
- Waiting on: OFF-103
- Owner files: 0.dev-matrix/AI-HANDOFF.md, 0.dev-matrix/STATE.md, 0.dev-matrix/TASK.md, 0.dev-matrix/LAST-CLOSEOUT.md
- Why: The repo should finish the first automation slice with aligned proof and handoff continuity.
- Done when: Handoff, state, task board, and closeout all reflect the same validated automation evidence.
- Validate: powershell -ExecutionPolicy Bypass -File ./0.dev-matrix/launch-check.ps1 ; powershell -ExecutionPolicy Bypass -File ./0.dev-matrix/sync-two-task-loop.ps1 -Mode manual
- Business value: Locks the repo's first reusable automation bundle into durable evidence future sessions can resume from.

## Next 2 Queued Tasks

- none

## Explicitly Blocked Tasks

1.  - 
- Priority:  | Phase:  | Status: 

## Rule

- Work the current one or two tasks only.
- When one task is done and verified, rerun 0.dev-matrix/sync-two-task-loop.ps1.
- At close-day, the queue should freeze the next two tasks instead of reopening broad planning.

