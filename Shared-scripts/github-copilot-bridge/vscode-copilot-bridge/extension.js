// GitHub Copilot Models Bridge
// Starts a local HTTP server that proxies AI requests through your logged-in
// GitHub Copilot session (vscode.lm API). No PAT or API key required.
//
// How it works:
//   1. VS Code activates this extension on startup (onStartupFinished)
//   2. Extension listens on http://127.0.0.1:3010 (configurable)
//   3. Any local tool can send POST /chat requests to this bridge
//   4. Bridge uses vscode.lm.selectChatModels() to call Copilot
//   5. Response is streamed back to the server
//
// Supported routes:
//   GET  /health  → { status: "ok", models: [...] }
//   POST /chat    → { model, prompt, systemPrompt?, maxTokens? }
//                ← { success, content, model, family }

const vscode = require('vscode');
const http = require('http');

let server = null;
let outputChannel = null;

const OUTPUT_CHANNEL_NAME = 'GitHub Models Bridge';
const CONFIG_NAMESPACE = 'githubModelsBridge';
const DEFAULT_MODEL_FAMILY = 'claude-sonnet-4.6';

function log(msg) {
  if (!outputChannel) {
    outputChannel = vscode.window.createOutputChannel(OUTPUT_CHANNEL_NAME);
  }
  outputChannel.appendLine(`[${new Date().toISOString()}] ${msg}`);
}

function getBridgeSettings() {
  const config = vscode.workspace.getConfiguration(CONFIG_NAMESPACE);

  return {
    port: config.get('port', 3010),
    defaultModel: config.get('defaultModel', DEFAULT_MODEL_FAMILY),
  };
}

/**
 * Call a Copilot model via vscode.lm API.
 * @param {string} modelFamily  e.g. "claude-sonnet-4-6", "gpt-4o"
 * @param {string} prompt
 * @param {string|undefined} systemPrompt
 * @param {number} maxTokens
 */
async function callCopilot(modelFamily, prompt, systemPrompt, maxTokens) {
  // Try the requested model family first
  let models = await vscode.lm.selectChatModels({ vendor: 'copilot', family: modelFamily });

  // If specific family not available, try any Copilot model
  if (!models || models.length === 0) {
    log(`Model family "${modelFamily}" not found, trying any Copilot model...`);
    models = await vscode.lm.selectChatModels({ vendor: 'copilot' });
  }

  if (!models || models.length === 0) {
    throw new Error(
      'No GitHub Copilot models available. ' +
      'Make sure GitHub Copilot Chat is installed and you are signed in to GitHub.'
    );
  }

  const model = models[0];
  log(`Using model: ${model.vendor}/${model.family} (id: ${model.id})`);

  // Build messages
  const messages = [];
  if (systemPrompt) {
    messages.push(vscode.LanguageModelChatMessage.User(`[System context]\n${systemPrompt}`));
  }
  messages.push(vscode.LanguageModelChatMessage.User(prompt));

  const tokenSource = new vscode.CancellationTokenSource();

  const response = await model.sendRequest(
    messages,
    { modelOptions: { max_tokens: maxTokens || 4000 } },
    tokenSource.token
  );

  // Collect streamed response
  let content = '';
  for await (const chunk of response.text) {
    content += chunk;
  }

  return { success: true, content, model: model.id, family: model.family };
}

/**
 * Handle incoming HTTP requests.
 */
function createRequestHandler() {
  return async function (req, res) {
    const headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    };

    // Health check
    if (req.method === 'GET' && req.url === '/health') {
      try {
        const models = await vscode.lm.selectChatModels({ vendor: 'copilot' });
        const modelList = (models || []).map(m => `${m.family}/${m.id}`);
        res.writeHead(200, headers);
        res.end(JSON.stringify({ status: 'ok', bridge: 'vscode-copilot', models: modelList }));
      } catch {
        res.writeHead(200, headers);
        res.end(JSON.stringify({ status: 'ok', bridge: 'vscode-copilot', models: [] }));
      }
      return;
    }

    // Chat completion
    if (req.method === 'POST' && req.url === '/chat') {
      let body = '';
      req.on('data', chunk => { body += chunk; });
      req.on('end', async () => {
        try {
          const { defaultModel } = getBridgeSettings();
          const { model = defaultModel, prompt, systemPrompt, maxTokens = 4000 } = JSON.parse(body);

          if (!prompt) {
            res.writeHead(400, headers);
            res.end(JSON.stringify({ success: false, error: 'Missing required field: prompt' }));
            return;
          }

          const result = await callCopilot(model, prompt, systemPrompt, maxTokens);
          res.writeHead(200, headers);
          res.end(JSON.stringify(result));
        } catch (error) {
          log(`Chat error: ${error.message}`);
          res.writeHead(500, headers);
          res.end(JSON.stringify({ success: false, error: error.message }));
        }
      });
      return;
    }

    res.writeHead(404, headers);
    res.end(JSON.stringify({ error: 'Not found. Use GET /health or POST /chat' }));
  };
}

function activate(context) {
  outputChannel = vscode.window.createOutputChannel(OUTPUT_CHANNEL_NAME);

  const { port } = getBridgeSettings();

  server = http.createServer(createRequestHandler());

  server.listen(port, '127.0.0.1', () => {
    const msg = `GitHub Copilot Models Bridge active on port ${port}`;
    log(`✅ ${msg}`);
    log('   Local tools can now use your Copilot subscription through the bridge without a PAT.');
    vscode.window.setStatusBarMessage(`$(copilot) ${msg}`, 8000);
  });

  server.on('error', err => {
    if (err.code === 'EADDRINUSE') {
      log(`⚠️ Port ${port} already in use — bridge not started. Check if another VS Code window is running.`);
    } else {
      log(`Bridge server error: ${err.message}`);
    }
  });

  context.subscriptions.push({
    dispose: () => {
      if (server) {
        server.close();
        server = null;
      }
    }
  });
  context.subscriptions.push(outputChannel);
}

function deactivate() {
  if (server) {
    server.close();
    server = null;
  }
}

module.exports = { activate, deactivate };
