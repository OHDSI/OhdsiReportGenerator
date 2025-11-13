# Extract the cohort method model

This function extracts the cohort method model.

## Usage

``` r
getCmPropensityModel(
  connectionHandler,
  schema,
  cmTablePrefix = "cm_",
  targetId = NULL,
  comparatorId = NULL,
  analysisId = NULL,
  databaseId = NULL
)
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- cmTablePrefix:

  The prefix used for the cohort method results tables

- targetId:

  An integer corresponding to the target cohort ID

- comparatorId:

  the comparator ID of interest

- analysisId:

  the analysis ID to restrict to

- databaseId:

  the database ID to restrict to

## Value

Returns a data.frame with the cohort method model

## Details

Specify the connectionHandler, the schema and optionally the
target/comparator/analysis/database IDs

## See also

Other Estimation: [`getCMEstimation()`](getCMEstimation.md),
[`getCmDiagnosticsData()`](getCmDiagnosticsData.md),
[`getCmMetaEstimation()`](getCmMetaEstimation.md),
[`getCmNegativeControlEstimates()`](getCmNegativeControlEstimates.md),
[`getCmOutcomes()`](getCmOutcomes.md), [`getCmTable()`](getCmTable.md),
[`getCmTargets()`](getCmTargets.md),
[`getSccsDiagnosticsData()`](getSccsDiagnosticsData.md),
[`getSccsEstimation()`](getSccsEstimation.md),
[`getSccsMetaEstimation()`](getSccsMetaEstimation.md),
[`getSccsModel()`](getSccsModel.md),
[`getSccsNegativeControlEstimates()`](getSccsNegativeControlEstimates.md),
[`getSccsOutcomes()`](getSccsOutcomes.md),
[`getSccsTable()`](getSccsTable.md),
[`getSccsTargets()`](getSccsTargets.md),
[`getSccsTimeToEvent()`](getSccsTimeToEvent.md),
[`plotCmEstimates()`](plotCmEstimates.md),
[`plotSccsEstimates()`](plotSccsEstimates.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cmModel <- getCmPropensityModel(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
#> Please specify targetId
```
