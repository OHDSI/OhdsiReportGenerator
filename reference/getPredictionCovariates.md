# Extract covariate summary details

This function extracts the covariate summary details

## Usage

``` r
getPredictionCovariates(
  connectionHandler,
  schema,
  plpTablePrefix = "plp_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  performanceIds = NULL,
  modelDesignIds = NULL
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

- cgTablePrefix:

  The prefix used for the cohort generator results tables

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- performanceIds:

  (optional) restrict to the input performanceIds

- modelDesignIds:

  (optional) restrict to the input modelDesignIds

## Value

Returns a data.frame with the specified table

## Details

Specify the connectionHandler, the resultDatabaseSettings, the table of
interest and (optionally) modelDesignIds/performanceIds to filter to

## See also

Other Prediction:
[`getFullPredictionPerformances()`](getFullPredictionPerformances.md),
[`getPredictionAggregateTopPredictors()`](getPredictionAggregateTopPredictors.md),
[`getPredictionCohorts()`](getPredictionCohorts.md),
[`getPredictionDiagnosticTable()`](getPredictionDiagnosticTable.md),
[`getPredictionDiagnostics()`](getPredictionDiagnostics.md),
[`getPredictionHyperParamSearch()`](getPredictionHyperParamSearch.md),
[`getPredictionIntercept()`](getPredictionIntercept.md),
[`getPredictionLift()`](getPredictionLift.md),
[`getPredictionModelDesigns()`](getPredictionModelDesigns.md),
[`getPredictionOutcomes()`](getPredictionOutcomes.md),
[`getPredictionPerformanceTable()`](getPredictionPerformanceTable.md),
[`getPredictionPerformances()`](getPredictionPerformances.md),
[`getPredictionTargets()`](getPredictionTargets.md),
[`getPredictionTopPredictors()`](getPredictionTopPredictors.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

covs <- getPredictionCovariates(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
