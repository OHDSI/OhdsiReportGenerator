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
[`getExampleConnectionDetails()`](getExampleConnectionDetails.md),
[`getOutcomeTable()`](getOutcomeTable.md),
[`getTargetTable()`](getTargetTable.md), [`kableDark()`](kableDark.md),
[`printReactable()`](printReactable.md)

## Examples

``` r
removeSpaces(' made up.   string')
#> [1] "_made_up___string"
```
