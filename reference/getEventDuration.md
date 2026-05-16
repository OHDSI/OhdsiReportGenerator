# Extracts summary of event duration

This function extracts results summary stats of event duration for
specified analysis ids and target cohorts

## Usage

``` r
getEventDuration(
  connectionHandler,
  schema,
  analysisIds,
  tpTablePrefix = "tp_",
  databaseTable = "database_meta_data",
  databaseIds = NULL,
  databaseNames = NULL,
  targetIds = NULL
)
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- analysisIds:

  A vector of analysis ids to restrict to

- tpTablePrefix:

  The prefix used for the cohort generator results tables

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- databaseIds:

  (optional) A vector of database ids to restrict to

- databaseNames:

  (optional) A vector of database Names to restrict to

- targetIds:

  (optional) A vector of target cohort ids to restrict to

## Value

Returns a data.frame with the columns:

- databaseName the name of the database

- databaseId the unique identifier of the database

- analysisId the unique identifier of a treament patterns run

- targetCohortId the target cohort unique identifier

- targetCohortName the target cohort name

- eventName a string representing an events for a target. Uses '+' for
  combination of event cohorts

- rank the step number of event occurance

- eventCount the count of event occurance at rank

- durationAverage the average duration of event

- durationMax the maximum duration of event

- durationMin the minimum duration of event

- durationMedian the median duration of event

- p25Value the 25th percentile for duration of event

- p75Value the 75th percentile for duration of event

- standardDeviation the standard deviation for duration of event

## Details

Specify the connectionHandler, the schema, and the analysisIds

## See also

Other TreatmentPatterns:
[`getAnalysisCohorts()`](getAnalysisCohorts.md),
[`getTreatmentPathways()`](getTreatmentPathways.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

ed <- getEventDuration(
  connectionHandler = connectionHandler,
  schema = "main",
  analysisIds = c(1)
)
```
