// ExcelReportPipeline — Power Query M Transform
// Version: 0.1.0
// Purpose: Data cleaning, normalization, and shaping for the report pipeline
//
// Parameters surfaced by the VBA orchestrator:
//   - SourcePath:     Full path to the source data file (CSV or Excel)
//   - WorksheetName:  Sheet name for Excel sources (optional)
//   - Delimiter:      Field delimiter for CSV sources (default comma)
//   - ConnectionString: Connection string for database sources (future)

let
    // Parameter declarations — values injected by VBA at runtime
    SourcePathParam = if SourcePath <> null then SourcePath else "",
    WorksheetNameParam = if WorksheetName <> null then WorksheetName else null,
    DelimiterParam = if Delimiter <> null then Delimiter else ",",
    ConnectionStringParam = if ConnectionString <> null then ConnectionString else null,

    // Step 1: Import from accepted source based on file extension
    Extension = Text.Lower(Text.AfterDelimiter(SourcePathParam, ".", {0, RelativePosition.FromEnd})),
    SourceType = if Extension = "csv" then "csv"
                 else if Extension = "xlsx" or Extension = "xlsm" or Extension = "xls" then "excel"
                 else null,

    RawData = if SourceType = "csv" then
                  Csv.Document(
                      File.Contents(SourcePathParam),
                      [Delimiter=DelimiterParam, Columns=null, Encoding=65001, QuoteStyle=QuoteStyle.Csv]
                  )
              else if SourceType = "excel" then
                  Excel.Workbook(
                      File.Contents(SourcePathParam),
                      null,
                      true
                  )
              else
                  error "Unsupported source type. Accepted: .csv, .xlsx, .xlsm, .xls",

    // Step 2: Promote headers (first row as column names)
    PromotedHeaders = if SourceType = "csv" then
                          Table.PromoteHeaders(RawData, [PromoteAllScalars=true])
                      else if SourceType = "excel" then
                          let
                              Sheet = if WorksheetNameParam <> null then
                                          RawData{[Item=WorksheetNameParam, Kind="Sheet"]}[Data]
                                      else
                                          RawData{[Kind="Sheet"]}[Data],
                              Promoted = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true])
                          in
                              Promoted
                      else
                          RawData,

    // Step 3: Remove completely blank rows
    NoBlanks = Table.SelectRows(PromotedHeaders, each not List.AllTrue(List.Transform(Record.FieldValues(_), each _ = null or _ = ""))),

    // Step 4: Normalize columns — trim whitespace, cast to text for safety
    ColumnNames = Table.ColumnNames(NoBlanks),
    NormalizedColumns = List.Transform(
        ColumnNames,
        each let
            col = _,
            typed = Table.TransformColumnTypes(NoBlanks, {{col, type text}}),
            trimmed = Table.TransformColumns(typed, {{col, Text.Trim, type text}})
        in
            trimmed
    ),

    // Step 5: Apply normalization (last transform in the chain)
    Normalized = List.Last(NormalizedColumns),

    // Step 6: Output as structured table for the Report sheet
    Output = Table.AddKey(Normalized, Table.ColumnNames(Normalized), false)
in
    Output
