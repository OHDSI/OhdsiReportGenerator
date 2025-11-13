# Extract the cohort subset definition details

This function extracts all cohort subset definitions for the subsets of
interest.

## Usage

``` r
getCohortSubsetDefinitions(
  connectionHandler,
  schema,
  cgTablePrefix = "cg_",
  subsetIds = NULL
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

- subsetIds:

  A vector of subset cohort ids or NULL

## Value

Returns a data.frame with the cohort subset details

## Details

Specify the connectionHandler, the schema and the subset IDs

## See also

Other Cohorts: [`getCohortCounts()`](getCohortCounts.md),
[`getCohortDefinitions()`](getCohortDefinitions.md),
[`getCohortInclusionRules()`](getCohortInclusionRules.md),
[`getCohortInclusionStats()`](getCohortInclusionStats.md),
[`getCohortInclusionSummary()`](getCohortInclusionSummary.md),
[`getCohortMeta()`](getCohortMeta.md),
[`processCohorts()`](processCohorts.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

subsetDef <- getCohortSubsetDefinitions(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
