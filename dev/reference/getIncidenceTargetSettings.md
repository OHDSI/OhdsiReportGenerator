# A function to extarct the cohort incidence targets

A function to extarct the cohort incidence targets

## Usage

``` r
getIncidenceTargetSettings(
  connectionHandler,
  schema,
  ciTablePrefix = "ci_",
  cgTablePrefix = "cg_",
  targetIds = NULL
)
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- ciTablePrefix:

  The prefix used for the cohort incidence results tables

- cgTablePrefix:

  The prefix used for the cohort generator results tables

- targetIds:

  optional vector of targetIds to restrict to

## Value

A data.frame with the characterization target cohort ids, names and
inclusion criteria.

## Details

Specify the connectionHandler, the schema and the prefixes

## See also

Other Characterization:
[`characterizationCompareBinary()`](characterizationCompareBinary.md),
[`characterizationCompareContinuous()`](characterizationCompareContinuous.md),
[`getAggregateBinaryRiskFactors()`](getAggregateBinaryRiskFactors.md),
[`getAggregateContinuousRiskFactors()`](getAggregateContinuousRiskFactors.md),
[`getBinaryCaseSeries()`](getBinaryCaseSeries.md),
[`getBinaryRiskFactors()`](getBinaryRiskFactors.md),
[`getBinaryTargetBaseline()`](getBinaryTargetBaseline.md),
[`getCaseCounts()`](getCaseCounts.md),
[`getCharacterizationCaseSettings()`](getCharacterizationCaseSettings.md),
[`getCharacterizationDemographics()`](getCharacterizationDemographics.md),
[`getCharacterizationTargetSettings()`](getCharacterizationTargetSettings.md),
[`getContinuousCaseSeries()`](getContinuousCaseSeries.md),
[`getContinuousRiskFactors()`](getContinuousRiskFactors.md),
[`getContinuousTargetBaseline()`](getContinuousTargetBaseline.md),
[`getDechallengeRechallenge()`](getDechallengeRechallenge.md),
[`getDechallengeRechallengeFails()`](getDechallengeRechallengeFails.md),
[`getIncidenceRates()`](getIncidenceRates.md),
[`getNonCaseCounts()`](getNonCaseCounts.md),
[`getOutcomesUsedInCharacterization()`](getOutcomesUsedInCharacterization.md),
[`getOutcomesUsedInIncidence()`](getOutcomesUsedInIncidence.md),
[`getTargetCounts()`](getTargetCounts.md),
[`getTargetsUsedInCharacterization()`](getTargetsUsedInCharacterization.md),
[`getTargetsUsedInIncidence()`](getTargetsUsedInIncidence.md),
[`getTimeToEvent()`](getTimeToEvent.md),
[`plotAgeDistributions()`](plotAgeDistributions.md),
[`plotSexDistributions()`](plotSexDistributions.md),
[`viewIncidenceRate()`](viewIncidenceRate.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

targetCohorts <- getIncidenceTargetSettings(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
