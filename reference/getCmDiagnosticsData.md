# Extract the cohort method diagostic results

This function extracts the cohort method diagnostics that examine
whether the analyses were sufficiently powered and checks for different
types of bias.

## Usage

``` r
getCmDiagnosticsData(
  connectionHandler,
  schema,
  cmTablePrefix = "cm_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetIds = NULL,
  outcomeIds = NULL,
  comparatorIds = NULL,
  analysisIds = NULL,
  databaseIds = NULL
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

- analysisIds:

  An optional vector of analysisIds to filter to

- databaseIds:

  An optional vector of databaseIds to filter to

## Value

Returns a data.frame with the columns:

- databaseName the name of the database

- databaseId the unqiue identifier of the database

- analysisId the analysis unique identifier

- description a description of the analysis

- targetName the target cohort name

- targetId the target cohort unique identifier

- comparatorName the comparator cohort name

- comparatorId the comparator cohort unique identifier

- outcomeName the outcome name

- outcomeId the outcome cohort unique identifier

- maxSdm max allowed standardized difference of means when comparing the
  target to the comparator after PS adjustment for the ballance
  diagnostic diagnostic to pass.

- sharedMaxSdm max allowed standardized difference of means when
  comparing the target to the comparator after PS adjustment for the
  ballance diagnostic diagnostic to pass.

- equipoise the bounds on the preference score to determine whether a
  subject is in equipoise.

- mdrr the maximum passable minimum detectable relative risk (mdrr)
  value. If the mdrr is greater than this the diagnostics will fail.

- attritionFraction (depreciated) the minmum attrition before the
  diagnostics fails.

- ease The expected absolute systematic error (ease) measures residual
  bias.

- balanceDiagnostic whether the balance diagnostic passed or failed.

- sharedBalanceDiagnostic whether the shared balance diagnostic passed
  or failed.

- equipoiseDiagnostic whether the equipose diagnostic passed or failed.

- mdrrDiagnostic whether the mdrr (power) diagnostic passed or failed.

- attritionDiagnostic (depreciated) whether the attrition diagnostic
  passed or failed.

- easeDiagnostic whether the ease diagnostic passed or failed.

- unblindForEvidenceSynthesis whether the results can be unblinded for
  the meta analysis.

- unblind whether the results can be unblinded.

- summaryValue summary of diagnostics results. FAIL, PASS or number of
  warnings.

## Details

Specify the connectionHandler, the schema and the
target/comparator/outcome cohort IDs

## See also

Other Estimation: [`getCMEstimation()`](getCMEstimation.md),
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

cmDiag <- getCmDiagnosticsData(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1,
  outcomeIds = 3
)
```
