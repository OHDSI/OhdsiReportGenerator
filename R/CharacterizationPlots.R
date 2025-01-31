#' Plots the age distributions using the binary age groups
#' @description
#' Creates bar charts for the target and case age groups.
#'
#' @details
#' Input the data returned from 'getCharacterizationDemographics(type = 'age')' and the time-at-risk
#'
#' @param ageData The age data extracted using 'getCharacterizationDemographics(type = 'age')'
#' @param riskWindowStart The time at risk window start
#' @param riskWindowEnd The time at risk window end
#' @param startAnchor The anchor for the time at risk start
#' @param endAnchor The anchor for the time at risk end
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
#' targetId = 1, 
#' outcomeId = 3, 
#' type = 'age'
#' )
#' 
#' plotAgeDistributions(ageData = ageData)
#' 
plotAgeDistributions <- function(
    ageData,
    riskWindowStart = '1',
    riskWindowEnd = '365', 
    startAnchor = 'cohort start', 
    endAnchor = 'cohort start'
){
  # TODO add input checks
  
  ageData <- ageData %>%
    dplyr::filter(
      .data$riskWindowStart %in% c(NA,riskWindowStart) &
      .data$riskWindowEnd %in% c(NA,riskWindowEnd) &
        .data$startAnchor %in% c(NA,startAnchor) &
        .data$endAnchor %in% c(NA, endAnchor)
      )
  
  if(nrow(ageData) == 0){
    return() # empty plot?
  } 
  # TODO add input checks
  
  # filter to Target and Cases and remove censored
  ageData <- ageData %>% 
    dplyr::filter(.data$sumValue > 0) %>%
    dplyr::filter(.data$cohortType %in% c('Target', 'Cases'))
  
ind <- ageData$cohortType == 'Target'
ageData$averageValue[ind] <- -1*ageData$averageValue[ind] 
ageData$tar <- addTar(ageData)
result <- ggplot2::ggplot(
  data = ageData,
  ggplot2::aes(
    x = .data$averageValue,
    y = .data$covariateName,
    fill = formatCohortType(.data$cohortType)
  )
) +
  ggplot2::geom_col() +
  ggplot2::scale_x_continuous(
    breaks  = c(-1,-0.5, 0, 0.5, 1),
    labels = abs(c(-1,-0.5, 0, 0.5,  1))
  ) +
  ggplot2::facet_grid(
    cols = ggplot2::vars(.data$databaseName)
  ) +
  ggplot2::theme(
    legend.title=ggplot2::element_blank()
    ) +
  ggplot2::labs(
    y = "Variable", 
    x = "Frequency"
  )

return(result)
}

#' Plots the sex distributions using the sex features
#' @description
#' Creates bar charts for the target and case sex.
#'
#' @details
#' Input the data returned from 'getCharacterizationDemographics(type = 'sex')' and the time-at-risk
#'
#' @param sexData The sex data extracted using 'getCharacterizationDemographics(type = 'sex')'
#' @param riskWindowStart The time at risk window start
#' @param riskWindowEnd The time at risk window end
#' @param startAnchor The anchor for the time at risk start
#' @param endAnchor The anchor for the time at risk end
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
#'   targetId = 1, 
#'   outcomeId = 3, 
#'   type = 'sex'
#' )
#' plotSexDistributions(sexData = sexData)
#' 
plotSexDistributions <- function(
    sexData,
    riskWindowStart = '1',
    riskWindowEnd = '365', 
    startAnchor = 'cohort start', 
    endAnchor = 'cohort start'
    ){
  # TODO add input checks
  
  sexData <- sexData %>% 
    dplyr::filter(
      .data$riskWindowStart %in% c(NA,riskWindowStart) &
      .data$riskWindowEnd %in% c(NA,riskWindowEnd) &
      .data$startAnchor %in% c(NA,startAnchor) &
      .data$endAnchor %in% c(NA, endAnchor)
  )
  
  if(nrow(sexData) == 0){
    return() # empty plot?
  } 
  
  # filter to Target and Cases and remove censored
  sexData <- sexData %>% 
    dplyr::filter(.data$sumValue > 0) %>%
    dplyr::filter(.data$cohortType %in% c('Target', 'Cases'))
  
  ind <- sexData$cohortType == 'Target'
  sexData$averageValue[ind] <- -1*sexData$averageValue[ind] 
  sexData$tar <- addTar(sexData)
  
  result <- ggplot2::ggplot(
    data = sexData,
    ggplot2::aes(
      x = .data$averageValue,
      y = .data$covariateName,
      fill =  formatCohortType(.data$cohortType)
    )
  ) +
    ggplot2::geom_col() +
    ggplot2::scale_x_continuous(
      breaks  = c(-1,-0.5, 0, 0.5, 1),
      labels = abs(c(-1,-0.5, 0, 0.5,  1))
    ) +
    ggplot2::facet_grid(
      cols = ggplot2::vars(.data$databaseName)
    ) +
    ggplot2::theme(
      legend.title=ggplot2::element_blank()
      ) +
    ggplot2::labs(
      y = "Variable", 
      x = "Frequency"
    )
  
  return(result)
}



