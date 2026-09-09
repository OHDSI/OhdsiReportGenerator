# @file SccPlots.R
#
# Copyright 2026 Observational Health Data Sciences and Informatics
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

#' Plot the self controlled cohort forest plot
#'
#' @description
#' Create a forest plot of the self controlled cohort incidence rate ratio
#' estimates across databases (and optionally the meta analysis row)
#'
#' @details
#' The input data should contain the per database estimates returned by
#' \code{\link{getSccEstimation}} with the meta analytic estimate appended as
#' an additional row returned by \code{\link{getSccMetaEstimation}}.  A column
#' called \code{meta} (0 for the database rows and 1 for the meta analysis
#' rows) is used to style the meta analysis row
#'
#' @param data A data.frame with the columns databaseName, description,
#'   rr, lb95, ub95, calibratedRr, calibratedLb95, calibratedUb95 and
#'   optionally meta
#' @param calibrated Whether to use the calibrated estimates (defaults to
#'   TRUE).  When TRUE the uncalibrated estimates are never used as a fallback
#'   and rows without a calibrated estimate are omitted
#' @return A ggplot object
#' @family SelfControlledCohort
#' @export
plotSccForest <- function(
    data,
    calibrated = TRUE
) {
  if (is.null(data) || nrow(data) == 0) {
    return(NULL)
  }

  if (!"meta" %in% colnames(data)) {
    data$meta <- 0
  }

  if (calibrated) {
    data <- data |>
      dplyr::mutate(
        value = .data$calibratedRr,
        lb = .data$calibratedLb95,
        ub = .data$calibratedUb95
      )
  } else {
    data <- data |>
      dplyr::mutate(
        value = .data$rr,
        lb = .data$lb95,
        ub = .data$ub95
      )
  }

  plotData <- data |>
    dplyr::mutate(
      label = ifelse(.data$meta == 1, paste0(.data$databaseName, " (meta)"), .data$databaseName)
    ) |>
    dplyr::filter(!is.na(.data$value) & !is.na(.data$lb) & !is.na(.data$ub)) |>
    dplyr::arrange(dplyr::desc(.data$value))

  if (nrow(plotData) == 0) {
    return(NULL)
  }

  # the same exposure-outcome pair may be analysed under multiple study
  # parameter settings (e.g. different time at risk windows).  Determine the
  # facet label for each distinct setting - if the analysis description is
  # reused for different analysis ids then disambiguate using the analysis id
  facetSetting <- NULL
  if ("description" %in% colnames(plotData)) {
    facetSetting <- plotData$description
    if ("analysisId" %in% colnames(plotData)) {
      key <- paste0(plotData$description, "|", plotData$analysisId)
      if (dplyr::n_distinct(key) > dplyr::n_distinct(facetSetting)) {
        facetSetting <- paste0(
          plotData$description,
          ifelse(is.na(plotData$analysisId), "",
                 paste0(" (analysis ", plotData$analysisId, ")"))
        )
      }
    }
  }
  plotData$facetSetting <- if (is.null(facetSetting)) "Results" else facetSetting

  # collapse any duplicated rows for the same setting / database
  plotData <- plotData |>
    dplyr::distinct(.data$facetSetting, .data$databaseName, .data$meta, .keep_all = TRUE)

  # limits for the log axis
  allValues <- c(plotData$lb, plotData$value, plotData$ub)
  low <- min(allValues, na.rm = TRUE)
  high <- max(allValues, na.rm = TRUE)
  xlimLow <- exp(floor(log(low)))
  xlimHigh <- exp(ceiling(log(high)))

  subtitle <- paste0(unique(plotData$targetName)[1], " - ",
                     unique(plotData$outcomeName)[1])

  breaks <- c(0.1, 0.25, 0.5, 1, 2, 4, 6, 8, 10)

  plot <- ggplot2::ggplot(
    data = plotData,
    ggplot2::aes(
      x = .data$label,
      y = .data$value,
      ymin = .data$lb,
      ymax = .data$ub
    )
  ) +
    ggplot2::geom_hline(yintercept = 1, colour = "#000000", lty = 1, linewidth = 0.5) +
    ggplot2::geom_errorbar(width = 0.25, linewidth = 0.5, colour = "#000000") +
    ggplot2::geom_point(
      size = 2.5,
      ggplot2::aes(shape = as.factor(.data$meta), fill = as.factor(.data$meta))
    ) +
    ggplot2::scale_shape_manual(values = c(21, 23), guide = "none") +
    ggplot2::scale_fill_manual(values = c("#0000CC", "#CC0000"), guide = "none") +
    ggplot2::scale_y_log10(
      "Incidence rate ratio",
      limits = c(xlimLow, xlimHigh),
      breaks = breaks,
      labels = breaks
    ) +
    ggplot2::ggtitle("Self controlled cohort results", subtitle = subtitle) +
    ggplot2::coord_flip() +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"),
      plot.subtitle = ggplot2::element_text(hjust = 0.5)
    )

  # give each distinct study parameter setting its own panel
  if (dplyr::n_distinct(plotData$facetSetting) > 1) {
    plot <- plot +
      ggplot2::facet_wrap(~ .data$facetSetting, scales = "free_y")
  }

  return(plot)
}

#' Plot the self controlled cohort summary statistics as boxplots
#'
#' @description
#' Create boxplots of the summary statistics (e.g. time at risk, time to
#' outcome) returned by \code{\link{getSccSummaryStats}}
#'
#' @param data A data.frame with the columns databaseName, minimum, p25,
#'   median, p75, maximum (and optionally mean, sd, p10, p90)
#' @param xLabel The label for the x axis
#' @param yLabel The label for the y axis
#' @return A ggplot object
#' @family SelfControlledCohort
#' @export
plotSccBoxPlot <- function(
    data,
    xLabel = "Data source",
    yLabel = "Days"
) {
  if (is.null(data) || nrow(data) == 0) {
    return(NULL)
  }

  if (!"mean" %in% colnames(data)) {
    data$mean <- NA
  }
  if (!"sd" %in% colnames(data)) {
    data$sd <- NA
  }

  # a database may contribute more than one summary row (e.g. one per study
  # parameter setting / analysis).  ggplot can only draw one boxplot per group
  # so collapse to a single row per database (within each analysis description
  # when present) before drawing
  if ("description" %in% colnames(data)) {
    data <- data |>
      dplyr::distinct(.data$description, .data$databaseName, .keep_all = TRUE)
  } else {
    data <- data |>
      dplyr::distinct(.data$databaseName, .keep_all = TRUE)
  }

  plot <- ggplot2::ggplot(data = data) +
    ggplot2::aes(
      x = .data$databaseName,
      ymin = .data$minimum,
      lower = .data$p25,
      middle = .data$median,
      upper = .data$p75,
      ymax = .data$maximum,
      average = .data$mean,
      sd = .data$sd,
      group = .data$databaseName,
      y = .data$median
    ) +
    ggplot2::geom_errorbar(linewidth = 0.5) +
    ggplot2::geom_boxplot(
      stat = "identity",
      fill = grDevices::rgb(0, 0, 0.8, alpha = 0.25),
      linewidth = 0.2
    ) +
    ggplot2::xlab(xLabel) +
    ggplot2::ylab(yLabel) +
    ggplot2::theme_bw() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

  # when a database appears more than once (e.g. it has results for multiple
  # analyses) a boxplot can only draw one box per group so we facet by the
  # analysis description to give each analysis its own panel
  if ("description" %in% colnames(data)) {
    nPerDatabase <- table(data$databaseName)
    if (any(nPerDatabase > 1)) {
      plot <- plot +
        ggplot2::facet_wrap(~ .data$description, scales = "free_x")
    }
  }

  return(plot)
}

#' Create a self controlled cohort signal discovery table
#'
#' @description
#' Create a formatted gt table of the signal discovery grid returned by
#' \code{\link{getSccSignals}}
#'
#' @param data A data.frame returned by \code{\link{getSccSignals}}
#' @return A gt table
#' @family SelfControlledCohort
#' @export
createSccSignalsTable <- function(data) {
  if (is.null(data) || nrow(data) == 0) {
    return(NULL)
  }

  tableData <- data |>
    dplyr::mutate(
      targetName = .data$targetName,
      outcomeName = .data$outcomeName,
      benefitCount = .data$benefitCount,
      riskCount = .data$riskCount,
      metaRr = ifelse(is.na(.data$metaRr), "", sprintf("%.2f", .data$metaRr)),
      metaP = ifelse(is.na(.data$metaP), "", sprintf("%.3f", .data$metaP)),
      i2 = ifelse(is.na(.data$i2), "", sprintf("%.2f", .data$i2)),
      nDatabases = .data$nDatabases
    ) |>
    dplyr::select(
      "targetName", "outcomeName", "benefitCount", "riskCount",
      "metaRr", "metaP", "i2", "nDatabases"
    )

  table <- tableData |>
    gt::gt() |>
    gt::cols_label(
      targetName = "Exposure",
      outcomeName = "Outcome",
      benefitCount = "Databases showing benefit",
      riskCount = "Databases showing risk",
      metaRr = "Meta RR",
      metaP = "Meta p",
      i2 = "I2",
      nDatabases = "Databases in meta"
    ) |>
    gt::fmt_number(columns = c("benefitCount", "riskCount", "nDatabases"), decimals = 0)

  return(table)
}

#' Plot the self controlled cohort systematic error
#'
#' @description
#' Create a systematic error plot of the negative control estimates returned
#' by \code{\link{getSccNegativeControlEstimates}}.  Each negative control
#' estimate is plotted by its log incidence rate ratio against its standard
#' error (with and without empirical calibration).  The dashed lines indicate
#' where the estimates should lie if the null is correctly calibrated
#'
#' @param data A data.frame with the columns trueEffectSize, rr, seLogRr,
#'   lb95, ub95 and the optional columns calibratedRr, calibratedSeLogRr,
#'   calibratedLb95, calibratedUb95
#' @param ease An optional ease value to add to the title
#' @return A ggplot object
#' @family SelfControlledCohort
#' @export
plotSccSystematicError <- function(
    data,
    ease = NULL
) {
  if (is.null(data) || nrow(data) == 0) {
    return(NULL)
  }

  data <- data |>
    dplyr::mutate(
      se = ifelse(
        is.na(.data$seLogRr),
        (log(.data$ub95) - log(.data$lb95)) / (2 * stats::qnorm(0.975)),
        .data$seLogRr
      )
    )

  plotData <- rbind(
    data.frame(
      yGroup = "Uncalibrated",
      logRr = log(data$rr),
      seLogRr = data$se,
      ci95Lb = log(data$lb95),
      ci95Ub = log(data$ub95),
      trueRr = data$trueEffectSize
    ),
    data.frame(
      yGroup = "Calibrated",
      logRr = ifelse(is.na(data$calibratedRr), NA, log(data$calibratedRr)),
      seLogRr = ifelse(
        is.na(data$calibratedSeLogRr),
        (log(data$calibratedUb95) - log(data$calibratedLb95)) / (2 * stats::qnorm(0.975)),
        data$calibratedSeLogRr
      ),
      ci95Lb = ifelse(is.na(data$calibratedRr), NA, log(data$calibratedLb95)),
      ci95Ub = ifelse(is.na(data$calibratedRr), NA, log(data$calibratedUb95)),
      trueRr = data$trueEffectSize
    )
  )

  plotData <- plotData[!is.na(plotData$logRr) & !is.na(plotData$ci95Lb) &
                         !is.na(plotData$ci95Ub), , drop = FALSE]

  if (nrow(plotData) == 0) {
    return(NULL)
  }

  plotData$Group <- as.factor(plotData$trueRr)
  plotData$Significant <- plotData$ci95Lb > log(plotData$trueRr) |
    plotData$ci95Ub < log(plotData$trueRr)

  temp1 <- stats::aggregate(Significant ~ Group + yGroup, data = plotData, length)
  temp2 <- stats::aggregate(Significant ~ Group + yGroup, data = plotData, mean)
  temp1$nLabel <- paste0(formatC(temp1$Significant, big.mark = ","), " estimates")
  temp1$Significant <- NULL
  temp2$meanLabel <- paste0(
    formatC(100 * (1 - temp2$Significant), digits = 1, format = "f"),
    "% of CIs include ",
    temp2$Group
  )
  temp2$Significant <- NULL
  dd <- merge(temp1, temp2)
  dd$tes <- as.numeric(as.character(dd$Group))

  titleText <- ifelse(is.null(ease), "Systematic error", paste0("Ease: ", ease))

  plotData$Group <- paste("True relative risk =", plotData$Group)
  dd$Group <- paste("True relative risk =", dd$Group)

  breaks <- c(0.1, 0.25, 0.5, 1, 2, 4, 6, 8, 10)
  theme <- ggplot2::element_text(colour = "#000000", size = 14)
  themeRA <- ggplot2::element_text(colour = "#000000", size = 14, hjust = 1)

  plot <- ggplot2::ggplot(plotData, ggplot2::aes(x = .data$logRr, y = .data$seLogRr)) +
    ggplot2::geom_vline(xintercept = log(breaks), colour = "#AAAAAA", lty = 1, linewidth = 0.5) +
    ggplot2::geom_abline(
      ggplot2::aes(
        intercept = (-log(.data$tes)) / stats::qnorm(0.025),
        slope = 1 / stats::qnorm(0.025)
      ),
      colour = grDevices::rgb(0.8, 0, 0),
      linetype = "dashed",
      linewidth = 1,
      alpha = 0.5,
      data = dd
    ) +
    ggplot2::geom_abline(
      ggplot2::aes(
        intercept = (-log(.data$tes)) / stats::qnorm(0.975),
        slope = 1 / stats::qnorm(0.975)
      ),
      colour = grDevices::rgb(0.8, 0, 0),
      linetype = "dashed",
      linewidth = 1,
      alpha = 0.5,
      data = dd
    ) +
    ggplot2::geom_point(size = 2, shape = 16, colour = grDevices::rgb(0, 0, 0, alpha = 0.5)) +
    ggplot2::geom_hline(yintercept = 0) +
    ggplot2::geom_label(
      x = log(0.15), y = 0.9, alpha = 1, hjust = "left",
      ggplot2::aes(label = .data$nLabel), size = 4, data = dd
    ) +
    ggplot2::geom_label(
      x = log(0.15), y = 0.6, alpha = 1, hjust = "left",
      ggplot2::aes(label = .data$meanLabel), size = 4, data = dd
    ) +
    ggplot2::scale_x_continuous(
      "Relative risk",
      limits = log(c(0.1, 10)),
      breaks = log(breaks),
      labels = breaks
    ) +
    ggplot2::scale_y_continuous("Standard Error", limits = c(0, 1)) +
    ggplot2::facet_grid(yGroup ~ Group) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.text.y = themeRA,
      axis.text.x = theme,
      axis.title = theme,
      strip.text = theme,
      strip.background = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5)
    ) +
    ggplot2::ggtitle(label = titleText)

  return(plot)
}
