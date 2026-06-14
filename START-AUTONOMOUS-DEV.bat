@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Force a UTF-8 console so live unattended output from opencode does not mojibake.
"%SystemRoot%\System32\chcp.com" 65001 >nul 2>&1
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"

set "PROJECT_NAME=Office_Scripts"
set "DEFAULT_MAX_RUNS=8"

set "RUNS="
set "FORWARD_ARGS="

:parse_args
if "%~1"=="" goto launch

echo(%~1| findstr /R "^[0-9][0-9]*$" >nul
if not errorlevel 1 if not defined RUNS (
  set "RUNS=%~1"
  shift
  goto parse_args
)

set "FORWARD_ARGS=%FORWARD_ARGS% %1"
shift
goto parse_args

:launch
if not defined RUNS set "RUNS=%DEFAULT_MAX_RUNS%"

title AUTONOMOUS CODING IN PROGRESS - %PROJECT_NAME%
echo ========================================================
echo [LOADING] Unattended autonomous coding is starting.
echo [LOADING] Project: %PROJECT_NAME%
echo [LOADING] Max runs: %RUNS%
echo [LOADING] Policy: free models first, DeepSeek final review only after free pass.
echo [LOADING] Browser-heavy tasks use the shared Microsoft Webwright harness.
echo [LOADING] Keep this window open while work is in progress.
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "D:\Github\Frame\run-portfolio.ps1" -ProjectName "%PROJECT_NAME%" -MaxRunsOverride %RUNS%%FORWARD_ARGS%
exit /b %ERRORLEVEL%
