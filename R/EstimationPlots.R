#' Plots the cohort method results for one analysis
#' @description
#' Creates nice cohort method plots 
#'
#' @details
#' Input the cohort method data 
#'
#' @param cmData The cohort method data 
#' @param cmDiagnostics (optional) The cohort method diagnostic data
#' @param cmMeta (optional) The cohort method evidence synthesis data
#' @param cohortNames A data.frame with columns cohortId and cohortName
#' @param includeCounts Whether to include the target/comp size and event counts
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
    cmDiagnostics = NULL,
    cmMeta = NULL,
    cohortNames = NULL,
    includeCounts = TRUE,
    selectedAnalysisId = NULL
)
{
  if(!is.null(selectedAnalysisId)){
    cmDataAll <- cmData %>%
      dplyr::filter(.data$analysisId == !!selectedAnalysisId)
  } else{
    cmDataAll <- cmData
  }
  
  # Add in diagnostics 
  diagColumns <- c("MDRR","EASE","SMD","EQUIPOISE")
  
  if(!is.null(cmDiagnostics)){
    
    cmDataAll <- cmDataAll %>%
      dplyr::inner_join(
        y = cmDiagnostics %>%
          dplyr::select("databaseId","analysisId", "targetId",
                        "comparatorId", "outcomeId", "indicationId",
                        "mdrrDiagnostic", "easeDiagnostic",
                        "sharedBalanceDiagnostic",
                        "equipoiseDiagnostic") %>%
          dplyr::rename(
            MDRR = "mdrrDiagnostic",
            EASE = "easeDiagnostic",
            SMD = "sharedBalanceDiagnostic",
            EQUIPOISE = "equipoiseDiagnostic"
          ),
        by = c("databaseId","analysisId", "targetId",
               "comparatorId", "outcomeId", "indicationId")
      )
    
  }
  
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
    
    if(!is.null(selectedAnalysisId)){
      cmMetaAll <- cmMeta %>%
        dplyr::filter(.data$analysisId == !!selectedAnalysisId)
    } else{
      cmMetaAll <- cmMeta
    }
    
    if(!is.null(cohortNames)){
      cmMetaAll <- cmMetaAll %>%
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
  }
  
  ton <- cmDataAll %>%
    dplyr::select("targetId","outcomeId", "indicationId",
                  "targetName","outcomeName", "indicationName") %>%
    dplyr::distinct()
  
  plotList <- list()
  length(plotList) <- nrow(ton)
  names(plotList) <- paste0(ton$targetName,'-', ton$outcomeName, '-', ton$indicationName)
  
  for(ind in 1:nrow(ton)){
    
    # filter the cmDataAll to specific T/O/I
    cmDataTon <- cmDataAll %>%
      dplyr::filter(.data$targetId == !!ton$targetId[ind] &
                    .data$outcomeId == !!ton$outcomeId[ind] &
                    .data$indicationId == !!ton$indicationId[ind]
      ) %>%
      dplyr::mutate(  
        order = 2,
        summary = FALSE
        )
    
    # create the heading rows
    headings <- rbind(
      cmDataTon %>% 
        dplyr::select("description", "comparatorName") %>%
        dplyr::distinct() %>%
        dplyr::mutate(
          databaseName = substr(.data$comparatorName,1,50),
          unblindForEvidenceSynthesis = NA,
          MDRR = NA,
          EASE = NA,
          SMD = NA,
          EQUIPOISE = NA,
          calibratedRr  = NA,
          calibratedCi95Lb  = NA,
          calibratedCi95Ub  = NA,
          targetSubjects  = NA,
          targetDays  = NA,
          targetOutcomes = NA,
          comparatorSubjects = NA,
          comparatorDays = NA,
          comparatorOutcomes = NA,
          unblind = NA,
          order = 1,
          summary = FALSE
        ),
      cmDataTon %>% 
        dplyr::select("description", "comparatorName") %>%
        dplyr::distinct() %>%
        dplyr::mutate(
          databaseName = substr(.data$description,1,50),
          unblindForEvidenceSynthesis = NA,
          MDRR = NA,
          EASE = NA,
          SMD = NA,
          EQUIPOISE = NA,
          calibratedRr  = NA,
          calibratedCi95Lb  = NA,
          calibratedCi95Ub  = NA,
          targetSubjects  = NA,
          targetDays  = NA,
          targetOutcomes = NA,
          comparatorSubjects = NA,
          comparatorDays = NA,
          comparatorOutcomes = NA,
          unblind = NA,
          order = 1.2,
          summary = FALSE
        )
    )
    
    # add the header rows to the cm data
    plotData <- dplyr::bind_rows(
      cmDataTon %>%
        dplyr::mutate(
          databaseName = paste0('   ', .data$databaseName)
        ) %>%
        dplyr::select(
          "databaseName",
          "comparatorName",
          "description",
          "order",
          "summary",
          
          "targetSubjects",
          "targetOutcomes",
          "comparatorSubjects",
          "comparatorOutcomes",
          
          "calibratedRr",
          "calibratedCi95Lb", 
          "calibratedCi95Ub",
          "unblindForEvidenceSynthesis",
          dplyr::any_of(diagColumns)
        ),
      headings %>%
        dplyr::select(
          "databaseName",
          "comparatorName",
          "description",
          "order",
          "summary",
          
          "targetSubjects",
          "targetOutcomes",
          "comparatorSubjects",
          "comparatorOutcomes",
          
          "calibratedRr",
          "calibratedCi95Lb", 
          "calibratedCi95Ub",
          "unblindForEvidenceSynthesis"
        )
    )
    
    # add the meta rows (if input)
    if (!is.null(cmMeta)) {
      
      # create three rows - the main meta, tau row below and then prediction interval
      metaRows <- rbind(
        cmMetaAll %>%
          dplyr::filter(.data$targetId == !!ton$targetId[ind] &
                          .data$outcomeId == !!ton$outcomeId[ind] &
                          .data$indicationId == !!ton$indicationId[ind]
          ) %>%
          dplyr::mutate(
            order = 3,
            summary = TRUE
          ) %>%
          dplyr::select(
            "databaseName",
            "comparatorName",
            "description",
            "order",
            "summary",
            
            "targetSubjects",
            "targetOutcomes",
            "comparatorSubjects",
            "comparatorOutcomes",
            
            "calibratedRr",
            "calibratedCi95Lb", 
            "calibratedCi95Ub"
          ),
        
        cmMetaAll %>%
          dplyr::filter(.data$targetId == !!ton$targetId[ind] &
                          .data$outcomeId == !!ton$outcomeId[ind] &
                          .data$indicationId == !!ton$indicationId[ind]
          ) %>% 
          dplyr::mutate(
          databaseName = paste0('tau = ',sprintf("%.3f", .data$tau)),
          order = 3.1,
          summary = FALSE,
          
          targetSubjects = NA,
          targetOutcomes = NA,
          comparatorSubjects = NA,
          comparatorOutcomes = NA,
          
          calibratedRr = NA,
          calibratedCi95Lb = NA,
          calibratedCi95Ub = NA
        ) %>%
          dplyr::select(
            "databaseName",
            "comparatorName",
            "description",
            "order",
            "summary",
            
            "targetSubjects",
            "targetOutcomes",
            "comparatorSubjects",
            "comparatorOutcomes",
            
            "calibratedRr",
            "calibratedCi95Lb", 
            "calibratedCi95Ub"
          ),
      
        cmMetaAll %>%
          dplyr::filter(.data$targetId == !!ton$targetId[ind] &
                          .data$outcomeId == !!ton$outcomeId[ind] &
                          .data$indicationId == !!ton$indicationId[ind]
          ) %>%
        dplyr::mutate(
          databaseName = "Prediction Interval",
          order = 3.2,
          summary = TRUE,
          
          targetSubjects = NA,
          targetOutcomes = NA,
          comparatorSubjects = NA,
          comparatorOutcomes = NA,
          
          calibratedRr = NA,
          calibratedCi95Lb = .data$calibratedPi95Lb,
          calibratedCi95Ub = .data$calibratedPi95Ub
        ) %>%
          dplyr::select(
            "databaseName",
            "comparatorName",
            "description",
            "order",
            "summary",
            
            "targetSubjects",
            "targetOutcomes",
            "comparatorSubjects",
            "comparatorOutcomes",
            
            "calibratedRr",
            "calibratedCi95Lb", 
            "calibratedCi95Ub"
          )
      )
      
      
      # add the rows to the main
      plotData <- dplyr::bind_rows(plotData,metaRows)
    }
    
    # if diagnostics are missing add them:
    if(sum(diagColumns %in% colnames(plotData)) != length(diagColumns)){
      missCols <- diagColumns[!diagColumns %in% colnames(plotData)]
      plotData[missCols] <- NA
    }
    
  
    # Now the code to do the plot
    plotData <- plotData %>%
      dplyr::arrange(.data$comparatorName, .data$description, .data$order)
    
    plotTable <- plotData %>%
      dplyr::mutate(
        `Study` = dplyr::case_when(
          is.na(.data$unblindForEvidenceSynthesis) ~ .data$databaseName, 
          .data$unblindForEvidenceSynthesis == 1 ~ paste0(.data$databaseName, "*"),
          .data$unblindForEvidenceSynthesis == 0 ~ .data$databaseName
        ),
        ` ` = strrep(" ", 50), # spacer column used for CI drawing
        `RR (95% CI)` = dplyr::case_when(
          !is.na(.data$calibratedRr) ~ sprintf("%.2f (%.2f, %.2f)", .data$calibratedRr, .data$calibratedCi95Lb, .data$calibratedCi95Ub),
          is.na(.data$calibratedRr) & !is.na(.data$calibratedCi95Lb) ~ sprintf("(%0.2f, %0.2f)", .data$calibratedCi95Lb, .data$calibratedCi95Ub),
          TRUE ~ ""
        ),
        
        `Target\n    N` = ifelse(
          is.na(.data$targetSubjects),
          "",
          format(.data$targetSubjects, big.mark = ",")
        ),
        `Target\nevents` = ifelse(
          is.na(.data$targetOutcomes),
          "",
          format(.data$targetOutcomes, big.mark = ",")
        ),
        `Comparator\n      N` = ifelse(
          is.na(.data$comparatorSubjects),
          "",
          format(.data$comparatorSubjects, big.mark = ",")
        ),
        `Comparator\n    events` = ifelse(
          is.na(.data$comparatorOutcomes),
          "",
          format(.data$comparatorOutcomes, big.mark = ",")
        ),
        
        `MDRR` = dplyr::case_when(
          is.na(.data$MDRR) ~ "", 
          .data$MDRR == 'PASS' ~ "\u2714",
          .data$MDRR == 'FAIL' ~ "\u2718",
          .data$MDRR == 'NOT EVALUATED' ~ "?"
        ), 
        `EASE` = dplyr::case_when(
          is.na(.data$EASE) ~ "", 
          .data$EASE == 'PASS' ~ "\u2714",
          .data$EASE == 'FAIL' ~ "\u2718",
          .data$EASE == 'NOT EVALUATED' ~ "?"
        ),
        `SMD` = dplyr::case_when(
          is.na(.data$SMD) ~ "", 
          .data$SMD == 'PASS' ~ "\u2714",
          .data$SMD == 'FAIL' ~ "\u2718",
          .data$SMD == 'NOT EVALUATED' ~ "?"
        ),
        `EQUIP\nOISE` = dplyr::case_when(
          is.na(.data$EQUIPOISE) ~ "", 
          .data$EQUIPOISE == 'PASS' ~ "\u2714",
          .data$EQUIPOISE == 'FAIL' ~ "\u2718",
          .data$EQUIPOISE == 'NOT EVALUATED' ~ "?"
        )
      ) %>%
      dplyr::select(-"EQUIPOISE")
    
    isPi <- grepl("Prediction Interval", plotTable$Study, fixed = TRUE)
    isMeta <- grepl("Bayesian", plotTable$Study, fixed = TRUE)
    isSummaryPlot <- isMeta & !isPi
    
    
    # For rows with PI only (no point estimate), use geometric midpoint for plotting
    estForPlot <- ifelse(
      is.na(plotTable$calibratedRr) &
        !is.na(plotTable$calibratedCi95Lb) &
        !is.na(plotTable$calibratedCi95Ub),
      sqrt(plotTable$calibratedCi95Lb * plotTable$calibratedCi95Ub),
      plotTable$calibratedRr
    )
    
    # Keep log-scale limits data-driven but stable
    finiteBounds <- c(plotTable$calibratedCi95Lb, plotTable$calibratedCi95Ub)
    finiteBounds <- finiteBounds[is.finite(finiteBounds) & finiteBounds > 0]
    xMin <- max(min(finiteBounds, na.rm = TRUE) * 0.8, 0.1)
    xMax <- max(finiteBounds, na.rm = TRUE) * 1.2
    
    tm <- forestploter::forest_theme(
      base_size = 10,
      refline_col = "#555555",
      ci_col = "#1F78B4",
      summary_col = "#D95F02",
      footnote_col = "#555555"
    )
    
    sizes <- ifelse(isPi, 0.001, 0.4)
    
    if(!is.null(cmDiagnostics)){
      plotDiagCols <- c('MDRR',"EASE", "SMD", "EQUIP\nOISE")
    } else{
      plotDiagCols <- c()
    }
    
    if(includeCounts){
      countCols <- c("Target\n    N", "Target\nevents", "Comparator\n      N", "Comparator\n    events")
    } else{
      countCols <- c()
    }
    
    columsToInclude <- c("Study", " ", "RR (95% CI)", countCols, plotDiagCols)
    
    p <- forestploter::forest(
      plotTable[, columsToInclude],
      est = estForPlot,
      lower = plotTable$calibratedCi95Lb,
      upper = plotTable$calibratedCi95Ub,
      sizes = sizes,
      ci_column = 2,
      is_summary = isSummaryPlot,
      ref_line = 1,
      x_trans = "log",
      xlim = c(0.1, 10),
      vert_line = c(0.25, 0.5, 2 , 4),
      vert_line_lty = "dashed",
      vert_line_col = "grey50", 
      ticks_at = c(0.1, 0.5, 1, 2, 10),
      arrow_lab = c("Favours target", "Favours comparator"),
      theme = tm, 
      footnote = "* database used in Baysian analysis"
    )
    

    # Shade from each meta-analysis row through its prediction-interval row
    metaRows <- which(grepl("Bayesian", plotTable$Study, fixed = TRUE))
    piRows <- which(grepl("Prediction Interval", plotTable$Study, fixed = TRUE))
    
    # Light blue transparent fill
    shadeFill <- grDevices::adjustcolor("#ADD8E6", alpha.f = 0.5)
    
    for (i in seq_len(min(length(metaRows), length(piRows)))) {
      blockRows <- metaRows[i]:piRows[i]
      p <- forestploter::edit_plot(
        p,
        row = blockRows,
        col = 1:(3+length(countCols)+length(plotDiagCols)),                  # all displayed table/CI columns
        part = "body",
        which = "background",
        gp = grid::gpar(fill = shadeFill, col = NA)
      )
    }
    
    # add bold text for summary
    p <- forestploter::edit_plot(
      p,
      row = which(isMeta | isPi),
      col = 1:(3+length(countCols)),        # adjust upper bound to match your total text column count
      part = "body",
      which = "text",
      gp = grid::gpar(fontface = "bold")
    ) 
    
    # edit the diagnostics columns to make headings small and enable ticks/crosses
    if(length(plotDiagCols) > 0){
      p <- p %>%
        forestploter::edit_plot(
        col = (1+3+length(countCols)):(3+length(countCols)+length(plotDiagCols)),
        part = "header",
        which = "text",
        gp = grid::gpar(fontsize = 5)
      ) %>%
      forestploter::edit_plot(
        col = (1+3+length(countCols)):(3+length(countCols)+length(plotDiagCols)),
        part = "body",
        which = "text",
        gp = grid::gpar(fontfamily = "Arial Unicode MS")
      )
    }
    
    # changing color for tick/cross
    for(diagnostic in c('MDRR', 'EASE', "SMD", "EQUIP\nOISE")){
      
      if(diagnostic %in% columsToInclude){
        colInd <- which(columsToInclude %in% diagnostic)
        passRows <- which(plotTable[diagnostic] == "\u2714")
        failRows <- which(plotTable[diagnostic] == "\u2718")
        
        if (length(passRows) > 0) {
          p <- forestploter::edit_plot(
            p,
            row = passRows,
            col = colInd,
            part = "body",
            which = "text",
            gp = grid::gpar(col = "#2E8B57", fontface = "bold")  # green
          )
        }
        
        if (length(failRows) > 0) {
          p <- forestploter::edit_plot(
            p,
            row = failRows,
            col = colInd,
            part = "body",
            which = "text",
            gp = grid::gpar(col = "#CC0000", fontface = "bold")  # red
          )
        }
      }
      
    }
    
      plotList[[ind]] <- p
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
#' @param sccsDiagnostics (optional) The self controlled case series diagnostic data
#' @param sccsMeta (optional) The self controlled case series evidence synthesis data
#' @param includeCounts Whether to include count on the plot
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
#'   selectedAnalysisId = 1
#' )
#' 
plotSccsEstimates <- function(
    sccsData, 
    sccsDiagnostics = NULL,
    sccsMeta = NULL, 
    includeCounts = TRUE,
    selectedAnalysisId
    )
{
  
  # replace indicationId NA with 0
  sccsData <- sccsData %>%
    dplyr::mutate(
      indicationId = dplyr::case_when(
        is.na(.data$indicationId) ~ 0,
        !is.na(.data$indicationId) ~ .data$indicationId
      )
    )
  if(!is.null(sccsDiagnostics)){
    sccsDiagnostics <- sccsDiagnostics %>%
      dplyr::mutate(
        indicationId = dplyr::case_when(
          is.na(.data$indicationId) ~ 0,
          !is.na(.data$indicationId) ~ .data$indicationId
        )
      )
  }
  if(!is.null(sccsMeta)){
    sccsMeta <- sccsMeta %>%
      dplyr::mutate(
        indicationId = dplyr::case_when(
          is.na(.data$indicationId) ~ 0,
          !is.na(.data$indicationId) ~ .data$indicationId
        )
      )
  }
  
  if(!is.null(selectedAnalysisId)){
    sccsDataAll <- sccsData %>%
      dplyr::filter(.data$analysisId == !!selectedAnalysisId)
  } else{
    sccsDataAll <- sccsData
  }
  
  # Add in diagnostics 
  diagColumns <- c("MDRR","EASE","TIME", 
                   "EXPOSURE", "OBS",
                   "RARE")
  
  if(!is.null(sccsDiagnostics)){
    
    sccsDataAll <- sccsDataAll %>%
      dplyr::inner_join(
        y = sccsDiagnostics %>%
          dplyr::select("databaseId","analysisId", "targetId",
                        "outcomeId", "indicationId", "covariateName",
                        "mdrrDiagnostic", "easeDiagnostic",
                        "timeStabilityDiagnostic",
                        "eventExposureDiagnostic",
                        "eventObservationDiagnostic",
                        "rareOutcomeDiagnostic") %>%
          dplyr::rename(
            MDRR = "mdrrDiagnostic",
            EASE = "easeDiagnostic",
            TIME = "timeStabilityDiagnostic",
            EXPOSURE = "eventExposureDiagnostic",
            OBS = "eventObservationDiagnostic",
            RARE = "rareOutcomeDiagnostic"
          ),
        by = c("databaseId","analysisId", "targetId",
                "outcomeId", "indicationId", "covariateName")
      )
    
  }
  
  if(!is.null(sccsMeta)){
    
    if(!is.null(selectedAnalysisId)){
      sccsMetaAll <- sccsMeta %>%
        dplyr::filter(.data$analysisId == !!selectedAnalysisId)
    } else{
      sccsMetaAll <- sccsMeta
    }
  
  }
  
  ton <- sccsDataAll %>%
    dplyr::select("targetId","outcomeId", "indicationId",
                  "targetName","outcomeName", "indicationName") %>%
    dplyr::distinct()
  
  plotList <- list()
  length(plotList) <- nrow(ton)
  names(plotList) <- paste0(ton$targetName,'-', ton$outcomeName, '-', ton$indicationName)
  
  for(ind in 1:nrow(ton)){
    
    # filter the cmDataAll to specific T/O/I
    sccsDataTon <- sccsDataAll %>%
      dplyr::filter(.data$targetId == !!ton$targetId[ind] &
                      .data$outcomeId == !!ton$outcomeId[ind] &
                      .data$indicationId == !!ton$indicationId[ind]
      ) %>%
      dplyr::mutate(  
        order = 2,
        summary = FALSE
      )
    
    # create the heading rows
    headings <- rbind(
      sccsDataTon %>% 
        dplyr::select("description", "covariateName") %>%
        dplyr::distinct() %>%
        dplyr::mutate(
          databaseName = substr(.data$covariateName,1,50),
          unblindForEvidenceSynthesis = NA,
          
          MDRR = NA,
          EASE = NA,
          TIME = NA,
          EXPOSURE = NA,
          OBS = NA,
          RARE = NA,
          
          calibratedRr  = NA,
          calibratedCi95Lb  = NA,
          calibratedCi95Ub  = NA,
          
          covariateSubjects  = NA,
          covariateDays  = NA,
          covariateOutcomes = NA,
          outcomeSubjects = NA,
          outcomeEvents = NA,
          
          unblind = NA,
          order = 1,
          summary = FALSE
        ),
      sccsDataTon %>% 
        dplyr::select("description", "covariateName") %>%
        dplyr::distinct() %>%
        dplyr::mutate(
          databaseName = substr(.data$description,1,50),
          unblindForEvidenceSynthesis = NA,
          
          MDRR = NA,
          EASE = NA,
          TIME = NA,
          EXPOSURE = NA,
          OBS = NA,
          RARE = NA,
          
          calibratedRr  = NA,
          calibratedCi95Lb  = NA,
          calibratedCi95Ub  = NA,
          
          covariateSubjects  = NA,
          covariateDays  = NA,
          covariateOutcomes = NA,
          outcomeSubjects = NA,
          outcomeEvents = NA,
          
          unblind = NA,
          order = 1.2,
          summary = FALSE
        )
    )
    
    # add the header rows to the cm data
    plotData <- dplyr::bind_rows(
      sccsDataTon %>%
        dplyr::mutate(
          databaseName = paste0('   ', .data$databaseName)
        ) %>%
        dplyr::select(
          "databaseName",
          "covariateName",
          "description",
          "order",
          "summary",
          
          "covariateSubjects",
          "covariateDays",
          "covariateOutcomes",
          "outcomeSubjects",
          "outcomeEvents",
          
          "calibratedRr",
          "calibratedCi95Lb", 
          "calibratedCi95Ub",
          "unblindForEvidenceSynthesis",
          dplyr::any_of(diagColumns)
        ),
      headings %>%
        dplyr::select(
          "databaseName",
          "covariateName",
          "description",
          "order",
          "summary",
          
          "covariateSubjects",
          "covariateDays",
          "covariateOutcomes",
          "outcomeSubjects",
          "outcomeEvents",
          
          "calibratedRr",
          "calibratedCi95Lb", 
          "calibratedCi95Ub",
          "unblindForEvidenceSynthesis"
        )
    )
    
    # add the meta rows (if input)
    if (!is.null(sccsMeta)) {
      
      # create three rows - the main meta, tau row below and then prediction interval
      metaRows <- rbind(
        sccsMetaAll %>%
          dplyr::filter(.data$targetId == !!ton$targetId[ind] &
                          .data$outcomeId == !!ton$outcomeId[ind] &
                          .data$indicationId == !!ton$indicationId[ind]
          ) %>%
          dplyr::mutate(
            order = 3,
            summary = TRUE
          ) %>%
          dplyr::select(
            "databaseName",
            "covariateName",
            "description",
            "order",
            "summary",
            
            "covariateSubjects",
            "covariateDays",
            "covariateOutcomes",
            "outcomeSubjects",
            "outcomeEvents",
            
            "calibratedRr",
            "calibratedCi95Lb", 
            "calibratedCi95Ub"
          ),
        
        sccsMetaAll %>%
          dplyr::filter(.data$targetId == !!ton$targetId[ind] &
                          .data$outcomeId == !!ton$outcomeId[ind] &
                          .data$indicationId == !!ton$indicationId[ind]
          ) %>% 
          dplyr::mutate(
            databaseName = paste0('tau = ',sprintf("%.3f", .data$tau)),
            order = 3.1,
            summary = FALSE,
            
            covariateSubjects = NA,
            covariateDays = NA,
            covariateOutcomes = NA,
            outcomeSubjects = NA,
            outcomeEvents = NA,
            
            calibratedRr = NA,
            calibratedCi95Lb = NA,
            calibratedCi95Ub = NA
          ) %>%
          dplyr::select(
            "databaseName",
            "covariateName",
            "description",
            "order",
            "summary",
            
            "covariateSubjects",
            "covariateDays",
            "covariateOutcomes",
            "outcomeSubjects",
            "outcomeEvents",
            
            "calibratedRr",
            "calibratedCi95Lb", 
            "calibratedCi95Ub"
          ),
        
        sccsMetaAll %>%
          dplyr::filter(.data$targetId == !!ton$targetId[ind] &
                          .data$outcomeId == !!ton$outcomeId[ind] &
                          .data$indicationId == !!ton$indicationId[ind]
          ) %>%
          dplyr::mutate(
            databaseName = "Prediction Interval",
            order = 3.2,
            summary = TRUE,
            
            covariateSubjects = NA,
            covariateDays = NA,
            covariateOutcomes = NA,
            outcomeSubjects = NA,
            outcomeEvents = NA,
            
            calibratedRr = NA,
            calibratedCi95Lb = .data$calibratedPi95Lb,
            calibratedCi95Ub = .data$calibratedPi95Ub
          ) %>%
          dplyr::select(
            "databaseName",
            "covariateName",
            "description",
            "order",
            "summary",
            
            "covariateSubjects",
            "covariateDays",
            "covariateOutcomes",
            "outcomeSubjects",
            "outcomeEvents",
            
            "calibratedRr",
            "calibratedCi95Lb", 
            "calibratedCi95Ub"
          )
      ) %>%
        dplyr::mutate(
          calibratedCi95Lb = as.double(.data$calibratedCi95Lb),
          calibratedCi95Ub = as.double(.data$calibratedCi95Ub)
        )
      
      
      # add the rows to the main
      plotData <- dplyr::bind_rows(plotData,metaRows)
    }
    
    # if diagnostics are missing add them:
    if(sum(diagColumns %in% colnames(plotData)) != length(diagColumns)){
      missCols <- diagColumns[!diagColumns %in% colnames(plotData)]
      plotData[missCols] <- NA
    }
    
    
    # Now the code to do the plot
    plotData <- plotData %>%
      dplyr::arrange(.data$covariateName, .data$description, .data$order)
    
    plotTable <- plotData %>%
      dplyr::mutate(
        `Study` = dplyr::case_when(
          is.na(.data$unblindForEvidenceSynthesis) ~ .data$databaseName, 
          .data$unblindForEvidenceSynthesis == 1 ~ paste0(.data$databaseName, "*"),
          .data$unblindForEvidenceSynthesis == 0 ~ .data$databaseName
        ),
        ` ` = strrep(" ", 50), # spacer column used for CI drawing
        `HR (95% CI)` = dplyr::case_when(
          !is.na(.data$calibratedRr) ~ sprintf("%.2f (%.2f, %.2f)", .data$calibratedRr, .data$calibratedCi95Lb, .data$calibratedCi95Ub),
          is.na(.data$calibratedRr) & !is.na(.data$calibratedCi95Lb) ~ sprintf("(%0.2f, %0.2f)", .data$calibratedCi95Lb, .data$calibratedCi95Ub),
          TRUE ~ ""
        ),
        
        `Target\n    N` = ifelse(
          is.na(.data$covariateSubjects),
          "",
          format(.data$covariateSubjects, big.mark = ",")
        ),
        `Target\nevents` = ifelse(
          is.na(.data$covariateOutcomes),
          "",
          format(.data$covariateOutcomes, big.mark = ",")
        ),
        `Outcome\nSubjects` = ifelse(
          is.na(.data$outcomeSubjects),
          "",
          format(.data$outcomeSubjects, big.mark = ",")
        ),
        `Outcome\nEvents` = ifelse(
          is.na(.data$outcomeEvents),
          "",
          format(.data$outcomeEvents, big.mark = ",")
        ),
        
        `MDRR` = dplyr::case_when(
          is.na(.data$MDRR) ~ "", 
          .data$MDRR == 'PASS' ~ "\u2714",
          .data$MDRR == 'FAIL' ~ "\u2718",
          .data$MDRR == 'NOT EVALUATED' ~ "?"
        ), 
        `EASE` = dplyr::case_when(
          is.na(.data$EASE) ~ "", 
          .data$EASE == 'PASS' ~ "\u2714",
          .data$EASE == 'FAIL' ~ "\u2718",
          .data$EASE == 'NOT EVALUATED' ~ "?"
        ),
        `TIME` = dplyr::case_when(
          is.na(.data$TIME) ~ "", 
          .data$TIME == 'PASS' ~ "\u2714",
          .data$TIME == 'FAIL' ~ "\u2718",
          .data$TIME == 'NOT EVALUATED' ~ "?"
        ),
        `EXPO\nSURE` = dplyr::case_when(
          is.na(.data$EXPOSURE) ~ "", 
          .data$EXPOSURE == 'PASS' ~ "\u2714",
          .data$EXPOSURE == 'FAIL' ~ "\u2718",
          .data$EXPOSURE == 'NOT EVALUATED' ~ "?"
        ),
        `OBS` = dplyr::case_when(
          is.na(.data$OBS) ~ "", 
          .data$OBS == 'PASS' ~ "\u2714",
          .data$OBS == 'FAIL' ~ "\u2718",
          .data$OBS == 'NOT EVALUATED' ~ "?"
        ),
        `RARE` = dplyr::case_when(
          is.na(.data$RARE) ~ "", 
          .data$RARE == 'PASS' ~ "\u2714",
          .data$RARE == 'FAIL' ~ "\u2718",
          .data$RARE == 'NOT EVALUATED' ~ "?"
        )
      ) %>%
      dplyr::select(-"EXPOSURE")
    
    isPi <- grepl("Prediction Interval", plotTable$Study, fixed = TRUE)
    isMeta <- grepl("Bayesian", plotTable$Study, fixed = TRUE)
    isSummaryPlot <- isMeta & !isPi
    
    
    # For rows with PI only (no point estimate), use geometric midpoint for plotting
    estForPlot <- ifelse(
      is.na(plotTable$calibratedRr) &
        !is.na(plotTable$calibratedCi95Lb) &
        !is.na(plotTable$calibratedCi95Ub),
      sqrt(plotTable$calibratedCi95Lb * plotTable$calibratedCi95Ub),
      plotTable$calibratedRr
    )
    
    # Keep log-scale limits data-driven but stable
    finiteBounds <- c(plotTable$calibratedCi95Lb, plotTable$calibratedCi95Ub)
    finiteBounds <- finiteBounds[is.finite(finiteBounds) & finiteBounds > 0]
    xMin <- max(min(finiteBounds, na.rm = TRUE) * 0.8, 0.1)
    xMax <- max(finiteBounds, na.rm = TRUE) * 1.2
    
    tm <- forestploter::forest_theme(
      base_size = 10,
      refline_col = "#555555",
      ci_col = "#1F78B4",
      summary_col = "#D95F02",
      footnote_col = "#555555"
    )
    
    sizes <- ifelse(isPi, 0.001, 0.4)
    
    if(!is.null(sccsDiagnostics)){
      plotDiagCols <- c('MDRR',"EASE", "TIME", "EXPO\nSURE","OBS", "RARE")
    } else{
      plotDiagCols <- c()
    }
    
    if(includeCounts){
      countCols <- c("Target\n    N", "Target\nevents", "Outcome\nSubjects", "Outcome\nEvents")
    } else{
      countCols <- c()
    }
    
    columsToInclude <- c("Study", " ", "HR (95% CI)", countCols, plotDiagCols)
    
    p <- forestploter::forest(
      plotTable[, columsToInclude],
      est = estForPlot,
      lower = as.numeric(plotTable$calibratedCi95Lb),
      upper = as.numeric(plotTable$calibratedCi95Ub),
      sizes = sizes,
      ci_column = 2,
      is_summary = isSummaryPlot,
      ref_line = 1,
      x_trans = "log",
      xlim = c(0.1, 10),
      vert_line = c(0.25, 0.5, 2 , 4),
      vert_line_lty = "dashed",
      vert_line_col = "grey50", 
      ticks_at = c(0.1, 0.5, 1, 2, 10),
      arrow_lab = c("Favours target", "Favours comparator"),
      theme = tm, 
      footnote = "* database used in Baysian analysis"
    )
    
    
    # Shade from each meta-analysis row through its prediction-interval row
    metaRows <- which(grepl("Bayesian", plotTable$Study, fixed = TRUE))
    piRows <- which(grepl("Prediction Interval", plotTable$Study, fixed = TRUE))
    
    # Light blue transparent fill
    shadeFill <- grDevices::adjustcolor("#ADD8E6", alpha.f = 0.5)
    
    for (i in seq_len(min(length(metaRows), length(piRows)))) {
      blockRows <- metaRows[i]:piRows[i]
      p <- forestploter::edit_plot(
        p,
        row = blockRows,
        col = 1:(3+length(countCols)+length(plotDiagCols)),                  # all displayed table/CI columns
        part = "body",
        which = "background",
        gp = grid::gpar(fill = shadeFill, col = NA)
      )
    }
    
    # add bold text for summary
    p <- forestploter::edit_plot(
      p,
      row = which(isMeta | isPi),
      col = 1:(3+length(countCols)),        # adjust upper bound to match your total text column count
      part = "body",
      which = "text",
      gp = grid::gpar(fontface = "bold")
    ) 
    
    # edit the diagnostics columns to make headings small and enable ticks/crosses
    if(length(plotDiagCols) > 0){
      p <- p %>%
        forestploter::edit_plot(
          col = (1+3+length(countCols)):(3+length(countCols)+length(plotDiagCols)),
          part = "header",
          which = "text",
          gp = grid::gpar(fontsize = 5)
        ) %>%
        forestploter::edit_plot(
          col = (1+3+length(countCols)):(3+length(countCols)+length(plotDiagCols)),
          part = "body",
          which = "text",
          gp = grid::gpar(fontfamily = "Arial Unicode MS")
        )
    }
    
    # changing color for tick/cross
    for(diagnostic in c('MDRR',"EASE", "TIME", "EXPO\nSURE","OBS", "RARE")){
      
      if(diagnostic %in% columsToInclude){
        colInd <- which(columsToInclude %in% diagnostic)
        passRows <- which(plotTable[diagnostic] == "\u2714")
        failRows <- which(plotTable[diagnostic] == "\u2718")
        
        if (length(passRows) > 0) {
          p <- forestploter::edit_plot(
            p,
            row = passRows,
            col = colInd,
            part = "body",
            which = "text",
            gp = grid::gpar(col = "#2E8B57", fontface = "bold")  # green
          )
        }
        
        if (length(failRows) > 0) {
          p <- forestploter::edit_plot(
            p,
            row = failRows,
            col = colInd,
            part = "body",
            which = "text",
            gp = grid::gpar(col = "#CC0000", fontface = "bold")  # red
          )
        }
      }
      
    }
    
    plotList[[ind]] <- p
  }
  
  return(plotList)
}






