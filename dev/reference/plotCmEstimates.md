# Plots the cohort method results for one analysis

Creates nice cohort method plots

## Usage

``` r
plotCmEstimates(cmData, cmMeta = NULL, cohortNames = NULL, selectedAnalysisId)
```

## Arguments

- cmData:

  The cohort method data

- cmMeta:

  (optional) The cohort method evidence synthesis data

- cohortNames:

  A data.frame with columns cohortId and cohortName

- selectedAnalysisId:

  The analysis ID of interest to plot

## Value

Returns a ggplot with the estimates

## Details

Input the cohort method data

## See also

Other Estimation: [`.getCmVersion()`](dot-getCmVersion.md),
[`getCMEstimation()`](getCMEstimation.md),
[`getCmDiagnosticsData()`](getCmDiagnosticsData.md),
[`getCmMetaEstimation()`](getCmMetaEstimation.md),
[`getCmNegativeControlEstimates()`](getCmNegativeControlEstimates.md),
[`getCmOutcomes()`](getCmOutcomes.md),
[`getCmPropensityModel()`](getCmPropensityModel.md),
[`getCmTable()`](getCmTable.md), [`getCmTargets()`](getCmTargets.md),
[`getSccsDiagnosticsData()`](getSccsDiagnosticsData.md),
[`getSccsEstimation()`](getSccsEstimation.md),
[`getSccsMetaEstimation()`](getSccsMetaEstimation.md),
[`getSccsModel()`](getSccsModel.md),
[`getSccsNegativeControlEstimates()`](getSccsNegativeControlEstimates.md),
[`getSccsOutcomes()`](getSccsOutcomes.md),
[`getSccsTable()`](getSccsTable.md),
[`getSccsTargets()`](getSccsTargets.md),
[`getSccsTimeToEvent()`](getSccsTimeToEvent.md),
[`plotSccsEstimates()`](plotSccsEstimates.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cmEst <- getCMEstimation(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1002,
  outcomeIds = 3
)
plotCmEstimates(
  cmData = cmEst, 
  cmMeta = NULL, 
  selectedAnalysisId = 1
)
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection

#> $`1002-3`
#> 
```
