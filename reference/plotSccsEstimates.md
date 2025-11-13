# Plots the self controlled case series results for one analysis

Creates nice self controlled case series plots

## Usage

``` r
plotSccsEstimates(sccsData, sccsMeta = NULL, targetName, selectedAnalysisId)
```

## Arguments

- sccsData:

  The self controlled case series data

- sccsMeta:

  (optional) The self controlled case seriesd evidence synthesis data

- targetName:

  A friendly name for the target cohort

- selectedAnalysisId:

  The analysis ID of interest to plot

## Value

Returns a ggplot with the estimates

## Details

Input the self controlled case series data

## See also

Other Estimation: [`getCMEstimation()`](getCMEstimation.md),
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
[`plotCmEstimates()`](plotCmEstimates.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

sccsEst <- getSccsEstimation(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1,
  outcomeIds = 3
)
plotSccsEstimates(
  sccsData = sccsEst, 
  sccsMeta = NULL, 
  targetName = 'target', 
  selectedAnalysisId = 1
)
#> Warning: lower bound is zero - can not use log scale

```
