#' Plots the cohort method results for one analysis
#' @description
#' Creates nice cohort method plots 
#'
#' @details
#' Input the cohort method data 
#'
#' @param cmData The cohort method data 
#' @param cmMeta (optional) The cohort method evidence synthesis data
#' @param cohortNames A data.frame with columns cohortId and cohortName
#' @param selectedAnalysisId The analysis ID of interest to plot
#' 
#' @family Estimation
#' @return
#' Returns a ggplot with the estimates
#' 
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' cmEst <- getCMEstimation(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1002,
#'   outcomeIds = 3
#' )
#' plotCmEstimates(
#'   cmData = cmEst, 
#'   cmMeta = NULL, 
#'   selectedAnalysisId = 1
#' )
#' 
plotCmEstimates <- function (
    cmData,
    cmMeta = NULL,
    cohortNames = NULL,
    selectedAnalysisId
)
{
  cmDataAll <- cmData %>%
    dplyr::filter(.data$analysisId == !!selectedAnalysisId)
  
  if(!is.null(cohortNames)){
    # add code to change target, comp and outcome names
    cmDataAll <- cmDataAll %>%
      dplyr::left_join(
        cohortNames %>% dplyr::rename(
          targetId = "cohortId",
          targetNameFriendly = "cohortName"
        ),
        by = "targetId"
      ) %>%
      dplyr::left_join(
        cohortNames %>% dplyr::rename(
          outcomeId = "cohortId",
          outcomeNameFriendly = "cohortName"
        ),
        by = "outcomeId"
      ) %>%
      dplyr::left_join(
        cohortNames %>% dplyr::rename(
          comparatorId = "cohortId",
          comparatorNameFriendly = "cohortName"
        ),
        by = "comparatorId"
      ) %>%
      dplyr::mutate(
        targetName = dplyr::coalesce(.data$targetNameFriendly, .data$targetName),
        outcomeName = dplyr::coalesce(.data$outcomeNameFriendly, .data$outcomeName),
        comparatorName = dplyr::coalesce(.data$comparatorNameFriendly, .data$comparatorName)
      )
  }
  
  if(!is.null(cmMeta)){
    cmMetaAll <- cmMeta %>%
      dplyr::filter(.data$analysisId == !!selectedAnalysisId) %>%
      dplyr::left_join(
        cohortNames %>% dplyr::rename(
          targetId = "cohortId",
          targetNameFriendly = "cohortName"
        ),
        by = "targetId"
      ) %>%
      dplyr::left_join(
        cohortNames %>% dplyr::rename(
          outcomeId = "cohortId",
          outcomeNameFriendly = "cohortName"
        ),
        by = "outcomeId"
      ) %>%
      dplyr::left_join(
        cohortNames %>% dplyr::rename(
          comparatorId = "cohortId",
          comparatorNameFriendly = "cohortName"
        ),
        by = "comparatorId"
      ) %>%
      dplyr::mutate(
        targetName = dplyr::coalesce(.data$targetNameFriendly, .data$targetName),
        outcomeName = dplyr::coalesce(.data$outcomeNameFriendly, .data$outcomeName),
        comparatorName = dplyr::coalesce(.data$comparatorNameFriendly, .data$comparatorName)
      )
  }
  
  toPairs <- cmDataAll %>%
    dplyr::select("targetId","outcomeId") %>%
    dplyr::distinct()
  
  plotList <- list()
  length(plotList) <- nrow(toPairs)
  names(plotList) <- paste0(toPairs$targetId,'-', toPairs$outcomeId)
  
  for(ind in 1:nrow(toPairs)){
    
    cmData <- cmDataAll %>%
      dplyr::filter(.data$targetId == !!toPairs$targetId[ind] &
                      .data$outcomeId == !!toPairs$outcomeId[ind]
      )
    
    
    targetName <- substr(unique(cmData$targetName), 1, 25)
    outcomeName <- substr(unique(cmData$outcomeName), 1, 25)
    analysisName <- unique(cmData$description)
    cmData$comparatorName <- substr(cmData$comparatorName, 1, 25)
    
    
    noDbResults <- sum(is.na(cmData$calibratedRr)) == length(cmData$calibratedRr)
    noMetaResults <- TRUE
    if (!is.null(cmMeta)) {
      cmMeta <- cmMetaAll %>%
        dplyr::filter(.data$targetId == !!toPairs$targetId[ind] &
                        .data$outcomeId == !!toPairs$outcomeId[ind]
        )
      cmMeta$comparatorName <- substr(cmMeta$comparatorName, 1, 25)
      noMetaResults <- nrow(cmMeta) == 0
    }
    
    
    if (noDbResults & noMetaResults) {
      plotList[ind] <- 'No Data'
    } else{
      fmtHazardRatio <- "%.2f"
      fmtIncidenceRate <- "%.1f"
      incidenceRateMult <- 365.25 * 1000
      estimates <- cmData %>% dplyr::mutate(
        hr = ifelse(is.na(.data$calibratedRr), NA, paste0(sprintf(fmtHazardRatio, .data$calibratedRr),
                                                          " (",
                                                          sprintf(fmtHazardRatio, .data$calibratedCi95Lb),
                                                          ", ",
                                                          sprintf(fmtHazardRatio, .data$calibratedCi95Ub),
                                                          ")")),
        eventsTarget = ifelse(.data$targetOutcomes < 0, "<5",
                              as.character(.data$targetOutcomes)),
        eventsComparator = ifelse(.data$comparatorOutcomes < 0, "<5",
                                  as.character(.data$comparatorOutcomes)),
        nTarget = prettyNum(.data$targetSubjects, big.mark = ","),
        nComparator = prettyNum(.data$comparatorSubjects, big.mark = ","),
        targetIr = ifelse(.data$targetOutcomes < 0,
                          paste0("<", as.character(sprintf(fmtIncidenceRate, 5/.data$targetDays * !!incidenceRateMult))),
                          as.character(sprintf(fmtIncidenceRate,.data$targetOutcomes/.data$targetDays * !!incidenceRateMult))
        ),
        comparatorIr = ifelse(.data$comparatorOutcomes < 0,
                              paste0("<", as.character(sprintf(fmtIncidenceRate, 5/.data$comparatorDays * !!incidenceRateMult))),
                              as.character(sprintf(fmtIncidenceRate, .data$comparatorOutcomes/.data$comparatorDays * !!incidenceRateMult))
        ),
        mean = .data$calibratedRr,
        lower = .data$calibratedCi95Lb,
        upper = .data$calibratedCi95Ub,
        summary = FALSE
      ) %>%
        dplyr::mutate(
          hr = ifelse(.data$unblindForEvidenceSynthesis == 1 & .data$unblind == 0 , "--", .data$hr),
          databaseName = ifelse(.data$unblindForEvidenceSynthesis == 0 & .data$unblind == 0 , paste0(.data$databaseName, '*') ,.data$databaseName),
          eventsTarget = ifelse(.data$nTarget == 0, "--", .data$eventsTarget),
          eventsComparator = ifelse(.data$nComparator == 0, "--", .data$eventsComparator),
          targetIr = ifelse(.data$nTarget == 0, "--", .data$targetIr),
          comparatorIr = ifelse(.data$nComparator == 0, "--", .data$comparatorIr)
        ) %>%
        dplyr::arrange(.data$databaseName) %>%
        dplyr::select("databaseName",'comparatorName', "nTarget", "nComparator",
                      "eventsTarget", "eventsComparator", "targetIr", "comparatorIr",
                      "hr", "summary", "mean", "upper", "lower")
      if (nrow(estimates) <= 0) {
        plotList[ind] <- 'No Estimates'
      }
      meta <- NULL
      if (!is.null(cmMeta)) {
        if (nrow(cmMeta) > 0) {
          meta <- cmMeta %>%
            dplyr::filter(
              .data$analysisId == !!selectedAnalysisId
            ) %>%
            dplyr::mutate(
              hr = paste0(sprintf(fmtHazardRatio, .data$calibratedRr),
                          " (",
                          sprintf(fmtHazardRatio, .data$calibratedCi95Lb),
                          ", ",
                          sprintf(fmtHazardRatio, .data$calibratedCi95Ub),
                          ")"
              ),
              mean = .data$calibratedRr,
              upper = .data$calibratedCi95Ub,
              lower = .data$calibratedCi95Lb,
              nTarget = ifelse(.data$targetSubjects < 0,
                               paste0('<',prettyNum(abs(.data$targetSubjects), big.mark = ",")),
                               prettyNum(.data$targetSubjects, big.mark = ",")),#"",
              nComparator = ifelse(.data$comparatorSubjects < 0,
                                   paste0('<',prettyNum(abs(.data$comparatorSubjects), big.mark = ",")),
                                   prettyNum(.data$comparatorSubjects, big.mark = ",")),#"",
              eventsTarget = ifelse(.data$targetOutcomes < 0,
                                    paste0('<',prettyNum(abs(.data$targetOutcomes), big.mark = ",")),
                                    prettyNum(.data$targetOutcomes, big.mark = ",")),#"",
              eventsComparator = ifelse(.data$comparatorOutcomes < 0,
                                        paste0('<',prettyNum(abs(.data$comparatorOutcomes), big.mark = ",")),
                                        prettyNum(.data$comparatorOutcomes, big.mark = ",")),#"",
              targetIr = "",
              comparatorIr = "",
              summary = TRUE
            ) %>%
            dplyr::mutate(
              hr = ifelse(is.na(.data$calibratedRr), "--", .data$hr)#,
              #databaseName = "Meta Analysis"
            ) %>%
            dplyr::select("databaseName","comparatorName", "nTarget", "nComparator",
                          "eventsTarget", "eventsComparator", "targetIr",
                          "comparatorIr", "hr", "summary", "mean", "upper",
                          "lower")
        }
      }
      
      plotData <- estimates
      
      if (!is.null(cmMeta)) {
        plotData <- dplyr::bind_rows(plotData, meta)
      }
      if (sum(plotData$lower < 0.01, na.rm = TRUE) > 0) {
        plotData$lower[plotData$lower < 0.01] <- 0.01
      }
      if (sum(plotData$upper > 50, na.rm = TRUE) > 0) {
        plotData$lower[plotData$lower > 50] <- 50
      }
      
      # restricting database name to 23 char
      plotData$databaseName <- substr(plotData$databaseName, 1,23)
      
      p <- plotData %>%
        dplyr::select(
          c("databaseName",
            "comparatorName",
            "nTarget",
            "eventsTarget",
            #"nComparator",
            #"eventsComparator",
            #"targetIr", "comparatorIr",
            "hr",
            "mean", "upper", "lower", "summary")
        ) %>% forestplot::forestplot(
          labeltext = c("databaseName",
                        "comparatorName",
                        "nTarget",
                        "eventsTarget",
                        #"nComparator",
                        #"eventsComparator",
                        #"targetIr", "comparatorIr",
                        "hr"),
          is.summary = summary,
          xlog = TRUE,
          boxsize = 0.5,
          #txt_gp = forestplot::fpTxtGp(
          #  summary = grid::gpar(cex = 0.5)
          #),
          vertices = TRUE,
          colgap = grid::unit(2, "mm"),
          graph.pos = 5,
          title = paste(targetName,' - ', outcomeName, ": ", analysisName),
          clip = c(exp(-5),exp(3))
        ) %>%
        forestplot::fp_add_header(
          databaseName = c("Database", " "),
          comparatorName = c("Comparator", ""),
          nTarget = c("Target", "N"),
          #nComparator = c("Comparator", "N"),
          eventsTarget = c("Target", "Events"),
          #eventsComparator = c("Comparator", "Events"),
          #targetIr = c("Target", "IR"),
          #comparatorIr = c("Comparator","IR"),
          hr = c("Hazard Ratio", "(95% CI)")
        ) %>%
        forestplot::fp_add_lines() |>
        forestplot::fp_set_style(
          box = "royalblue",
          line = "darkblue",
          summary = "royalblue",
          align = "lrrr",
          hrz_lines = "#999999"#,
          #txt_gp = forestplot::fpTxtGp(label = grid::gpar(fontfamily = "mono"))
        )
      plotList[[ind]] <- p
    }
  }
  
  return(plotList)
}


#' Plots the self controlled case series results for one analysis
#' @description
#' Creates nice self controlled case series plots 
#'
#' @details
#' Input the self controlled case series data 
#'
#' @param sccsData The self controlled case series data 
#' @param sccsMeta (optional) The self controlled case seriesd evidence synthesis data
#' @param targetName A friendly name for the target cohort
#' @param selectedAnalysisId The analysis ID of interest to plot
#' 
#' @family Estimation
#' @return
#' Returns a ggplot with the estimates
#' 
#' @export
#' @examples
#' 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' sccsEst <- getSccsEstimation(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1,
#'   outcomeIds = 3
#' )
#' plotSccsEstimates(
#'   sccsData = sccsEst, 
#'   sccsMeta = NULL, 
#'   targetName = 'target', 
#'   selectedAnalysisId = 1
#' )
#' 
plotSccsEstimates <- function(
    sccsData, 
    sccsMeta = NULL, 
    targetName, 
    selectedAnalysisId
    )
{
  
  fmtHazardRatio <- "%.2f"
  fmtIncidenceRate <- "%.1f"
  incidenceRateMult <- 365.25 * 1000
  maxVal <- max(sccsData$calibratedRr, na.rm = TRUE)
  sccsData$calibratedCi95Ub <- as.double(sccsData$calibratedCi95Ub)
  sccsData$calibratedCi95Lb <- as.double(sccsData$calibratedCi95Lb)
  estimates <- sccsData %>%
    dplyr::filter(.data$analysisId == !!selectedAnalysisId) %>%
    dplyr::select("databaseName", "calibratedRr",
                  "calibratedCi95Lb", "calibratedCi95Ub",
                  "calibratedLogRr", "calibratedP",
                  "outcomeSubjects":"observedDays",
                  "unblind", "unblindForEvidenceSynthesis"
    ) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      calibratedCi95Lb = tidyr::replace_na(.data$calibratedCi95Lb, 0.01),
      calibratedCi95Ub = tidyr::replace_na(.data$calibratedCi95Ub, !!maxVal)
    ) %>%
    dplyr::arrange(.data$databaseName) %>%
    dplyr::mutate(db = .data$databaseName) %>%
    dplyr::mutate(irr = ifelse(is.na(.data$calibratedRr), NA, paste0(sprintf(fmtHazardRatio, .data$calibratedRr),
                                                                     " (",
                                                                     sprintf(fmtHazardRatio, .data$calibratedCi95Lb),
                                                                     ", ",
                                                                     sprintf(fmtHazardRatio, .data$calibratedCi95Ub),
                                                                     ")")),
                  #cases = prettyNum(.data$outcomeEvents, big.mark = ","),
                  cases = ifelse(.data$outcomeSubjects < 0, "<5",
                                 as.character(prettyNum(.data$outcomeSubjects, big.mark = ","))),
                  yearsObs = format(round(.data$observedDays/365.25, 1), nsmall = 1, big.mark = ","),
                  #totalEvents = prettyNum(.data$outcomeEvents, big.mark = ","),
                  totalEvents = ifelse(.data$outcomeEvents < 0, "<5",
                                       as.character(prettyNum(.data$outcomeEvents, big.mark = ","))),
                  nExposed = ifelse(.data$covariateSubjects < 0, "<5",
                                    as.character(prettyNum(.data$covariateSubjects, big.mark = ","))),
                  #nExposed = prettyNum(.data$covariateSubjects, big.mark = ","),
                  yearsExposed = format(round(.data$covariateDays/365.25,1),
                                        nsmall = 1, big.mark = ","
                  ),
                  #exposedEvents = prettyNum(.data$covariateOutcomes, big.mark = ","),
                  exposedEvents = ifelse(.data$covariateOutcomes < 0, "<5",
                                         as.character(prettyNum(.data$covariateOutcomes, big.mark = ","))),
                  mean = .data$calibratedRr,
                  lower = .data$calibratedCi95Lb,
                  upper = .data$calibratedCi95Ub,
                  summary = FALSE
    ) %>%
    dplyr::mutate(
      irr = ifelse(.data$unblindForEvidenceSynthesis == 1 & .data$unblind == 0 , "--", .data$irr),
      databaseName = ifelse(.data$unblindForEvidenceSynthesis == 0 & .data$unblind == 0 , paste0(.data$databaseName, '*') ,.data$databaseName)
    )
  if (nrow(estimates) == 0) {
    return(NULL)
  }
  if (!is.null(sccsMeta)) {
    meta <- sccsMeta %>%
      dplyr::filter(.data$analysisId == !!selectedAnalysisId) %>%
      dplyr::mutate(databaseName = "Meta Analysis") %>%
      dplyr::select("databaseName", "calibratedRr", "calibratedCi95Lb",
                    "calibratedCi95Ub", "calibratedLogRr", "calibratedP",
                    "outcomeSubjects":"observedDays") %>%
      tidyr::drop_na() %>%
      dplyr::mutate(
        irr = paste0(sprintf(fmtHazardRatio, .data$calibratedRr),
                     " (",
                     sprintf(fmtHazardRatio,.data$calibratedCi95Lb),
                     ", ",
                     sprintf(fmtHazardRatio, .data$calibratedCi95Ub),
                     ")"
        ),
        cases = prettyNum(.data$outcomeSubjects, big.mark = ","),#"",
        yearsObs = "",
        totalEvents = prettyNum(.data$outcomeEvents, big.mark = ","),#"",
        nExposed = prettyNum(.data$covariateSubjects, big.mark = ","),#"",
        yearsExposed = "",
        exposedEvents = paste0(ifelse(.data$covariateOutcomes < 0,'<',''),prettyNum(abs(.data$covariateOutcomes), big.mark = ",")),#"",
        mean = .data$calibratedRr,
        lower = .data$calibratedCi95Lb,
        upper = .data$calibratedCi95Ub,
        summary = TRUE
      )
  }
  
  studyAnalysis <- sccsData %>%
    dplyr::filter(.data$analysisId == !!selectedAnalysisId)
  
  plotData <- estimates
  if (!is.null(sccsMeta)) {
    plotData <- dplyr::bind_rows(plotData,meta)
  }
  
  xlog <- TRUE
  if (min(plotData$lower, na.rm = TRUE) == 0) {
    warning("lower bound is zero - can not use log scale")
    xlog <- FALSE
  }
  p <- plotData %>%
    forestplot::forestplot(
      labeltext = c("databaseName",
                    "cases",
                    #"yearsObs",
                    "totalEvents",
                    "nExposed",
                    #"yearsExposed",
                    "exposedEvents",
                    "irr"
      ),
      is.summary = summary,
      xlog = xlog,
      boxsize = 0.5,
      colgap = grid::unit(2, "mm"),
      graph.pos = 6,
      title = paste(targetName, ':', unique(studyAnalysis$description))
    ) %>%
    forestplot::fp_add_header(
      databaseName = c("Data", "Source"),
      cases = c("Total", "Cases"),
      #yearsObs = c("Years of", "Observation"),
      totalEvents = c("Total", "Events"),
      nExposed = c("Exposed", "Cases"),
      #yearsExposed = c("Exposed", "Years"),
      exposedEvents = c("Exposed", "Events"),
      irr = c("Incidence Rate Ratio", "(95% CI)")
    ) %>%
    forestplot::fp_add_lines() |>
    forestplot::fp_set_style(
      box = "royalblue",
      line = "darkblue",
      summary = "royalblue",
      align = "lrrr",
      hrz_lines = "#999999"
    )
  
  
  return(p)
}






