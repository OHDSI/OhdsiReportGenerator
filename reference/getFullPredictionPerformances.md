# Extract the model performances per evaluation

This function extracts the model performances per evaluation

## Usage

``` r
getFullPredictionPerformances(
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

- timeStamp the date/time when the analysis occurred

- performanceId the unique identifier for the performance

- modelDesignId the unique identifier for the model design

- modelType the type of classifier

- covariateName a summary name for the candidate covariates

- developmentDatabaseId the unique identifier for the database used to
  develop the model

- validationDatabaseId the unique identifier for the database used to
  validate the model

- developmentTargetId the unique cohort id for the development target
  population

- developmentTargetName the name for the development target population

- validationTargetId the id for the validation target population

- validationTargetName the name for the validation target population if
  different from development

- developmentOutcomeId the unique cohort id for the development outcome

- developmentOutcomeName the name for the development outcome

- validationOutcomeId the id for the validation outcome

- validationOutcomeName the name for the validation outcome if different
  from development

- developmentDatabase the name for the database used to develop the
  model

- validationDatabase the name for the database used to validate the
  model if different from development

- validationTarId the validation time at risk id

- validationTimeAtRisk the time at risk used when evaluating the model
  if different from development

- developmentTarId the development time at risk id

- developmentTimeAtRisk the time at risk used when developing the model

- evaluation The type of evaluation: Test/Train/CV/Validation

- populationSize the test/validation population size used to develop the
  model

- outcomeCount the test/validation outcome count used to develop the
  model

- AUROC the AUROC value for the model

- 95 lower AUROC: the lower bound of the 95 percent CI AUROC value for
  the model

- 95 upper AUROC: the upper bound of the 95 percent CI AUROC value for
  the model

- AUPRC the discrimination AUPRC value for the model

- brier score: the brier value for the model

- brier score scaled: the scaled brier value for the model

- Average Precision: the average precision value for the model

- Eavg the calibration average error e-statistic value for the model

- E90 the calibration 90 percent upper bound e-statistic value for the
  model

- Emax the calibration max error e-statistic value for the model

- calibrationInLarge mean prediction: the calibration in the large mean
  predicted risk value for the model

- calibrationInLarge observed risk: the calibration in the large mean
  observed risk value for the model

- calibrationInLarge intercept: the calibration in the large value
  intercept for the model

- weak calibration intercept: the weak calibration intercept for the
  model

- weak calibration gradient: the weak calibration gradient for the model

- Hosmer Lemeshow calibration intercept: the Hosmer Lemeshow calibration
  intercept for the model

- Hosmer Lemeshow calibration gradient: the Hosmer Lemeshow calibration
  gradient for the model

- ... Additional metrics that are added to PLP

## Details

Specify the connectionHandler, the resultDatabaseSettings and
(optionally) a modelDesignId and/or developmentDatabaseId to restrict
models to

## See also

Other Prediction:
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
[`getPredictionTargets()`](getPredictionTargets.md),
[`getPredictionTopPredictors()`](getPredictionTopPredictors.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

perf <- getFullPredictionPerformances(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
