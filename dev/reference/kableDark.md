# output a nicely formatted html table

This returns a html table with the input data

## Usage

``` r
kableDark(data, caption = NULL, position = NULL)
```

## Arguments

- data:

  A data.frame containing data of interest to show via a table

- caption:

  A caption for the table

- position:

  The position for the table if used within a quarto document. This is
  the "real" or say floating position for the latex table environment.
  The kable only puts tables in a table environment when a caption is
  provided. That is also the reason why your tables will be floating
  around if you specify captions for your table. Possible choices are h
  (here), t (top, default), b (bottom) and p (on a dedicated page).

## Value

An object of class \`knitr_kable\` that will show the data via a nice
html table

## Details

Input the data that you want to be shown via a dark html table

## See also

Other helper: [`addTarColumn()`](addTarColumn.md),
[`formatBinaryCovariateName()`](formatBinaryCovariateName.md),
[`getExampleConnectionDetails()`](getExampleConnectionDetails.md),
[`getOutcomeTable()`](getOutcomeTable.md),
[`getTargetTable()`](getTargetTable.md),
[`printReactable()`](printReactable.md),
[`removeSpaces()`](removeSpaces.md)

## Examples

``` r
kableDark(
data = data.frame(a=1,b=4), 
caption = 'A made up table to demonstrate this function',
position = 'h'
)
#> <table class=" lightable-material-dark lightable-hover" style='font-family: "Source Sans Pro", helvetica, sans-serif; margin-left: auto; margin-right: auto;'>
#> <caption>A made up table to demonstrate this function</caption>
#>  <thead>
#>   <tr>
#>    <th style="text-align:right;"> a </th>
#>    <th style="text-align:right;"> b </th>
#>   </tr>
#>  </thead>
#> <tbody>
#>   <tr>
#>    <td style="text-align:right;"> 1 </td>
#>    <td style="text-align:right;"> 4 </td>
#>   </tr>
#> </tbody>
#> </table>
```
