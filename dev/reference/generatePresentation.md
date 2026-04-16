# generatePresentation

Generates a presentation from a Strategus result

## Usage

``` r
generatePresentation(
  server,
  username,
  password,
  dbms,
  resultsSchema = NULL,
  dbDetails = NULL,
  lead = "add name",
  team = "name 1 name 2",
  trigger = "A signal was found in spontaneous reports",
  safetyQuestion = "",
  objective = "",
  topline1 =
    "Very brief executive summary. You can copy-paste language from the conclusion.",
  topline2 =
    "If an estimation was requested but not feasible, this should be mentioned here.",
  topline3 =
    "If no estimation study was requested, this high-level summary might be skipped.",
  date = as.character(Sys.Date()),
  targetId = 1,
  outcomeIds = 3,
  cohortNames = c("target name", "outcome name"),
  cohortIds = c(1, 3),
  covariateIds = NULL,
  details = list(studyPeriod = "All Time", restrictions = "Age - None"),
  evaluationText = "",
  includeCI = TRUE,
  includeCharacterization = TRUE,
  includeCM = TRUE,
  includeSCCS = TRUE,
  includePLP = TRUE,
  outputLocation,
  outputName = paste0("presentation_", gsub(":", "_", gsub(" ", "_",
    as.character(date()))), ".html"),
  intermediateDir = fs::path_real(tempdir()),
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

- dbDetails:

  (Optional) a data.frame with the columns:

- lead:

  The name of the presenter

- team:

  A vector or all the team members

- trigger:

  What triggered the request

- safetyQuestion:

  What is the general safety question

- objective:

  What is the request/objective of the work.

- topline1:

  add a very brief executive summary for the topline slide

- topline2:

  add estimation summary here for the topline slide

- topline3:

  add any other statement summary here for the topline slide

- date:

  The date of the presentation

- targetId:

  The cohort definition id for the target cohort

- outcomeIds:

  The cohort definition id for the outcome

- cohortNames:

  Friendly names for any cohort used in the study

- cohortIds:

  The corresponding Ids for the cohortNames

- covariateIds:

  A vector of covariateIds to include in the characterization

- details:

  a list with the studyPeriod and restrictions

- evaluationText:

  a list of bullet points for the evaluation

- includeCI:

  Whether to include the cohort incidence slides

- includeCharacterization:

  Whether to include the characterization slides

- includeCM:

  Whether to include the cohort method slides

- includeSCCS:

  Whether to include the self controlled case series slides

- includePLP:

  Whether to include the patient level prediction slides

- outputLocation:

  The file location and name to save the protocol

- outputName:

  The name of the html protocol that is created

- intermediateDir:

  The work directory for quarto

- pathToDriver:

  Path to a folder containing the JDBC driver JAR files.

## Value

An named R list with the elements 'standard' and 'source'

## Details

Specify the connection details to the result database and the schema
name to generate a presentation.

## See also

Other Reporting:
[`createPredictionReport()`](createPredictionReport.md),
[`generateFullReport()`](generateFullReport.md),
[`generatePresentationMultiple()`](generatePresentationMultiple.md),
[`generateSummaryPredictionReport()`](generateSummaryPredictionReport.md)
