# A function to extract binary risk factor across databases

A function to extract binary risk factor across databases

## Usage

``` r
getAggregateBinaryRiskFactors(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  characterizationTargetId = NULL,
  characterizationCaseId = NULL,
  outcomeId = NULL,
  outcomeWashout = NULL,
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

- characterizationTargetId:

  the characterization target id

- characterizationCaseId:

  the characterization case id

- outcomeId:

  Am integer corresponding to the outcome cohort ID

- outcomeWashout:

  (optional) restrict to outcome washout

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

A data.frame with the aggregate binary risk factors

## Details

Specify the connectionHandler, the schema and the target/outcome cohort
IDs

## See also

Other Characterization:
[`characterizationCompareBinary()`](characterizationCompareBinary.md),
[`characterizationCompareContinuous()`](characterizationCompareContinuous.md),
[`getAggregateContinuousRiskFactors()`](getAggregateContinuousRiskFactors.md),
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

rf <- getAggregateBinaryRiskFactors(
  connectionHandler = connectionHandler, 
  schema = 'main',
  characterizationTargetId = 1, 
  outcomeId = 3
)
#> Warning: Parameter 'use_risk_window_start' not found in SQL
#> Warning: Parameter 'risk_window_start' not found in SQL
#> Warning: Parameter 'use_risk_window_end' not found in SQL
#> Warning: Parameter 'risk_window_end' not found in SQL
#> Warning: Parameter 'use_start_anchor' not found in SQL
#> Warning: Parameter 'start_anchor' not found in SQL
#> Warning: Parameter 'use_end_anchor' not found in SQL
#> Warning: Parameter 'end_anchor' not found in SQL
```
