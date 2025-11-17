# Extract the model design diagnostics for a specific development database

This function extracts the PROBAST diagnostics

## Usage

``` r
getPredictionDiagnostics(
  connectionHandler,
  schema,
  plpTablePrefix = "plp_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  modelDesignIds = NULL,
  threshold1_2 = 0.9
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

  The identifier for a model design to restrict results to

- threshold1_2:

  A threshold for probast 1.2

## Value

Returns a data.frame with the columns:

- modelDesignId the unique identifier for the model design

- diagnosticId the unique identifier for diagnostic result

- developmentDatabaseName the name for the database used to develop the
  model

- developmentTargetName the name for the development target population

- developmentOutcomeName the name for the development outcome

- probast1_1 Were appropriate data sources used, e.g., cohort, RCT, or
  nested case-control study data?

- probast1_2 Were all inclusions and exclusions of paticipants
  appropriate?

- probast2_1 Were predictors defined and assessed in a similar way for
  all participants?

- probast2_2 Were predictors assessments made without knowledge of
  outcome data?

- probast2_3 All all predictors available at the time the model is
  intended to be used?

- probast3_4 Was the outcome defined and determined in a similar way for
  all participants?

- probast3_6 Was the time interval between predictor assessment and
  outcome determination appropriate?

- probast4_1 Were there a reasonable number of participants with the
  outcome?

## Details

Specify the connectionHandler, the resultDatabaseSettings and
(optionally) a modelDesignId and threshold1_2 a threshold value to use
for the PROBAST 1.2

## See also

Other Prediction:
[`getFullPredictionPerformances()`](getFullPredictionPerformances.md),
[`getPredictionAggregateTopPredictors()`](getPredictionAggregateTopPredictors.md),
[`getPredictionCohorts()`](getPredictionCohorts.md),
[`getPredictionCovariates()`](getPredictionCovariates.md),
[`getPredictionDiagnosticTable()`](getPredictionDiagnosticTable.md),
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

diag <- getPredictionDiagnostics(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
```
