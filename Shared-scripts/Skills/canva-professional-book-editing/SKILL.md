---
name: canva-professional-book-editing
description: "Use when turning saved AI art or structured book content into professional-level Canva covers, interiors, and print exports. Best for book editing, cover assembly, typography cleanup, reusable templates, and final export polish."
argument-hint: "Project path, book type, or Canva layout task"
user-invocable: true
---

# Canva Professional Book Editing

Use this skill when the goal is not raw image generation, but professional editing and assembly inside Canva.

## When To Use

- turning saved ChatGPT or Nano Banana art into a final book cover
- creating a reusable Canva cover template for a KDP trim-size family
- improving typography, spacing, hierarchy, and print safety
- building cleaner interiors for activity books, puzzle books, and low-content books
- exporting professional print PDFs from Canva rather than relying on rough AI mockups

## Core Rule

Canva is the editing and assembly lane, not the idea-discovery lane.
Bring in saved art or structured content first, then use Canva to create a polished, print-safe book that looks intentional at thumbnail size and in print.

## Inputs To Gather First

1. trim size and full wrap size
2. page count and spine width
3. front-cover art path
4. title, subtitle, author, and badge copy
5. back-cover blurb and feature bullets
6. barcode-safe zone requirement
7. whether the product is kids, adult hobby, or elder-focused large print
8. whether a project-specific Canva spec already exists

## Route Order

1. import saved art or content
2. create the Canva document at exact print size
3. lock guides, safe areas, and barcode zone first
4. build the typography hierarchy
5. simplify decorative elements until the layout feels intentional
6. export a print PDF and proof at full size plus thumbnail size

## Cover Editing Workflow

### Route A: Build The Template

1. Create the document using the exact KDP dimensions.
2. Add bleed, trim, spine, safe-area, and barcode guides as locked reference layers.
3. Use one reusable template per trim-size and page-count family when possible.
4. Keep the back cover calmer than the front cover.
5. If the spine is too thin for reliable text, omit spine text entirely.

### Route B: Import Saved AI Art

1. Import the saved ChatGPT or Nano Banana image from the project, not from Downloads.
2. Use the art only where it strengthens the layout.
3. Do not stretch portrait art awkwardly across the full wrap.
4. If the art is front-cover only, extend the wrap with extracted colors, clean shapes, or a restrained background continuation.
5. Keep image cleanup minimal; Canva is for composition and typography, not heavy repainting.

### Route C: Typography And Hierarchy

1. Use at most two font families for the cover.
2. Make the title the clear dominant element.
3. Keep subtitle and benefit copy short enough to read at Amazon thumbnail size.
4. Use badges only when they communicate a buyer benefit, not as decoration.
5. Avoid text shadows, novelty outlines, and crowded sticker-style labels.

### Route D: Back Cover Discipline

1. Use a short headline plus one concise blurb paragraph.
2. Use 3 short feature bullets or chips, not a dense sales wall.
3. Keep a clean white barcode box at the lower right.
4. Leave generous breathing room; a restrained back cover reads as more professional.

## Interior Editing Workflow

1. Use one master template for repeating page types.
2. Keep body text highly readable and high contrast.
3. For kids books, use friendly but disciplined fonts; for elder-focused books, favor readability over style.
4. Keep decorative elements outside puzzle, activity, or reading zones.
5. Proof one page at 100 percent zoom and one printed sample before final export when possible.

## Default Font Logic

- kids cover title: `Baloo 2 ExtraBold` or `Fredoka Bold`
- subtitle and back-cover copy: `Nunito Sans`, `Lexend`, or `Atkinson Hyperlegible`
- numeric badge or short benefit chip: `League Spartan` or `Nunito Sans ExtraBold`
- elder-focused books: favor `Lexend`, `Atkinson Hyperlegible`, or `Andika`
- avoid decorative fonts in body copy

## Color And Layout Rules

- use one dominant accent color plus one support color family
- keep high contrast between text and background
- avoid purple-on-white defaults, muddy gradients, and low-contrast pastels
- do not add more icons if the page already feels full
- if something looks cute but weak at thumbnail size, remove it

## Output Contract

A complete Canva editing pass should leave behind:

1. a project-local Canva template spec or checklist
2. a final front-cover or wrap composition that uses saved art cleanly
3. a print-safe export plan
4. the final export path recorded in the project

## Quality Bar

The result should satisfy all of these:

- the title is readable at thumbnail size
- the layout feels like a real book, not an AI collage
- the back cover is restrained and print-safe
- the cover looks giftable and commercially credible
- the typography looks intentional and consistent across the line

## References

- [Canva Book Quality Checklist](./references/canva-book-quality-checklist.md)