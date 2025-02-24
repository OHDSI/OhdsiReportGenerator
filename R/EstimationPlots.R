#' Plots the cohort method results for one analysis
#' @description
#' Creates nice cohort method plots 
#'
#' @details
#' Input the cohort method data 
#'
#' @param cmData The cohort method data 
#' @param cmMeta (optional) The cohort method evidence synthesis data
#' @param targetName A friendly name for the target cohort
#' @param comparatorName A friendly name for the comparator cohort
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
#'   targetIds = 1,
#'   outcomeIds = 3
#' )
#' plotCmEstimates(
#'   cmData = cmEst, 
#'   cmMeta = NULL, 
#'   targetName = 'target', 
#'   comparatorName = 'comp', 
#'   selectedAnalysisId = 1
#' )
#' 
plotCmEstimates <- function(
    cmData,
    cmMeta = NULL,
    targetName,
    comparatorName,
    selectedAnalysisId
){
  
  fmtHazardRatio <- "%.2f"
  fmtIncidenceRate <- "%.1f"
  incidenceRateMult <- 365.25 * 1000 
  
  
  estimates <- cmData %>%
    dplyr::filter(.data$analysisId == !!selectedAnalysisId) %>%
    dplyr::mutate(
      hr = paste0(
        sprintf(fmtHazardRatio, .data$calibratedRr),
        " (",
        sprintf(fmtHazardRatio, .data$calibratedCi95Lb),
        ", ",
        sprintf(fmtHazardRatio, .data$calibratedCi95Ub),
        ")"),
      eventsTarget = ifelse(.data$targetOutcomes < 1, "<5", as.character(.data$targetOutcomes)),
      eventsComparator = ifelse(.data$comparatorOutcomes < 1, "<5", as.character(.data$comparatorOutcomes)),
      nTarget = prettyNum(.data$targetSubjects, big.mark = ","),
      nComparator = prettyNum(.data$comparatorSubjects, big.mark = ","),
      targetIr = ifelse(
        .data$targetOutcomes < 1,
        paste0("<", as.character(sprintf(fmtIncidenceRate, 5 / .data$targetDays * !!incidenceRateMult))),
        as.character(sprintf(fmtIncidenceRate, .data$targetOutcomes / .data$targetDays * !!incidenceRateMult))),
      comparatorIr = ifelse(
        .data$comparatorOutcomes < 1, 
        paste0("<", as.character(sprintf(fmtIncidenceRate, 5 / .data$comparatorDays * !!incidenceRateMult))),
        as.character(sprintf(fmtIncidenceRate, .data$comparatorOutcomes / .data$comparatorDays * !!incidenceRateMult))),
      mean = .data$calibratedRr,
      lower = .data$calibratedCi95Lb,
      upper = .data$calibratedCi95Ub,
      summary = FALSE
    ) %>%
    dplyr::mutate(
      hr = ifelse(is.na(.data$calibratedRr), "--", .data$hr),
      eventsTarget = ifelse(.data$nTarget == 0, "--", .data$eventsTarget),
      eventsComparator = ifelse(.data$nComparator == 0, "--", .data$eventsComparator),
      targetIr = ifelse(.data$nTarget == 0, "--", .data$targetIr),
      comparatorIr = ifelse(.data$nComparator == 0, "--", .data$comparatorIr)
    ) %>%
    dplyr::arrange(.data$databaseName) %>%
    dplyr::select(
      "databaseName", 
      "nTarget", 
      "nComparator", 
      "eventsTarget", 
      "eventsComparator", 
      "targetIr", 
      "comparatorIr", 
      "hr", 
      "summary", 
      "mean", 
      "upper", 
      "lower"
    )
  
  if (nrow(estimates) <= 0) {
    # No data to plot
    return(NULL)
  }
  
  if (!is.null(cmMeta)) {
    meta <- cmMeta %>%
      dplyr::filter(.data$analysisId == !!selectedAnalysisId) %>%
      dplyr::mutate(
        hr = paste0(
          sprintf(fmtHazardRatio, .data$calibratedRr),
          " (",
          sprintf(fmtHazardRatio, .data$calibratedCi95Lb),
          ", ",
          sprintf(fmtHazardRatio, .data$calibratedCi95Ub),
          ")"),
        mean = .data$calibratedRr,
        upper = .data$calibratedCi95Ub,
        lower = .data$calibratedCi95Lb,
        nTarget = "",
        nComparator = "", 
        eventsTarget = "",
        eventsComparator = "",
        targetIr = "",
        comparatorIr = "",
        summary = TRUE
      ) %>%
      dplyr::mutate(
        hr = ifelse(is.na(.data$calibratedRr), "--", .data$hr),
        database = "Meta Analysis"
      ) %>%
      dplyr::select(
        "databaseName", 
        "nTarget", 
        "nComparator", 
        "eventsTarget", 
        "eventsComparator", 
        "targetIr", 
        "comparatorIr", 
        "hr", 
        "summary", 
        "mean", 
        "upper", 
        "lower"
      )
  }
  
  header <- tibble::tibble(
    databaseName = c("Data", "Source"),
    nTarget = c("Target", "N"),
    nComparator = c("Comparator", "N"),
    eventsTarget = c("Target", "Events"),
    eventsComparator = c("Comparator", "Events"),
    targetIr = c("Target", "IR"),
    comparatorIr = c("Comparator", "IR"),
    hr = c("Hazard Ratio", "(95% CI)"),
    summary = TRUE
  )
  
  plotData <- dplyr::bind_rows(
    header,
    estimates
  )
  
  if (!is.null(cmMeta)) {
    plotData <- dplyr::bind_rows(
      plotData,
      tibble::tibble(calibratedRr = NA_real_),
      meta
    )
  }
  
  dividers <- list(grid::gpar(lty = 1),
                   grid::gpar(lty = 1))
  names(dividers) <- as.character(c(3, nrow(plotData) - 1))
  
  # edit to enable log scale
  if(sum(plotData$lower < 0.01, na.rm = TRUE) > 0){
    plotData$lower[plotData$lower < 0.01] <- 0.01
  }
  if(sum(plotData$upper > 50, na.rm = TRUE) > 0){
    plotData$lower[plotData$lower > 50] <- 50
  }
  
  p <- plotData %>%
    forestplot::forestplot(
      labeltext = c( # .data?
        "databaseName", 
        "nTarget", 
        "nComparator", 
        "eventsTarget", 
        "eventsComparator", 
        "targetIr", 
        "comparatorIr", 
        "hr"
      ),
      is.summary = summary,
      xlog = TRUE,
      boxsize = 0.5,
      hrzl_lines = dividers,
      # align = c("l", "c", "c", "c"),
      txt_gp = forestplot::fpTxtGp(summary = grid::gpar(cex=0.5)),
      colgap = grid::unit(2, "mm"),
      graph.pos = 8,
      title = paste(targetName, "v.", comparatorName))
  return(p)
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
) {
  # check only one target and outcome in data
  fmtHazardRatio <- "%.2f"
  fmtIncidenceRate <- "%.1f"
  incidenceRateMult <- 365.25 * 1000 
  
  maxVal <- max(sccsData$calibratedRr, na.rm = TRUE)
  
  estimates <- sccsData %>%
    dplyr::filter(.data$analysisId == !!selectedAnalysisId) %>%
    dplyr::select(
      "databaseName",
      #"exposuresOutcomeSetId", # no longer in results?
      "calibratedRr",
      "calibratedCi95Lb",
      "calibratedCi95Ub",
      "calibratedLogRr",
      "calibratedP",
      "outcomeSubjects":"observedDays") %>%
    tidyr::drop_na("databaseName","calibratedRr","calibratedLogRr","calibratedP","outcomeSubjects":"observedDays") %>%
    dplyr::mutate(
      calibratedCi95Lb = tidyr::replace_na(0),
      calibratedCi95Ub = tidyr::replace_na(!!maxVal)
    ) %>%
    dplyr::arrange(.data$databaseName) %>%
    dplyr::mutate(db = .data$databaseName) %>%
    dplyr::mutate(
      irr = paste0(
        sprintf(fmtHazardRatio, .data$calibratedRr),
        " (",
        sprintf(fmtHazardRatio, .data$calibratedCi95Lb),
        ", ",
        sprintf(fmtHazardRatio, .data$calibratedCi95Ub),
        ")"),
      cases = prettyNum(.data$outcomeEvents, big.mark = ","),
      yearsObs = format(round(.data$observedDays / 365.25, 1), nsmall = 1, big.mark = ","),
      totalEvents = prettyNum(.data$outcomeEvents, big.mark = ","),
      nExposed = prettyNum(.data$covariateSubjects, big.mark = ","),
      yearsExposed = format(round(.data$covariateDays / 365.25, 1), nsmall = 1, big.mark = ","),
      exposedEvents = prettyNum(.data$covariateOutcomes, big.mark = ","),
      mean = .data$calibratedRr,
      lower = .data$calibratedCi95Lb,
      upper = .data$calibratedCi95Ub,
      summary = FALSE)
  
  if (nrow(estimates) == 0) {
    # No data
    return(NULL)
  }
  
  if (!is.null(sccsMeta)) {
    meta <- sccsMeta %>%
      dplyr::filter(.data$analysisId == !!selectedAnalysisId) %>%
      dplyr::mutate(databaseName = "Meta Analysis") %>% 
      dplyr::select(
        "databaseName",
        #"exposuresOutcomeSetId",
        "calibratedRr",
        "calibratedCi95Lb",
        "calibratedCi95Ub",
        "calibratedLogRr",
        "calibratedP",
        "outcomeSubjects":"observedDays") %>%
      tidyr::drop_na() %>%
      dplyr::mutate(
        irr = paste0(
          sprintf(fmtHazardRatio, .data$calibratedRr),
          " (",
          sprintf(fmtHazardRatio, .data$calibratedCi95Lb),
          ", ",
          sprintf(fmtHazardRatio, .data$calibratedCi95Ub),
          ")"),
        cases = "",
        yearsObs = "",
        totalEvents = "",
        nExposed = "",
        yearsExposed = "",
        exposedEvents = "",
        mean = .data$calibratedRr,
        lower = .data$calibratedCi95Lb,
        upper = .data$calibratedCi95Ub,
        summary = TRUE)
  }
  
  header <- tibble::tibble(
    databaseName = c("Data", "Source"),
    cases = c("Total", "Cases"),
    yearsObs = c("Years of", "Observation"),
    totalEvents = c("Total", "Events"),
    nExposed = c("Exposed", "Cases"),
    yearsExposed = c("Exposed", "Years"),
    exposedEvents = c("Exposed", "Events"),
    irr = c("Incidence Rate Ratio", "(95% CI)"),
    summary = TRUE
  )
  
  plotData <- dplyr::bind_rows(
    header,
    estimates
  )
  
  if (!is.null(sccsMeta)) {
    plotData <- dplyr::bind_rows(
      plotData,
      tibble::tibble(calibratedRr = NA_real_),
      meta
      
    )
  }
  
  dividers <- list(grid::gpar(lty = 1),
                   grid::gpar(lty = 1))
  names(dividers) <- as.character(c(3, nrow(plotData) - 1))
  
  # check lower is not 0
  xlog <- TRUE
  if(min(plotData$lower, na.rm = TRUE) == 0){
    warning('lower bound is zero - can not use log scale')
    xlog <- FALSE
  }
  
  p <- plotData %>%
    forestplot::forestplot(
      labeltext = c(
        "databaseName", 
        "cases", 
        "yearsObs", 
        "totalEvents", 
        "nExposed", 
        "yearsExposed", 
        "exposedEvents", 
        "irr"
      ),
      is.summary = summary,
      xlog = xlog,
      boxsize = 0.5,
      hrzl_lines = dividers,
      # align = c("l", "c", "c", "c"),
      colgap = grid::unit(2, "mm"),
      graph.pos = 8,
      title = paste(targetName))
  return(p)
}
