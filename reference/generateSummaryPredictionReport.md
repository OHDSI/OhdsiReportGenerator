# generateSummaryPredictionReport

Generates a summary report for a given targets and outcomes

## Usage

``` r
generateSummaryPredictionReport(
  connectionHandler,
  schema,
  targetIds = NULL,
  outcomeIds = NULL,
  plpTablePrefix = "plp_",
  databaseTablePrefix = "",
  cgTablePrefix = "cg_",
  outputFolder,
  outputFileName = "plp-summary.html",
  intermediatesDir = file.path(tempdir(), "plp-prot"),
  overwrite = FALSE
)
```

## Arguments

- connectionHandler:

  The connection handler to the results database

- schema:

  The result database schema

- targetIds:

  The target cohort IDs of interest

- outcomeIds:

  The outcome cohort IDs of interest

- plpTablePrefix:

  The prediction table prefix

- databaseTablePrefix:

  The database table name e.g., database_meta_data

- cgTablePrefix:

  The cohort generator table prefix

- outputFolder:

  The folder name where file will be save to

- outputFileName:

  The file name of the saved report

- intermediatesDir:

  The work directory for rmarkdown

- overwrite:

  whether to overwrite any existing file at the
  outputFolder/outputFileName

## Value

A html file is created with the summary report

## Details

Specify the connection handler to the result database, the schema name
and the cohortId of interest to generate a html report summarizing the
performance of prediction models in the database.

## See also

Other Reporting:
[`createPredictionReport()`](createPredictionReport.md),
[`generateFullReport()`](generateFullReport.md),
[`generatePresentation()`](generatePresentation.md),
[`generatePresentationMultiple()`](generatePresentationMultiple.md)
