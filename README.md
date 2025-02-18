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

generatePresentationMultiple(
    server = conDet$server(),
    username = conDet$user(),
    password = conDet$password(),
    dbms = conDet$dbms,
    resultsSchema = 'main',
    targetId = 1,
    targetName = 'target',
    cmSubsetId = 2,
    sccsSubsetId = NULL,
    indicationName = NULL,
    outcomeIds = 3,
    outcomeNames = 'outcome',
    comparatorIds = 2,
    comparatorNames = 'comparator',
    covariateIds = NULL,
    details = list(
      studyPeriod = 'All Time',
      restrictions = "Age - None"
    ),
    title = 'Example results repport',
    lead = 'John Doe',
    date = Sys.Date(),
    backgroundText = '',
    evaluationText = '',
  outputLocation = file.path(getwd(), "extras/reportTest"),
  outputName = paste0('presentation_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html')
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
