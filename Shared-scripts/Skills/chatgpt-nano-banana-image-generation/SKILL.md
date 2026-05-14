---
name: chatgpt-nano-banana-image-generation
description: "Use when generating production-ready images with ChatGPT first and Gemini Nano Banana second, especially when the work needs a canonical saved asset, prompt parity, and downstream handoff into PDF, layout, or proof flows."
argument-hint: "Project path, asset type, or image brief"
user-invocable: true
---

# ChatGPT + Nano Banana Image Generation

Use this skill when the goal is to create a real image asset, save it into a project, and keep the generation flow reusable for other agents.

## When To Use

- generating a first-pass image in ChatGPT
- refining a chosen image in Gemini Nano Banana
- saving a real image file into a project instead of leaving it only in the browser
- keeping prompt generation and asset saving tied to a canonical source brief
- handing the saved art into Canva, PDF proofs, KDP covers, landing pages, or any other downstream asset pipeline

## Core Rule

The work is not complete when the image merely exists in ChatGPT or Gemini.
The work is complete only when the real image file is saved into the project at a canonical path and any downstream proof or layout artifact has been refreshed from that saved file.

## Inputs To Gather First

Collect or infer these before generating:

1. product or asset title
2. audience and buyer
3. one-line goal or conversion intent
4. canonical source brief path, if one already exists
5. canonical image save path, if one already exists
6. orientation and output shape
7. title-safe or copy-safe zone requirements
8. hero object and supporting objects
9. banned failure modes

If the repo already contains a source JSON, prefer that over ad hoc notes.

## Preferred Source Format

Prefer a single source file like `cover-image-source.json` or `image-source.json` with fields similar to:

```json
{
  "version": 1,
  "product": {
    "title": "...",
    "subtitle": "...",
    "orientation": "portrait"
  },
  "audience": {
    "primary": "...",
    "buyer": "..."
  },
  "artwork": {
    "chatgptImageFile": "projects/.../production/assets/chatgpt-image.png",
    "nanoBananaImageFile": "projects/.../production/assets/nano-banana-image.png"
  },
  "goal": "...",
  "mood": ["..."],
  "hero": "...",
  "supportingObjects": ["..."],
  "colorDirection": ["..."],
  "titleSafeArea": {
    "description": "...",
    "coverage": "...",
    "textRule": "..."
  },
  "style": "...",
  "qualityBar": ["..."],
  "mustKeep": ["..."],
  "avoid": ["..."]
}
```

## Route Order

Use this order unless the user explicitly asks for a different one:

1. source brief
2. ChatGPT first-pass generation
3. save the winning raw ChatGPT image into the project
4. Nano Banana refinement or edit pass
5. save the refined Nano Banana image into the project
6. regenerate downstream proofs, previews, or layout artifacts from the saved file

## Procedure

### Route A: ChatGPT First Pass

1. Start from the product brief, not from generic art direction.
2. Build a prompt that includes audience, buyer, hero object, title-safe zone, output orientation, mood, and banned failure modes.
3. Ask ChatGPT for exactly one image when the goal is controlled iteration, or 2 to 3 images when the goal is broader concept exploration.
4. Keep text out of the image unless the user explicitly wants embedded text.
5. Prefer a single dominant hero and 4 to 6 supporting shapes or objects.
6. Avoid tiny props, clutter, muddy gradients, photorealism, logos, watermarks, and copyrighted characters.

### Route B: Save The Real ChatGPT Asset

1. Do not stop after generation.
2. Save the actual generated image into the project at the canonical path.
3. If the canonical path does not exist yet, create a project-local asset folder first, for example `production/assets/`.
4. Save the clean image only. Do not save browser chrome, chat UI, or other screenshot noise.
5. If direct download is blocked, isolate the raw image and save only the image content.

### Route C: Nano Banana Refinement

Use Nano Banana only after a real ChatGPT asset exists.

1. Upload the chosen ChatGPT image as the base.
2. Ask Nano Banana to preserve composition and safe area.
3. Use it for local edits, polish, lighting, edge cleanup, hierarchy cleanup, alternate angles, or style tightening.
4. Save the refined result as a separate file first.
5. Only replace the canonical downstream asset if the refined result is clearly better.

### Route D: Refresh Downstream Artifacts

After a real image file is saved:

1. regenerate any PDF proof that should show the image
2. regenerate any PNG preview that depends on that proof
3. regenerate any layout or cover-assembly artifact that depends on the art
4. confirm the downstream artifact is using the saved file, not a fallback placeholder

## Save Rules

- prefer canonical paths declared in the source JSON
- keep the raw ChatGPT image and Nano Banana refinement as separate files when possible
- if there is no declared path, use stable names under `production/assets/`
- do not leave important image assets only in Downloads or a temp folder
- if the image is part of a modular pipeline, update the source file or metadata that points to the saved asset

## Browser / Account Handling

- if ChatGPT or Gemini is not signed in, stop and ask the user to sign in to the relevant page
- once signed in, proceed with generation and saving without asking the user to do the mechanical steps
- never claim an image exists in the project unless the file is actually saved there

## Output Contract

A complete run should leave behind:

1. a canonical source brief or updated source brief
2. the generated ChatGPT prompt or prompt pack
3. the saved real ChatGPT image file
4. the saved Nano Banana refinement file, if a refinement step was requested
5. refreshed downstream proof or preview artifacts

## Quality Bar

The saved image should satisfy all of these:

- the hero object reads clearly at thumbnail size
- the title-safe or copy-safe area is preserved
- no baked-in accidental text unless explicitly requested
- no watermarks, browser chrome, or UI overlays
- color and hierarchy fit the actual audience and selling context
- the saved asset is good enough to reuse in downstream layout without manual cleanup as the first step

## Default Prompt Pattern

Use this structure when no project-specific prompt already exists:

`Create a premium [asset type] illustration only for [audience or buyer]. [Orientation] composition for [format or size]. Leave a clear [title-safe or copy-safe area] with no text inside it. Build the scene around that area with [hero object] plus [supporting objects]. Use [style]. Keep the mood [mood]. Make it [quality bar]. No [avoid list].`

## Default Nano Banana Edit Pattern

Use this structure when refining the saved ChatGPT image:

`Use my uploaded image as the base. Preserve the overall composition and the safe area. Improve the art quality so it feels more premium and more sellable: cleaner edges, stronger lighting, better hierarchy, fewer weak small props, and better thumbnail readability. Do not add text. Do not crop into the safe area.`

## References

- [Image brief template](./references/image-brief-template.md)