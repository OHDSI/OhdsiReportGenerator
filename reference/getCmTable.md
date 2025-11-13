# Extract the cohort method table specified

This function extracts the specific cohort method table.

## Usage

``` r
getCmTable(
  connectionHandler,
  schema,
  table = c("attrition", "follow_up_dist", "interaction_result", "covariate_balance",
    "kaplan_meier_dist", "likelihood_profile", "preference_score_dist",
    "propensity_model", "shared_covariate_balance")[1],
  cmTablePrefix = "cm_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetIds = NULL,
  outcomeIds = NULL,
  comparatorIds = NULL,
  analysisIds = NULL,
  databaseIds = NULL
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

- cmTablePrefix:

  The prefix used for the cohort method results tables

- cgTablePrefix:

  The prefix used for the cohort generator results tables

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- targetIds:

  A vector of integers corresponding to the target cohort IDs

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

- comparatorIds:

  A vector of integers corresponding to the comparator cohort IDs

- analysisIds:

  the analysis IDs to restrict to

- databaseIds:

  the database IDs to restrict to

## Value

Returns a data.frame with the cohort method requested table

## Details

Specify the connectionHandler, the schema and optionally the
target/comparator/outcome/analysis/database IDs

## See also

Other Estimation: [`getCMEstimation()`](getCMEstimation.md),
[`getCmDiagnosticsData()`](getCmDiagnosticsData.md),
[`getCmMetaEstimation()`](getCmMetaEstimation.md),
[`getCmNegativeControlEstimates()`](getCmNegativeControlEstimates.md),
[`getCmOutcomes()`](getCmOutcomes.md),
[`getCmPropensityModel()`](getCmPropensityModel.md),
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

cmTable <- getCmTable(
  connectionHandler = connectionHandler, 
  schema = 'main',
  table = 'attrition'
)
```
