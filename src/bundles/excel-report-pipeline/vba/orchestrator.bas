Attribute VB_Name = "Orchestrator"
Option Explicit

' ExcelReportPipeline — VBA Orchestrator
' Version: 0.1.0
' Purpose: Runtime orchestration for the report pipeline
'   - Resolve input source at runtime
'   - Invoke Power Query refresh
'   - Apply post-processing (freeze panes, print area, named ranges)
'   - Trigger output generation and optional distribution

Private Const MODULE_NAME As String = "ExcelReportPipeline.Orchestrator"
Private Const DEFAULT_OUTPUT_DIR As String = "data/output"
Private Const LOG_DIR As String = "data/logs"

Private Type PipelineConfig
    SourcePath As String
    SourceType As String
    ReportDate As String
    OutputFormat As String
    DistributionTarget As String
    OutputDir As String
    LogPath As String
End Type

Public Function RunPipeline(ByVal SourcePath As String, _
                            Optional ByVal ReportDate As String = "", _
                            Optional ByVal OutputFormat As String = "xlsx", _
                            Optional ByVal DistributionTarget As String = "local") As Boolean

    Dim Config As PipelineConfig
    Dim result As Boolean

    On Error GoTo ErrorHandler

    Config = BuildConfig(SourcePath, ReportDate, OutputFormat, DistributionTarget)

    If Not PreFlightCheck(Config) Then
        LogEvent Config.LogPath, "PREFLIGHT_FAILED", "Pre-flight validation failed"
        RunPipeline = False
        Exit Function
    End If

    LogEvent Config.LogPath, "PIPELINE_START", "Starting pipeline for " & Config.SourcePath

    If Not ImportSource(Config) Then
        LogEvent Config.LogPath, "IMPORT_FAILED", "Failed to import source data"
        RunPipeline = False
        Exit Function
    End If

    RefreshQueries

    If Not PostProcess(Config) Then
        LogEvent Config.LogPath, "POSTPROCESS_FAILED", "Post-processing failed"
        RunPipeline = False
        Exit Function
    End If

    If Not SaveOutput(Config) Then
        LogEvent Config.LogPath, "SAVE_FAILED", "Failed to save output"
        RunPipeline = False
        Exit Function
    End If

    If Not PostFlightCheck(Config) Then
        LogEvent Config.LogPath, "POSTFLIGHT_FAILED", "Post-flight validation failed"
        RunPipeline = False
        Exit Function
    End If

    If DistributionTarget <> "local" Then
        DistributeOutput Config
    End If

    LogEvent Config.LogPath, "PIPELINE_COMPLETE", "Pipeline completed successfully"
    RunPipeline = True
    Exit Function

ErrorHandler:
    LogEvent Config.LogPath, "PIPELINE_ERROR", Err.Description & " (Error " & Err.Number & ")"
    RunPipeline = False
End Function

Private Function BuildConfig(ByVal SourcePath As String, _
                             ByVal ReportDate As String, _
                             ByVal OutputFormat As String, _
                             ByVal DistributionTarget As String) As PipelineConfig

    Dim Config As PipelineConfig

    If ReportDate = "" Then
        ReportDate = Format(Now, "yyyy-mm-dd")
    End If

    Config.SourcePath = SourcePath
    Config.ReportDate = ReportDate
    Config.OutputFormat = OutputFormat
    Config.DistributionTarget = DistributionTarget

    Config.SourceType = DetermineSourceType(SourcePath)
    Config.OutputDir = GetOutputDir()
    Config.LogPath = GetLogPath(ReportDate)

    BuildConfig = Config
End Function

Private Function DetermineSourceType(ByVal FilePath As String) As String
    Dim ext As String
    ext = LCase(Right(FilePath, Len(FilePath) - InStrRev(FilePath, ".")))

    Select Case ext
        Case "csv"
            DetermineSourceType = "csv"
        Case "xlsx", "xlsm", "xls"
            DetermineSourceType = "excelWorkbook"
        Case Else
            DetermineSourceType = "unknown"
    End Select
End Function

Private Function GetOutputDir() As String
    Dim dir As String
    dir = ThisWorkbook.Path & Application.PathSeparator & DEFAULT_OUTPUT_DIR
    If Dir(dir, vbDirectory) = "" Then
        MkDir dir
    End If
    GetOutputDir = dir
End Function

Private Function GetLogPath(ByVal ReportDate As String) As String
    Dim logDir As String
    Dim logFile As String

    logDir = ThisWorkbook.Path & Application.PathSeparator & LOG_DIR
    If Dir(logDir, vbDirectory) = "" Then
        MkDir logDir
    End If

    logFile = "ExcelReportPipeline_" & ReportDate & ".log"
    GetLogPath = logDir & Application.PathSeparator & logFile
End Function

Private Function PreFlightCheck(ByRef Config As PipelineConfig) As Boolean

    If Dir(Config.SourcePath) = "" Then
        LogEvent Config.LogPath, "PREFLIGHT_FAIL", "Source file not found: " & Config.SourcePath
        PreFlightCheck = False
        Exit Function
    End If

    If FileLen(Config.SourcePath) = 0 Then
        LogEvent Config.LogPath, "PREFLIGHT_FAIL", "Source file is empty"
        PreFlightCheck = False
        Exit Function
    End If

    Dim outputDir As String
    outputDir = Config.OutputDir
    If Right(outputDir, 1) <> Application.PathSeparator Then
        outputDir = outputDir & Application.PathSeparator
    End If

    Dim testFile As String
    testFile = outputDir & "test_write.tmp"
    On Error Resume Next
    Open testFile For Output As #1
    If Err.Number <> 0 Then
        LogEvent Config.LogPath, "PREFLIGHT_FAIL", "Output directory not writable: " & Config.OutputDir
        PreFlightCheck = False
        Exit Function
    End If
    Close #1
    Kill testFile
    On Error GoTo 0

    PreFlightCheck = True
End Function

Private Function ImportSource(ByRef Config As PipelineConfig) As Boolean

    On Error GoTo ImportError

    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Data")

    ws.Cells.Clear

    Select Case Config.SourceType
        Case "csv"
            Dim qConn As Object
            Set qConn = ws.QueryTables.Add( _
                Connection:="TEXT;" & Config.SourcePath, _
                Destination:=ws.Range("A1"))

            With qConn
                .Name = "Import_" & Config.ReportDate
                .TextFilePlatform = 65001
                .TextFileStartRow = 1
                .TextFileParseType = xlDelimited
                .TextFileTextQualifier = xlTextQualifierDoubleQuote
                .TextFileConsecutiveDelimiter = False
                .TextFileCommaDelimiter = True
                .Refresh BackgroundQuery:=False
            End With

        Case "excelWorkbook"
            Dim srcWb As Workbook
            Set srcWb = Workbooks.Open(Config.SourcePath)
            srcWb.Sheets(1).UsedRange.Copy Destination:=ws.Range("A1")
            srcWb.Close SaveChanges:=False

        Case Else
            LogEvent Config.LogPath, "IMPORT_FAIL", "Unknown source type: " & Config.SourceType
            ImportSource = False
            Exit Function
    End Select

    LogEvent Config.LogPath, "IMPORT_OK", "Imported " & ws.UsedRange.Rows.Count - 1 & " data rows from " & Config.SourcePath
    ImportSource = True
    Exit Function

ImportError:
    LogEvent Config.LogPath, "IMPORT_ERROR", Err.Description
    ImportSource = False
End Function

Private Sub RefreshQueries()
    ThisWorkbook.RefreshAll
End Sub

Private Function PostProcess(ByRef Config As PipelineConfig) As Boolean

    On Error GoTo PostProcessError

    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Report")

    If ws.UsedRange.Rows.Count > 1 Then
        ws.Activate
        ws.Range("A2").Select
        ActiveWindow.FreezePanes = True
    End If

    If ws.UsedRange.Rows.Count > 1 And ws.UsedRange.Columns.Count > 1 Then
        ws.PageSetup.PrintArea = ws.UsedRange.Address
    End If

    ThisWorkbook.Names.Add Name:="ReportData", RefersTo:="=" & ws.UsedRange.Address
    ThisWorkbook.Names.Add Name:="ReportTitle", RefersTo:="=Report!A1"
    ThisWorkbook.Names.Add Name:="ReportDate", RefersTo:="=""" & Config.ReportDate & """"

    PostProcess = True
    Exit Function

PostProcessError:
    LogEvent Config.LogPath, "POSTPROCESS_ERROR", Err.Description
    PostProcess = False
End Function

Private Function SaveOutput(ByRef Config As PipelineConfig) As Boolean

    On Error GoTo SaveError

    Dim outputFile As String
    outputFile = Config.OutputDir & Application.PathSeparator & _
                 "ExcelReportPipeline_" & Config.ReportDate & "_v0.1.0." & Config.OutputFormat

    Dim fileFormat As XlFileFormat
    Select Case LCase(Config.OutputFormat)
        Case "xlsx"
            fileFormat = xlOpenXMLWorkbook
        Case "xlsm"
            fileFormat = xlOpenXMLWorkbookMacroEnabled
        Case "pdf"
            fileFormat = xlTypePDF
        Case Else
            fileFormat = xlOpenXMLWorkbook
    End Select

    ThisWorkbook.SaveCopyAs outputFile

    LogEvent Config.LogPath, "SAVE_OK", "Output saved to " & outputFile
    SaveOutput = True
    Exit Function

SaveError:
    LogEvent Config.LogPath, "SAVE_ERROR", Err.Description
    SaveOutput = False
End Function

Private Function PostFlightCheck(ByRef Config As PipelineConfig) As Boolean

    Dim outputFile As String
    outputFile = Config.OutputDir & Application.PathSeparator & _
                 "ExcelReportPipeline_" & Config.ReportDate & "_v0.1.0." & Config.OutputFormat

    If Dir(outputFile) = "" Then
        LogEvent Config.LogPath, "POSTFLIGHT_FAIL", "Output file not found: " & outputFile
        PostFlightCheck = False
        Exit Function
    End If

    If FileLen(outputFile) = 0 Then
        LogEvent Config.LogPath, "POSTFLIGHT_FAIL", "Output file is empty"
        PostFlightCheck = False
        Exit Function
    End If

    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Report")
    If ws.UsedRange.Rows.Count < 2 Then
        LogEvent Config.LogPath, "POSTFLIGHT_WARN", "Report sheet has no data rows"
    End If

    On Error Resume Next
    Dim nm As Name
    Set nm = ThisWorkbook.Names("ReportData")
    If Err.Number <> 0 Then
        LogEvent Config.LogPath, "POSTFLIGHT_FAIL", "Named range ReportData missing"
        PostFlightCheck = False
        Exit Function
    End If
    Set nm = ThisWorkbook.Names("ReportTitle")
    If Err.Number <> 0 Then
        LogEvent Config.LogPath, "POSTFLIGHT_FAIL", "Named range ReportTitle missing"
        PostFlightCheck = False
        Exit Function
    End If
    Set nm = ThisWorkbook.Names("ReportDate")
    If Err.Number <> 0 Then
        LogEvent Config.LogPath, "POSTFLIGHT_FAIL", "Named range ReportDate missing"
        PostFlightCheck = False
        Exit Function
    End If
    On Error GoTo 0

    LogEvent Config.LogPath, "POSTFLIGHT_OK", "All post-flight checks passed"
    PostFlightCheck = True
End Function

Private Sub DistributeOutput(ByRef Config As PipelineConfig)

    Dim outputFile As String
    outputFile = Config.OutputDir & Application.PathSeparator & _
                 "ExcelReportPipeline_" & Config.ReportDate & "_v0.1.0." & Config.OutputFormat

    Select Case LCase(Config.DistributionTarget)
        Case "email"
            SendViaOutlook outputFile, Config.ReportDate
        Case "sharepoint"
            LogEvent Config.LogPath, "DISTRIBUTE_SKIP", "SharePoint distribution not yet implemented"
        Case Else
            LogEvent Config.LogPath, "DISTRIBUTE_LOCAL", "Output available at " & outputFile
    End Select
End Sub

Private Sub SendViaOutlook(ByVal FilePath As String, ByVal ReportDate As String)

    On Error GoTo OutlookError

    Dim olApp As Object
    Dim olMail As Object

    Set olApp = CreateObject("Outlook.Application")
    Set olMail = olApp.CreateItem(0)

    With olMail
        .Subject = "ExcelReportPipeline Report " & ReportDate
        .Body = "Attached is the automated report for " & ReportDate & "."
        .Attachments.Add FilePath
        .Send
    End With

    LogEvent GetLogPath(ReportDate), "EMAIL_SENT", "Report sent via Outlook"
    Exit Sub

OutlookError:
    LogEvent GetLogPath(ReportDate), "EMAIL_ERROR", "Outlook send failed: " & Err.Description
End Sub

Public Sub LogEvent(ByVal LogPath As String, ByVal Level As String, ByVal Message As String)
    On Error Resume Next
    Dim fh As Integer
    fh = FreeFile
    Open LogPath For Append As #fh
    Print #fh, Format(Now, "yyyy-mm-dd HH:MM:SS") & " [" & Level & "] " & Message
    Close #fh
End Sub
