# A function to extract case series continuous feature characterization results

A function to extract case series continuous feature characterization
results

## Usage

``` r
getContinuousCaseSeries(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  characterizationTargetId = NULL,
  characterizationCaseId = NULL,
  outcomeId = NULL,
  databaseIds = NULL,
  riskWindowStart = NULL,
  riskWindowEnd = NULL,
  startAnchor = NULL,
  endAnchor = NULL,
  outcomeWashout = NULL
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

- characterizationTargetId:

  The characterization target id to restrict results to

- characterizationCaseId:

  The characterization case id to restrict results to

- outcomeId:

  Am integer corresponding to the outcome cohort ID

- databaseIds:

  (optional) One or more unique identifiers for the databases

- riskWindowStart:

  (optional) A riskWindowStart to restrict to

- riskWindowEnd:

  (optional) A riskWindowEnd to restrict to

- startAnchor:

  (optional) A startAnchor to restrict to

- endAnchor:

  (optional) An endAnchor to restrict to

- outcomeWashout:

  (optional) the outcomeWashout to restrict to

## Value

A data.frame with the characterization case series results

## Details

Specify the connectionHandler, the schema and the target/outcome cohort
IDs

## See also

Other Characterization:
[`characterizationCompareBinary()`](characterizationCompareBinary.md),
[`characterizationCompareContinuous()`](characterizationCompareContinuous.md),
[`getAggregateBinaryRiskFactors()`](getAggregateBinaryRiskFactors.md),
[`getAggregateContinuousRiskFactors()`](getAggregateContinuousRiskFactors.md),
[`getBinaryCaseSeries()`](getBinaryCaseSeries.md),
[`getBinaryRiskFactors()`](getBinaryRiskFactors.md),
[`getBinaryTargetBaseline()`](getBinaryTargetBaseline.md),
[`getCaseCounts()`](getCaseCounts.md),
[`getCharacterizationCaseSettings()`](getCharacterizationCaseSettings.md),
[`getCharacterizationDemographics()`](getCharacterizationDemographics.md),
[`getCharacterizationTargetSettings()`](getCharacterizationTargetSettings.md),
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

cs <- getContinuousCaseSeries(
  connectionHandler = connectionHandler, 
  schema = 'main',
  characterizationTargetId = 1, 
  outcomeId = 3
)
```
