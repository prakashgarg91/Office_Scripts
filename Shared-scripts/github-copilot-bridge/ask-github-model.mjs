#!/usr/bin/env node

const DEFAULT_PORT = 3010
const DEFAULT_HOST = '127.0.0.1'

function parseArgs(argv) {
    const options = {
        host: DEFAULT_HOST,
        port: DEFAULT_PORT,
        model: undefined,
        prompt: undefined,
        systemPrompt: undefined,
        maxTokens: undefined,
        health: false,
        json: false,
    }

    for (let index = 0; index < argv.length; index += 1) {
        const arg = argv[index]

        if (arg === '--health') {
            options.health = true
            continue
        }

        if (arg === '--json') {
            options.json = true
            continue
        }

        if (arg === '--prompt') {
            options.prompt = argv[index + 1]
            index += 1
            continue
        }

        if (arg === '--model') {
            options.model = argv[index + 1]
            index += 1
            continue
        }

        if (arg === '--system') {
            options.systemPrompt = argv[index + 1]
            index += 1
            continue
        }

        if (arg === '--max-tokens') {
            options.maxTokens = Number.parseInt(argv[index + 1], 10)
            index += 1
            continue
        }

        if (arg === '--port') {
            options.port = Number.parseInt(argv[index + 1], 10)
            index += 1
            continue
        }

        if (arg === '--host') {
            options.host = argv[index + 1]
            index += 1
            continue
        }

        if (arg === '--help' || arg === '-h') {
            printUsage()
            process.exit(0)
        }
    }

    return options
}

function printUsage() {
    console.log(`Usage:
  node ask-github-model.mjs --health
  node ask-github-model.mjs --model claude-haiku-4.5 --prompt "Reply with exactly: bridge-ok"
  echo Hello | node ask-github-model.mjs --model claude-haiku-4.5

Options:
  --health             Call GET /health and print the result
  --prompt <text>      Prompt text to send to the bridge
  --model <family>     Model family, for example claude-haiku-4.5
  --system <text>      Optional system prompt
  --max-tokens <n>     Optional max token limit
  --port <n>           Override bridge port (default: 3010)
  --host <host>        Override bridge host (default: 127.0.0.1)
  --json               Print the full JSON response
  --help, -h           Show this help
`)
}

async function readStdin() {
    if (process.stdin.isTTY) {
        return ''
    }

    const chunks = []
    for await (const chunk of process.stdin) {
        chunks.push(chunk)
    }

    return Buffer.concat(chunks).toString('utf8').trim()
}

async function callBridge({ host, port, model, prompt, systemPrompt, maxTokens, health, json }) {
    const baseUrl = `http://${host}:${port}`

    if (health) {
        const response = await fetch(`${baseUrl}/health`)
        const payload = await response.json()
        console.log(JSON.stringify(payload, null, 2))
        return
    }

    const finalPrompt = prompt || await readStdin()

    if (!finalPrompt) {
        console.error('Missing prompt. Use --prompt, pipe stdin, or call with --health.')
        process.exit(1)
    }

    const body = {
        prompt: finalPrompt,
    }

    if (model) {
        body.model = model
    }

    if (systemPrompt) {
        body.systemPrompt = systemPrompt
    }

    if (Number.isFinite(maxTokens)) {
        body.maxTokens = maxTokens
    }

    const response = await fetch(`${baseUrl}/chat`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
    })

    const payload = await response.json()

    if (!response.ok || payload.success === false) {
        console.error(JSON.stringify(payload, null, 2))
        process.exit(1)
    }

    if (json) {
        console.log(JSON.stringify(payload, null, 2))
        return
    }

    process.stdout.write(payload.content)
    if (!payload.content.endsWith('\n')) {
        process.stdout.write('\n')
    }
}

const options = parseArgs(process.argv.slice(2))

callBridge(options).catch(error => {
    console.error(error instanceof Error ? error.message : String(error))
    process.exit(1)
})