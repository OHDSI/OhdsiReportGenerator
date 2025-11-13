# Extract the SCCS negative controls

This function extracts the sccs negative controls.

## Usage

``` r
getSccsNegativeControlEstimates(
  connectionHandler,
  schema,
  sccsTablePrefix = "sccs_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  databaseIds = NULL,
  exposuresOutcomeSetIds = NULL,
  indicationIds = NULL,
  outcomeIds = NULL,
  targetIds = NULL,
  analysisIds = NULL,
  covariateIds = NULL,
  covariateAnalysisIds = NULL
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

- databaseIds:

  the database IDs to restrict to

- exposuresOutcomeSetIds:

  the exposureOutcomeIds to restrict to

- indicationIds:

  The indications that the target was nested to

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

- targetIds:

  A vector of integers corresponding to the target cohort IDs

- analysisIds:

  the analysis IDs to restrict to

- covariateIds:

  the covariate IDs to restrict to

- covariateAnalysisIds:

  the covariate analysis IDs to restrict to

## Value

Returns a data.frame with the SCCS negative controls

## Details

Specify the connectionHandler, the schema and optionally the
target/outcome/analysis/database IDs

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
[`getSccsMetaEstimation()`](getSccsMetaEstimation.md),
[`getSccsModel()`](getSccsModel.md),
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

sccsNcs <- getSccsNegativeControlEstimates(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
