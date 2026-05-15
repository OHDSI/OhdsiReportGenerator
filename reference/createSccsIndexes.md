# A function to add indexes to the SCCS results

A function to add indexes to the SCCS results

## Usage

``` r
createSccsIndexes(connectionHandler, schema, sccsTablePrefix = "sccs_")
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- sccsTablePrefix:

  The prefix used for the cohort generator results tables

## Details

Specify the connectionHandler, the schema and the prefixes

## See also

Other Indexes:
[`createCharacterizationIndexes()`](createCharacterizationIndexes.md),
[`createCohortIndexes()`](createCohortIndexes.md),
[`createIncidenceIndexes()`](createIncidenceIndexes.md)
