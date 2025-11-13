# createPredictionReport

Generates a report for a given prediction model design

## Usage

``` r
createPredictionReport(
  connectionHandler,
  schema,
  plpTablePrefix,
  databaseTablePrefix = plpTablePrefix,
  cgTablePrefix = plpTablePrefix,
  modelDesignId,
  output,
  intermediatesDir = file.path(tempdir(), "plp-prot"),
  outputFormat = "html_document"
)
```

## Arguments

- connectionHandler:

  The connection handler to the results database

- schema:

  The result database schema

- plpTablePrefix:

  The prediction table prefix

- databaseTablePrefix:

  The database table name e.g., database_meta_data

- cgTablePrefix:

  The cohort generator table prefix

- modelDesignId:

  The model design ID of interest

- output:

  The folder name where main.html will be save to

- intermediatesDir:

  The work directory for rmarkdown

- outputFormat:

  the type of outcome html_document or html_fragment

## Value

An named R list with the elements 'standard' and 'source'

## Details

Specify the connection handler to the result database, the schema name
and the modelDesignId of interest to generate a html report summarizing
the performance of models developed across databases.

## See also

Other Reporting: [`generateFullReport()`](generateFullReport.md),
[`generatePresentation()`](generatePresentation.md),
[`generatePresentationMultiple()`](generatePresentationMultiple.md),
[`generateSummaryPredictionReport()`](generateSummaryPredictionReport.md)
