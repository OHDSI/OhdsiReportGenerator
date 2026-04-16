# prints a reactable in a quarto document

This function lets you print a reactable in a quarto document

## Usage

``` r
printReactable(
  data,
  columns = NULL,
  groupBy = NULL,
  defaultPageSize = 20,
  highlight = TRUE,
  striped = TRUE,
  searchable = TRUE,
  filterable = TRUE
)
```

## Arguments

- data:

  The data for the table

- columns:

  The formating for the columns

- groupBy:

  A column or columns to group the table by

- defaultPageSize:

  The number of rows in the table

- highlight:

  whether to highlight the row of interest

- striped:

  whether the rows change color to give a striped appearance

- searchable:

  whether you can search in the table

- filterable:

  whether you can filter the table

## Value

Nothing but the html code for the table is printed (to be used in a
quarto document)

## Details

Input the values for reactable::reactable

## See also

Other helper: [`addTarColumn()`](addTarColumn.md),
[`formatBinaryCovariateName()`](formatBinaryCovariateName.md),
[`getExampleConnectionDetails()`](getExampleConnectionDetails.md),
[`getOutcomeTable()`](getOutcomeTable.md),
[`getTargetTable()`](getTargetTable.md), [`kableDark()`](kableDark.md),
[`removeSpaces()`](removeSpaces.md)

## Examples

``` r
printReactable(
data = data.frame(a=1,b=4)
)
#> <div class="reactable html-widget html-fill-item" id="htmlwidget-ac96cb3ee4656e2e9ec3" style="width:auto;height:auto;"></div>
#> <script type="application/json" data-for="htmlwidget-ac96cb3ee4656e2e9ec3">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"a":[1],"b":[4]},"columns":[{"id":"a","name":"a","type":"numeric"},{"id":"b","name":"b","type":"numeric"}],"filterable":true,"searchable":true,"defaultPageSize":20,"highlight":true,"striped":true,"dataKey":"74006b58611cd0240b77609648c1a054"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
```
