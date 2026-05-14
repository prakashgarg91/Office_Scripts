# Image Brief Template

Use this template when a repo does not already have a canonical image-source file.

## Minimal JSON Shape

```json
{
  "version": 1,
  "product": {
    "title": "",
    "subtitle": "",
    "orientation": "portrait"
  },
  "audience": {
    "primary": "",
    "buyer": ""
  },
  "artwork": {
    "chatgptImageFile": "projects/.../production/assets/chatgpt-image.png",
    "nanoBananaImageFile": "projects/.../production/assets/nano-banana-image.png",
    "previewFallbackFile": "projects/.../exports/.../preview.png"
  },
  "goal": "",
  "mood": [],
  "hero": "",
  "supportingObjects": [],
  "colorDirection": [],
  "titleSafeArea": {
    "description": "",
    "coverage": "",
    "textRule": ""
  },
  "style": "",
  "qualityBar": [],
  "mustKeep": [],
  "avoid": []
}
```

## Prompt Drafting Checklist

1. one clear hero object
2. only a few large supporting objects
3. explicit safe area rule
4. explicit output orientation
5. no-text rule unless text is desired
6. banned failure modes listed directly
7. buyer intent included, not only art style

## Save Checklist

1. create `production/assets/` if it does not exist
2. save the real ChatGPT image to the canonical path
3. save the Nano Banana refinement separately
4. refresh any proof PDF or preview PNG that depends on the art
5. verify downstream artifacts are reading the saved file rather than a fallback