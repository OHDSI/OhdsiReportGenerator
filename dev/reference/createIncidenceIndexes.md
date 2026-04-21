# A function to add indexes to the incidence results

A function to add indexes to the incidence results

## Usage

``` r
createIncidenceIndexes(connectionHandler, schema, ciTablePrefix = "ci_")
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- ciTablePrefix:

  The prefix used for the cohort incidence results tables

## Details

Specify the connectionHandler, the schema and the prefixes

## See also

Other Indexes:
[`createCharacterizationIndexes()`](createCharacterizationIndexes.md),
[`createCohortIndexes()`](createCohortIndexes.md),
[`createSccsIndexes()`](createSccsIndexes.md)
