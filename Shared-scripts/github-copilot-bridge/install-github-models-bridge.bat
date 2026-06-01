@echo off
setlocal

set "SCRIPT_ROOT=%~dp0"
set "SOURCE_DIR=%SCRIPT_ROOT%vscode-copilot-bridge"
set "TARGET_ROOT=%USERPROFILE%\.vscode\extensions"
set "EXTENSIONS_JSON=%TARGET_ROOT%\extensions.json"
set "LEGACY_TARGET_DIR=%TARGET_ROOT%\blogger-mcp-local.blogger-mcp-copilot-bridge-1.0.0"
set "TARGET_DIR=%TARGET_ROOT%\shared-local.github-copilot-models-bridge-1.0.0"

if not exist "%SOURCE_DIR%\package.json" (
  echo Bridge source folder not found: "%SOURCE_DIR%"
  exit /b 1
)

if not exist "%TARGET_ROOT%" mkdir "%TARGET_ROOT%"

if exist "%LEGACY_TARGET_DIR%" rmdir /s /q "%LEGACY_TARGET_DIR%"
if exist "%TARGET_DIR%" rmdir /s /q "%TARGET_DIR%"

robocopy "%SOURCE_DIR%" "%TARGET_DIR%" /E >nul
if errorlevel 8 (
  echo Failed to install GitHub Copilot Models Bridge into "%TARGET_DIR%"
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$path = $env:EXTENSIONS_JSON; if (Test-Path $path) { $raw = Get-Content $path -Raw; $items = if ($raw.Trim()) { @($raw | ConvertFrom-Json) } else { @() }; $filtered = foreach ($item in $items) { $extensionPath = $item.location.path; if (-not $extensionPath) { $item; continue }; $normalized = $extensionPath -replace '^/([a-zA-Z]):/', '$1:/' -replace '/', '\'; if (Test-Path $normalized) { $item } }; $filtered | ConvertTo-Json -Depth 20 -Compress | Set-Content $path -Encoding UTF8 }"

echo Installed GitHub Copilot Models Bridge to:
echo   "%TARGET_DIR%"

where code >nul 2>nul
if errorlevel 1 (
  echo.
  echo VS Code CLI not found on PATH.
  echo Reload an existing VS Code window or open a new VS Code window to activate the bridge.
  exit /b 0
)

echo.
echo Opening a fresh VS Code window so the bridge can activate on startup...
start "" code --new-window
exit /b 0