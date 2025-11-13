# Extract the outcome cohorts and where they are used in the analyses.

This function extracts the outcome cohorts, the number of
subjects/entries and where the cohort was used.

## Usage

``` r
getOutcomeTable(
  connectionHandler,
  schema,
  cgTablePrefix = "cg_",
  cTablePrefix = "c_",
  ciTablePrefix = "ci_",
  cmTablePrefix = "cm_",
  sccsTablePrefix = "sccs_",
  plpTablePrefix = "plp_",
  databaseTable = "database_meta_data",
  targetId = NULL,
  getIncidenceInclusion = TRUE,
  getCharacterizationInclusion = TRUE,
  getPredictionInclusion = TRUE,
  getCohortMethodInclusion = TRUE,
  getSccsInclusion = TRUE,
  printTimes = FALSE
)
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

- cTablePrefix:

  The prefix used for the characterization results tables

- ciTablePrefix:

  The prefix used for the cohort incidence results tables

- cmTablePrefix:

  The prefix used for the cohort method results tables

- sccsTablePrefix:

  The prefix used for the cohort generator results tables

- plpTablePrefix:

  The prefix used for the patient level prediction results tables

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

- targetId:

  An integer corresponding to the target cohort ID

- getIncidenceInclusion:

  Whether to check usage of the cohort in incidence

- getCharacterizationInclusion:

  Whether to check usage of the cohort in characterization

- getPredictionInclusion:

  Whether to check usage of the cohort in prediction

- getCohortMethodInclusion:

  Whether to check usage of the cohort in cohort method

- getSccsInclusion:

  Whether to check usage of the cohort in SCCS

- printTimes:

  whether to print the time it takes to run each SQL query

## Value

Returns a data.frame with the columns:

- cohortId the number id for the target cohort

- cohortName the name of the cohort

- subsetParent the number id of the parent cohort

- subsetDefinitionId the number id of the subset

- numDatabase number of databases with the cohort

- databaseString all the names of the databases with the cohort

- databaseIdString all the ids of the databases with the cohort

- databaseStringCount all the names of the databases with the cohort
  plus their counts

- databaseCount all the names of the databases with the cohort and their
  sizes

- minSubjectCount number of subjects in databases with lowest count

- maxSubjectCount number of subjects in databases with highest count

- minEntryCount number of entries in databases with lowest count

- maxEntryCount number of entries in databases with highest count

- cohortIncidence whether the cohort was used in cohort incidence

- dechalRechal whether the cohort was used in dechallenge rechallenge

- riskFactors whether the cohort was used in risk factors

- caseSeries whether the cohort was used in case series analysis

- timeToEvent whether the cohort was used in time to event

- prediction whether the cohort was used in prediction

- cohortMethod whether the cohort was used in cohort method

- selfControlledCaseSeries whether the cohort was used in self
  controlled case series

## Details

Specify the connectionHandler, the schema and the table prefixes

## See also

Other helper: [`addTarColumn()`](addTarColumn.md),
[`formatBinaryCovariateName()`](formatBinaryCovariateName.md),
[`getExampleConnectionDetails()`](getExampleConnectionDetails.md),
[`getTargetTable()`](getTargetTable.md), [`kableDark()`](kableDark.md),
[`printReactable()`](printReactable.md),
[`removeSpaces()`](removeSpaces.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

outcomeTable <- getOutcomeTable(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
#> [1] "Extracting characterization outcomes took: 0.0726029872894287 secs"
#> [1] "-- Total time for extarcting outcome table: 0.206499814987183 secs"
```
