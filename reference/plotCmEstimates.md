# Plots the cohort method results for one analysis

Creates nice cohort method plots

## Usage

``` r
plotCmEstimates(
  cmData,
  cmMeta = NULL,
  targetName,
  comparatorName,
  selectedAnalysisId
)
```

## Arguments

- cmData:

  The cohort method data

- cmMeta:

  (optional) The cohort method evidence synthesis data

- targetName:

  A friendly name for the target cohort

- comparatorName:

  A friendly name for the comparator cohort

- selectedAnalysisId:

  The analysis ID of interest to plot

## Value

Returns a ggplot with the estimates

## Details

Input the cohort method data

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
[`plotSccsEstimates()`](plotSccsEstimates.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cmEst <- getCMEstimation(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1,
  outcomeIds = 3
)
plotCmEstimates(
  cmData = cmEst, 
  cmMeta = NULL, 
  targetName = 'target', 
  comparatorName = 'comp', 
  selectedAnalysisId = 1
)
#> NULL
```
