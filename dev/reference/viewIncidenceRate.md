# View the Incidence Rates

Creates a table with the incidence rates and optionally demographics

## Usage

``` r
viewIncidenceRate(
  incidenceData,
  ageData = NULL,
  genderData = NULL,
  stratification = "overall",
  maxAgeSampleSize = 5000
)
```

## Arguments

- incidenceData:

  The data extracted using 'getIncidenceRates'

- ageData:

  The data extracted using 'getBinaryTargetBaseline' with analysisIds =
  3

- genderData:

  The data extracted using 'getBinaryTargetBaseline' with analysisIds =
  1

- stratification:

  Pick either overall/age/sex/year to specify whether to view the
  overall rates or stratified by age/sex/year

- maxAgeSampleSize:

  When creating the age distributions this is the max age vector length
  to create

## Value

Returns a gt table that displays the incidence rates

## Details

Input the incidence rate data (and optionally demographic data)

## See also

Other Characterization:
[`getBinaryCaseSeries()`](getBinaryCaseSeries.md),
[`getBinaryRiskFactors()`](getBinaryRiskFactors.md),
[`getBinaryTargetBaseline()`](getBinaryTargetBaseline.md),
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
schema <- 'main'

incidenceData <- getIncidenceRates(
  connectionHandler = connectionHandler , 
  schema = schema
  )
  
  # incidence data does not have rate values to imputing them
  incidenceData$incidenceRateP100py <- 1 +
    sample(c(-1,1),replace = TRUE)*runif(nrow(incidenceData))
  incidenceData$incidenceProportionP100p <- 0.5 +
    sample(c(-1,1),replace = TRUE)*runif(nrow(incidenceData))
  
 ageData <- getBinaryTargetBaseline(
  connectionHandler = connectionHandler, 
  schema = schema,  
  analysisIds = 3
 )
 
 genderData <- getBinaryTargetBaseline(
  connectionHandler = connectionHandler, 
  schema = schema,  
  analysisIds = 1
 )

viewIncidenceRate(
  incidenceData = incidenceData,
  ageData = ageData,
  genderData = genderData
  )


  
```
