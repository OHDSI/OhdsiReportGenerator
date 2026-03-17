# Get cohort subset attrition

Retrieves attrition information for specified cohort subsets from the
database.

## Usage

``` r
getCohortSubsetAttrition(
  connectionHandler,
  schema,
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  cohortIds = NULL
)
```

## Arguments

- connectionHandler:

  A connection handler object.

- schema:

  The database schema name.

- cgTablePrefix:

  Prefix for cohort generator tables. Default is 'cg\_'.

- databaseTable:

  Name of the database metadata table. Default is 'database_meta_data'.

- cohortIds:

  Optional vector of cohort IDs to filter.

## Value

A tibble with attrition details for each cohort subset.

## See also

Other Cohorts: [`getCohortAttrition()`](getCohortAttrition.md),
[`getCohortCounts()`](getCohortCounts.md),
[`getCohortDefinitions()`](getCohortDefinitions.md),
[`getCohortInclusionRules()`](getCohortInclusionRules.md),
[`getCohortInclusionStats()`](getCohortInclusionStats.md),
[`getCohortInclusionSummary()`](getCohortInclusionSummary.md),
[`getCohortMeta()`](getCohortMeta.md),
[`getCohortSubsetDefinitions()`](getCohortSubsetDefinitions.md),
[`getSubsetText()`](getSubsetText.md),
[`processCohortDefinitionsForQuarto()`](processCohortDefinitionsForQuarto.md),
[`processCohorts()`](processCohorts.md),
[`restrictCohortDefinitionsForQuarto()`](restrictCohortDefinitionsForQuarto.md)
