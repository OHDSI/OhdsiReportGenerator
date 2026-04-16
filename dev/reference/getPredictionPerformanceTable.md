# Extract specific results table

This function extracts the specified table

## Usage

``` r
getPredictionPerformanceTable(
  connectionHandler,
  schema,
  plpTablePrefix = "plp_",
  databaseTable = "database_meta_data",
  table = "attrition",
  modelDesignIds = NULL,
  performanceIds = NULL,
  evaluations = NULL
)
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- plpTablePrefix:

  The prefix used for the patient level prediction results tables

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- table:

  The table to extract (covariate_summary, attrition,
  prediction_distribution, threshold_summary, calibration_summary,
  evaluation_statistics or demographic_summary )

- modelDesignIds:

  (optional) restrict to the input modelDesignIds

- performanceIds:

  (optional) restrict to the input performanceIds

- evaluations:

  (optional) restrict to the type of evaluation (e.g.,
  'Test'/'Train'/'CV'/'Validation')

## Value

Returns a data.frame with the specified table

## Details

Specify the connectionHandler, the resultDatabaseSettings, the table of
interest and (optionally) a performanceId to filter to

## See also

Other Prediction:
[`getFullPredictionPerformances()`](getFullPredictionPerformances.md),
[`getPredictionAggregateTopPredictors()`](getPredictionAggregateTopPredictors.md),
[`getPredictionCohorts()`](getPredictionCohorts.md),
[`getPredictionCovariates()`](getPredictionCovariates.md),
[`getPredictionDiagnosticTable()`](getPredictionDiagnosticTable.md),
[`getPredictionDiagnostics()`](getPredictionDiagnostics.md),
[`getPredictionHyperParamSearch()`](getPredictionHyperParamSearch.md),
[`getPredictionIntercept()`](getPredictionIntercept.md),
[`getPredictionLift()`](getPredictionLift.md),
[`getPredictionModelDesigns()`](getPredictionModelDesigns.md),
[`getPredictionOutcomes()`](getPredictionOutcomes.md),
[`getPredictionPerformances()`](getPredictionPerformances.md),
[`getPredictionTargets()`](getPredictionTargets.md),
[`getPredictionTopPredictors()`](getPredictionTopPredictors.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

attrition <- getPredictionPerformanceTable(
  connectionHandler = connectionHandler, 
  schema = 'main',
  table = 'attrition'
)
```
