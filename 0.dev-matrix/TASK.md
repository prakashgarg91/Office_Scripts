# TASK — Office_Scripts

> Scope: low-priority Office automation workspace and script catalog
>
> **Queue normalization note (2026-05-14):** the canonical machine-owned queue now lives in `0.dev-matrix/AI-TASKS.json`. Active pair: `OFF-101` define the first shippable automation bundle and `OFF-102` add the automation contract artifact. `OFF-103` is the first reusable automation proof slice, and `OFF-104` is the evidence-capture follow-through. The queue below supersedes the earlier script-catalog idea list that reused `OFF-*` IDs differently.

---

## ACTIVE TASKS

| ID | Task | Type | Owner | Status |
|----|------|------|-------|--------|
| OFF-104 | Capture normalized Office automation evidence | Proof | CANONICAL QUEUE | 🟡 Active |

## NEXT TASKS

| ID | Task | Type | Owner | Status |
|----|------|------|-------|--------|
| — | — | — | — | — |

## COMPLETED TASKS

| ID | Task | Completed | Evidence |
|----|------|-----------|---------|
| OFF-103 | Validate the first reusable automation slice — ExcelReportPipeline core landed | 2026-05-31 | src/bundles/excel-report-pipeline/ created: VBA orchestrator, Power Query M, sample data, validation script. Validate.ps1: 29/29 passes, 0 failures |
| OFF-102 | Add the automation contract artifact — SPEC.json accepted for ExcelReportPipeline | 2026-05-31 | 0.dev-matrix/SPEC.json created, valid JSON, sync-two-task-loop.ps1 confirms queue normalized |
| OFF-101 | Define the first shippable automation bundle — ExcelReportPipeline named | 2026-05-31 | README.md, LAUNCH_CHECKLIST.md, TASK.md all aligned to ExcelReportPipeline |
| OFF-001 | Repo classified in the cross-repo portfolio as low-priority Office automation work | 2026-05-10 | 0.dev-matrix portfolio closeout and repo registry |