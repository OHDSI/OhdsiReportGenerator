# Function to figure out the target, comparator, outcome and indication ids of interest for the quarto report based on the user inputs

Function to figure out the target, comparator, outcome and indication
ids of interest for the quarto report based on the user inputs

## Usage

``` r
restrictCohortDefinitionsForQuarto(
  connectionHandler,
  schema,
  cohortDefinitions,
  targetId,
  outcomeIds,
  comparatorIds,
  restrictTargetToIndications,
  indicationIds,
  includeCohortMethod
)
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- cohortDefinitions:

  The output of \`processCohortDefinitionsForQuarto()\`

- targetId:

  a parent target id

- outcomeIds:

  a vector of outcome ids

- comparatorIds:

  NULL or a vector of comparator parent ids

- restrictTargetToIndications:

  whether to restrict the target ids to cohorts nested in indicationIds

- indicationIds:

  The indication ids of interest for restrictTargetToIndications

- includeCohortMethod:

  If TRUE, when comparatorIds is NULL all comparators included in
  CohortMethod are included in the report

## Value

A list of targetIdsOfInterest that is a vector of cohortIds that are
targets of interest to include in the report, comparatorIds a vector of
cohortIds that are comparators, comparatorIdsOfInterest a vector of
cohortIds that are comparators of interest, outcomeIdsOfInterest a
vector of cohortIds that are outcomes of interest and
indicationIdsOfInterest a vector of cohortIds that are indications of
interest.

## Details

This function finds the targets, comparators, indications and outcomes
of interest based on the user inputs for quarto report generation.

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
[`processCohortDefinitionsForQuarto()`](processCohortDefinitionsForQuarto.md),
[`processCohorts()`](processCohorts.md)
