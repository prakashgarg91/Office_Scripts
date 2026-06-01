# GitHub Copilot Models Bridge

Reusable local VS Code bridge for calling GitHub Copilot chat models from other local AI tools without storing a PAT or separate model API key.

## Contents

- `vscode-copilot-bridge/`
  - The shared VS Code extension payload.
- `install-github-models-bridge.bat`
  - Installs the extension into `%USERPROFILE%\.vscode\extensions`.
- `ask-github-model.mjs`
  - Tiny Node CLI for calling `/health` and `/chat` from scripts or other local AIs.

## Requirements

- VS Code installed
- GitHub Copilot Chat installed and signed in inside VS Code
- A running VS Code window after install so the extension can activate on startup

## Install

Run:

```bat
install-github-models-bridge.bat
```

That installs the extension to:

```text
%USERPROFILE%\.vscode\extensions\shared-local.github-copilot-models-bridge-1.0.0
```

The installer also removes the older Blogger-named bridge folder if it is present so you do not end up with two bridge copies competing for port `3010`.

## HTTP API

### Health check

```http
GET http://127.0.0.1:3010/health
```

Example response:

```json
{
  "status": "ok",
  "bridge": "vscode-copilot",
  "models": ["claude-haiku-4.5/claude-haiku-4.5"]
}
```

### Chat request

```http
POST http://127.0.0.1:3010/chat
Content-Type: application/json
```

Request body:

```json
{
  "model": "claude-haiku-4.5",
  "prompt": "Reply with exactly: bridge-ok",
  "systemPrompt": "Optional system prompt",
  "maxTokens": 128
}
```

Response shape:

```json
{
  "success": true,
  "content": "bridge-ok",
  "model": "claude-haiku-4.5",
  "family": "claude-haiku-4.5"
}
```

## Notes

- Default port is `3010`.
- VS Code setting keys are `githubModelsBridge.port` and `githubModelsBridge.defaultModel`.
- If port `3010` is already in use, the extension will not start until the conflict is removed or the VS Code setting is changed.

## Node client helper

Health check:

```bash
node ask-github-model.mjs --health
```

Simple prompt:

```bash
node ask-github-model.mjs --model claude-haiku-4.5 --prompt "Reply with exactly: bridge-ok"
```

JSON response:

```bash
node ask-github-model.mjs --model claude-haiku-4.5 --prompt "Reply with exactly: bridge-ok" --json
```

Prompt from stdin:

```bash
echo Reply with exactly: bridge-ok | node ask-github-model.mjs --model claude-haiku-4.5
```