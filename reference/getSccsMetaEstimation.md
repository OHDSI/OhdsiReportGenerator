# Extract the self controlled case series (sccs) meta analysis results

This function extracts any meta analysis estimation results for sccs.

## Usage

``` r
getSccsMetaEstimation(
  connectionHandler,
  schema,
  sccsTablePrefix = "sccs_",
  cgTablePrefix = "cg_",
  esTablePrefix = "es_",
  targetIds = NULL,
  outcomeIds = NULL,
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

- sccsTablePrefix:

  The prefix used for the cohort generator results tables

- cgTablePrefix:

  The prefix used for the cohort generator results tables

- esTablePrefix:

  The prefix used for the evidence synthesis results tables

- targetIds:

  A vector of integers corresponding to the target cohort IDs

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

- includeOneSidedP:

  This lets you extract from older results that do not have the one
  sided p by setting this to FALSE

## Value

Returns a data.frame with the columns:

- databaseName the database name

- analysisId the analysis unique identifier

- description an analysis description

- targetName the target name

- targetId the target cohort id

- outcomeName the outcome name

- outcomeId the outcome cohort id

- indicationName the indicationname

- indicationId the indication cohort id

- covariateName whether main or secondary analysis

- outcomeSubjects The number of subjects with at least one outcome.

- outcomeEvents The number of outcome events.

- outcomeObservationPeriods The number of observation periods containing
  at least one outcome.

- covariateSubjects The number of subjects having the covariate.

- covariateDays The total covariate time in days.

- covariateEras The number of continuous eras of the covariate.

- covariateOutcomes The number of outcomes observed during the covariate
  time.

- observedDays The number of days subjects were observed.

- calibratedRr the calibrated relative risk

- calibratedCi95Lb the lower bound of the 95 percent confidence interval
  for the calibrated relative risk

- calibratedCi95Ub the upper bound of the 95 percent confidence interval
  for the calibrated relative risk

- calibratedP the calibrated p-value

- calibratedOneSidedP the calibrated one sided p-value

- calibratedLogRr the calibrated log of the relative risk

- calibratedSeLogRr the calibrated log of the relative risk standard
  error

- nDatabases The number of databases included in the estimate.

## Details

Specify the connectionHandler, the schema and the targetoutcome cohort
IDs

## See also

Other Estimation: [`getCMEstimation()`](getCMEstimation.md),
[`getCmDiagnosticsData()`](getCmDiagnosticsData.md),
[`getCmMetaEstimation()`](getCmMetaEstimation.md),
[`getCmNegativeControlEstimates()`](getCmNegativeControlEstimates.md),
[`getCmOutcomes()`](getCmOutcomes.md),
[`getCmPropensityModel()`](getCmPropensityModel.md),
[`getCmTable()`](getCmTable.md), [`getCmTargets()`](getCmTargets.md),
[`getSccsDiagnosticsData()`](getSccsDiagnosticsData.md),
[`getSccsEstimation()`](getSccsEstimation.md),
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

sccsMeta <- getSccsMetaEstimation(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1,
  outcomeIds = 3
)
```
