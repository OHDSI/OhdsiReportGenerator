# Extract the self controlled case series (sccs) results

This function extracts the single database sccs estimates

## Usage

``` r
getSccsEstimation(
  connectionHandler,
  schema,
  sccsTablePrefix = "sccs_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetIds = NULL,
  outcomeIds = NULL
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

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- targetIds:

  A vector of integers corresponding to the target cohort IDs

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

## Value

Returns a data.frame with the columns:

- databaseName the database name

- databaseId the database id

- exposuresOutcomeSetId the exposure outcome set identifier

- analysisId the analysis unique identifier

- description an analysis description

- targetName the target name

- targetId the target cohort id

- outcomeName the outcome name

- outcomeId the outcome cohort id

- indicationName the indication name

- indicatonId the indication cohort id

- covariateName whether main or secondary analysis

- covariateId the analysis id

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

- rr the relative risk

- ci95Lb the lower bound of the 95 percent confidence interval for the
  relative risk

- ci95Ub the upper bound of the 95 percent confidence interval for the
  relative risk

- p the p-value for the relative risk

- logRr the log of the relative risk

- seLogRr the standard error or the log of the relative risk

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

- llr The log of the likelihood ratio (of the MLE vs the null hypothesis
  of no effect).

- mdrr The minimum detectable relative risk.

- unblind Whether the results can be unblinded

## Details

Specify the connectionHandler, the schema and the target/outcome cohort
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

sccsEst <- getSccsEstimation(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1,
  outcomeIds = 3
)
```
