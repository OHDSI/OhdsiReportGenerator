# Extract aggregate statistics of binary feature analysis IDs of interest for targets (ignoring excluding people with prior outcome)

This function extracts the feature extraction results for targets
corresponding to specified target but does not exclude any patients with
the outcome during the outcome washout (so it agnostic to the outcome of
interest).

## Usage

``` r
getTargetBinaryFeatures(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetId = NULL,
  databaseIds = NULL,
  analysisIds = NULL,
  conceptIds = NULL
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

- databaseIds:

  (optional) A vector of database ids to restrict to

- analysisIds:

  (optional) The feature extraction analysis ID of interest (e.g., 201
  is condition)

- conceptIds:

  (optional) The feature extraction concept ID of interest to restrict
  to

## Value

Returns a data.frame with the columns:

- databaseName the name of the database

- databaseId the unique identifier of the database

- targetName the target cohort name

- targetId the target cohort unique identifier

- minPriorObservation the minimum required observation days prior to
  index for an entry

- covariateId the id of the feature

- covariateName the name of the feature

- sumValue the number of target patients who have the feature value of 1
  (target patients are restricted to first occurrence and require min
  prior obervation days)

- averageAvalue the fraction of target patients who have the feature
  value of 1 (target patients are restricted to first occurrence and
  require min prior obervation days)

## Details

Specify the connectionHandler, the schema and the target cohort IDs

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
[`getDechallengeRechallengeFails()`](getDechallengeRechallengeFails.md),
[`getIncidenceOutcomes()`](getIncidenceOutcomes.md),
[`getIncidenceRates()`](getIncidenceRates.md),
[`getIncidenceTargets()`](getIncidenceTargets.md),
[`getTargetContinuousFeatures()`](getTargetContinuousFeatures.md),
[`getTimeToEvent()`](getTimeToEvent.md),
[`plotAgeDistributions()`](plotAgeDistributions.md),
[`plotSexDistributions()`](plotSexDistributions.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

tbf <- getTargetBinaryFeatures (
connectionHandler = connectionHandler, 
schema = 'main',
targetId = 1
)
```
