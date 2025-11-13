# Extract hyper parameters details

This function extracts the hyper parameters details

## Usage

``` r
getPredictionHyperParamSearch(
  connectionHandler,
  schema,
  plpTablePrefix = "plp_",
  modelDesignId = NULL,
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

- plpTablePrefix:

  The prefix used for the patient level prediction results tables

- modelDesignId:

  The identifier for a model design to restrict to

- databaseId:

  The identifier for the development database to restrict to

## Value

Returns a data.frame with the columns:

- metric the hyperparameter optimization metric

- fold the fold in cross validation

- value the metric value for the fold with the specified hyperparameter
  combination

plus columns for all the hyperparameters and their values

## Details

Specify the connectionHandler, the resultDatabaseSettings, the
modelDesignId and the databaseId

## See also

Other Prediction:
[`getFullPredictionPerformances()`](getFullPredictionPerformances.md),
[`getPredictionAggregateTopPredictors()`](getPredictionAggregateTopPredictors.md),
[`getPredictionCohorts()`](getPredictionCohorts.md),
[`getPredictionCovariates()`](getPredictionCovariates.md),
[`getPredictionDiagnosticTable()`](getPredictionDiagnosticTable.md),
[`getPredictionDiagnostics()`](getPredictionDiagnostics.md),
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

hyperParams <- getPredictionHyperParamSearch(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
#> Warning: Please enter a modelDesignId and databaseId
```
