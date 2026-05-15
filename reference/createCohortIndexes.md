# A function to add indexes to the Cohort Generator results

A function to add indexes to the Cohort Generator results

## Usage

``` r
createCohortIndexes(connectionHandler, schema, cgTablePrefix = "cg_")
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- cgTablePrefix:

  The prefix used for the cohort generator results tables

## Details

Specify the connectionHandler, the schema and the prefixes

## See also

Other Indexes:
[`createCharacterizationIndexes()`](createCharacterizationIndexes.md),
[`createIncidenceIndexes()`](createIncidenceIndexes.md),
[`createSccsIndexes()`](createSccsIndexes.md)
