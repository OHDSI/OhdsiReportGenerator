# addTarColumn

Finds the four TAR columns and creates a new column called tar that
pastes the columns into a nice string

## Usage

``` r
addTarColumn(data)
```

## Arguments

- data:

  The data.frame with the individual TAR columns that you want to
  combine into one column

## Value

The data data.frame object with the tar column added if seperate TAR
columns are found

## Details

Create a friendly single tar column

## See also

Other helper:
[`formatBinaryCovariateName()`](formatBinaryCovariateName.md),
[`getExampleConnectionDetails()`](getExampleConnectionDetails.md),
[`getOutcomeTable()`](getOutcomeTable.md),
[`getTargetTable()`](getTargetTable.md), [`kableDark()`](kableDark.md),
[`printReactable()`](printReactable.md),
[`removeSpaces()`](removeSpaces.md)

## Examples

``` r
addTarColumn(data.frame(
tarStartWith = 'cohort start',
tarStartOffset = 1,
tarEndWith = 'cohort start',
tarEndOffset = 0
))
#> Found CI TAR columns
#>   tarStartWith tarStartOffset   tarEndWith tarEndOffset
#> 1 cohort start              1 cohort start            0
#>                                       tar
#> 1 (cohort start + 1) - (cohort start + 0)
```
