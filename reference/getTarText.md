# output a string summarizing the time at risk

This returns a character that describes the time at risk

## Usage

``` r
getTarText(tar)
```

## Arguments

- tar:

  a list containing the four tar setting

## Value

An character string describing the tar

## Details

Input the tar settings

## See also

Other helper: [`addTarColumn()`](addTarColumn.md),
[`formatBinaryCovariateName()`](formatBinaryCovariateName.md),
[`formatTargetPopulation()`](formatTargetPopulation.md),
[`getExampleConnectionDetails()`](getExampleConnectionDetails.md),
[`getOutcomeTable()`](getOutcomeTable.md),
[`getTargetTable()`](getTargetTable.md), [`kableDark()`](kableDark.md),
[`removeSpaces()`](removeSpaces.md)

## Examples

``` r
targetText <- getTarText(
list(
startAnchor = 'cohort_start',
riskWindowStart = 1,
endAnchor = 'cohort_end',
riskWindowEnd = 0
)
)
```
