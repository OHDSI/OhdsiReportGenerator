# Extract the cohort meta

This function extracts all cohort meta for the cohorts of interest.

## Usage

``` r
getCohortMeta(
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

Returns a data.frame with the cohort inclusion rules

## Details

Specify the connectionHandler, the schema and the cohort IDs

## See also

Other Cohorts: [`getCohortAttrition()`](getCohortAttrition.md),
[`getCohortCounts()`](getCohortCounts.md),
[`getCohortDefinitions()`](getCohortDefinitions.md),
[`getCohortInclusionRules()`](getCohortInclusionRules.md),
[`getCohortInclusionStats()`](getCohortInclusionStats.md),
[`getCohortInclusionSummary()`](getCohortInclusionSummary.md),
[`getCohortSubsetAttrition()`](getCohortSubsetAttrition.md),
[`getCohortSubsetDefinitions()`](getCohortSubsetDefinitions.md),
[`getSubsetText()`](getSubsetText.md),
[`processCohortDefinitionsForQuarto()`](processCohortDefinitionsForQuarto.md),
[`processCohorts()`](processCohorts.md),
[`restrictCohortDefinitionsForQuarto()`](restrictCohortDefinitionsForQuarto.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cohortMeta <- getCohortMeta(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
