# removeSpaces

Removes spaces and replaces with under scroll

## Usage

``` r
removeSpaces(x)
```

## Arguments

- x:

  A string

## Value

A string without spaces

## Details

Removes spaces and replaces with under scroll

## See also

Other helper: [`addTarColumn()`](addTarColumn.md),
[`formatBinaryCovariateName()`](formatBinaryCovariateName.md),
[`formatTargetPopulation()`](formatTargetPopulation.md),
[`getExampleConnectionDetails()`](getExampleConnectionDetails.md),
[`getOutcomeTable()`](getOutcomeTable.md),
[`getTarText()`](getTarText.md),
[`getTargetTable()`](getTargetTable.md), [`kableDark()`](kableDark.md)

## Examples

``` r
removeSpaces(' made up.   string')
#> [1] "_made_up___string"
```
