---
name: kdp-cover-export-proof-review
description: "Use after Canva cover editing to export the final KDP cover PDF, verify dimensions and proof quality, compare against fallback exports, and decide whether the cover is ready for upload."
argument-hint: "Project path or cover export task"
user-invocable: true
---

# KDP Cover Export And Proof Review

Use this skill after the Canva cover edit is complete and the next task is export, proof review, and upload readiness.

## When To Use

- exporting a final KDP cover from Canva
- reviewing whether the Canva export is actually stronger than a fallback scripted cover
- checking full-wrap dimensions, spine assumptions, bleed, and barcode zone
- deciding whether a cover is ready to replace `exports/kdp/cover.pdf`

## Core Rule

Do not treat a Canva cover as complete just because it looks good in the editor.
It is complete only when the exported PDF matches KDP dimensions, survives thumbnail review, and beats the fallback export in clarity and professionalism.

## Inputs To Gather First

1. full-wrap size
2. trim size
3. bleed setting
4. spine width
5. whether spine text is allowed or intentionally omitted
6. Canva export path
7. current fallback or previous cover path

## Workflow

### Route A: Export Discipline

1. Export from Canva as `PDF Print`.
2. Confirm the exported size matches the exact KDP wrap dimensions.
3. Keep the exported file in the project, not only in Downloads.
4. Preserve the previous or fallback cover until the new one passes review.

### Route B: Proof Review

Check all of these:

1. front cover reads clearly at thumbnail size
2. title hierarchy is stronger than every badge or chip
3. back cover remains restrained and readable
4. barcode box is clear and unobstructed
5. art is not stretched awkwardly across the wrap
6. nothing critical sits in unsafe trim space
7. spine handling matches the actual spine width

### Route C: Comparison Review

1. compare the Canva export against the previous or fallback cover
2. keep the Canva version only if it is clearly stronger in buyer trust, title readability, and print polish
3. if the Canva version is only different and not better, revise before replacing the old export

### Route D: Upload Readiness

The cover is upload-ready only if:

- dimensions are correct
- thumbnail readability is strong
- back cover is clean
- no UI artifacts or temporary guide layers remain
- the file path is recorded and stable

## Output Contract

A complete run should leave behind:

1. the final exported cover PDF in the project
2. at least one proof screenshot or preview artifact
3. a pass/fail judgement on upload readiness
4. a short note comparing the Canva export to the fallback cover

## References

- [KDP Cover Proof Checklist](./references/kdp-cover-proof-checklist.md)