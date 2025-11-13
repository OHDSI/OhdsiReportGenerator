# generatePresentationMultiple

Generates a presentation from a Strategus result

## Usage

``` r
generatePresentationMultiple(
  server,
  username,
  password,
  dbms,
  resultsSchema = NULL,
  targetId = 1,
  targetName = "target cohort",
  cmSubsetId = 2,
  sccsSubsetId = NULL,
  indicationName = NULL,
  outcomeIds = 3,
  outcomeNames = "outcome cohort",
  comparatorIds = c(2, 4),
  comparatorNames = c("comparator cohort 1", "comparator cohort 2"),
  covariateIds = NULL,
  details = list(studyPeriod = "All Time", restrictions = "Age - None"),
  title = "ASSURE 001 ...",
  lead = "add name",
  date = Sys.Date(),
  backgroundText = "",
  evaluationText = "",
  outputLocation,
  outputName = paste0("presentation_", gsub(":", "_", gsub(" ", "_",
    as.character(date()))), ".html"),
  intermediateDir = tempdir()
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

- targetName:

  A friendly name for the target cohort

- cmSubsetId:

  Optional a subset ID for the cohort method/prediction results

- sccsSubsetId:

  Optional a subset ID for the SCCS and characterization results

- indicationName:

  A name for the indication if used or NULL

- outcomeIds:

  The cohort definition id for the outcome

- outcomeNames:

  Friendly names for the outcomes

- comparatorIds:

  The cohort method comparator cohort id

- comparatorNames:

  Friendly names for the comparators

- covariateIds:

  A vector of covariateIds to include in the characterization

- details:

  a list with the studyPeriod and restrictions

- title:

  A title for the presentation

- lead:

  The name of the presentor

- date:

  The date of the presentation

- backgroundText:

  a character with any background text

- evaluationText:

  a list of bullet points for the evaluation

- outputLocation:

  The file location and name to save the protocol

- outputName:

  The name of the html protocol that is created

- intermediateDir:

  The work directory for quarto

## Value

An named R list with the elements 'standard' and 'source'

## Details

Specify the connection details to the result database and the schema
name to generate a presentation.

## See also

Other Reporting:
[`createPredictionReport()`](createPredictionReport.md),
[`generateFullReport()`](generateFullReport.md),
[`generatePresentation()`](generatePresentation.md),
[`generateSummaryPredictionReport()`](generateSummaryPredictionReport.md)
