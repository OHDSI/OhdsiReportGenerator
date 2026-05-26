# Extracts treatment pathways

This function extracts results pathways for specified analysis ids and
target cohorts

## Usage

``` r
getTreatmentPathways(
  connectionHandler,
  schema,
  tpTablePrefix = "tp_",
  databaseTable = "database_meta_data",
  age = "all",
  sex = "all",
  indexYear = "all",
  analysisIds = NULL,
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

- tpTablePrefix:

  The prefix used for the cohort generator results tables

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- age:

  (optional) a string representing an age bucket to restrict (e.g.,
  "0-17", "18-34", "65+")

- sex:

  (optional) A string "male" or "female" to restrict

- indexYear:

  (optional) A string with a four-digit year to restrict

- analysisIds:

  (optional) A vector of analysis ids to restrict to

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

- targetCohortName the target cohort name

- targetCohortId the target cohort unique identifier

- pathway a string representing the progression of events for a target.
  Use '-' to separate sequential steps and '+' for combination of events
  at that step

- freq the count of pathway occurance

- age the stratifyed pathways for age

- indexYear the stratifyed pathways for index year

- sex the stratifyed pathways for sex

## Details

Specify the connectionHandler and the schema

## See also

Other TreatmentPatterns:
[`getAnalysisCohorts()`](getAnalysisCohorts.md),
[`getEventDuration()`](getEventDuration.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

tp <- getTreatmentPathways(
  connectionHandler = connectionHandler,
  schema = "main"
)
#> Closing database connection
```
