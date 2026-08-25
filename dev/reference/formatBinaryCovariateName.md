# formatBinaryCovariateName

Removes the long part of the covariate name to make it friendly

## Usage

``` r
formatBinaryCovariateName(data)
```

## Arguments

- data:

  The data.frame with the covariateName column

## Value

The data data.frame object with the ovariateName column changed to be
more friendly

## Details

Makes the covariateName more friendly and shorter

## See also

Other helper: [`addTarColumn()`](addTarColumn.md),
[`formatTargetPopulation()`](formatTargetPopulation.md),
[`getExampleConnectionDetails()`](getExampleConnectionDetails.md),
[`getOutcomeTable()`](getOutcomeTable.md),
[`getTarText()`](getTarText.md),
[`getTargetTable()`](getTargetTable.md), [`kableDark()`](kableDark.md),
[`removeSpaces()`](removeSpaces.md)

## Examples

``` r
formatBinaryCovariateName(data.frame(
covariateName = c("fdfgfgf: dgdgff","made up test")
))
#>       covariateName
#> 1            dgdgff
#> 2 Unknown covariate
```
