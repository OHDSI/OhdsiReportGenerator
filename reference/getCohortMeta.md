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

Other Cohorts: [`getCohortCounts()`](getCohortCounts.md),
[`getCohortDefinitions()`](getCohortDefinitions.md),
[`getCohortInclusionRules()`](getCohortInclusionRules.md),
[`getCohortInclusionStats()`](getCohortInclusionStats.md),
[`getCohortInclusionSummary()`](getCohortInclusionSummary.md),
[`getCohortSubsetDefinitions()`](getCohortSubsetDefinitions.md),
[`processCohorts()`](processCohorts.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cohortMeta <- getCohortMeta(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
#> <simpleError in value[[3L]](cond): SELECT 
#>   cd.cohort_definition_id as cohort_id, 
#>   cd.cohort_name,
#>   cg.generation_status, 
#>   cg.start_time, 
#>   cg.end_time, 
#>   dt.cdm_source_name as database_name,
#>   dt.database_id
#>   FROM main.cg_COHORT_GENERATION cg
#>   INNER JOIN main.database_meta_data dt
#>   ON cg.database_id = dt.database_id
#>   INNER JOIN main.cg_COHORT_DEFINITION cd
#>   ON cg.cohort_definition_id = cd.cohort_definition_id
#>   ;
#> 
#> Error in `.createErrorReport()`:
#> ! Error executing SQL:
#> no such column: cg.cohort_definition_id
#> An error report has been created at  /home/runner/work/OhdsiReportGenerator/OhdsiReportGenerator/docs/reference/errorReportSql.txt
#> >
#> [1] "COHORT_GENERATION table has outdated column name for cohort_definition_id"
```
