# Extract the top N predictors per model

This function extracts the top N predictors per model from the
prediction results tables

## Usage

``` r
getPredictionTopPredictors(
  connectionHandler,
  schema,
  plpTablePrefix = "plp_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetIds = NULL,
  outcomeIds = NULL,
  numberPredictors = 100
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

  The database table name

- targetIds:

  A vector of integers corresponding to the target cohort IDs

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

- numberPredictors:

  the number of predictors per model to return

## Value

Returns a data.frame with the columns:

- databaseName the name of the database the model was developed on

- tarStartDay the time-at-risk start day

- tarStartAnchor whether the time-at-risk start is relative to cohort
  start or end

- tarEndDay the time-at-risk end day

- tarEndAnchor whether the time-at-risk end is relative to cohort start
  or end

- performanceId a unique identifier for the performance

- covariateId the FeatureExtraction covariate identifier

- covariateName the name of the covariate

- conceptId the covariates corresponding concept or 0

- covariateValue the feature importance or coefficient value

- covariateCount how many people had the covariate

- covariateMean the fraction of the target population with the covariate

- covariateStDev the standard deviation

- withNoOutcomeCovariateCount the number of the target population
  without the outcome with the covariate

- withNoOutcomeCovariateMean the fraction of the target population
  without the outcome with the covariate

- withNoOutcomeCovariateStDev the covariate standard deviation of the
  target population without the outcome

- withOutcomeCovariateCount the number of the target population with the
  outcome with the covariate

- withOutcomeCovariateMean the fraction of the target population with
  the outcome with the covariate

- withOutcomeCovariateStDev the covariate standard deviation of the
  target population with the outcome

- standardizedMeanDiff the standardized mean difference comparing the
  target population with outcome and without the outcome

- rn the row number showing the covariate rank

## Details

Specify the connectionHandler, the resultDatabaseSettings and
(optionally) any targetIds or outcomeIds to restrict models to

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
[`getPredictionPerformanceTable()`](getPredictionPerformanceTable.md),
[`getPredictionPerformances()`](getPredictionPerformances.md),
[`getPredictionTargets()`](getPredictionTargets.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

topPreds <- getPredictionTopPredictors(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1,
  outcomeIds = 3
)
```
