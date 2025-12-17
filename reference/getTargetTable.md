# Extract the target cohorts and where they are used in the analyses.

This function extracts the target cohorts, the number of
subjects/entries and where the cohort was used.

## Usage

``` r
getTargetTable(
  connectionHandler,
  schema,
  cgTablePrefix = "cg_",
  cTablePrefix = "c_",
  ciTablePrefix = "ci_",
  cmTablePrefix = "cm_",
  sccsTablePrefix = "sccs_",
  plpTablePrefix = "plp_",
  databaseTable = "database_meta_data",
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

- getIncidenceInclusion:

  Whether to check useage of the cohort in incidence

- getCharacterizationInclusion:

  Whether to check useage of the cohort in characterization

- getPredictionInclusion:

  Whether to check useage of the cohort in prediction

- getCohortMethodInclusion:

  Whether to check useage of the cohort in cohort method

- getSccsInclusion:

  Whether to check useage of the cohort in SCCS

- printTimes:

  Whether to print how long each query took

## Value

Returns a data.frame with the columns:

- cohortId the number id for the target cohort

- cohortName the name of the cohort

- subsetParent the number id of the parent cohort

- subsetDefinitionId the number id of the subset

- subsetDefinitionJson the json of the subset

- subsetCohortIds the ids of any cohorts that are restricted to by the
  subset logic

- numDatabase number of databases with the cohort

- databaseString all the names of the databases with the cohort

- databaseCount all the names of the databases with the cohort and their
  sizes

- minSubjectCount number of subjects in databases with lowest count

- maxSubjectCount number of subjects in databases with highest count

- minEntryCount number of entries in databases with lowest count

- maxEntryCount number of entries in databases with highest count

- cohortIncidence whether the cohort was used in cohort incidence

- databaseComparator whether the cohort was used in database comparator

- cohortComparator whether the cohort was used in cohort comparator

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
[`getOutcomeTable()`](getOutcomeTable.md),
[`kableDark()`](kableDark.md), [`printReactable()`](printReactable.md),
[`removeSpaces()`](removeSpaces.md)

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection
#> Closing database connection

targetTable <- getTargetTable(
  connectionHandler = connectionHandler, 
  schema = 'main'
)
#> [1] "-- all extracting characterization targets took: 0.0976214408874512 secs"
#> [1] "-- Total time for extarcting target table: 0.238523006439209 secs"
```
