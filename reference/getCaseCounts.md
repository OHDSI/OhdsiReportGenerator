# Extract the outcome cohort counts result

This function extracts outcome cohort counts across databases in the
results for specified target and outcome cohorts.

## Usage

``` r
getCaseCounts(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetIds = NULL,
  outcomeIds = NULL,
  databaseIds = NULL,
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

- targetIds:

  A vector of integers corresponding to the target cohort IDs

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

- databaseIds:

  (optional) A vector of database IDs to restrict to

- riskWindowStart:

  (optional) A vector of time-at-risk risk window starts to restrict to

- riskWindowEnd:

  (optional) A vector of time-at-risk risk window ends to restrict to

- startAnchor:

  (optional) A vector of time-at-risk start anchors to restrict to

- endAnchor:

  (optional) A vector of time-at-risk end anchors to restrict to

## Value

Returns a data.frame with the columns:

- databaseName the name of the database

- databaseId the unique identifier of the database

- targetName the target cohort name

- targetId the target cohort unique identifier

- outcomeName the outcome name

- outcomeId the outcome unique identifier

- rowCount the number of entries in the cohort

- personCount the number of people in the cohort

- minPriorObservation the minimum required observation days prior to
  index for an entry

- outcomeWashoutDays patients with the outcome occurring within this
  number of days prior to index are excluded (NA means no exclusion)

- riskWindowStart the number of days ofset the start anchor that is the
  start of the time-at-risk

- startAnchor the start anchor is either the target cohort start or
  cohort end date

- riskWindowEnd the number of days ofset the end anchor that is the end
  of the time-at-risk

- endAnchor the end anchor is either the target cohort start or cohort
  end date

## Details

Specify the connectionHandler, the schema and the target/outcome cohort
IDs

## See also

Other Characterization:
[`getBinaryCaseSeries()`](getBinaryCaseSeries.md),
[`getBinaryRiskFactors()`](getBinaryRiskFactors.md),
[`getCaseBinaryFeatures()`](getCaseBinaryFeatures.md),
[`getCaseContinuousFeatures()`](getCaseContinuousFeatures.md),
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

cc <- getCaseCounts(
connectionHandler = connectionHandler, 
schema = 'main'
)
```
