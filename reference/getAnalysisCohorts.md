# Extracts the different analyses ran for each target and event cohorts

This function extracts analysis ids, events cohorts, and databases per
target from treatment patterns

## Usage

``` r
getAnalysisCohorts(connectionHandler, schema, tpTablePrefix = "tp_")
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- tpTablePrefix:

  The prefix used for the cohort generator results tables

## Value

Returns a data.frame with the columns:

- databaseName a concatinated string of all the database names ran for
  that analysis

- databaseId a concatinated string of all the database ids ran for that
  analysis

- analysisId the analysis ids for the treament patterns run

- targetCohortName the target cohort name

- targetCohortId the target cohort unique identifier

- eventCohortList a concatinated string of all the event cohort names
  ran for that target

- exitCohortList a concatinated string of all the exit cohort names ran
  for that target

## Details

Specify the connectionHandler and the schema

## See also

Other TreatmentPatterns: [`getEventDuration()`](getEventDuration.md),
[`getTreatmentPathways()`](getTreatmentPathways.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

cohortAnalysis <- getAnalysisCohorts(
  connectionHandler = connectionHandler,
  schema = "main"
)
```
