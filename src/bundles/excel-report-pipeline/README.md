# ExcelReportPipeline v0.1.0

First reusable automation bundle for Office_Scripts. Automates recurring business-report production:

**raw data import → Power Query transform → VBA orchestration → formatted Excel report → optional email distribution**

## Structure

```
excel-report-pipeline/
├── vba/
│   └── orchestrator.bas          VBA module: runtime orchestration
├── power-query/
│   └── load-and-transform.m      Power Query M script: data shaping
├── sample/
│   └── input/
│       └── sample-data.csv       Sample 12-row sales dataset
├── validation/
│   └── result.txt                Last validation report (auto-generated)
├── validate.ps1                  PowerShell slice validation runner
└── README.md                     This file
```

## Usage

### VBA Orchestrator

Import `vba/orchestrator.bas` into an Excel workbook with "Data" and "Report" sheets, then call:

```vba
Dim result As Boolean
result = Orchestrator.RunPipeline("C:\path\to\data.csv", "2026-05-31", "xlsx", "local")
```

Parameters:
- `SourcePath` — full path to CSV or Excel source file
- `ReportDate` — date string (defaults to today if empty)
- `OutputFormat` — `xlsx`, `xlsm`, or `pdf`
- `DistributionTarget` — `local`, `email` (Outlook), or `sharepoint` (future)

### Power Query M

`power-query/load-and-transform.m` is loaded into Excel's Power Query editor. It accepts four parameters via VBA injection:
- `SourcePath`, `WorksheetName`, `Delimiter`, `ConnectionString`

### Validation

Run the slice validator from PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\src\bundles\excel-report-pipeline\validate.ps1
```

Use `-SkipComTest` to skip the Excel COM automation smoke test:

```powershell
powershell -ExecutionPolicy Bypass -File .\src\bundles\excel-report-pipeline\validate.ps1 -SkipComTest
```

## Contract

This bundle implements the `ExcelReportPipeline` contract defined in `0.dev-matrix/SPEC.json`. See that file for the full input/transform/output/distribution/validation contract.

## Dependencies

- Office 2016 or Microsoft 365 with Excel and Power Query (Get & Transform)
- Outlook required for email distribution only
- No external libraries required
