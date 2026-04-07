param()

$ErrorActionPreference = 'Continue'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ReportPath = Join-Path $RepoRoot '0.dev-matrix\LAST-CLOSEOUT.md'
$LogDir = Join-Path $RepoRoot '0.dev-matrix\closeout-logs'
$AllowedRuntimeDirtyFiles = @(
  '0.dev-matrix/AI-HANDOFF.md',
  '0.dev-matrix/LAST-CLOSEOUT.md'
)
$AllowedRuntimeDirtyPrefixes = @(
  '0.dev-matrix/closeout-logs/'
)
$RequiredHandoffLabels = @('Changed:', 'Verified:', 'Operational proof:', 'Continue from:', 'Next step:', 'Blockers:')
$pass = 0
$fail = 0
$reportLines = @()
$outputLog = @()
$todayStamp = Get-Date -Format 'yyyy-MM-dd'
$latestHandoffDate = 'missing'
$latestHandoffOperationalProof = 'missing'
$latestHandoffContinue = 'missing'
$latestHandoffNext = 'missing'
$latestHandoffBlockers = 'missing'
$launchStatusState = 'not configured'
$launchStatusSummary = 'light-governance repo; no background launch-check configured'
$launchStatusLog = 'none'

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$dateStamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$LogFile = Join-Path $LogDir "closeout-$dateStamp.log"

function Log($text) {
  $script:outputLog += $text
  Add-Content -Path $script:LogFile -Value $text -ErrorAction SilentlyContinue
}

function Gate($name, $ok, $detail) {
  if ($ok) { $script:pass++ } else { $script:fail++ }
  $status = if ($ok) { 'PASS' } else { 'FAIL' }
  Write-Host "[$status] $name - $detail"
  $script:reportLines += "- [$status] $name - $detail"
  Log "[$status] $name - $detail"
}

function ConvertTo-RepoRelativePath($path) {
  if ([string]::IsNullOrWhiteSpace($path)) { return $null }
  return ($path -replace '\\', '/').Trim()
}

function Get-StatusPath($statusLine) {
  if ([string]::IsNullOrWhiteSpace($statusLine) -or $statusLine.Length -lt 4) { return $null }
  $path = $statusLine.Substring(3).Trim()
  if ($path -match ' -> ') { $path = ($path -split ' -> ')[-1].Trim() }
  return ConvertTo-RepoRelativePath $path
}

function Test-IsAllowedRuntimeDirtyPath($relativePath) {
  if ([string]::IsNullOrWhiteSpace($relativePath)) { return $false }
  if ($AllowedRuntimeDirtyFiles -contains $relativePath) { return $true }
  foreach ($prefix in $AllowedRuntimeDirtyPrefixes) {
    if ($relativePath -like "$prefix*") { return $true }
  }
  return $false
}

function Get-HandoffFieldValue($body, $label) {
  if ([string]::IsNullOrWhiteSpace($body) -or [string]::IsNullOrWhiteSpace($label)) { return $null }
  $pattern = '(?mi)^-\s*' + [regex]::Escape($label) + '\s*(?<value>.+)$'
  $match = [regex]::Match($body, $pattern)
  if ($match.Success) {
    return $match.Groups['value'].Value.Trim()
  }
  return $null
}

function Get-LatestHandoffEntry($content) {
  if ([string]::IsNullOrWhiteSpace($content)) { return $null }
  $match = [regex]::Match($content, '(?ms)^###\s*(?<date>\d{4}-\d{2}-\d{2})(?<suffix>[^\r\n]*)\r?\n(?<body>.*?)(?=^###\s|\z)')
  if (-not $match.Success) { return $null }
  return @{
    Date = $match.Groups['date'].Value
    Body = $match.Groups['body'].Value.Trim()
  }
}

function Test-IsMeaningfulOperationalProof($value) {
  if ([string]::IsNullOrWhiteSpace($value)) { return $false }
  return $value.Trim().ToLowerInvariant() -ne 'none'
}

$required = @('0.dev-matrix\AI-HANDOFF.md', '0.dev-matrix\resume-work.ps1', '0.dev-matrix\pause-work.ps1', '0.dev-matrix\CLOSING-DAY-HOOK.md')
$missing = $required | Where-Object { -not (Test-Path (Join-Path $RepoRoot $_)) }
Gate 'light runtime docs' ($missing.Count -eq 0) ($(if ($missing.Count -eq 0) { 'handoff/resume/pause/close-day docs present' } else { 'missing: ' + ($missing -join ', ') }))

Gate 'background launch-check' $true $launchStatusSummary
Gate 'close-day handoff mode' $true 'light repo close-day records handoff and git status without inventing launch verification'

Push-Location $RepoRoot
try {
  $gitStatus = @(git status --porcelain 2>$null)
  $handoffTouch = @(git status --porcelain -- '0.dev-matrix/AI-HANDOFF.md' 2>$null)
  $dirtyPaths = @($gitStatus | ForEach-Object { Get-StatusPath $_ } | Where-Object { $_ })
  $blockingDirty = @($dirtyPaths | Where-Object { -not (Test-IsAllowedRuntimeDirtyPath $_) } | Select-Object -Unique)

  if ($gitStatus.Count -eq 0) {
    $statusOk = $true
    $statusDetail = 'repo clean'
  } elseif ($blockingDirty.Count -eq 0) {
    $statusOk = $true
    $statusDetail = 'only runtime handoff files changed'
  } elseif ($handoffTouch.Count -gt 0) {
    $diffBytes = @(
      git diff --stat -- '0.dev-matrix/AI-HANDOFF.md' 2>$null
      git diff --cached --stat -- '0.dev-matrix/AI-HANDOFF.md' 2>$null
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Out-String
    if ($diffBytes.Trim().Length -gt 0) {
      $statusOk = $true
      $statusDetail = 'AI-HANDOFF has real content changes'
      Log '--- handoff diff ---'
      Log $diffBytes.Trim()
    } else {
      $statusOk = $false
      $statusDetail = 'AI-HANDOFF touched but no real content change detected (whitespace-only edits do not count)'
    }
  } else {
    $statusOk = $false
    $statusDetail = 'repo changed without AI-HANDOFF update'
  }
  Gate 'status update discipline' $statusOk $statusDetail
  $gitSummary = if ($gitStatus.Count -gt 0) { ($gitStatus | Select-Object -First 10) -join ' | ' } else { 'clean' }

  $workingTreeOk = $blockingDirty.Count -eq 0
  $workingTreeDetail = if ($workingTreeOk) {
    if ($dirtyPaths.Count -eq 0) { 'repo clean before closeout report' } else { 'only runtime handoff files are dirty before report write' }
  } else {
    'dirty working tree outside runtime handoff: ' + (($blockingDirty | Select-Object -First 5) -join ', ')
  }
  Gate 'working tree cleanliness' $workingTreeOk $workingTreeDetail

  $handoffFile = Join-Path $RepoRoot '0.dev-matrix\AI-HANDOFF.md'
  if (Test-Path $handoffFile) {
    $latestHandoff = Get-LatestHandoffEntry (Get-Content $handoffFile -Raw)
    if ($null -eq $latestHandoff) {
      Gate 'handoff continuity' $false 'AI-HANDOFF.md has no parseable top entry'
      Gate 'operational proof' $false 'AI-HANDOFF.md has no parseable top entry'
    } else {
      $latestHandoffDate = $latestHandoff.Date
      $latestHandoffOperationalProof = Get-HandoffFieldValue $latestHandoff.Body 'Operational proof:'
      $latestHandoffContinue = Get-HandoffFieldValue $latestHandoff.Body 'Continue from:'
      $latestHandoffNext = Get-HandoffFieldValue $latestHandoff.Body 'Next step:'
      $latestHandoffBlockers = Get-HandoffFieldValue $latestHandoff.Body 'Blockers:'
      $missingHandoffLabels = @(
        $RequiredHandoffLabels |
          Where-Object { -not [regex]::IsMatch($latestHandoff.Body, '(?mi)^-\s*' + [regex]::Escape($_) + '\s*.+$') }
      )
      $handoffDateOk = $latestHandoff.Date -eq $todayStamp
      $handoffOk = $handoffDateOk -and $missingHandoffLabels.Count -eq 0
      $handoffDetail = if ($handoffOk) {
        'latest entry is dated today and contains changed/verified/operational-proof/continue/next/blockers fields'
      } elseif (-not $handoffDateOk) {
        "latest entry dated $($latestHandoff.Date); expected $todayStamp"
      } else {
        'latest entry missing fields: ' + (($missingHandoffLabels | ForEach-Object { $_.TrimEnd(':') }) -join ', ')
      }
      Gate 'handoff continuity' $handoffOk $handoffDetail

      $operationalProofOk = Test-IsMeaningfulOperationalProof $latestHandoffOperationalProof
      $operationalProofDetail = if ($operationalProofOk) {
        'latest entry records operational proof'
      } elseif ($missingHandoffLabels -contains 'Operational proof:') {
        'latest entry missing field: Operational proof'
      } else {
        'Operational proof cannot be none; record concrete proof or not run - reason'
      }
      Gate 'operational proof' $operationalProofOk $operationalProofDetail
    }
  } else {
    Gate 'handoff continuity' $false 'AI-HANDOFF.md not found'
    Gate 'operational proof' $false 'AI-HANDOFF.md not found'
  }
} finally {
  Pop-Location
}

$prevReport = if (Test-Path $ReportPath) { Get-Content $ReportPath -Raw } else { $null }
$prevPassMatch = if ($prevReport) { [regex]::Match($prevReport, 'Pass:\s*(\d+)') } else { $null }
$prevFailMatch = if ($prevReport) { [regex]::Match($prevReport, 'Fail:\s*(\d+)') } else { $null }
$prevPass = if ($prevPassMatch -and $prevPassMatch.Success) { [int]$prevPassMatch.Groups[1].Value } else { -1 }
$prevFail = if ($prevFailMatch -and $prevFailMatch.Success) { [int]$prevFailMatch.Groups[1].Value } else { -1 }

$regressionNote = ''
if ($prevPass -ge 0) {
  if ($pass -lt $prevPass) {
    $regressionNote = "REGRESSION: pass count dropped from $prevPass to $pass"
    Write-Host "[WARN] $regressionNote" -ForegroundColor Yellow
  }
  if ($fail -gt $prevFail -and $prevFail -ge 0) {
    $regressionNote += "; fail count rose from $prevFail to $fail"
    Write-Host "[WARN] fail count rose from $prevFail to $fail" -ForegroundColor Yellow
  }
}

if (Test-Path $ReportPath) {
  Copy-Item $ReportPath (Join-Path $LogDir "closeout-prev-$dateStamp.md") -Force
}

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$report = @(
  '# Last Closeout',
  '',
  "- Time: $timestamp",
  '- Launch verification mode: not configured in this light-governance repo',
  "- Git status: $gitSummary",
  "- Log: 0.dev-matrix/closeout-logs/closeout-$dateStamp.log",
  ''
)
$report += '## AI Handoff'
$report += "- Latest handoff date: $latestHandoffDate"
$report += '- Resume command: powershell -ExecutionPolicy Bypass -File .\\0.dev-matrix\\resume-work.ps1'
$report += "- Operational proof: $latestHandoffOperationalProof"
$report += "- Continue from: $latestHandoffContinue"
$report += "- Next step: $latestHandoffNext"
$report += "- Blockers: $latestHandoffBlockers"
$report += ''
$report += '## Launch Verification'
$report += "- State: $launchStatusState"
$report += "- Summary: $launchStatusSummary"
$report += "- Log: $launchStatusLog"
$report += ''
if ($regressionNote) { $report += '## Regression Warning'; $report += ''; $report += "- $regressionNote"; $report += '' }
$report += '## Results'
$report += $reportLines
$report += ''
$report += '## Summary'
$report += "- Pass: $pass"
$report += "- Fail: $fail"
Set-Content -Path $ReportPath -Value $report

Write-Host ''
Write-Host "Summary: $pass pass, $fail fail"
Write-Host ''
Write-Host 'AI handoff for next session' -ForegroundColor Yellow
Write-Host "- Continue from: $latestHandoffContinue"
Write-Host "- Next step: $latestHandoffNext"
Write-Host "- Blockers: $latestHandoffBlockers"
Write-Host '- Resume command: powershell -ExecutionPolicy Bypass -File .\0.dev-matrix\resume-work.ps1'
if ($regressionNote) { Write-Host "WARNING: $regressionNote" -ForegroundColor Yellow }
if ($fail -gt 0) { exit 1 }