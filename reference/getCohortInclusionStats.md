# Extract the cohort inclusion stats

This function extracts all cohort inclusion stats for the cohorts of
interest.

## Usage

``` r
getCohortInclusionStats(
  connectionHandler,
  schema,
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
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

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- cohortIds:

  Optionally a list of cohortIds to restrict to

## Value

Returns a data.frame with the cohort inclusion stats

## Details

Specify the connectionHandler, the schema and the cohort IDs

## See also

Other Cohorts: [`getCohortCounts()`](getCohortCounts.md),
[`getCohortDefinitions()`](getCohortDefinitions.md),
[`getCohortInclusionRules()`](getCohortInclusionRules.md),
[`getCohortInclusionSummary()`](getCohortInclusionSummary.md),
[`getCohortMeta()`](getCohortMeta.md),
[`getCohortSubsetDefinitions()`](getCohortSubsetDefinitions.md),
[`processCohorts()`](processCohorts.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cohortInclsuionsStats <- getCohortInclusionStats(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
```
