# A function to extract the failed dechallenge-rechallenge cases

A function to extract the failed dechallenge-rechallenge cases

## Usage

``` r
getDechallengeRechallengeFails(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  targetId = NULL,
  outcomeId = NULL,
  databaseId = NULL,
  dechallengeStopInterval = NULL,
  dechallengeEvaluationWindow = NULL
)
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- cTablePrefix:

  The prefix used for the characterization results tables

- targetId:

  An integer corresponding to the target cohort ID

- outcomeId:

  Am integer corresponding to the outcome cohort ID

- databaseId:

  The unique identifier for the database of interest

- dechallengeStopInterval:

  (optional) The maximum number of days between the outcome start and
  target end for an outcome to be flagged

- dechallengeEvaluationWindow:

  (optional) The maximum number of days after the target restarts to see
  whether the outcome restarts

## Value

A data.frame each failed dechallenge rechallenge exposures and outcomes

## Details

Specify the connectionHandler, the schema and the target/outcome cohort
IDs and database id

## See also

Other Characterization:
[`getBinaryCaseSeries()`](getBinaryCaseSeries.md),
[`getBinaryRiskFactors()`](getBinaryRiskFactors.md),
[`getCaseBinaryFeatures()`](getCaseBinaryFeatures.md),
[`getCaseContinuousFeatures()`](getCaseContinuousFeatures.md),
[`getCaseCounts()`](getCaseCounts.md),
[`getCaseTargetBinaryFeatures()`](getCaseTargetBinaryFeatures.md),
[`getCaseTargetCounts()`](getCaseTargetCounts.md),
[`getCharacterizationCohortBinary()`](getCharacterizationCohortBinary.md),
[`getCharacterizationCohortContinuous()`](getCharacterizationCohortContinuous.md),
[`getCharacterizationDemographics()`](getCharacterizationDemographics.md),
[`getCharacterizationOutcomes()`](getCharacterizationOutcomes.md),
[`getCharacterizationTargets()`](getCharacterizationTargets.md),
[`getContinuousCaseSeries()`](getContinuousCaseSeries.md),
[`getContinuousRiskFactors()`](getContinuousRiskFactors.md),
[`getDechallengeRechallenge()`](getDechallengeRechallenge.md),
[`getIncidenceOutcomes()`](getIncidenceOutcomes.md),
[`getIncidenceRates()`](getIncidenceRates.md),
[`getIncidenceTargets()`](getIncidenceTargets.md),
[`getTargetBinaryFeatures()`](getTargetBinaryFeatures.md),
[`getTargetContinuousFeatures()`](getTargetContinuousFeatures.md),
[`getTimeToEvent()`](getTimeToEvent.md),
[`plotAgeDistributions()`](plotAgeDistributions.md),
[`plotSexDistributions()`](plotSexDistributions.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

conCohort <- getDechallengeRechallengeFails(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetId = 1, 
  outcomeId = 3,
  databaseId = 'eunomia'
)
```
