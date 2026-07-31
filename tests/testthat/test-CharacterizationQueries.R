pickCasePair <- function() {
  counts <- getCaseCounts(
    connectionHandler = connectionHandler,
    schema = schema
  )

  if (nrow(counts) == 0) {
    return(NULL)
  }

  list(
    characterizationTargetId = counts$targetId[1],
    outcomeId = counts$outcomeId[1]
  )
}

pickCharacterizationTarget <- function() {
  targets <- getTargetCounts(
    connectionHandler = connectionHandler,
    schema = schema
  )

  if (nrow(targets) == 0) {
    return(NULL)
  }

  targets$characterizationTargetId[1]
}

getCharacterizationVersion <- function() {
  OhdsiReportGenerator:::.getCVersion(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = "c_"
  )
}

test_that("getCharacterizationTargetSettings", {
  targetSettings <- getCharacterizationTargetSettings(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true(nrow(targetSettings) > 0)
  testthat::expect_true("characterizationTargetId" %in% colnames(targetSettings))

  characterizationTargetId <- unique(targetSettings$characterizationTargetId)[1]
  restricted <- getCharacterizationTargetSettings(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetIds = characterizationTargetId
  )

  testthat::expect_true(nrow(restricted) <= nrow(targetSettings))
  if (nrow(restricted) > 0) {
    testthat::expect_true(all(restricted$characterizationTargetId == characterizationTargetId))
  }

  withDbDetails <- getCharacterizationTargetSettings(
    connectionHandler = connectionHandler,
    schema = schema,
    addDatabaseDetails = TRUE
  ) %>% suppressWarnings()

  testthat::expect_true("databaseString" %in% colnames(withDbDetails))
  testthat::expect_true("databaseIdString" %in% colnames(withDbDetails))
})

test_that("getIncidenceTargetSettings", {
  incidenceSettings <- getIncidenceTargetSettings(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true(nrow(incidenceSettings) > 0)

  targetCol <- if ("targetId" %in% colnames(incidenceSettings)) {
    "targetId"
  } else if ("cohortDefinitionId" %in% colnames(incidenceSettings)) {
    "cohortDefinitionId"
  } else {
    NA_character_
  }

  testthat::expect_false(is.na(targetCol))

  restricted <- getIncidenceTargetSettings(
    connectionHandler = connectionHandler,
    schema = schema,
    targetIds = incidenceSettings[[targetCol]][1]
  )

  testthat::expect_true(nrow(restricted) <= nrow(incidenceSettings))
  if (nrow(restricted) > 0 && targetCol %in% colnames(restricted)) {
    testthat::expect_true(all(restricted[[targetCol]] == incidenceSettings[[targetCol]][1]))
  }
})

test_that("getCharacterizationCaseSettings", {
  testthat::skip_if(
    getCharacterizationVersion() != "4_0_0",
    "Case settings are only available for characterization version 4_0_0"
  )

  caseSettings <- getCharacterizationCaseSettings(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true(nrow(caseSettings) > 0)
  testthat::expect_true("characterizationTargetId" %in% colnames(caseSettings))
  testthat::expect_true("outcomeId" %in% colnames(caseSettings))
})

test_that("getTargetsUsedInCharacterization", {
  targets <- getTargetsUsedInCharacterization(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true(nrow(targets) > 0)
  testthat::expect_true("cohortName" %in% colnames(targets))
  testthat::expect_true("cohortDefinitionId" %in% colnames(targets))
  testthat::expect_true("timeToEvent" %in% colnames(targets))
  testthat::expect_true("dechalRechal" %in% colnames(targets))
  testthat::expect_true("riskFactors" %in% colnames(targets))
})

test_that("getTargetsUsedInIncidence", {
  targets <- getTargetsUsedInIncidence(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true(nrow(targets) > 0)
  testthat::expect_true("cohortName" %in% colnames(targets))
  testthat::expect_true("cohortDefinitionId" %in% colnames(targets))
})

test_that("getDechallengeRechallengeFails input validation", {
  testthat::expect_error(
    getDechallengeRechallengeFails(
      connectionHandler = connectionHandler,
      schema = schema,
      characterizationTargetId = c(1, 2),
      outcomeId = 1,
      databaseId = "x"
    ),
    "Must specify one characterizationTargetId"
  )

  testthat::expect_error(
    getDechallengeRechallengeFails(
      connectionHandler = connectionHandler,
      schema = schema,
      characterizationTargetId = 1,
      outcomeId = c(1, 2),
      databaseId = "x"
    ),
    "Must specify exactly one outcomeId"
  )

  testthat::expect_error(
    getDechallengeRechallengeFails(
      connectionHandler = connectionHandler,
      schema = schema,
      characterizationTargetId = 1,
      outcomeId = 1,
      databaseId = c("x", "y")
    ),
    "Must specify exactly one databaseId"
  )
})

test_that("getDechallengeRechallengeFails extraction", {
  dcrc <- getDechallengeRechallenge(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::skip_if(nrow(dcrc) == 0, "No dechallenge-rechallenge rows in example data")

  fails <- getDechallengeRechallengeFails(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetId = dcrc$targetId[1],
    outcomeId = dcrc$outcomeId[1],
    databaseId = dcrc$databaseId[1]
  )

  testthat::expect_true(is.data.frame(fails))
  testthat::expect_true(ncol(fails) > 0)

  if (nrow(fails) > 0) {
    if ("characterizationTargetId" %in% colnames(fails)) {
      testthat::expect_true(all(fails$characterizationTargetId == dcrc$targetId[1]))
    }
    if ("targetId" %in% colnames(fails)) {
      testthat::expect_true(all(fails$targetId == dcrc$targetId[1]))
    }
    if ("outcomeId" %in% colnames(fails)) {
      testthat::expect_true(all(fails$outcomeId == dcrc$outcomeId[1]))
    }
    if ("databaseId" %in% colnames(fails)) {
      testthat::expect_true(all(fails$databaseId == dcrc$databaseId[1]))
    }
  }
})

test_that("getContinuousTargetBaseline", {
  ctb <- getContinuousTargetBaseline(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true("covariateName" %in% colnames(ctb))
  testthat::expect_true("covariateId" %in% colnames(ctb))
  testthat::expect_true("countValue" %in% colnames(ctb))
  testthat::expect_true("averageValue" %in% colnames(ctb))

  targetId <- pickCharacterizationTarget()
  testthat::skip_if(is.null(targetId), "No characterization target in example data")

  ctb2 <- getContinuousTargetBaseline(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetIds = targetId
  )

  testthat::expect_true(nrow(ctb2) <= nrow(ctb))
  if (nrow(ctb2) > 0 && "characterizationTargetId" %in% colnames(ctb2)) {
    testthat::expect_true(all(ctb2$characterizationTargetId == targetId))
  }
})

test_that("getTargetCounts", {
  counts <- getTargetCounts(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true(nrow(counts) > 0)
  testthat::expect_true("settingId" %in% colnames(counts))
  testthat::expect_true("databaseId" %in% colnames(counts))
  testthat::expect_true("characterizationTargetId" %in% colnames(counts))
  testthat::expect_true("n" %in% colnames(counts))

  restricted <- getTargetCounts(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetIds = counts$characterizationTargetId[1]
  )

  testthat::expect_true(nrow(restricted) <= nrow(counts))
  if (nrow(restricted) > 0) {
    testthat::expect_true(all(restricted$characterizationTargetId == counts$characterizationTargetId[1]))
  }
})

test_that("incidence rates", {
  incidence <- getIncidenceRates(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true(nrow(incidence) > 0)
  testthat::expect_true("incidenceProportionP100p" %in% colnames(incidence))
  testthat::expect_true("incidenceRateP100py" %in% colnames(incidence))
  testthat::expect_true("personsAtRisk" %in% colnames(incidence))
  testthat::expect_true("personDays" %in% colnames(incidence))
  testthat::expect_true("databaseName" %in% colnames(incidence))
  testthat::expect_true("targetName" %in% colnames(incidence))
  testthat::expect_true("outcomeName" %in% colnames(incidence))
})

test_that("getTimeToEvent", {
  tte <- getTimeToEvent(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true("databaseName" %in% colnames(tte))
  testthat::expect_true("targetName" %in% colnames(tte))
  testthat::expect_true("outcomeName" %in% colnames(tte))
  testthat::expect_true("outcomeType" %in% colnames(tte))
  testthat::expect_true("targetOutcomeType" %in% colnames(tte))
  testthat::expect_true("timeToEvent" %in% colnames(tte))
  testthat::expect_true("numEvents" %in% colnames(tte))
  testthat::expect_true("timeScale" %in% colnames(tte))

  ids <- pickCasePair()
  testthat::skip_if(is.null(ids), "No case target/outcome pair in example data")

  tte2 <- getTimeToEvent(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetIds = ids$characterizationTargetId,
    outcomeIds = ids$outcomeId
  )

  testthat::expect_true(nrow(tte2) <= nrow(tte))
  if (nrow(tte2) > 0) {
    if ("targetId" %in% colnames(tte2)) {
      testthat::expect_true(all(tte2$targetId == ids$characterizationTargetId))
    }
    if ("outcomeId" %in% colnames(tte2)) {
      testthat::expect_true(all(tte2$outcomeId == ids$outcomeId))
    }
  }
})

test_that("getDechallengeRechallenge", {
  result <- getDechallengeRechallenge(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true("databaseName" %in% colnames(result))
  testthat::expect_true("targetName" %in% colnames(result))
  testthat::expect_true("outcomeName" %in% colnames(result))
  testthat::expect_true("dechallengeStopInterval" %in% colnames(result))
  testthat::expect_true("dechallengeEvaluationWindow" %in% colnames(result))
  testthat::expect_true("numExposureEras" %in% colnames(result))
  testthat::expect_true("numCases" %in% colnames(result))
  testthat::expect_true("pctDechallengeSuccess" %in% colnames(result))
  testthat::expect_true("pctRechallengeFail" %in% colnames(result))

  ids <- pickCasePair()
  testthat::skip_if(is.null(ids), "No case target/outcome pair in example data")

  result2 <- getDechallengeRechallenge(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetIds = ids$characterizationTargetId,
    outcomeIds = ids$outcomeId
  )

  testthat::expect_true(nrow(result2) <= nrow(result))
  if (nrow(result2) > 0) {
    if ("targetId" %in% colnames(result2)) {
      testthat::expect_true(all(result2$targetId == ids$characterizationTargetId))
    }
    if ("outcomeId" %in% colnames(result2)) {
      testthat::expect_true(all(result2$outcomeId == ids$outcomeId))
    }
  }
})

test_that("getBinaryTargetBaseline", {
  res <- getBinaryTargetBaseline(
    connectionHandler = connectionHandler,
    schema = schema,
    cTablePrefix = "c_",
    cgTablePrefix = "cg_",
    databaseTable = "database_meta_data"
  )

  testthat::expect_true("covariateName" %in% colnames(res))
  testthat::expect_true("covariateId" %in% colnames(res))
  testthat::expect_true("analysisId" %in% colnames(res))

  targetId <- pickCharacterizationTarget()
  testthat::skip_if(is.null(targetId), "No characterization target in example data")

  res2 <- getBinaryTargetBaseline(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetIds = targetId
  )

  testthat::expect_true(nrow(res2) <= nrow(res))
  if (nrow(res2) > 0) {
    if ("characterizationTargetId" %in% colnames(res2)) {
      testthat::expect_true(all(res2$characterizationTargetId == targetId))
    }
    if ("targetId" %in% colnames(res2)) {
      testthat::expect_true(all(res2$targetId == targetId))
    }
  }

  res3 <- getBinaryTargetBaseline(
    connectionHandler = connectionHandler,
    schema = schema,
    analysisIds = 3
  )

  if (nrow(res3) > 0 && "analysisId" %in% colnames(res3)) {
    testthat::expect_true(all(unique(res3$analysisId) == 3))
  }
})

test_that("target counts", {
  counts <- getNonCaseCounts(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true("databaseName" %in% colnames(counts))
  testthat::expect_true("targetName" %in% colnames(counts))
  testthat::expect_true("outcomeName" %in% colnames(counts))
  testthat::expect_true("rowCount" %in% colnames(counts))
  testthat::expect_true("personCount" %in% colnames(counts))

  ids <- pickCasePair()
  testthat::skip_if(is.null(ids), "No case target/outcome pair in example data")

  counts2 <- getNonCaseCounts(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetIds = ids$characterizationTargetId,
    outcomeIds = ids$outcomeId
  )

  testthat::expect_true(nrow(counts2) <= nrow(counts))
  if (nrow(counts2) > 0) {
    if ("targetId" %in% colnames(counts2)) {
      testthat::expect_true(all(counts2$targetId == ids$characterizationTargetId))
    }
    if ("outcomeId" %in% colnames(counts2)) {
      testthat::expect_true(all(counts2$outcomeId == ids$outcomeId))
    }
  }
})

test_that("getCaseCounts", {
  counts <- getCaseCounts(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::expect_true(nrow(counts) > 0)
  testthat::expect_true("databaseName" %in% colnames(counts))
  testthat::expect_true("targetName" %in% colnames(counts))
  testthat::expect_true("outcomeName" %in% colnames(counts))
  testthat::expect_true("rowCount" %in% colnames(counts))
  testthat::expect_true("personCount" %in% colnames(counts))

  ids <- pickCasePair()
  testthat::skip_if(is.null(ids), "No case target/outcome pair in example data")

  counts2 <- getCaseCounts(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetIds = ids$characterizationTargetId,
    outcomeIds = ids$outcomeId
  )

  testthat::expect_true(nrow(counts2) <= nrow(counts))
  if (nrow(counts2) > 0) {
    if ("targetId" %in% colnames(counts2)) {
      testthat::expect_true(all(counts2$targetId == ids$characterizationTargetId))
    }
    if ("outcomeId" %in% colnames(counts2)) {
      testthat::expect_true(all(counts2$outcomeId == ids$outcomeId))
    }
  }
})

test_that("getCharacterizationDemographics", {
  targetId <- pickCharacterizationTarget()
  testthat::skip_if(is.null(targetId), "No characterization target in example data")

  ageData <- getCharacterizationDemographics(
    connectionHandler = connectionHandler,
    schema = schema,
    type = "age",
    characterizationTargetId = targetId
  )

  testthat::expect_true("databaseName" %in% colnames(ageData))
  testthat::expect_true("targetName" %in% colnames(ageData))
  testthat::expect_true("covariateName" %in% colnames(ageData))
  testthat::expect_true("sumValue" %in% colnames(ageData))
  testthat::expect_true("averageValue" %in% colnames(ageData))

  sexData <- getCharacterizationDemographics(
    connectionHandler = connectionHandler,
    schema = schema,
    type = "sex",
    characterizationTargetId = targetId
  )

  testthat::expect_true("databaseName" %in% colnames(sexData))
  testthat::expect_true("targetName" %in% colnames(sexData))
  testthat::expect_true("covariateName" %in% colnames(sexData))

  testthat::expect_error(
    getCharacterizationDemographics(
      connectionHandler = connectionHandler,
      schema = schema,
      type = "none"
    )
  )
})

test_that("getBinaryRiskFactors", {
  ids <- pickCasePair()
  testthat::skip_if(is.null(ids), "No case target/outcome pair in example data")

  data <- getBinaryRiskFactors(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetId = ids$characterizationTargetId,
    outcomeId = ids$outcomeId,
    analysisIds = c(1, 3, 210, 410)
  )

  testthat::expect_true("databaseName" %in% colnames(data))
  testthat::expect_true("targetName" %in% colnames(data))
  testthat::expect_true("outcomeName" %in% colnames(data))
  testthat::expect_true("covariateName" %in% colnames(data))
  testthat::expect_true("caseCount" %in% colnames(data))
  testthat::expect_true("caseAverage" %in% colnames(data))
  testthat::expect_true("nonCaseCount" %in% colnames(data))
  testthat::expect_true("nonCaseAverage" %in% colnames(data))
  testthat::expect_true("smd" %in% colnames(data))
})

test_that("getContinuousRiskFactors", {
  ids <- pickCasePair()
  testthat::skip_if(is.null(ids), "No case target/outcome pair in example data")

  data <- getContinuousRiskFactors(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetId = ids$characterizationTargetId,
    outcomeId = ids$outcomeId
  )

  testthat::expect_true("databaseName" %in% colnames(data))
  testthat::expect_true("targetName" %in% colnames(data))
  testthat::expect_true("outcomeName" %in% colnames(data))
  testthat::expect_true("covariateName" %in% colnames(data))
  testthat::expect_true("caseCountValue" %in% colnames(data))
  testthat::expect_true("caseAverageValue" %in% colnames(data))
  testthat::expect_true("targetCountValue" %in% colnames(data))
  testthat::expect_true("targetAverageValue" %in% colnames(data))
  testthat::expect_true("smd" %in% colnames(data))
})

test_that("getBinaryCaseSeries", {
  ids <- pickCasePair()
  testthat::skip_if(is.null(ids), "No case target/outcome pair in example data")

  data <- getBinaryCaseSeries(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetId = ids$characterizationTargetId,
    outcomeId = ids$outcomeId
  )

  testthat::expect_true("databaseName" %in% colnames(data))
  testthat::expect_true("targetName" %in% colnames(data))
  testthat::expect_true("outcomeName" %in% colnames(data))
  testthat::expect_true("covariateName" %in% colnames(data))
  testthat::expect_true("sumValueBefore" %in% colnames(data))
  testthat::expect_true("sumValueDuring" %in% colnames(data))
  testthat::expect_true("sumValueAfter" %in% colnames(data))
})

test_that("getContinuousCaseSeries", {
  ids <- pickCasePair()
  testthat::skip_if(is.null(ids), "No case target/outcome pair in example data")

  data <- getContinuousCaseSeries(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetId = ids$characterizationTargetId,
    outcomeId = ids$outcomeId
  )

  testthat::expect_true("databaseName" %in% colnames(data))
  testthat::expect_true("targetName" %in% colnames(data))
  testthat::expect_true("outcomeName" %in% colnames(data))
  testthat::expect_true("covariateName" %in% colnames(data))
  testthat::expect_true("countValueBefore" %in% colnames(data))
  testthat::expect_true("countValueDuring" %in% colnames(data))
  testthat::expect_true("countValueAfter" %in% colnames(data))
})

test_that("getOutcomesUsedInCharacterization", {
  outcomes <- getOutcomesUsedInCharacterization(
    connectionHandler = connectionHandler,
    schema = schema,
    targetId = NULL
  )

  testthat::expect_true(nrow(outcomes) > 0)
  testthat::expect_true(sum(c("cohortName", "cohortDefinitionId", "dechalRechal", "riskFactors", "timeToEvent", "caseSeries") %in% colnames(outcomes)) == 6)

  charTargets <- getTargetsUsedInCharacterization(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::skip_if(nrow(charTargets) == 0, "No characterization targets in example data")

  outcomes2 <- getOutcomesUsedInCharacterization(
    connectionHandler = connectionHandler,
    schema = schema,
    targetId = charTargets$cohortDefinitionId[1]
  )

  testthat::expect_true(nrow(outcomes2) <= nrow(outcomes))

  outcomes3 <- getOutcomesUsedInCharacterization(
    connectionHandler = connectionHandler,
    schema = schema,
    targetId = -99999
  )

  testthat::expect_true(nrow(outcomes3) == 0)
})

test_that("getOutcomesUsedInIncidence", {
  outcomes <- getOutcomesUsedInIncidence(
    connectionHandler = connectionHandler,
    schema = schema,
    targetId = NULL
  )

  testthat::expect_true(nrow(outcomes) > 0)
  testthat::expect_true(sum(c("cohortName", "cohortDefinitionId", "cohortIncidence") %in% colnames(outcomes)) == 3)

  incTargets <- getTargetsUsedInIncidence(
    connectionHandler = connectionHandler,
    schema = schema
  )

  testthat::skip_if(nrow(incTargets) == 0, "No incidence targets in example data")

  outcomes2 <- getOutcomesUsedInIncidence(
    connectionHandler = connectionHandler,
    schema = schema,
    targetId = incTargets$cohortDefinitionId[1]
  )

  testthat::expect_true(nrow(outcomes2) <= nrow(outcomes))

  outcomes3 <- getOutcomesUsedInIncidence(
    connectionHandler = connectionHandler,
    schema = schema,
    targetId = -99999
  )

  testthat::expect_true(nrow(outcomes3) == 0)
})

test_that("characterizationCompareBinary", {
  targetId <- pickCharacterizationTarget()
  testthat::skip_if(is.null(targetId), "No characterization target in example data")

  data <- characterizationCompareBinary(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetIds = targetId
  ) %>% suppressWarnings()

  testthat::skip_if(is.null(data), "No binary characterization comparison data in example data")
  testthat::skip_if(nrow(data$covariates) == 0 || ncol(data$covariates) == 0, "No binary covariate comparison rows in example data")

  testthat::expect_true(nrow(data$covRef) > 0)
  testthat::expect_true("covariateId" %in% colnames(data$covariates))
  testthat::expect_true("covariateName" %in% colnames(data$covariates))
  testthat::expect_true(unique(data$covRef$characterizationTargetId) == targetId)
})

test_that("characterizationCompareContinuous", {
  targetId <- pickCharacterizationTarget()
  testthat::skip_if(is.null(targetId), "No characterization target in example data")

  data <- characterizationCompareContinuous(
    connectionHandler = connectionHandler,
    schema = schema,
    characterizationTargetIds = targetId
  ) %>% suppressWarnings()

  testthat::skip_if(is.null(data), "No continuous characterization comparison data in example data")
  testthat::skip_if(nrow(data$covariates) == 0 || ncol(data$covariates) == 0, "No continuous covariate comparison rows in example data")

  testthat::expect_true(nrow(data$covRef) > 0)
  testthat::expect_true("covariateName" %in% colnames(data$covariates))
  testthat::expect_true("covariateId" %in% colnames(data$covariates))
  testthat::expect_true(unique(data$covRef$characterizationTargetId) == targetId)
})
