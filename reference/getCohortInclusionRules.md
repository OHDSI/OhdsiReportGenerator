# Extract the cohort inclusion rules

This function extracts all cohort inclusion rules for the cohorts of
interest.

## Usage

``` r
getCohortInclusionRules(
  connectionHandler,
  schema,
  cgTablePrefix = "cg_",
  cohortIds = NULL
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

- cohortIds:

  Optionally a list of cohortIds to restrict to

## Value

Returns a data.frame with the cohort inclusion rules

## Details

Specify the connectionHandler, the schema and the cohort IDs

## See also

Other Cohorts: [`getCohortCounts()`](getCohortCounts.md),
[`getCohortDefinitions()`](getCohortDefinitions.md),
[`getCohortInclusionStats()`](getCohortInclusionStats.md),
[`getCohortInclusionSummary()`](getCohortInclusionSummary.md),
[`getCohortMeta()`](getCohortMeta.md),
[`getCohortSubsetDefinitions()`](getCohortSubsetDefinitions.md),
[`processCohorts()`](processCohorts.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cohortInclsuionsRules <- getCohortInclusionRules(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
