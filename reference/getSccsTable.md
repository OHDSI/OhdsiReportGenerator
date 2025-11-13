# Extract the SCCS table specified

This function extracts the specific cohort method table.

## Usage

``` r
getSccsTable(
  connectionHandler,
  schema,
  table = c("attrition", "time_trend", "event_dep_observation", "age_spanning",
    "calendar_time_spanning", "spline")[1],
  sccsTablePrefix = "sccs_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  indicationIds = NULL,
  outcomeIds = NULL,
  analysisIds = NULL,
  databaseIds = NULL,
  exposureOutcomeIds = NULL,
  covariateIds = NULL
)
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- table:

  The result table to extract

- sccsTablePrefix:

  The prefix used for the cohort generator results tables

- cgTablePrefix:

  The prefix used for the cohort generator results tables

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- indicationIds:

  The indications that the target was nested to

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

- analysisIds:

  the analysis IDs to restrict to

- databaseIds:

  the database IDs to restrict to

- exposureOutcomeIds:

  the exposureOutcomeIds to restrict to

- covariateIds:

  the covariateIds to restrict to

## Value

Returns a data.frame with the cohort method requested table

## Details

Specify the connectionHandler, the schema and optionally the
target/outcome/analysis/database IDs

## See also

Other Estimation: [`getCMEstimation()`](getCMEstimation.md),
[`getCmDiagnosticsData()`](getCmDiagnosticsData.md),
[`getCmMetaEstimation()`](getCmMetaEstimation.md),
[`getCmNegativeControlEstimates()`](getCmNegativeControlEstimates.md),
[`getCmOutcomes()`](getCmOutcomes.md),
[`getCmPropensityModel()`](getCmPropensityModel.md),
[`getCmTable()`](getCmTable.md), [`getCmTargets()`](getCmTargets.md),
[`getSccsDiagnosticsData()`](getSccsDiagnosticsData.md),
[`getSccsEstimation()`](getSccsEstimation.md),
[`getSccsMetaEstimation()`](getSccsMetaEstimation.md),
[`getSccsModel()`](getSccsModel.md),
[`getSccsNegativeControlEstimates()`](getSccsNegativeControlEstimates.md),
[`getSccsOutcomes()`](getSccsOutcomes.md),
[`getSccsTargets()`](getSccsTargets.md),
[`getSccsTimeToEvent()`](getSccsTimeToEvent.md),
[`plotCmEstimates()`](plotCmEstimates.md),
[`plotSccsEstimates()`](plotSccsEstimates.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

sccsTable <- getSccsTable(
  connectionHandler = connectionHandler, 
  schema = 'main',
  table = 'attrition'
)
```
