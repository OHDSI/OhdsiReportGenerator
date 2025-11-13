# A function to extract non-case and case binary characterization results

A function to extract non-case and case binary characterization results

## Usage

``` r
getBinaryRiskFactors(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetId = NULL,
  outcomeId = NULL,
  databaseId = NULL,
  analysisIds = c(3),
  riskWindowStart = NULL,
  riskWindowEnd = NULL,
  startAnchor = NULL,
  endAnchor = NULL
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

- targetId:

  An integer corresponding to the target cohort ID

- outcomeId:

  Am integer corresponding to the outcome cohort ID

- databaseId:

  The database ID to restrict results to

- analysisIds:

  The feature extraction analysis ID of interest (e.g., 201 is
  condition)

- riskWindowStart:

  (optional) A vector of time-at-risk risk window starts to restrict to

- riskWindowEnd:

  (optional) A vector of time-at-risk risk window ends to restrict to

- startAnchor:

  (optional) A vector of time-at-risk start anchors to restrict to

- endAnchor:

  (optional) A vector of time-at-risk end anchors to restrict to

## Value

A data.frame with the characterization results for the cases and
non-cases

## Details

Specify the connectionHandler, the schema and the target/outcome cohort
IDs

## See also

Other Characterization:
[`getBinaryCaseSeries()`](getBinaryCaseSeries.md),
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

rf <- getBinaryRiskFactors(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetId = 1, 
  outcomeId = 3
)
```
