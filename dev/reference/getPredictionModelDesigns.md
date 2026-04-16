# Extract the model designs from the prediction results

This function extracts the model design settings

## Usage

``` r
getPredictionModelDesigns(
  connectionHandler,
  schema,
  plpTablePrefix = "plp_",
  cgTablePrefix = "cg_",
  targetIds = NULL,
  outcomeIds = NULL,
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

- targetIds:

  A vector of integers corresponding to the target cohort IDs

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

- modelDesignIds:

  (Optional) A set of model design ids to restrict to

## Value

Returns a data.frame with the columns:

- modelDesignId a unique identifier in the database for the model design

- modelType the type of classifier or surival model

- developmentTargetId a unique identifier for the development target ID

- developmentTargetName the name of the development target cohort

- developmentTargetJson the json of the target cohort

- developmentOutcomeId a unique identifier for the development outcome
  ID

- developmentOutcomeName the name of the development outcome cohort

- timeAtRisk the time at risk string

- developmentOutcomeJson the json of the outcome cohort

- covariateSettingsJson the covariate settings json

- populationSettingsJson the population settings json

- tidyCovariatesSettingsJson the tidy covariate settings json

- plpDataSettingsJson the plp data extraction settings json

- featureEngineeringSettingsJson the feature engineering settings json

- splitSettingsJson the split settings json

- sampleSettingsJson the sample settings json

- modelSettingsJson the model settings json

## Details

Specify the connectionHandler, the resultDatabaseSettings and
(optionally) any targetIds or outcomeIds to restrict model designs to

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

modDesign <- getPredictionModelDesigns(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
