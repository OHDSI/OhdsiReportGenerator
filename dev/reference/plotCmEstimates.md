# Plots the cohort method results for one analysis

Creates nice cohort method plots

## Usage

``` r
plotCmEstimates(
  cmData,
  cmDiagnostics = NULL,
  cmMeta = NULL,
  cohortNames = NULL,
  includeCounts = TRUE,
  selectedAnalysisId = NULL
)
```

## Arguments

- cmData:

  The cohort method data

- cmDiagnostics:

  (optional) The cohort method diagnostic data

- cmMeta:

  (optional) The cohort method evidence synthesis data

- cohortNames:

  A data.frame with columns cohortId and cohortName

- includeCounts:

  Whether to include the target/comp size and event counts

- selectedAnalysisId:

  The analysis ID of interest to plot

## Value

Returns a ggplot with the estimates

## Details

Input the cohort method data

## See also

Other Estimation: [`.getCmVersion()`](dot-getCmVersion.md),
[`.getSccsVersion()`](dot-getSccsVersion.md),
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
#> refline_col will be deprecated, use refline_gp instead.
#> footnote_col will be deprecated, use footnote_gp instead.
#> $`Celecoxib - first event with 365 prior obs first event with 365 prior obs-GI bleed-NA`

#> 
```
