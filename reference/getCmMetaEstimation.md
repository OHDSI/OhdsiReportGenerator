# Extract the cohort method meta analysis results

This function extracts any meta analysis estimation results for cohort
method.

## Usage

``` r
getCmMetaEstimation(
  connectionHandler,
  schema,
  cmTablePrefix = "cm_",
  cgTablePrefix = "cg_",
  esTablePrefix = "es_",
  targetIds = NULL,
  outcomeIds = NULL,
  comparatorIds = NULL,
  includeOneSidedP = TRUE
)
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- cmTablePrefix:

  The prefix used for the cohort method results tables

- cgTablePrefix:

  The prefix used for the cohort generator results tables

- esTablePrefix:

  The prefix used for the evidence synthesis results tables

- targetIds:

  A vector of integers corresponding to the target cohort IDs

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

- comparatorIds:

  A vector of integers corresponding to the comparator cohort IDs

- includeOneSidedP:

  This lets you extract from older results that do not have the one
  sided p by setting this to FALSE

## Value

Returns a data.frame with the columns:

- databaseName the name of the database

- analysisId the analysis unique identifier

- description a description of the analysis

- targetName the target cohort name

- targetId the target cohort unique identifier

- comparatorName the comparator cohort name

- comparatorId the comparator cohort unique identifier

- outcomeName the outcome name

- outcomeId the outcome cohort unique identifier

- calibratedRr the calibrated relative risk

- calibratedRrCi95Lb the calibrated relative risk 95 percent confidence
  interval lower bound

- calibratedRrCi95Ub the calibrated relative risk 95 percent confidence
  interval upper bound

- calibratedP the two sided calibrated p value

- calibratedOneSidedP the one sided calibrated p value

- calibratedLogRr the calibrated relative risk logged

- calibratedSeLogRr the standard error of the calibrated relative risk
  logged

- targetSubjects the number of people in the target cohort across
  included database

- comparatorSubjects the number of people in the comparator cohort
  across included database

- targetDays the total number of days at risk across the target cohort
  people across included database

- comparatorDays the total number of days at risk across the comparator
  cohort people across included database

- targetOutcomes the total number of outcomes occuring during the time
  at risk for the target cohort people across included database

- comparatorOutcomes the total number of outcomes occuring during the
  time at risk for the comparator cohort people across included database

- unblind whether the results can be unblinded.

- nDatabases the number of databases included

## Details

Specify the connectionHandler, the schema and the
target/comparator/outcome cohort IDs

## See also

Other Estimation: [`getCMEstimation()`](getCMEstimation.md),
[`getCmDiagnosticsData()`](getCmDiagnosticsData.md),
[`getCmNegativeControlEstimates()`](getCmNegativeControlEstimates.md),
[`getCmOutcomes()`](getCmOutcomes.md),
[`getCmPropensityModel()`](getCmPropensityModel.md),
[`getCmTable()`](getCmTable.md), [`getCmTargets()`](getCmTargets.md),
[`getSccsDiagnosticsData()`](getSccsDiagnosticsData.md),
[`getSccsEstimation()`](getSccsEstimation.md),
[`getSccsMetaEstimation()`](getSccsMetaEstimation.md),
[`getSccsModel()`](getSccsModel.md),
[`getSccsNegativeControlEstimates()`](getSccsNegativeControlEstimates.md),
[`getSccsOutcomes()`](getSccsOutcomes.md),
[`getSccsTable()`](getSccsTable.md),
[`getSccsTargets()`](getSccsTargets.md),
[`getSccsTimeToEvent()`](getSccsTimeToEvent.md),
[`plotCmEstimates()`](plotCmEstimates.md),
[`plotSccsEstimates()`](plotSccsEstimates.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cmMeta <- getCmMetaEstimation(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1,
  outcomeIds = 3
)
```
