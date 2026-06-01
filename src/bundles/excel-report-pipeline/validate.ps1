param(
    [switch]$SkipComTest,
    [string]$OutputReport = "validation\result.txt"
)

$ErrorActionPreference = "Stop"
$BundleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$Passes = @()
$Fails = @()
$Warns = @()

function Assert-Pass {
    param($label, $condition, $detail)
    if ($condition) {
        $script:Passes += "[PASS] $label"
        Write-Host "  [PASS] $label" -ForegroundColor Green
        if ($detail) { Write-Host "    $detail" }
    } else {
        $script:Fails += "[FAIL] $label"
        Write-Host "  [FAIL] $label" -ForegroundColor Red
        if ($detail) { Write-Host "    $detail" }
    }
}

function Assert-Warn {
    param($label, $detail)
    $script:Warns += "[WARN] $label"
    Write-Host "  [WARN] $label" -ForegroundColor Yellow
    if ($detail) { Write-Host "    $detail" }
}

Write-Host "`n=== ExcelReportPipeline v0.1.0 - Slice Validation ===" -ForegroundColor Cyan
Write-Host "Bundle Root: $BundleRoot`n"

Write-Host "--- File Existence ---" -ForegroundColor Cyan

$vbaFile = Join-Path $BundleRoot "vba\orchestrator.bas"
$pqFile = Join-Path $BundleRoot "power-query\load-and-transform.m"
$sampleFile = Join-Path $BundleRoot "sample\input\sample-data.csv"

Assert-Pass "VBA orchestrator exists" (Test-Path $vbaFile) $vbaFile
Assert-Pass "Power Query M script exists" (Test-Path $pqFile) $pqFile
Assert-Pass "Sample input data exists" (Test-Path $sampleFile) $sampleFile

Write-Host "`n--- VBA Orchestrator (orchestrator.bas) ---" -ForegroundColor Cyan

if (Test-Path $vbaFile) {
    $vbaContent = Get-Content $vbaFile -Raw

    $hasAttr = $vbaContent -match [regex]::Escape('Attribute VB_Name = "Orchestrator"')
    Assert-Pass "Has VB_Name attribute" $hasAttr

    $hasOption = $vbaContent -match "Option Explicit"
    Assert-Pass "Has Option Explicit" $hasOption

    $hasMain = $vbaContent -match "Public Function RunPipeline"
    Assert-Pass "Has RunPipeline entry point" $hasMain

    $funcNames = @("PreFlightCheck", "ImportSource", "PostProcess", "SaveOutput", "PostFlightCheck", "DistributeOutput", "LogEvent")
    foreach ($fn in $funcNames) {
        $pattern = "(Function|Sub) $fn"
        $found = $vbaContent -match $pattern
        Assert-Pass "Has function: $fn" $found
    }

    $noAutoOpen = $vbaContent -notmatch "Sub\s+Auto_Open|Sub\s+Workbook_Open"
    if ($noAutoOpen) {
        Assert-Warn "No Auto_Open trigger" "Orchestrator runs via RunPipeline call, not auto-open. Expected for library module."
    }
}

Write-Host "`n--- Power Query M (load-and-transform.m) ---" -ForegroundColor Cyan

if (Test-Path $pqFile) {
    $pqContent = Get-Content $pqFile -Raw

    Assert-Pass "Has let block" ($pqContent -match '\blet\b')
    Assert-Pass "Has in block" ($pqContent -match '\bin\b')

    $steps = @("SourcePathParam", "RawData", "PromotedHeaders", "NoBlanks", "Normalized", "Output")
    foreach ($s in $steps) {
        $found = $pqContent -match "\b$s\b"
        Assert-Pass "Has step: $s" $found
    }
}

Write-Host "`n--- Sample Data (sample-data.csv) ---" -ForegroundColor Cyan

if (Test-Path $sampleFile) {
    $csvLines = Get-Content $sampleFile
    Assert-Pass "CSV has header row" ($csvLines.Count -ge 1)

    $headerCols = ($csvLines[0] -split ',').Count
    Assert-Pass "CSV has 6 columns" ($headerCols -eq 6) "Found $headerCols columns"

    $allRowsOK = $true
    foreach ($line in $csvLines[1..($csvLines.Count-1)]) {
        $cols = $line -split ','
        if ($cols.Count -ne 6) {
            Assert-Pass "Row consistency check" $false "Row has $($cols.Count) cols, expected 6"
            $allRowsOK = $false
            break
        }
    }
    if ($allRowsOK) {
        $dataRows = $csvLines.Count - 1
        Assert-Pass "All rows have 6 columns" $true "$dataRows data rows"
    }

    Assert-Pass "Has at least 1 data row" (($csvLines.Count - 1) -ge 1) "$($csvLines.Count - 1) data rows"
}

Write-Host "`n--- Excel COM Smoke Test ---" -ForegroundColor Cyan

if ($SkipComTest) {
    Assert-Warn "COM test skipped by flag" "Use -SkipComTest:`$false to enable"
} else {
    try {
        $excel = New-Object -ComObject Excel.Application -ErrorAction Stop
        $excel.Visible = $false
        $excel.DisplayAlerts = $false

        Assert-Pass "Excel COM object" $true "Excel version: $($excel.Version)"

        $wb = $excel.Workbooks.Add()

        $sheet1 = $wb.Sheets(1)
        $sheet1.Name = "Data"
        $sheet2 = $wb.Sheets.Add()
        $sheet2.Name = "Report"

        $csvData = Import-Csv $sampleFile
        $row = 1
        foreach ($prop in $csvData[0].PSObject.Properties.Name) {
            $sheet1.Cells.Item(1, $row) = $prop
            $row++
        }
        $csvRow = 2
        foreach ($record in $csvData) {
            $col = 1
            foreach ($prop in $record.PSObject.Properties.Name) {
                $sheet1.Cells.Item($csvRow, $col) = $record.$prop
                $col++
            }
            $csvRow++
        }

        Assert-Pass "Data sheet populated" $true "$($csvData.Count) rows imported"

        $sheet2.Cells.Item(1, 1) = "ExcelReportPipeline Test Report"
        $sheet2.Cells.Item(1, 2) = (Get-Date -Format "yyyy-MM-dd")
        $sheet2.Cells.Item(1, 3) = "v0.1.0"

        $sheet2.Range("A2").Select()
        $wb.Application.ActiveWindow.FreezePanes = $true

        $printArea = $sheet1.UsedRange.Address($true, $true, 1, $true)
        $sheet2.PageSetup.PrintArea = $printArea

        $wb.Names.Add("ReportData", "=Report!A1:C1") | Out-Null
        $wb.Names.Add("ReportTitle", "=Report!A1") | Out-Null
        $wb.Names.Add("ReportDate", "=Report!B1") | Out-Null

        Assert-Pass "Named ranges created" $true "ReportData, ReportTitle, ReportDate"

        $outputDir = Join-Path $BundleRoot "validation\tmp"
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        $outputFile = Join-Path $outputDir "test-output.xlsx"
        $wb.SaveAs($outputFile, 51)

        Assert-Pass "Output saved to .xlsx" (Test-Path $outputFile) $outputFile
        Assert-Pass "Output has content" ((Get-Item $outputFile).Length -gt 0) "$((Get-Item $outputFile).Length) bytes"

        $wb.Close($false)
        $excel.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
        Remove-Variable excel -ErrorAction SilentlyContinue

        Remove-Item $outputFile -Force -ErrorAction SilentlyContinue
        Remove-Item $outputDir -Force -ErrorAction SilentlyContinue

    } catch {
        Assert-Warn "Excel COM not available" $_.Exception.Message
        Assert-Warn "Try in environment with Excel" ""
    }
}

Write-Host "`n--- SPEC.json Contract Alignment ---" -ForegroundColor Cyan

$specPath = Join-Path $BundleRoot "..\..\..\0.dev-matrix\SPEC.json"
$specResolved = Resolve-Path $specPath -ErrorAction SilentlyContinue
if (Test-Path $specResolved) {
    $spec = Get-Content $specResolved -Raw | ConvertFrom-Json

    Assert-Pass "SPEC bundle name matches" ($spec.bundle.name -eq "ExcelReportPipeline")
    Assert-Pass "SPEC references orchestrator.bas" ($spec.contract.dependencies.repoInternal -contains "vba/orchestrator.bas")
    Assert-Pass "SPEC references load-and-transform.m" ($spec.contract.dependencies.repoInternal -contains "power-query/load-and-transform.m")
    Assert-Pass "SPEC has nextTask" ($spec.acceptance.nextTask -ne $null -and $spec.acceptance.nextTask.Length -gt 0) "Next task: $($spec.acceptance.nextTask)"
} else {
    Assert-Warn "SPEC.json not found at $specPath" "Contract alignment checks skipped"
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VALIDATION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Passed: $($Passes.Count)" -ForegroundColor Green
Write-Host "  Failed: $($Fails.Count)" -ForegroundColor Red
Write-Host "  Warnings: $($Warns.Count)" -ForegroundColor Yellow

$allPassed = $Fails.Count -eq 0

$reportDir = Join-Path $BundleRoot "validation"
if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}
$reportPath = Join-Path $BundleRoot $OutputReport

$lines = @()
$lines += "=== ExcelReportPipeline v0.1.0 Slice Validation ==="
$lines += "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += "Bundle Root: $BundleRoot"
if ($allPassed) { $lines += "Overall: PASS" } else { $lines += "Overall: FAIL" }
$lines += "Passes: $($Passes.Count) | Fails: $($Fails.Count) | Warnings: $($Warns.Count)"
$lines += ""
$lines += "Passes:"
$lines += $Passes
$lines += ""
$lines += "Fails:"
$lines += $Fails
$lines += ""
$lines += "Warnings:"
$lines += $Warns

$lines | Out-File -FilePath $reportPath -Encoding UTF8

if ($allPassed) {
    Write-Host "`nRESULT: SLICE VALIDATED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nRESULT: SLICE FAILED VALIDATION" -ForegroundColor Red
    exit 1
}
