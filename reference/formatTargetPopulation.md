# output a string summarizing the target population

This returns a character that describes the target population

## Usage

``` r
formatTargetPopulation(popSetting)
```

## Arguments

- popSetting:

  the target population setting

## Value

An object of class \`knitr_kable\` that will show the data via a nice
html table

## Details

Input the target population setting list

## See also

Other helper: [`addTarColumn()`](addTarColumn.md),
[`formatBinaryCovariateName()`](formatBinaryCovariateName.md),
[`getExampleConnectionDetails()`](getExampleConnectionDetails.md),
[`getOutcomeTable()`](getOutcomeTable.md),
[`getTarText()`](getTarText.md),
[`getTargetTable()`](getTargetTable.md), [`kableDark()`](kableDark.md),
[`removeSpaces()`](removeSpaces.md)

## Examples

``` r
targetText <- formatTargetPopulation(
list(
limitToFirstInNDays = 365,
minPriorObservation = 365,
nestingName = 'Indication',
minAge = 12, maxAge = 9999,
studyEnd = 'Mar 2012', studyStart = NA,
genderConceptIds = NA
)
)
#> Warning: NAs introduced by coercion
```
