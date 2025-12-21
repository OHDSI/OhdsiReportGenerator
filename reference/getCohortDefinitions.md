# Extract the cohort definition details

This function extracts all cohort definitions for the targets of
interest.

## Usage

``` r
getCohortDefinitions(
  connectionHandler,
  schema,
  cgTablePrefix = "cg_",
  targetIds = NULL
)
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- cgTablePrefix:

  The prefix used for the cohort generator results tables

- targetIds:

  A vector of integers corresponding to the target cohort IDs

## Value

Returns a data.frame with the cohort details

## Details

Specify the connectionHandler, the schema and the target cohort IDs

## See also

Other Cohorts: [`getCohortCounts()`](getCohortCounts.md),
[`getCohortInclusionRules()`](getCohortInclusionRules.md),
[`getCohortInclusionStats()`](getCohortInclusionStats.md),
[`getCohortInclusionSummary()`](getCohortInclusionSummary.md),
[`getCohortMeta()`](getCohortMeta.md),
[`getCohortSubsetDefinitions()`](getCohortSubsetDefinitions.md),
[`processCohorts()`](processCohorts.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()
#> Closing database connection

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cohortDef <- getCohortDefinitions(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
