# A function to add indexes to the Characterization results

A function to add indexes to the Characterization results

## Usage

``` r
createCharacterizationIndexes(connectionHandler, schema, cTablePrefix = "c_")
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- cTablePrefix:

  The prefix used for the characterization results tables

## Details

Specify the connectionHandler, the schema and the prefixes

## See also

Other Indexes: [`createCohortIndexes()`](createCohortIndexes.md),
[`createIncidenceIndexes()`](createIncidenceIndexes.md),
[`createSccsIndexes()`](createSccsIndexes.md)
