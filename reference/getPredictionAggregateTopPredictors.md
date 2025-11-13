# Extract the top N predictors across a set of models

This function extracts the top N predictors across models by finding the
sum of the absolute coefficient value across models.

## Usage

``` r
getPredictionAggregateTopPredictors(
  connectionHandler,
  schema,
  plpTablePrefix = "plp_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
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

- modelDesignIds:

  One or more model design IDs to restrict to

## Value

Returns a data.frame with the columns:

- databaseName the name of the database the model was developed on

- tarStartDay the time-at-risk start day

- tarStartAnchor whether the time-at-risk start is relative to cohort
  start or end

- tarEndDay the time-at-risk end day

- tarEndAnchor whether the time-at-risk end is relative to cohort start
  or end

- covariateId the FeatureExtraction covariate identifier

- covariateName the name of the covariate

- conceptId the covariates corresponding concept or 0

- sumCovariateValue the total absolute feature importance or coefficient
  value

- numberOfTimesPredictive number of models that contained the covariate

## Details

Specify the connectionHandler, the resultDatabaseSettings and
(optionally) any modelDesignIds to restrict to

## See also

Other Prediction:
[`getFullPredictionPerformances()`](getFullPredictionPerformances.md),
[`getPredictionCohorts()`](getPredictionCohorts.md),
[`getPredictionCovariates()`](getPredictionCovariates.md),
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

topPreds <- getPredictionAggregateTopPredictors(
  connectionHandler = connectionHandler, 
  schema = 'main',
  modelDesignIds = c(1,2,5)
)
```
