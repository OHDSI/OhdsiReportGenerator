# create a connection detail for an example OHDSI results database

This returns an object of class \`ConnectionDetails\` that lets you
connect via \`DatabaseConnector::connect()\` to the example result
database.

## Usage

``` r
getExampleConnectionDetails(exdir = tempdir())
```

## Arguments

- exdir:

  a directory to unzip the example result data into. Default is
  tempdir().

## Value

An object of class \`ConnectionDetails\` with the details to connect to
the example OHDSI result database

## Details

Finds the location of the example result database in the package and
calls \`DatabaseConnector::createConnectionDetails\` to create a
\`ConnectionDetails\` object for connecting to the database.

## See also

Other helper: [`addTarColumn()`](addTarColumn.md),
[`formatBinaryCovariateName()`](formatBinaryCovariateName.md),
[`getOutcomeTable()`](getOutcomeTable.md),
[`getTargetTable()`](getTargetTable.md), [`kableDark()`](kableDark.md),
[`printReactable()`](printReactable.md),
[`removeSpaces()`](removeSpaces.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver
```
