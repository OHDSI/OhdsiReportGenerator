# Extract aggregate statistics of binary feature analysis IDs of interest for targets

This function extracts the feature extraction results for targets
corresponding to specified target and outcome cohorts.

## Usage

``` r
getCaseTargetBinaryFeatures(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetIds = NULL,
  outcomeIds = NULL,
  databaseIds = NULL,
  analysisIds = c(3)
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

  (optional) A vector of database ids to restrict to

- analysisIds:

  (optional) The feature extraction analysis ID of interest (e.g., 201
  is condition)

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

- covariateId the id of the feature

- covariateName the name of the feature

- sumValue the number of target patients who have the feature value of 1
  (minus those excluded due to having the outcome prior)

- rawSum the number of target patients who have the feature value of 1
  (ignoring exclusions)

- rawAverage the fraction of target patients who have the feature value
  of 1 (ignoring exclusions)

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

tbf <- getCaseTargetBinaryFeatures (
connectionHandler = connectionHandler, 
schema = 'main'
)
```
