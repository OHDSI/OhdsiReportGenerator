# Extract the binary age groups for the cases and targets

This function extracts the age group feature extraction results for
cases and targets corresponding to specified target and outcome cohorts.

## Usage

``` r
getCharacterizationDemographics(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetId = NULL,
  outcomeId = NULL,
  type = "age"
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

- type:

  A character of 'age' or 'sex'

## Value

Returns a data.frame with the columns:

- databaseName the name of the database

- databaseId the unique identifier of the database

- targetName the target cohort name

- targetId the target cohort unique identifier

- outcomeName the outcome name

- outcomeId the outcome unique identifier

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

- covariateName the name of the feature

- sumValue the number of cases who have the feature value of 1

- averageValue the mean feature value

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
# example code

conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

ageData <- getCharacterizationDemographics(
connectionHandler = connectionHandler, 
schema = 'main'
)
```
