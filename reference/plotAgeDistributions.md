# Plots the age distributions using the binary age groups

Creates bar charts for the target.

## Usage

``` r
plotAgeDistributions(ageData)
```

## Arguments

- ageData:

  The age data extracted using 'getCharacterizationDemographics(type =
  'age')'

## Value

Returns a ggplot with the distributions

## Details

Input the data returned from 'getCharacterizationDemographics(type =
'age')'

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
[`getOutcomesUsedInCharacterization()`](getOutcomesUsedInCharacterization.md),
[`getOutcomesUsedInIncidence()`](getOutcomesUsedInIncidence.md),
[`getTargetCounts()`](getTargetCounts.md),
[`getTargetsUsedInCharacterization()`](getTargetsUsedInCharacterization.md),
[`getTargetsUsedInIncidence()`](getTargetsUsedInIncidence.md),
[`getTimeToEvent()`](getTimeToEvent.md),
[`plotSexDistributions()`](plotSexDistributions.md),
[`viewIncidenceRate()`](viewIncidenceRate.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

ageData <- getCharacterizationDemographics(
connectionHandler = connectionHandler, 
schema = 'main',
characterizationTargetId = 10, 
type = 'age'
)

plotAgeDistributions(ageData = ageData)
#> NULL
```
