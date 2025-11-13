# Extract the dechallenge rechallenge results

This function extracts all dechallenge rechallenge results across
databases for specified target and outcome cohorts.

## Usage

``` r
getDechallengeRechallenge(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetIds = NULL,
  outcomeIds = NULL
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

- cgTablePrefix:

  The prefix used for the cohort generator results tables

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- targetIds:

  A vector of integers corresponding to the target cohort IDs

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

## Value

Returns a data.frame with the columns:

- databaseName the name of the database

- databaseId the unique identifier of the database

- targetName the target cohort name

- targetId the target cohort unique identifier

- outcomeName the outcome name

- outcomeId the outcome unique identifier

- dechallengeStopInterval An integer specifying the how much time to add
  to the cohort_end when determining whether the event starts during
  cohort and ends after

- dechallengeEvaluationWindow A period of time evaluated for outcome
  recurrence after discontinuation of exposure, among patients with
  challenge outcomes

- numExposureEras Distinct number of exposure events (i.e. drug eras) in
  a given target cohort

- numPersonsExposed Distinct number of people exposed in target cohort.
  A person must have at least 1 day exposure to be included

- numCases Distinct number of persons in outcome cohort. A person must
  have at least 1 day of observation time to be included

- dechallengeAttempt Distinct count of people with observable time after
  discontinuation of the exposure era during which the challenge outcome
  occurred

- dechallengeFail Among people with challenge outcomes, the distinct
  number of people with outcomes during dechallengeEvaluationWindow

- dechallengeSuccess Among people with challenge outcomes, the distinct
  number of people without outcomes during the
  dechallengeEvaluationWindow

- rechallengeAttempt Number of people with a new exposure era after the
  occurrence of an outcome during a prior exposure era

- rechallengeFail Number of people with a new exposure era during which
  an outcome occurred, after the occurrence of an outcome during a prior
  exposure era

- rechallengeSuccess Number of people with a new exposure era during
  which an outcome did not occur, after the occurrence of an outcome
  during a prior exposure era

- pctDechallengeAttempt Percent of people with observable time after
  discontinuation of the exposure era during which the challenge outcome
  occurred

- pctDechallengeFail Among people with challenge outcomes, the percent
  of people without outcomes during the dechallengeEvaluationWindow

- pctDechallengeSuccess Among people with challenge outcomes, the
  percent of people with outcomes during dechallengeEvaluationWindow

- pctRechallengeAttempt Percent of people with a new exposure era after
  the occurrence of an outcome during a prior exposure era

- pctRechallengeFail Percent of people with a new exposure era during
  which an outcome did not occur, after the occurrence of an outcome
  during a prior exposure era

- pctRechallengeSuccess Percent of people with a new exposure era during
  which an outcome occurred, after the occurrence of an outcome during a
  prior exposure era

## Details

Specify the connectionHandler, the schema and the target/outcome cohort
IDs

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
[`getDechallengeRechallengeFails()`](getDechallengeRechallengeFails.md),
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

dcrc <- getDechallengeRechallenge(
connectionHandler = connectionHandler, 
schema = 'main'
)
```
