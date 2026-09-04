test_that("getSccAnalysisSettings", {
  result <- OhdsiReportGenerator::getSccAnalysisSettings(
    connectionHandler = connectionHandler,
    schema = schema
  )
  expect_true(nrow(result) > 0)
  expect_true(all(c("analysisId", "description") %in% colnames(result)))
})

test_that("getSccTargets", {
  result <- OhdsiReportGenerator::getSccTargets(
    connectionHandler = connectionHandler,
    schema = schema
  )
  expect_true(9 %in% result$cohortDefinitionId)
  expect_true(all(c("cohortDefinitionId", "cohortName") %in% colnames(result)))
})

test_that("getSccOutcomes restricted to a target", {
  result <- OhdsiReportGenerator::getSccOutcomes(
    connectionHandler = connectionHandler,
    schema = schema,
    targetIds = 9
  )
  expect_true(11 %in% result$cohortDefinitionId)
})

test_that("getSccEstimation returns per database results", {
  result <- OhdsiReportGenerator::getSccEstimation(
    connectionHandler = connectionHandler,
    schema = schema,
    targetIds = 9,
    outcomeIds = 11
  )
  expect_equal(nrow(result), 3)
  expect_true(all(c(
    "databaseName", "targetName", "outcomeName", "rr", "calibratedRr",
    "calibratedLb95", "calibratedUb95", "calibratedPValue"
  ) %in% colnames(result)))
  expect_true(all(result$rr < 1))
})

test_that("getSccMetaEstimation returns evidence synthesis results", {
  result <- OhdsiReportGenerator::getSccMetaEstimation(
    connectionHandler = connectionHandler,
    schema = schema
  )
  expect_true(nrow(result) > 0)
  expect_true(all(c(
    "databaseName", "nDatabases", "i2", "tau", "ease", "unblind"
  ) %in% colnames(result)))
  expect_true(all(result$nDatabases == 3))
})

test_that("getSccSignals returns the discovery grid", {
  result <- OhdsiReportGenerator::getSccSignals(
    connectionHandler = connectionHandler,
    schema = schema
  )
  expect_true(nrow(result) > 0)
  expect_true(all(c(
    "targetId", "outcomeId", "targetName", "outcomeName",
    "benefitCount", "riskCount", "metaRr", "metaP"
  ) %in% colnames(result)))
})

test_that("getSccSignals can filter on the meta analysis", {
  result <- OhdsiReportGenerator::getSccSignals(
    connectionHandler = connectionHandler,
    schema = schema,
    filterByMeta = TRUE,
    benefit = 0.5
  )
  expect_true(nrow(result) > 0)
  expect_true(all(result$metaRr <= 0.5))
})

test_that("getSccDiagnosticsData pivots the diagnostics", {
  result <- OhdsiReportGenerator::getSccDiagnosticsData(
    connectionHandler = connectionHandler,
    schema = schema,
    targetIds = 9
  )
  expect_true(nrow(result) > 0)
  expect_true(all(c("mdrr", "ease", "summaryValue") %in% colnames(result)))
})

test_that("getSccSummaryStats returns boxplot statistics", {
  result <- OhdsiReportGenerator::getSccSummaryStats(
    connectionHandler = connectionHandler,
    schema = schema,
    statTypes = "time_exposed",
    targetIds = 9,
    outcomeIds = 11
  )
  expect_equal(nrow(result), 3)
  expect_true(all(c("statType", "median", "p25", "p75") %in% colnames(result)))
})

test_that("getSccNegativeControlEstimates returns controls", {
  result <- OhdsiReportGenerator::getSccNegativeControlEstimates(
    connectionHandler = connectionHandler,
    schema = schema,
    targetIds = 9
  )
  expect_true(nrow(result) > 0)
  expect_true(all(c("trueEffectSize", "rr", "seLogRr") %in% colnames(result)))
})

test_that("plot functions return ggplot objects", {
  estimation <- OhdsiReportGenerator::getSccEstimation(
    connectionHandler = connectionHandler,
    schema = schema,
    targetIds = 9,
    outcomeIds = 11
  )
  meta <- OhdsiReportGenerator::getSccMetaEstimation(
    connectionHandler = connectionHandler,
    schema = schema,
    targetIds = 9,
    outcomeIds = 11
  )
  estimation$meta <- 0
  meta$meta <- 1
  combined <- dplyr::bind_rows(estimation, meta)

  expect_s3_class(
    OhdsiReportGenerator::plotSccForest(combined, calibrated = TRUE),
    "ggplot"
  )

  stats <- OhdsiReportGenerator::getSccSummaryStats(
    connectionHandler = connectionHandler,
    schema = schema,
    statTypes = "time_exposed",
    targetIds = 9,
    outcomeIds = 11
  )
  expect_s3_class(
    OhdsiReportGenerator::plotSccBoxPlot(stats),
    "ggplot"
  )

  controls <- OhdsiReportGenerator::getSccNegativeControlEstimates(
    connectionHandler = connectionHandler,
    schema = schema,
    targetIds = 9
  )
  expect_s3_class(
    OhdsiReportGenerator::plotSccSystematicError(controls),
    "ggplot"
  )
})

test_that("createSccSignalsTable returns a gt table", {
  signals <- OhdsiReportGenerator::getSccSignals(
    connectionHandler = connectionHandler,
    schema = schema
  )
  expect_s3_class(
    OhdsiReportGenerator::createSccSignalsTable(signals),
    "gt_tbl"
  )
})

test_that("the full report template includes the self controlled cohort section", {
  templateFile <- system.file(
    "templates", "full-report", "self_controlled_cohort.qmd",
    package = "OhdsiReportGenerator"
  )
  expect_true(file.exists(templateFile))
  templateText <- readLines(templateFile)
  expect_true(any(grepl("includeScc", templateText)))
})
