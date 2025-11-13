# Plots the age distributions using the binary age groups

Creates bar charts for the target and case age groups.

## Usage

``` r
plotAgeDistributions(
  ageData,
  riskWindowStart = "1",
  riskWindowEnd = "365",
  startAnchor = "cohort start",
  endAnchor = "cohort start"
)
```

## Arguments

- ageData:

  The age data extracted using 'getCharacterizationDemographics(type =
  'age')'

- riskWindowStart:

  The time at risk window start

- riskWindowEnd:

  The time at risk window end

- startAnchor:

  The anchor for the time at risk start

- endAnchor:

  The anchor for the time at risk end

## Value

Returns a ggplot with the distributions

## Details

Input the data returned from 'getCharacterizationDemographics(type =
'age')' and the time-at-risk

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
[`getTargetBinaryFeatures()`](getTargetBinaryFeatures.md),
[`getTargetContinuousFeatures()`](getTargetContinuousFeatures.md),
[`getTimeToEvent()`](getTimeToEvent.md),
[`plotSexDistributions()`](plotSexDistributions.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

ageData <- getCharacterizationDemographics(
connectionHandler = connectionHandler, 
schema = 'main',
targetId = 1, 
outcomeId = 3, 
type = 'age'
)

plotAgeDistributions(ageData = ageData)

```
