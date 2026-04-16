# Extract model lift at given model sensitivity

This function extracts the model lift (PPV/outcomeRate)

## Usage

``` r
getPredictionLift(
  connectionHandler,
  schema,
  plpTablePrefix = "plp_",
  modelDesignIds = NULL,
  performanceIds = NULL,
  sensitivity = 0.1
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

- modelDesignIds:

  (optional) restrict to the input modelDesignIds

- performanceIds:

  (optional) restrict to the input performanceIds

- sensitivity:

  (default 0.1) the lift at the threshold with the sensitivity closest
  to this value is return

## Value

Returns a data.frame with the columns: modelDesignId, performanceId,
evaluation, sensitivity, outcomeCount, positivePredictiveValue,
outcomeRate and lift.

## Details

Specify the connectionHandler, the resultDatabaseSettings and
(optionally) modelDesignIds or performanceIds to filter to

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

liftsAt0p15 <- getPredictionLift(
  connectionHandler = connectionHandler, 
  schema = 'main', 
  sensitivity = 0.15
)
```
