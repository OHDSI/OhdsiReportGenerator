# Extract aggregate statistics of continuous feature analysis IDs of interest for targets

This function extracts the continuous feature extraction results for
cases corresponding to specified target and outcome cohorts.

## Usage

``` r
getCaseContinuousFeatures(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetIds = NULL,
  outcomeIds = NULL,
  analysisIds = NULL,
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

- analysisIds:

  The feature extraction analysis ID of interest (e.g., 201 is
  condition)

- databaseIds:

  (optional) A vector of database IDs to restrict results to

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

- minPriorObservation the minimum required observation days prior to
  index for an entry

- outcomeWashoutDays patients with the outcome occurring within this
  number of days prior to index are excluded (NA means no exclusion)

- riskWindowStart the time at risk start point

- riskWindowEnd the time at risk end point

- startAnchor the time at risk start point offset

- endAnchor the time at risk end point offset

- covariateName the name of the feature

- covariateId the id of the feature

- countValue the number of cases who have the feature

- minValue the minimum value observed for the feature

- maxValue the maximum value observed for the feature

- averageValue the mean value observed for the feature

- standardDeviation the standard deviation of the value observed for the
  feature

- medianValue the median value observed for the feature

- p10Value the 10th percentile of the value observed for the feature

- p25Value the 25th percentile of the value observed for the feature

- p75Value the 75th percentile of the value observed for the feature

- p90Value the 90th percentile of the value observed for the feature

## Details

Specify the connectionHandler, the schema and the target/outcome cohort
IDs

## See also

Other Characterization:
[`getBinaryCaseSeries()`](getBinaryCaseSeries.md),
[`getBinaryRiskFactors()`](getBinaryRiskFactors.md),
[`getCaseBinaryFeatures()`](getCaseBinaryFeatures.md),
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

ccf <- getCaseContinuousFeatures(
connectionHandler = connectionHandler, 
schema = 'main'
)
```
