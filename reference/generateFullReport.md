# generateFullReport

Generates a full report from a Strategus analysis

## Usage

``` r
generateFullReport(
  server,
  username,
  password,
  dbms,
  resultsSchema = NULL,
  targetId = 1,
  outcomeIds = 3,
  comparatorIds = 2,
  indicationIds = NULL,
  restrictTargetToIndications = FALSE,
  cohortNames = c("target name", "outcome name", "comp name"),
  cohortIds = c(1, 3, 2),
  includeCI = TRUE,
  includeCharacterization = TRUE,
  includeCohortMethod = TRUE,
  includeSccs = TRUE,
  includePrediction = TRUE,
  webAPI = NULL,
  authMethod = NULL,
  webApiUsername = NULL,
  webApiPassword = NULL,
  outputLocation,
  outputName = paste0("full_report_", gsub(":", "_", gsub(" ", "_",
    as.character(date()))), ".html"),
  intermediateDir = tempdir(),
  pathToDriver = Sys.getenv("DATABASECONNECTOR_JAR_FOLDER")
)
```

## Arguments

- server:

  The server containing the result database

- username:

  The username for an account that can access the result database

- password:

  The password for an account that can access the result database

- dbms:

  The dbms used to access the result database

- resultsSchema:

  The result database schema

- targetId:

  The cohort definition id for the target cohort

- outcomeIds:

  The cohort definition id for the outcome

- comparatorIds:

  (optional) The cohort definition id for any comparator cohorts. If
  NULL the report will find and include all possible comparators in the
  results if includeCohortMethod is TRUE.

- indicationIds:

  The cohort definition id for any indication cohorts to show in
  characterization. If no indication use NULL.

- restrictTargetToIndications:

  If you only want the results for targets that are nested by the
  indicationIds set this to TRUE otherwise results for all children of
  the targetId will be generated.

- cohortNames:

  Friendly names for any cohort used in the study

- cohortIds:

  The corresponding Ids for the cohortNames

- includeCI:

  Whether to include the cohort incidence slides

- includeCharacterization:

  Whether to include the characterization slides

- includeCohortMethod:

  Whether to include the cohort method slides

- includeSccs:

  Whether to include the self controlled case series slides

- includePrediction:

  Whether to include the patient level prediction slides

- webAPI:

  The ATLAS web API to use for the characterization index breakdown (set
  to NULL to not include)

- authMethod:

  The authorization method for the webAPI

- webApiUsername:

  The username for the webAPI authorization

- webApiPassword:

  The password for the webAPI authorization

- outputLocation:

  The file location and name to save the protocol

- outputName:

  The name of the html protocol that is created

- intermediateDir:

  The work directory for quarto

- pathToDriver:

  Path to a folder containing the JDBC driver JAR files.

## Value

An html document containing the full results for the target,
comparators, indications and outcomes specified.

## Details

Specify the connection details to the result database and the schema
name to generate the full report.

## See also

Other Reporting:
[`createPredictionReport()`](createPredictionReport.md),
[`generatePresentation()`](generatePresentation.md),
[`generatePresentationMultiple()`](generatePresentationMultiple.md),
[`generateSummaryPredictionReport()`](generateSummaryPredictionReport.md)
