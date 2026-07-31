# Extract the non-cases counts result

This function extracts non-case counts across databases in the results
for specified target and outcome cohorts.

## Usage

``` r
getNonCaseCounts(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  characterizationTargetIds = NULL,
  characterizationCaseIds = NULL,
  startAnchor = NULL,
  endAnchor = NULL,
  riskWindowStart = NULL,
  riskWindowEnd = NULL,
  outcomeIds = NULL,
  outcomeWashouts = NULL,
  databaseIds = NULL,
  includeNames = TRUE
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

- characterizationTargetIds:

  The characterization target cohort ids of interest

- characterizationCaseIds:

  The characterization case ids of interest

- startAnchor:

  optional filter by startAchor

- endAnchor:

  optional filter by endAchor

- riskWindowStart:

  optional filter by riskWindowStart

- riskWindowEnd:

  optional filter by riskWindowEnd

- outcomeIds:

  A vector of integers corresponding to the outcome cohort IDs

- outcomeWashouts:

  optional filter by washout

- databaseIds:

  A vector of database IDs to restrict to

- includeNames:

  whether to add the database names and cohort names

## Value

Returns a data.frame with the columns:

- databaseName the name of the database

- databaseId the unique identifier of the database

- characterizationCaseId the unique identifier of target, outcome and
  TAR combination

- targetName the target cohort name

- targetId the target cohort unique identifier

- limitToFirstInNDays target index is limited to first in N days

- minPriorObservation the minimum required observation days prior to
  index for an entry

- nestingCohortId the cohort id a person must be in at index

- nestingName the cohort name a person must be in at index

- minAge min age to be included at index

- maxAge max age to be included at index

- studyStart index must be on or after this date to be included

- studyEnd index must be on or before this date to be included

- genderConceptIds the gender concept ids a subject must have to be
  included

- outcomeName the outcome name

- outcomeId the outcome unique identifier

- outcomeWashoutDays patients with the outcome occurring within this
  number of days prior to index are excluded (NA means no exclusion)

- rowCount the number of entries in the cohort

- personCount the number of people in the cohort

- withoutExcludedPersonCount the number of people in the target ignoring
  exclusions

## Details

Specify the connectionHandler, the schema and the target/outcome cohort
IDs

## See also

Other Characterization:
[`characterizationCompareBinary()`](characterizationCompareBinary.md),
[`characterizationCompareContinuous()`](characterizationCompareContinuous.md),
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
[`getIncidenceTargetSettings()`](getIncidenceTargetSettings.md),
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

tc <- getNonCaseCounts(
connectionHandler = connectionHandler, 
schema = 'main'
)
#> Warning: Parameter 'outcome_washout' not found in SQL
#> Warning: Parameter 'use_outcome_washout' not found in SQL
```
