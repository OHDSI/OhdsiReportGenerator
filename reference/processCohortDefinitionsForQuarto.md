# Function processes the cohortDefinitions object ready for use in the main quarto report.

Function processes the cohortDefinitions object ready for use in the
main quarto report.

## Usage

``` r
processCohortDefinitionsForQuarto(
  cohortDefinitions,
  friendlyCohortIds,
  friendlyCohortNames,
  restrictTargetToIndications,
  indicationIds
)
```

## Arguments

- cohortDefinitions:

  The output of \`getCohortDefinitions()\`

- friendlyCohortIds:

  a vector of parent cohort ids that you want to rename

- friendlyCohortNames:

  a vector of new names for the friendlyCohortIds

- restrictTargetToIndications:

  whether to restrict the results to cohorts nested in certain
  indications

- indicationIds:

  The indication ids of interest for restrictTargetToIndications

## Value

A cohortDefinitions object with extra columns: friendlyName,

## Details

Function processes the cohortDefinitions object by adding friendly names
for specified parent cohorts, determines which cohorts are nested in the
specified indication cohort ids and ...

## See also

Other Cohorts: [`getCohortAttrition()`](getCohortAttrition.md),
[`getCohortCounts()`](getCohortCounts.md),
[`getCohortDefinitions()`](getCohortDefinitions.md),
[`getCohortInclusionRules()`](getCohortInclusionRules.md),
[`getCohortInclusionStats()`](getCohortInclusionStats.md),
[`getCohortInclusionSummary()`](getCohortInclusionSummary.md),
[`getCohortMeta()`](getCohortMeta.md),
[`getCohortSubsetAttrition()`](getCohortSubsetAttrition.md),
[`getCohortSubsetDefinitions()`](getCohortSubsetDefinitions.md),
[`getSubsetText()`](getSubsetText.md),
[`processCohorts()`](processCohorts.md),
[`restrictCohortDefinitionsForQuarto()`](restrictCohortDefinitionsForQuarto.md)
