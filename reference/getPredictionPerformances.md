# Extract the model performances

This function extracts the model performances

## Usage

``` r
getPredictionPerformances(
  connectionHandler,
  schema,
  plpTablePrefix = "plp_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  databaseTablePrefix = "",
  modelDesignId = NULL,
  developmentDatabaseId = NULL
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

- databaseTablePrefix:

  A prefix to the database table, either ” or 'plp\_'

- modelDesignId:

  The identifier for a model design to restrict results to

- developmentDatabaseId:

  The identifier for the development database to restrict results to

## Value

Returns a data.frame with the columns:

- performanceId the unique identifier for the performance

- modelDesignId the unique identifier for the model design

- modelType the type of classifier

- developmentDatabaseId the unique identifier for the database used to
  develop the model

- validationDatabaseId the unique identifier for the database used to
  validate the model

- developmentTargetId the unique cohort id for the development target
  population

- developmentTargetName the name for the development target population

- developmentOutcomeId the unique cohort id for the development outcome

- developmentOutcomeName the name for the development outcome

- developmentDatabase the name for the database used to develop the
  model

- validationDatabase the name for the database used to validate the
  model

- validationTargetName the name for the validation target population

- validationOutcomeName the name for the validation outcome

- timeStamp the date/time when the analysis occurred

- auroc the test/validation AUROC value for the model

- auroc95lb the test/validation lower bound of the 95 percent CI AUROC
  value for the model

- auroc95ub the test/validation upper bound of the 95 percent CI AUROC
  value for the model

- calibrationInLarge the test/validation calibration in the large value
  for the model

- eStatistic the test/validation calibration e-statistic value for the
  model

- brierScore the test/validation brier value for the model

- auprc the test/validation discrimination AUPRC value for the model

- populationSize the test/validation population size used to develop the
  model

- outcomeCount the test/validation outcome count used to develop the
  model

- evalPercent the percentage of the development data used as the test
  set

- outcomePercent the outcome percent in the development data

- validationTimeAtRisk time at risk for the validation

- predictionResultType development or validation

## Details

Specify the connectionHandler, the resultDatabaseSettings and
(optionally) a modelDesignId and/or developmentDatabaseId to restrict
models to

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
[`getPredictionTargets()`](getPredictionTargets.md),
[`getPredictionTopPredictors()`](getPredictionTopPredictors.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

perf <- getPredictionPerformances(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
