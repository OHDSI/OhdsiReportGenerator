# Copyright 2023 Observational Health Data Sciences and Informatics
#
# This file is part of OhdsiReportGenerator
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
#' @param exdir a directory to unzip the example result data into.  Default is tempdir().
#' 
#' @return
#' An object of class `ConnectionDetails` with the details to connect to the example OHDSI result database
#'
#' @family helper
#'
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
getExampleConnectionDetails <- function(exdir = tempdir()) {
  
  # unzip the data - it is compressed to save space
  utils::unzip(
    zipfile = system.file('exampledata','results.sqlite.zip', package = 'OhdsiReportGenerator'), 
    exdir = exdir
  )
  
  server <- file.path(exdir, 'results.sqlite')
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
#' @examples 
#' removeSpaces(' made up.   string')
#'
#' @export
removeSpaces <- function(x){
  return(gsub(' ', '_', gsub("[[:punct:]]", "", x)))
}

#' addTarColumn
#'
#' @description
#' Finds the four TAR columns and creates a new column called tar that pastes the columns
#' into a nice string
#'
#' @details
#' Create a friendly single tar column
#' 
#' @param data The data.frame with the individual TAR columns that you want to 
#'              combine into one column
#' @return
#' The data data.frame object with the tar column added if seperate TAR columns are found 
#' 
#' @family helper
#' 
#' @examples 
#' addTarColumn(data.frame(
#' tarStartWith = 'cohort start',
#' tarStartOffset = 1,
#' tarEndWith = 'cohort start',
#' tarEndOffset = 0
#' ))
#'
#' @export
addTarColumn <- function(
    data
){
  
    if(sum(c("tarStartWith","tarStartOffset","tarEndWith","tarEndOffset") %in%
           colnames(data)) == 4){
      message('Found CI TAR columns')
      data$tar <- paste0(
        '(',data$tarStartWith,' + ',data$tarStartOffset, ') - ',
        '(',data$tarEndWith,' + ', data$tarEndOffset, ')'
      )
    }
  
  if(sum(c("tarStartDay","tarStartAnchor","tarEndDay","tarEndAnchor") %in%
         colnames(data)) == 4){
    message('Found PLP TAR columns')
    data$tar <- paste0(
      '(',data$tarStartAnchor,' + ',data$tarStartDay, ') - ',
      '(',data$tarEndAnchor,' + ', data$tarEndDay, ')'
    )
  }
    
    if(sum(c("startAnchor","riskWindowStart","endAnchor","riskWindowEnd") %in%
           colnames(data)) == 4){
      message('Found CM TAR columns')
      data$tar <- paste0(
        '(',data$startAnchor,' + ',data$riskWindowStart, ') - ',
        '(',data$endAnchor,' + ', data$riskWindowEnd, ')'
      )
    }
  
  return(data)
}

#' formatBinaryCovariateName
#'
#' @description
#' Removes the long part of the covariate name to make it friendly 
#'
#' @details
#' Makes the covariateName more friendly and shorter
#' 
#' @param data The data.frame with the covariateName column
#' @return
#' The data data.frame object with the ovariateName column changed to be more friendly
#' 
#' @family helper
#' 
#' @examples 
#' formatBinaryCovariateName(data.frame(
#' covariateName = c("fdfgfgf: dgdgff","made up test")
#' ))
#'
#' @export
formatBinaryCovariateName <- function(data){
  if('covariateName' %in% colnames(data)){
    
    #riskFactorsBinary$covariateName[nchar(riskFactorsBinary$covariateName) < 25]
    
    tempNames <- data$covariateName
    for(val in c('ethnicity = ','gender = ','race = ','age group: ')){
      rfIds <- grep(val, tempNames)
      if(length(rfIds) > 0){
        tempNames[rfIds] <- gsub(val, ': ', tempNames[rfIds])
      }
    }
    
    data$covariateName <- unlist(lapply(tempNames, function(x) ifelse(length(strsplit(x,':')[[1]])>=2, strsplit(x,': ')[[1]][2], 'Unknown covariate')))
  } 
  
  # add conceptId to the name
  if('covariateId' %in% colnames(data)){
    if(sum(is.null(data$covariateId)) > 0){
      data$covariateId[is.null(data$covariateId)] <- 0
    }
  data$covariateName <- paste0(data$covariateName, ' (', floor(data$covariateId/1000) ,')')
  }
  
  return(data)
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
    dplyr::select(dplyr::all_of(tarColumnNames)) %>%
    tidyr::drop_na()
  
  tar <- unique(tar)
  tar <- lapply(
    X = 1:nrow(tar), 
    FUN = function(i){as.list(tar[i,])}
    )
  return(tar)
}

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
    connectionHandler,
    dbDetails = data.frame(
      cdmSourceAbbreviation = c(
        "AMBULATORY EMR", "IBM CCAE", "German DA",
        "JMDC", "Optum EHR", "OPTUM Extended SES", "IBM MDCD",
        "IBM MDCR"
      ),
      type = c('us ehr', 'us claims', 'non-us claims',
               "non-us claims", 'us ehr', 'us claims', 'us claims',
               'us claims')
    )
){
  
  res <- connectionHandler$queryDb(
    "select CDM_SOURCE_ABBREVIATION from @schema.database_meta_data;",
    schema = schema
  )
  dbs <- merge(res, dbDetails)$type
  
  types <- lapply(unique(dbs), function(type){sum(dbs == type)})
  names(types) <- unique(dbs)
  
  return(types)
}


#' output a nicely formatted html table
#'
#' @description
#' This returns a html table with the input data
#'
#' @details
#' Input the data that you want to be shown via a dark html table 
#' 
#' @param data A data.frame containing data of interest to show via a table
#' @param caption A caption for the table
#' @param position The position for the table if used within a quarto document.  
#'        This is the "real" or say floating position for the latex table environment. 
#'        The kable only puts tables in a table environment when a caption is provided. 
#'        That is also the reason why your tables will be floating around if you specify 
#'        captions for your table. Possible choices are h (here), t (top, default), 
#'        b (bottom) and p (on a dedicated page).
#' 
#' @return
#' An object of class `knitr_kable` that will show the data via a nice html table
#'
#' @family helper
#'
#' @export
#' @examples 
#' kableDark(
#' data = data.frame(a=1,b=4), 
#' caption = 'A made up table to demonstrate this function',
#' position = 'h'
#' )
#' 
kableDark <- function(data, caption = NULL, position = NULL){
  result <- data %>%
    kableExtra::kbl(
      caption = caption, 
      position = position
    ) %>%
    kableExtra::kable_material_dark(
      lightable_options = 'hover'
    )
  return(result)
}

#' prints a reactable in a quarto document 
#'
#' @description
#' This function lets you print a reactable in a quarto document 
#'
#' @details
#' Input the values for reactable::reactable
#' 
#' @param data The data for the table
#' @param columns The formating for the columns
#' @param groupBy A column or columns to group the table by
#' @param defaultPageSize The number of rows in the table
#' @param highlight whether to highlight the row of interest
#' @param striped whether the rows change color to give a striped appearance 
#' @param searchable whether you can search in the table
#' @param filterable whether you can filter the table
#' 
#' @return
#' Nothing but the html code for the table is printed (to be used in a quarto document)
#'
#' @family helper
#'
#' @export
#' @examples 
#' printReactable(
#' data = data.frame(a=1,b=4)
#' )
#' 
printReactable <- function(
    data,
    columns = NULL,
    groupBy = NULL,
    defaultPageSize = 20,
    highlight = TRUE, 
    striped = TRUE,
    searchable = TRUE, 
    filterable = TRUE
){
  print(
    htmltools::tagList(
      reactable::reactable(
        data = data,
        columns = columns,
        groupBy = groupBy,
        defaultPageSize = defaultPageSize,
        highlight = highlight, 
        striped = striped,
        searchable = searchable, 
        filterable = filterable
      )
    )
  )
}



