# A function to extract the outcomes found in characterization

A function to extract the outcomes found in characterization

## Usage

``` r
getOutcomesUsedInCharacterization(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  characterizationTargetId = NULL,
  targetId = NULL,
  printTimes = FALSE,
  useDcrc = TRUE,
  useTte = TRUE,
  useRf = TRUE,
  useCs = TRUE
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

  A vector of characterizationTargetIds to restrict to

- targetId:

  An integer corresponding to the target cohort ID

- printTimes:

  Print the time it takes to run each query

- useDcrc:

  look for outcome in dechal-rechal results

- useTte:

  look for outcome in time-to-event results

- useRf:

  look for outcome in risk-factor results

- useCs:

  look for outcome in case series results

## Value

A data.frame with the characterization outcome cohort ids, names and
which characterization analyses the cohorts are used in.

## Details

Specify the connectionHandler, the schema and the prefixes

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
[`getContinuousCaseSeries()`](getContinuousCaseSeries.md),
[`getContinuousRiskFactors()`](getContinuousRiskFactors.md),
[`getContinuousTargetBaseline()`](getContinuousTargetBaseline.md),
[`getDechallengeRechallenge()`](getDechallengeRechallenge.md),
[`getDechallengeRechallengeFails()`](getDechallengeRechallengeFails.md),
[`getIncidenceRates()`](getIncidenceRates.md),
[`getIncidenceTargetSettings()`](getIncidenceTargetSettings.md),
[`getNonCaseCounts()`](getNonCaseCounts.md),
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

cohorts <- getOutcomesUsedInCharacterization(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
```
