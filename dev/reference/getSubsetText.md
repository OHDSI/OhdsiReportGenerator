# Function that converts a subsetDefinitionJson into text description

Function that converts a subsetDefinitionJson into text description

## Usage

``` r
getSubsetText(subsetDefinitionJson, cohortDefinitions)
```

## Arguments

- subsetDefinitionJson:

  The subset logic json

- cohortDefinitions:

  A data.frame with the columns cohortDefinitionId, cohortName and
  optionally friendlyName that will be used to know the friendly cohort
  name for any subsetting that nests in other cohorts

## Value

A text string describing the subsetting

## Details

The function takes a subsetDefinitionJson and converts it into friendly
text describing the subset logic

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
[`processCohortDefinitionsForQuarto()`](processCohortDefinitionsForQuarto.md),
[`processCohorts()`](processCohorts.md),
[`restrictCohortDefinitionsForQuarto()`](restrictCohortDefinitionsForQuarto.md)
