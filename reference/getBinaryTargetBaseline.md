# Extract the aggregate covariates for the target ids of interest

This function extracts the specified covariates for the specified
targets

## Usage

``` r
getBinaryTargetBaseline(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  characterizationTargetIds = NULL,
  analysisIds = NULL,
  covariateIds = NULL,
  conceptIds = NULL,
  databaseIds = NULL,
  includeNames = TRUE,
  minThreshold = NULL
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

- analysisIds:

  The analysisIds of the covariate to restrict results to

- covariateIds:

  The covariateIds to restict results to

- conceptIds:

  The conceptIds of the covariate to restrict results to

- databaseIds:

  The databaseIds of the covariate to restrict results to

- includeNames:

  Whether to add database and cohort names (setting to FALSE will make
  extraction quicker)

- minThreshold:

  (optional) The minimum average value for results to be returned

## Value

Returns a data.frame with the columns:

- databaseName the name of the database

- databaseId the unique identifier of the database

- targetName the target cohort name

- targetId the target cohort unique identifier

- minPriorObservation the

- limitToFirstINDays the

- covariateName the

- covariateId the

- analysisId the

- sumValue the

- averageValue the

## Details

Specify the connectionHandler, the schema and the target cohort IDs

## See also

Other Characterization:
[`characterizationCompareBinary()`](characterizationCompareBinary.md),
[`characterizationCompareContinuous()`](characterizationCompareContinuous.md),
[`getAggregateBinaryRiskFactors()`](getAggregateBinaryRiskFactors.md),
[`getAggregateContinuousRiskFactors()`](getAggregateContinuousRiskFactors.md),
[`getBinaryCaseSeries()`](getBinaryCaseSeries.md),
[`getBinaryRiskFactors()`](getBinaryRiskFactors.md),
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

btb <- getBinaryTargetBaseline(
 connectionHandler = connectionHandler, 
 schema = 'main', 
 characterizationTargetIds = 1
)
 
```
