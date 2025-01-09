OhdsiReportGenerator
===============

Introduction
============

This package contains functions for extracting characterization, estimation and prediction results from the OHDSI result database (see https://ohdsi.github.io/Strategus/results-schema/index.html).

It also contains codes to create useful plots, presentations templates and report templates.

Examples
========

Download this repository and using RStudio, install the packgage. Then you can make use of the report generator by running:

```{r}
# Install OhdsiReportGenerator using remotes
install.packages('remotes')
remotes::install_github('OHDSI/OhdsiReportGenerator')

# Load the library to start using it
library(OhdsiReportGenerator)

# to run the report generator with a demo set of results
generatePresentation(
  dbms = "<dbms e.g., postgresql>",
  server = '<add database server with study results>',
  user = '<add username for account with read access to server>',
  password = '<add password for account with read access to server>',
  resultsSchema = "<result schema name>",
  targetId = 1082,
  outcomeId = 11123,
  comparatorId = 5373,
  covariateIds = c(
    316139,320128210,443454210,
    4282096210,441542210
  ),
  friendlyNames = list(
    targetName = 'Drug of interest',
    comparatorName = 'Comparator drug',
    indicationName = 'Indication A',
    outcomeName = 'Outcome B'
  ),
  title = 'Study investigating outcome B in new users of drug of interest',
  lead = 'Lead Investigator Name Here',
  date = Sys.Date(),
  backgroundText = '', # Add any background information about the project here
  outputLocation = file.path(getwd(), "extras/reportTest"),
  outputName = paste0('presentation_', gsub(':', '_',gsub(' ','_',as.character(date()))),'.html')
)

```


Technology
==========

OhdsiReportGenerator is an R package.


System Requirements
===================

Running the package requires R.


Installation
============

  
User Documentation
==================


Support
=======


Contributing
============


License
=======

ReportGenerator is licensed under Apache License 2.0. 


Development
===========

ReportGenerator is being developed in R Studio.


### Development status

Under development


Acknowledgements
================

