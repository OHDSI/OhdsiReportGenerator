# Extract the cohort parents and children cohorts (cohorts derieved from the parent cohort)

This function lets you split the cohort data.frame into the parents and
the children per parent.

## Usage

``` r
processCohorts(cohort)
```

## Arguments

- cohort:

  The data.frame extracted using \`getCohortDefinitions()\`

## Value

Returns a list containing parents: a named vector of all the parent
cohorts and cohortList: a list the same length as the parent vector with
the first element containing all the children of the first parent
cohort, the second element containing the children of the second parent,
etc.

## Details

Finds the parent cohorts and children cohorts

## See also

Other Cohorts: [`getCohortCounts()`](getCohortCounts.md),
[`getCohortDefinitions()`](getCohortDefinitions.md),
[`getCohortInclusionRules()`](getCohortInclusionRules.md),
[`getCohortInclusionStats()`](getCohortInclusionStats.md),
[`getCohortInclusionSummary()`](getCohortInclusionSummary.md),
[`getCohortMeta()`](getCohortMeta.md),
[`getCohortSubsetDefinitions()`](getCohortSubsetDefinitions.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cohortDef <- getCohortDefinitions(
  connectionHandler = connectionHandler, 
  schema = 'main'
)

parents <- processCohorts(cohortDef)
```
