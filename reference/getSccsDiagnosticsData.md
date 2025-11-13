# Extract the self controlled case series (sccs) diagostic results

This function extracts the sccs diagnostics that examine whether the
analyses were sufficiently powered and checks for different types of
bias.

## Usage

``` r
getSccsDiagnosticsData(
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

- databaseId the unique identifier for the database

- analysisId the analysis unique identifier

- description an analysis description

- targetName the target name

- targetId the target cohort id

- outcomeName the outcome name

- outcomeId the outcome cohort id

- indicationName the indication name

- indicatonId the indication cohort id

- covariateName whether main or secondary analysis

- mdrr the maximum passable minimum detectable relative risk (mdrr)
  value. If the mdrr is greater than this the diagnostics will fail.

- ease The expected absolute systematic error (ease) measures residual
  bias.

- timeTrendP (Depreciated to timeStabilityP) The p for whether the mean
  monthly ratio between observed and expected is no greater than 1.25.

- preExposureP (Depreciated) One-sided p-value for whether the rate
  before expore is higher than after, against the null of no difference.

- mdrrDiagnostic whether the mdrr (power) diagnostic passed or failed.

- easeDiagnostic whether the ease diagnostic passed or failed.

- timeStabilityP (New) The p for whether the mean monthly ratio between
  observed and expected exceeds the specified threshold.

- eventExposureLb (New) Lower bound of the 95% CI for the pre-expososure
  estimate.

- eventExposureUb (New) Upper bound of the 95% CI for the pre-expososure
  estimate.

- eventObservationLb (New) Lower bound of the 95% CI for the end of
  observation probe estimate.

- eventObservationUb (New) Upper bound of the 95% CI for the end of
  observation probe estimate.

- rareOutcomePrevalence (New) The proportion of people in the underlying
  population who have the outcome at least once.

- timeTrendDiagnostic (Depreciated) Pass / warning / fail / not
  evaluated classification of the time trend (unstalbe months)
  diagnostic.

- preExposureDiagnostic (Depreciated) Pass / warning / fail / not
  evaluated classification of the time trend (unstalbe months)
  diagnostic.

- timeStabilityDiagnostic (New) Pass / fail / not evaluated
  classification of the time stability diagnostic.

- eventExposureDiagnostic (New) Pass / fail / not evaluated
  classification of the event-exposure independence diagnostic.

- eventObservationDiagnostic (New) Pass / fail / not evaluated
  classification of the event-observation period dependence diagnostic.

- rareOutcomeDiagnostic (New) Pass / fail / not evaluated classification
  of the rare outcome diagnostic.

- unblind whether the results can be unblinded.

- unblindForEvidenceSynthesis whether the results can be unblinded for
  the meta analysis.

- summaryValue summary of diagnostics results. FAIL, PASS or number of
  warnings.

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

sccsDiag <- getSccsDiagnosticsData(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1,
  outcomeIds = 3
)
```
