#' View the Incidence Rates
#' @description
#' Creates a table with the incidence rates and optionally demographics
#'
#' @details
#' Input the incidence rate data (and optionally demographic data)
#'
#' @param incidenceData The data extracted using 'getIncidenceRates'
#' @param ageData The data extracted using 'getBinaryTargetBaseline' with analysisIds = 3 
#' @param genderData The data extracted using 'getBinaryTargetBaseline' with analysisIds = 1
#' @param stratification Pick either overall/age/sex/year to specify whether to view the overall rates or stratified by age/sex/year
#' @param maxAgeSampleSize When creating the age distributions this is the max age vector length to create
#' 
#' @family Characterization
#' @return
#' Returns a gt table that displays the incidence rates
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' schema <- 'main'
#' 
#' incidenceData <- getIncidenceRates(
#'   connectionHandler = connectionHandler , 
#'   schema = schema
#'   )
#'   
#'   # incidence data does not have rate values to imputing them
#'   incidenceData$incidenceRateP100py <- 1 +
#'     sample(c(-1,1),replace = TRUE)*runif(nrow(incidenceData))
#'   incidenceData$incidenceProportionP100p <- 0.5 +
#'     sample(c(-1,1),replace = TRUE)*runif(nrow(incidenceData))
#'   
#'  ageData <- getBinaryTargetBaseline(
#'   connectionHandler = connectionHandler, 
#'   schema = schema,  
#'   analysisIds = 3
#'  )
#'  
#'  genderData <- getBinaryTargetBaseline(
#'   connectionHandler = connectionHandler, 
#'   schema = schema,  
#'   analysisIds = 1
#'  )
#' 
#' viewIncidenceRate(
#'   incidenceData = incidenceData,
#'   ageData = ageData,
#'   genderData = genderData
#'   )
#'   
#' 
viewIncidenceRate <- function(
  incidenceData,
  ageData = NULL, 
  genderData = NULL, 
  stratification = 'overall', 
  maxAgeSampleSize = 5000
  ){
  
  if(!stratification %in% c('overall', 'age', 'sex',' year')){
    message("Please use one of 'overall', 'age', 'sex',' year' for stratification")
    return(invisible(NULL))
  }
  
  x <- filterCiGroup(
    incidenceData = incidenceData, 
    stratification = stratification
    )
  
  addAge <- FALSE
  if(!is.null(ageData) & stratification == 'overall'){
    if(ageData$analysisId[1] ==3){
      addAge <- TRUE
    }
  }  
  
  if(addAge){
    
    # added below to sample sumValue if too large
    
    cohortSizes <- ageData %>%
      dplyr::group_by(
        .data$databaseId, .data$targetCohortId
      ) %>%
      dplyr::summarise(
        n = sum(.data$sumValue)
      ) %>%
      dplyr::rowwise() %>%
      dplyr::mutate(
        scale = dplyr::case_when(.data$n/!!maxAgeSampleSize < 1 ~ 1,
                                 .data$n/!!maxAgeSampleSize >= 1 ~ .data$n/!!maxAgeSampleSize,
                                 )
      ) %>%
      dplyr::select("databaseId", "targetCohortId", "scale")
    
    # scale mod then join to ageData below and do size = floor(.data$sumValue/.data$scale)
    
    ageData <- ageData %>%
      dplyr::left_join(cohortSizes, by = c("databaseId", "targetCohortId")) %>%
      dplyr::rowwise() %>%
      dplyr::mutate(
        databaseId = as.character(.data$databaseId),
        ageMin = strsplit(x = gsub('age group:  ', '', .data$covariateName), split = ' -  ')[[1]][1],
        ageMax = strsplit(x = gsub('age group:  ', '', .data$covariateName), split = ' -  ')[[1]][2],
      ) %>%
      dplyr::mutate(
        ageList = list(sample(.data$ageMin:.data$ageMax, size = ceiling(.data$sumValue/.data$scale), replace = TRUE))
      ) %>%
      dplyr::group_by(
        .data$databaseId, .data$targetCohortId
      ) %>%
      dplyr::summarise(
        ageList = list(do.call(what = 'c', c(.data$ageList)))
      ) %>%
      dplyr::rename(
        targetId = "targetCohortId"
      )
    
    x <- x %>%
      dplyr::left_join(
        y = ageData, 
        by = c("databaseId","targetId")
          )
  } else{
    x <- x %>%
      dplyr::mutate(
        ageList = list(0)
      )
  }


addGender <- FALSE
if(!is.null(genderData) & stratification == 'overall'){
  if(genderData$analysisId[1] == 1){
    addGender <- TRUE
  }
}  
  
  if(addGender){
  
      totals <- genderData %>%
      dplyr::group_by(.data$databaseId, .data$targetCohortId) %>%
      dplyr::summarise(
        total = sum(.data$sumValue)
      )
      
    genderData <- genderData %>%
      dplyr::filter(.data$covariateName == 'gender = MALE') %>%
      dplyr::left_join(totals, by = c('databaseId','targetCohortId')) %>%
      dplyr::mutate(
        databaseId = as.character(.data$databaseId),
        malePercentage = .data$sumValue/.data$total*100
      ) %>%
      dplyr::rename(
        targetId = "targetCohortId"
      ) %>%
      dplyr::select(
        "databaseId", "targetId", "malePercentage"
      )
      
    
    x <- x %>%
      dplyr::left_join(
        y = genderData, 
        by = c("databaseId","targetId")
      ) %>%
      dplyr::rename(
        malePerc = "malePercentage"
      )
  } else{
    x <- x %>%
      dplyr::mutate(
        malePerc = NA
      )
  }
  
  if(stratification == 'overall'){
    x <- x %>% 
      dplyr::mutate(
        type = ''
      )
  } else if(stratification == 'age'){
    x <- x %>% 
      dplyr::mutate(
        type = .data[['ageGroupName']]
      )
  } else if(stratification == 'year'){
    x <- x %>% 
      dplyr::mutate(
        type = .data[['startYear']]
      )
  } else if(stratification == 'sex'){
    x <- x %>% 
      dplyr::mutate(
        type = .data[['genderName']]
      )
  }
  
 nicetbl <- x %>%
    dplyr::mutate(
      analysis = paste0(.data$outcomeName, ' ( wo ',.data$cleanWindow ,') during ', .data$tar),
      targetNameWithId = paste(.data$targetName, ' (',.data$targetId ,')'),
      rate = .data$incidenceRateP100py,
      proportion = .data$incidenceProportionP100p,
      meanFollowUp = .data$personDays/.data$personsAtRisk
      ) %>%
    dplyr::select("targetNameWithId","analysis", "databaseName","rate","incidenceRateP100py",
                  "proportion","incidenceProportionP100p", "personsAtRisk" , "meanFollowUp",
                  "outcomes", "type", "ageList", "malePerc") %>%
    dplyr::arrange(.data$targetNameWithId,.data$type) %>%
    dplyr::group_by(.data$type, .data$analysis) |>
    gt::gt() %>%
    gtExtras::gt_plt_bar(
      column = "incidenceRateP100py",
      color = "MidnightBlue", 
    ) %>%
    gtExtras::gt_plt_bar(
      column = "incidenceProportionP100p",
      color = "MidnightBlue"
    ) %>%
    gtExtras::gt_plt_dist(
      column = "ageList",
      type = "density", 
      same_limit = TRUE 
     ) %>%
    gt::fmt_number(
      columns = 'malePerc', 
      decimals = 1
      ) %>%
    gt::fmt_number(
      columns = c('rate', 'proportion'), 
      decimals = 3
    ) %>%
   gt::fmt_number(
     columns = c('meanFollowUp'),
     sep_mark = ',',
     decimals = 0
   ) %>%
   gt::fmt(
     columns = c('personsAtRisk', 'outcomes'),
     fns = function(x){ 
       x <- sprintf("%.0f", x)
       if(sum(x < 0) > 0){ 
         x[x < 0] <- paste('<', abs(x[x < 0]))
       }
       return(x)
     }
   ) %>%
    gt::cols_label(
      incidenceProportionP100p =  gt::md("**Proportion per 100 persons**"),
      incidenceRateP100py =  gt::md("**Rate per 100 person years**"),
      databaseName = gt::md("**Database**"),
      rate = "",
      proportion = "",
      personsAtRisk = gt::md("**N**"),
      meanFollowUp = gt::md("**Mean Follow-up Days**"),
      outcomes = gt::md("**Outcomes**"),
      ageList = gt::md("**Age**"),
      malePerc = gt::md("**Male %**"),
      targetNameWithId = ""
    ) %>%
    gt::tab_style(
      style = gt::cell_fill(color = "GoldenRod"),
      locations = gt::cells_row_groups(groups = gt::everything()) # Targets specific group
    ) %>%
    gt::tab_style(
      style = gt::cell_text(color = "MidnightBlue", weight = "bold"),
      locations = gt::cells_body(columns = c("rate", "proportion"))
    )
  
  if(!addGender | !addAge){
    nicetbl <- nicetbl %>%
      gt::cols_hide(
        columns = c("ageList","malePerc")[c(!addAge, !addGender)]
          )
  }

  return(nicetbl)
}


filterCiGroup <- function(
    incidenceData,
    stratification
    ){
  
  noAge <- incidenceData$ageGroupName == 'Any'
  noGen <- incidenceData$genderName == 'Any'
  noYear <- incidenceData$startYear == 'Any'
  
  if(stratification == 'overall'){
    include <- (noAge & noGen & noYear) 
  } else if(stratification == 'age'){
    include <- (!noAge & noGen & noYear)
  } else if(stratification == 'sex'){
    include <- (noAge & !noGen & noYear)
  } else if(stratification == 'year'){
    include <- (noAge & noGen & !noYear)
  } else{
    warning('Invalid stratification')
    return(NULL)
  }
  
  return(incidenceData[include,])
}


#' Plots the age distributions using the binary age groups
#' @description
#' Creates bar charts for the target.
#'
#' @details
#' Input the data returned from 'getCharacterizationDemographics(type = 'age')'
#'
#' @param ageData The age data extracted using 'getCharacterizationDemographics(type = 'age')'
#' 
#' @family Characterization
#' @return
#' Returns a ggplot with the distributions
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' ageData <- getCharacterizationDemographics(
#' connectionHandler = connectionHandler, 
#' schema = 'main',
#' characterizationTargetId = 10, 
#' type = 'age'
#' )
#' 
#' plotAgeDistributions(ageData = ageData)
#' 
plotAgeDistributions <- function(
    ageData
){
  # TODO add input checks
  
  if(nrow(ageData) == 0){
    return() # empty plot?
  } 
  # TODO add input checks
  
  
  # filter to columns you want
  ageData <- ageData %>% 
      dplyr::filter(.data$sumValue > 0) %>%
      dplyr::rowwise() %>%
      dplyr::mutate(
        targetName = paste0(.data$targetName, ' first in ', 
                            .data$limitToFirstInNDays, ' days with >= ',
                            .data$minPriorObservation, ' prior obs ',
                            ifelse(!is.na(.data$nestingName), paste0(' in cohort ', .data$nestingName), ''),
                            ' aged between ', .data$minAge, '-', .data$maxAge,
                            ' in study between ', .data$studyStart , '-',
                            .data$studyEnd, 
                            ifelse(!is.na(.data$genderConceptIds), paste0(' in gender ', .data$genderConceptIds), '')
        )
      ) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        targetName = vapply(
          X = .data$targetName,
          FUN = function(x) paste(base::strwrap(x, width = 55), collapse = "\n"),
          FUN.VALUE = character(1)
        )
      ) %>%
      dplyr::select("covariateName","averageValue", 
                    "databaseName",
                    "targetName")
  
ageData$averageValue <- as.double(ageData$averageValue)

# order the age group
covNames <- unique(ageData$covariateName)
covOrder <- as.double(unlist(lapply(strsplit(covNames, '-  '), function(x) x[2])))
ageData$covariateName <- factor(
  x = ageData$covariateName, 
  levels = covNames[order(covOrder)]
)

result <- ggplot2::ggplot(
  data = ageData,
  ggplot2::aes(
    x = .data$averageValue,
    y = .data$covariateName
  )
) +
  ggplot2::geom_col() +
  ggplot2::scale_x_continuous(
    breaks  = c(-1,-0.5, 0, 0.5, 1),
    labels = abs(c(-1,-0.5, 0, 0.5,  1))
  ) +
  ggplot2::facet_grid(
    cols = ggplot2::vars(.data$databaseName), 
    rows = ggplot2::vars(.data$targetName)
  ) +
  ggplot2::theme(
    legend.title = ggplot2::element_blank(),
    strip.text.y = ggplot2::element_text(angle = 0, lineheight = 0.9)
    ) +
  ggplot2::labs(
    y = "Variable", 
    x = "Frequency"
  )

return(result)
}

#' Plots the sex distributions using the sex features
#' @description
#' Creates bar charts for the target.
#'
#' @details
#' Input the data returned from 'getCharacterizationDemographics(type = 'sex')'
#'
#' @param sexData The sex data extracted using 'getCharacterizationDemographics(type = 'sex')'
#' 
#' @family Characterization
#' @return
#' Returns a ggplot with the distributions
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' sexData <- getCharacterizationDemographics(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   characterizationTargetId = 10, 
#'   outcomeId = 3, 
#'   type = 'sex'
#' )
#' plotSexDistributions(sexData = sexData)
#' 
plotSexDistributions <- function(
    sexData
    ){
  # TODO add input checks
  
  if(nrow(sexData) == 0){
    return() # empty plot?
  } 
  
  # filter to Target and Cases and remove censored
  sexData <- sexData %>%
    dplyr::filter(.data$sumValue > 0) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      targetName = paste0(.data$targetName, ' first in ', 
                          .data$limitToFirstInNDays, ' days with >= ',
                          .data$minPriorObservation, ' prior obs ',
                          ifelse(!is.na(.data$nestingName), paste0(' in cohort ', .data$nestingName), ''),
                          ' aged between ', .data$minAge, '-', .data$maxAge,
                          ' in study between ', .data$studyStart , '-',
                          .data$studyEnd, 
                          ifelse(!is.na(.data$genderConceptIds), paste0(' in gender ', .data$genderConceptIds), '')
      )
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      targetName = vapply(
        X = .data$targetName,
        FUN = function(x) paste(base::strwrap(x, width = 55), collapse = "\n"),
        FUN.VALUE = character(1)
      )
    ) %>%
    dplyr::select("covariateName","averageValue", 
                  "databaseName",
                  "targetName")
  sexData$averageValue <- as.double(sexData$averageValue)

  result <- ggplot2::ggplot(
    data = sexData,
    ggplot2::aes(
      x = .data$averageValue,
      y = .data$covariateName
    )
  ) +
    ggplot2::geom_col() +
    ggplot2::scale_x_continuous(
      breaks  = c(-1,-0.5, 0, 0.5, 1),
      labels = abs(c(-1,-0.5, 0, 0.5,  1))
    ) +
    ggplot2::facet_grid(
      cols = ggplot2::vars(.data$databaseName),
      rows = ggplot2::vars(.data$targetName)
    ) +
    ggplot2::theme(
      legend.title = ggplot2::element_blank(),
      strip.text.y = ggplot2::element_text(angle = 0, lineheight = 0.9)
      ) +
    ggplot2::labs(
      y = "Variable", 
      x = "Frequency"
    )
  
  return(result)
}



