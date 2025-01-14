# Copyright 2023 Observational Health Data Sciences and Informatics
#
# This file is part of ReportGenerator
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' create a connection detail for an example OHDSI results database
#'
#' @description
#' This returns an object of class `ConnectionDetails` that lets you connect via `DatabaseConnector::connect()` to the example result database.
#'
#' @details
#' Finds the location of the example result database in the package and calls `DatabaseConnector::createConnectionDetails` to create a `ConnectionDetails` object for connecting to the database. 
#' 
#' @return
#' An object of class `ConnectionDetails` with the details to connect to the example OHDSI result database
#'
#' @family helper
#'
#' @export
getExampleConnectionDetails <- function() {
  server <- system.file("exampledata", "results.sqlite", package = "OhdsiReportGenerator")
  cd <- DatabaseConnector::createConnectionDetails(
    dbms = "sqlite", 
    server = server
    )
  return(cd)
}

#' removeSpaces
#'
#' @description
#' Removes spaces and replaces with under scroll
#'
#' @details
#' Removes spaces and replaces with under scroll
#' 
#' @param x A string
#' @return
#' A string without spaces
#' 
#' @family helper
#'
#' @export
removeSpaces <- function(x){
  return(gsub(' ', '_', x))
}

formatCohortType <- function(
    cohortType
){
  x <- rep('No outcome', length(cohortType))
  x[cohortType == 'Cases'] <- 'outcome'
  
  return(x)
}

getTars <- function(
    data,
    tarColumnNames = c("tarStartWith","tarStartOffset","tarEndWith","tarEndOffset")
    ){
  tar <- data %>% 
    dplyr::select(dplyr::all_of(tarColumnNames))
  
  tar <- unique(tar)
  tar <- lapply(
    X = 1:nrow(tar), 
    FUN = function(i){as.list(tar[i,])}
    )
  return(tar)
}

# TODO: make this nice and add to Helpers.R
addTar <- function(data){
  result <- paste0(
    data$riskWindowStart,
    data$riskWindowEnd, 
    data$startAnchor, 
    data$endAnchor
  )
  
  return(result)
}

getAnalyses <- function(
    server,
    username,
    password,
    dbms,
    schema
){
  
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = dbms, 
    user = username, 
    password = password, 
    server = server 
  )
  
  connection <- DatabaseConnector::connect(
    connectionDetails = connectionDetails
    )
  on.exit(DatabaseConnector::disconnect(connection))
  
  tables <- DatabaseConnector::getTableNames(
    connection = connection, 
    databaseSchema = schema 
  )
  
  resultsRun <- unique(
    unlist(
      lapply(strsplit(tables, '_'), function(x) x[[1]][1])
    )
  )
  
  # TODO replace this with the resultDatabaseSettings values
  analyses <- data.frame(
    prefix = c('cd','cg','cm', 'sccs', 'plp', 'c', 'ci'),
    name = c('cohort diagnostics', 'cohort generator',
             'cohort method', 'self controlled case series',
             'patient level prediction', 
             'characterization', 'cohort incidence')
  )
  
  return(analyses[analyses$prefix %in% resultsRun,])
}


# TODO remove or have an input for the name to type?
getDbs <- function(
    schema,
    server,
    username,
    password,
    dbms,
    dbDetails = data.frame(
      CDM_SOURCE_ABBREVIATION = c(
        "AMBULATORY EMR", "IBM CCAE", "German DA",
        "JMDC", "Optum EHR", "OPTUM Extended SES", "IBM MDCD",
        "IBM MDCR"
      ),
      type = c('us ehr', 'us claims', 'non-us claims',
               "non-us claims", 'us ehr', 'us claims', 'us claims',
               'us claims')
    )
){
  
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = dbms,
    server = server,
    user = username,
    password = password
  )
  
  con <- DatabaseConnector::connect(
    connectionDetails = connectionDetails
  )
  on.exit(DatabaseConnector::disconnect(con))
  
  sql <- "select CDM_SOURCE_ABBREVIATION from @schema.database_meta_data;"
  sql <- SqlRender::render(
    sql = sql,
    schema = schema
  )
  res <- DatabaseConnector::querySql(con, sql)
  dbs <- merge(res, dbDetails)$type
  
  types <- lapply(unique(dbs), function(type){sum(dbs == type)})
  names(types) <- unique(dbs)
  
  return(types)
}











