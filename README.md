# OhdsiReportGenerator

[![Build Status](https://github.com/OHDSI/OhdsiReportGenerator/workflows/R-CMD-check/badge.svg)](https://github.com/OHDSI/OhdsiReportGenerator/actions?query=workflow%3AR-CMD-check+branch%3Amain)
[![codecov.io](https://codecov.io/github/OHDSI/OhdsiReportGenerator/coverage.svg?branch=main)](https://app.codecov.io/github/OHDSI/OhdsiReportGenerator?branch=main)

# Introduction

This package contains functions for extracting characterization, estimation and prediction results from the OHDSI result database (see <https://ohdsi.github.io/Strategus/results-schema/index.html>).

It also contains codes to create useful plots, presentations templates and report templates.

# Examples

Download this repository and using RStudio, install the package. Then you can make use of the report generator by running:

``` r

# Install OhdsiReportGenerator using remotes}
install.packages('remotes')
remotes::install_github('OHDSI/OhdsiReportGenerator')

# Load the library to start using it
library(OhdsiReportGenerator)

# to run the report generator with a demo set of results
conDet <- OhdsiReportGenerator:::getExampleConnectionDetails()

# render a quarto template report with the results in the 
# example database for targetId 1 and outcomeId 3.
generatePresentation(
  server = conDet$server(),
  username = conDet$user(),
  password = conDet$password(),
  dbms = conDet$dbms,
  resultsSchema = 'main',
  dbDetails = NULL,
  lead = 'John Doe',
  team = 'name 1, name 2',
  trigger = 'A signal was found in spontaneous reports',
  safetyQuestion = '',
  objective = '',
  date = as.character(Sys.Date()),
  targetId = 1,
  outcomeIds = 3,
  cohortNames = c('target','outcome'),
  cohortIds = c(1,3),
  covariateIds = NULL,
  details = list(
    studyPeriod = 'All Time',
    restrictions = "Age - None"
  ),
  evaluationText = '',
  includeCI = TRUE,
  includeCharacterization = TRUE,
  includeCM = TRUE,
  includeSCCS = TRUE,
  includePLP = FALSE,
  outputLocation = file.path(getwd(), "extras/reportTest"),
  outputName = paste0('presentation_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html')
  intermediateDir = tempdir()
)

```

# Technology

OhdsiReportGenerator is an R package.

# System Requirements

Running the package requires R and Java.

# License

OhdsiReportGenerator is licensed under Apache License 2.0.

# Development

OhdsiReportGenerator is being developed in R Studio.
