# Extract the cohort method results

This function extracts the single database cohort method estimates for
results that can be unblinded and have a calibrated RR

## Usage

``` r
getCMEstimation(
  connectionHandler,
  schema,
  cmTablePrefix = "cm_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetIds = NULL,
  outcomeIds = NULL,
  comparatorIds = NULL
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

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- targetIds:

  A vector of integers corresponding to the target cohort IDs

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

- comparatorIds:

  A vector of integers corresponding to the comparator cohort IDs

## Value

Returns a data.frame with the columns:

- databaseName the name of the database

- databaseId the unqiue identifier of the database

- analysisId the analysis design unique identifier

- description the analysis design description

- targetName the target cohort name

- targetId the target cohort unique identifier

- comparatorName the comparator cohort name

- comparatorId the comparator cohort unique identifier

- outcomeName the outcome name

- outcomeId the outcome unique identifier

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

- targetSubjects the number of people in the target cohort

- comparatorSubjects the number of people in the comparator cohort

- targetDays the total number of days at risk across the target cohort
  people

- comparatorDays the total number of days at risk across the comparator
  cohort people

- targetOutcomes the total number of outcomes occuring during the time
  at risk for the target cohort people

- comparatorOutcomes the total number of outcomes occuring during the
  time at risk for the comparator cohort people

- Unblind Whether the results passed diagnostics and were unblinded

- unblindForEvidenceSynthesis whether the results can be unblinded for
  the meta analysis.

- targetEstimator ...

## Details

Specify the connectionHandler, the schema and the
target/comparator/outcome cohort IDs

## See also

Other Estimation: [`getCmDiagnosticsData()`](getCmDiagnosticsData.md),
[`getCmMetaEstimation()`](getCmMetaEstimation.md),
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

cmEst <- getCMEstimation(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1,
  outcomeIds = 3
)
```
