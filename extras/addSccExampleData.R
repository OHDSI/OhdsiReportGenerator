# Script to add self controlled cohort (scc) results to the example
# OhdsiReportGenerator results database.
#
# The committed example database is created by running
#   extras/createExampleData.R
# which executes a Strategus analysis on Eunomia.  That database does not
# contain self controlled cohort results, so this script appends the
# SelfControlledCohort (scc_*) and SelfControlledCohort evidence synthesis
# (es_scc_*) tables together with a couple of additional simulated databases
# so the multi database discovery view and meta analysis can be explored.
#
# Multiple SCC analysis settings are simulated (two analyses with different
# time at risk windows) so the effect of the study parameter settings on the
# estimates can be explored.
#
# The scc results are simulated (i.e. they are NOT the output of the
# SelfControlledCohort R package) but are consistent with the cohort
# definitions that already exist in the example database (Doxylamine,
# PenicillinV, ViralSinusitis, GI bleed, Death etc).
#
# To regenerate the example database run (from the package root):
#   source('extras/addSccExampleData.R')
#
# This requires the DatabaseConnector package and will overwrite
# inst/exampledata/results.sqlite.zip

# location of the example results database
exampleFile <- file.path('inst', 'exampledata', 'results.sqlite')
exampleZip <- file.path('inst', 'exampledata', 'results.sqlite.zip')

if (!file.exists(exampleFile) && file.exists(exampleZip)) {
  message('Unzipping committed example database')
  utils::unzip(exampleZip, exdir = file.path('inst', 'exampledata'))
}

stopifnot(file.exists(exampleFile))

connection <- DatabaseConnector::connect(
  DatabaseConnector::createConnectionDetails(
    dbms = 'sqlite',
    server = exampleFile
  )
)

insertTable <- function(data, tableName) {
  DatabaseConnector::insertTable(
    connection = connection,
    databaseSchema = 'main',
    tableName = tableName,
    data = data,
    dropTableIfExists = TRUE,
    createTable = TRUE,
    camelCaseToSnakeCase = FALSE
  )
}

# --------------------------------------------------------------------------
# helper to add a new database to the database_meta_data table
# --------------------------------------------------------------------------
addDatabase <- function(databaseId, name) {
  existing <- DatabaseConnector::querySql(
    connection = connection,
    sql = 'SELECT * FROM main.database_meta_data LIMIT 1;'
  )
  newRow <- existing[1, , drop = FALSE]
  newRow$database_id <- databaseId
  newRow$cdm_source_name <- paste0(name, ' synthetic health database')
  newRow$cdm_source_abbreviation <- name
  return(newRow)
}

# --------------------------------------------------------------------------
# add two additional databases (so per database counts / meta analysis are
# meaningful) while keeping the original Eunomia database.  Any previously
# added synthetic databases are removed first so the script is idempotent
# --------------------------------------------------------------------------
dbMeta <- DatabaseConnector::querySql(
  connection = connection,
  sql = paste0(
    "SELECT * FROM main.database_meta_data ",
    "WHERE database_id NOT IN ('eunomia_2', 'eunomia_3');"
  )
)
dbMeta <- rbind(
  dbMeta,
  addDatabase('eunomia_2', 'Synthea B'),
  addDatabase('eunomia_3', 'Synthea C')
)
DatabaseConnector::insertTable(
  connection = connection,
  databaseSchema = 'main',
  tableName = 'database_meta_data',
  data = dbMeta,
  dropTableIfExists = TRUE,
  createTable = TRUE
)

# --------------------------------------------------------------------------
# add negative control outcome cohorts to the cohort definition table
# --------------------------------------------------------------------------
DatabaseConnector::executeSql(
  connection = connection,
  sql = "DELETE FROM main.cg_cohort_definition WHERE cohort_definition_id IN (5001, 5002);"
)
DatabaseConnector::executeSql(
  connection = connection,
  sql = paste0(
    "INSERT INTO main.cg_cohort_definition (cohort_definition_id, cohort_name) VALUES ",
    "(5001, 'Otitis media (neg control)'), ",
    "(5002, 'Urinary tract infection (neg control)');"
  )
)

# --------------------------------------------------------------------------
# the simulated exposure - outcome pairs
# --------------------------------------------------------------------------
databaseIds <- c('388020256', 'eunomia_2', 'eunomia_3')

# outcome / exposure pairs of interest (true_effect_size is NULL)
interestPairs <- list(
  # Doxylamine (an antiemetic) appears protective for the viral sinusitis
  # outcome and neutral / slightly risky for GI bleed and death
  list(targetId = 9, outcomeId = 11, rr = c(0.38, 0.44, 0.41), se = c(0.15, 0.17, 0.16)),
  list(targetId = 9, outcomeId = 3, rr = c(1.05, 1.20, 1.12), se = c(0.20, 0.22, 0.21)),
  list(targetId = 9, outcomeId = 8, rr = c(1.30, 1.12, 1.45), se = c(0.22, 0.23, 0.24)),
  # PenicillinV is used for viral sinusitis - mild protection
  list(targetId = 10, outcomeId = 11, rr = c(0.82, 0.90, 0.76), se = c(0.16, 0.18, 0.17)),
  # PenicillinV neutral for GI bleed but risky for death
  list(targetId = 10, outcomeId = 3, rr = c(0.95, 1.08, 1.00), se = c(0.19, 0.21, 0.20)),
  list(targetId = 10, outcomeId = 8, rr = c(1.55, 1.70, 1.45), se = c(0.22, 0.24, 0.23))
)

# negative control pairs (true_effect_size is not NULL)
controlPairs <- list(
  list(targetId = 9, outcomeId = 5001, trueEffectSize = 1, rr = c(1.02, 0.98, 1.05), se = c(0.20, 0.21, 0.22)),
  list(targetId = 10, outcomeId = 5002, trueEffectSize = 1, rr = c(0.97, 1.03, 0.99), se = c(0.20, 0.21, 0.20))
)

# --------------------------------------------------------------------------
# the study parameter settings (SCC analysis settings) to simulate
# --------------------------------------------------------------------------
analyses <- list(
  list(
    analysisId = 1,
    description = 'Self controlled cohort',
    settings = '{"riskWindowStart":0,"riskWindowEnd":30}',
    logFactor = 1.0,
    timeScale = 1.0,
    mdrr = 1.3,
    ease = 0.05
  ),
  list(
    analysisId = 2,
    description = 'Self controlled cohort - extended risk window',
    settings = '{"riskWindowStart":0,"riskWindowEnd":60}',
    logFactor = 1.18,
    timeScale = 0.85,
    mdrr = 1.5,
    ease = 0.08
  )
)

# the rr / se used by an analysis is the base value with the log relative risk
# scaled by the analysis logFactor
pairRrForAnalysis <- function(pair, logFactor) {
  return(exp(log(pair$rr) * logFactor))
}

# --------------------------------------------------------------------------
# scc_result rows for one analysis
# --------------------------------------------------------------------------
createResultRow <- function(databaseId, analysis, targetId, outcomeId, rr, se) {
  logRr <- log(rr)
  z <- logRr / se
  pValue <- 2 * stats::pnorm(-abs(z))
  data.frame(
    database_id = databaseId,
    analysis_id = analysis$analysisId,
    outcome_cohort_id = outcomeId,
    target_cohort_id = targetId,
    rr = rr,
    se_log_rr = se,
    log_rr = logRr,
    lb_95 = exp(logRr - 1.96 * se),
    ub_95 = exp(logRr + 1.96 * se),
    p_value = pValue,
    calibrated_rr = rr,
    calibrated_se_log_rr = se,
    calibrated_log_rr = logRr,
    calibrated_lb_95 = exp(logRr - 1.96 * se),
    calibrated_ub_95 = exp(logRr + 1.96 * se),
    calibrated_p_value = pValue,
    num_persons = 1000,
    time_at_risk_exposed = round(90000 * analysis$timeScale),
    time_at_risk_unexposed = 500000,
    num_outcomes_exposed = max(1, round(30 * rr)),
    num_outcomes_unexposed = 30,
    num_exposures = 1000,
    i2 = NA,
    stringsAsFactors = FALSE
  )
}

buildSccResultRows <- function(analysis) {
  interest <- do.call(rbind, lapply(seq_along(databaseIds), function(i) {
    db <- databaseIds[i]
    do.call(rbind, lapply(interestPairs, function(p) {
      rr <- pairRrForAnalysis(p, analysis$logFactor)
      createResultRow(db, analysis, p$targetId, p$outcomeId, rr[i], p$se[i])
    }))
  }))
  controls <- do.call(rbind, lapply(seq_along(databaseIds), function(i) {
    db <- databaseIds[i]
    do.call(rbind, lapply(controlPairs, function(p) {
      rr <- pairRrForAnalysis(p, analysis$logFactor)
      createResultRow(db, analysis, p$targetId, p$outcomeId, rr[i], p$se[i])
    }))
  }))
  return(rbind(interest, controls))
}

# --------------------------------------------------------------------------
# scc_stat rows for one analysis
# --------------------------------------------------------------------------
createStatRows <- function(databaseId, analysis, targetId, outcomeId, statType, timeScale) {
  baseTimeExposed <- c(mean = 84, sd = 18, min = 7, p10 = 60, p25 = 75, median = 88, p75 = 96, p90 = 100, max = 120)
  baseTimeToOutcome <- c(mean = 150, sd = 60, min = 2, p10 = 20, p25 = 60, median = 140, p75 = 210, p90 = 280, max = 365)

  values <- if (statType == 'time_exposed') baseTimeExposed else baseTimeToOutcome
  # scale the central / extreme values by the analysis timeScale and add a
  # little database variation
  values[c('mean', 'sd', 'min', 'p10', 'p25', 'median', 'p75', 'p90', 'max')] <-
    values[c('mean', 'sd', 'min', 'p10', 'p25', 'median', 'p75', 'p90', 'max')] * timeScale

  dbScale <- switch(databaseId, '388020256' = 1, 'eunomia_2' = 0.9, 'eunomia_3' = 1.1)
  values['mean'] <- values['mean'] * dbScale

  data.frame(
    database_id = databaseId,
    analysis_id = analysis$analysisId,
    outcome_cohort_id = outcomeId,
    target_cohort_id = targetId,
    stat_type = statType,
    mean = values['mean'],
    sd = values['sd'],
    minimum = values['min'],
    p10 = values['p10'],
    p25 = values['p25'],
    median = values['median'],
    p75 = values['p75'],
    p90 = values['p90'],
    maximum = values['max'],
    total = 1000,
    stringsAsFactors = FALSE
  )
}

buildSccStatRows <- function(analysis) {
  do.call(rbind, lapply(databaseIds, function(db) {
    do.call(rbind, lapply(interestPairs, function(p) {
      rbind(
        createStatRows(db, analysis, p$targetId, p$outcomeId, 'time_exposed', analysis$timeScale),
        createStatRows(db, analysis, p$targetId, p$outcomeId, 'time_to_outcome', analysis$timeScale)
      )
    }))
  }))
}

# --------------------------------------------------------------------------
# scc_diagnostics_summary rows for one analysis
# --------------------------------------------------------------------------
buildSccDiagRows <- function(analysis) {
  do.call(rbind, lapply(databaseIds, function(db) {
    do.call(rbind, lapply(interestPairs, function(p) {
      data.frame(
        database_id = db,
        analysis_id = analysis$analysisId,
        outcome_cohort_id = p$outcomeId,
        target_cohort_id = p$targetId,
        diagnostic_name = c('MDRR', 'EASE', 'PRE_EXPOSURE_P_VALUE', 'UNBLIND'),
        diagnostic_value = c(analysis$mdrr, analysis$ease, 0.4, 1),
        pass = c(1, 1, 1, 1),
        stringsAsFactors = FALSE
      )
    }))
  }))
}

# --------------------------------------------------------------------------
# evidence synthesis rows for one analysis
# --------------------------------------------------------------------------
buildEsResultRows <- function(analysis) {
  do.call(rbind, lapply(interestPairs, function(p) {
    rrDb <- pairRrForAnalysis(p, analysis$logFactor)
    rr <- exp(mean(log(rrDb)))
    se <- mean(p$se) / sqrt(length(databaseIds))
    logRr <- log(rr)
    z <- logRr / se
    pValue <- 2 * stats::pnorm(-abs(z))
    data.frame(
      target_cohort_id = p$targetId,
      outcome_cohort_id = p$outcomeId,
      analysis_id = analysis$analysisId,
      evidence_synthesis_analysis_id = 3,
      rr = rr,
      ci_95_lb = exp(logRr - 1.96 * se),
      ci_95_ub = exp(logRr + 1.96 * se),
      p = pValue,
      one_sided_p = pValue / 2,
      log_rr = logRr,
      se_log_rr = se,
      num_persons = 3000,
      time_at_risk_exposed = round(270000 * analysis$timeScale),
      time_at_risk_unexposed = 1500000,
      num_outcomes_exposed = 90,
      num_outcomes_unexposed = 90,
      num_exposures = 3000,
      n_databases = length(databaseIds),
      calibrated_rr = rr,
      calibrated_ci_95_lb = exp(logRr - 1.96 * se),
      calibrated_ci_95_ub = exp(logRr + 1.96 * se),
      calibrated_p = pValue,
      calibrated_one_sided_p = pValue / 2,
      calibrated_log_rr = logRr,
      calibrated_se_log_rr = se,
      stringsAsFactors = FALSE
    )
  }))
}

buildEsDiagRows <- function(analysis) {
  do.call(rbind, lapply(interestPairs, function(p) {
    data.frame(
      target_cohort_id = p$targetId,
      outcome_cohort_id = p$outcomeId,
      analysis_id = analysis$analysisId,
      evidence_synthesis_analysis_id = 3,
      mdrr = analysis$mdrr,
      i_2 = 10,
      tau = 0.05,
      ease = analysis$ease,
      mdrr_diagnostic = 'PASS',
      i_2_diagnostic = 'PASS',
      tau_diagnostic = 'PASS',
      ease_diagnostic = 'PASS',
      unblind = 1,
      stringsAsFactors = FALSE
    )
  }))
}

# --------------------------------------------------------------------------
# the exposure-outcome reference table (interest + negative controls) is
# independent of the analysis settings
# --------------------------------------------------------------------------
oexInterest <- do.call(rbind, lapply(interestPairs, function(p) {
  data.frame(
    outcome_cohort_id = p$outcomeId,
    target_cohort_id = p$targetId,
    true_effect_size = NA,
    stringsAsFactors = FALSE
  )
}))
oexControls <- do.call(rbind, lapply(controlPairs, function(p) {
  data.frame(
    outcome_cohort_id = p$outcomeId,
    target_cohort_id = p$targetId,
    true_effect_size = p$trueEffectSize,
    stringsAsFactors = FALSE
  )
}))
insertTable(rbind(oexInterest, oexControls), 'scc_outcome_exposure')

# --------------------------------------------------------------------------
# the analysis settings
# --------------------------------------------------------------------------
insertTable(
  do.call(rbind, lapply(analyses, function(a) {
    data.frame(
      analysis_id = a$analysisId,
      description = a$description,
      settings = a$settings,
      stringsAsFactors = FALSE
    )
  })),
  'scc_analysis_setting'
)

# --------------------------------------------------------------------------
# the per analysis result tables
# --------------------------------------------------------------------------
insertTable(
  do.call(rbind, lapply(analyses, buildSccResultRows)),
  'scc_result'
)
insertTable(
  do.call(rbind, lapply(analyses, buildSccStatRows)),
  'scc_stat'
)
insertTable(
  do.call(rbind, lapply(analyses, buildSccDiagRows)),
  'scc_diagnostics_summary'
)

# --------------------------------------------------------------------------
# evidence synthesis - a single ES analysis (id 3) covering each SCC analysis
# setting
# --------------------------------------------------------------------------
DatabaseConnector::executeSql(
  connection = connection,
  sql = "DELETE FROM main.es_analysis WHERE evidence_synthesis_analysis_id = 3;"
)
DatabaseConnector::executeSql(
  connection = connection,
  sql = paste0(
    "INSERT INTO main.es_analysis ",
    "(evidence_synthesis_analysis_id, evidence_synthesis_description, source_method, definition) ",
    "VALUES (3, 'Bayesian random-effects alpha 0.05 - adaptive grid ",
    "(SelfControlledCohort)', 'SelfControlledCohort', '{}');"
  )
)

insertTable(
  do.call(rbind, lapply(analyses, buildEsResultRows)),
  'es_scc_result'
)
insertTable(
  do.call(rbind, lapply(analyses, buildEsDiagRows)),
  'es_scc_diagnostics_summary'
)

DatabaseConnector::disconnect(connection)

# --------------------------------------------------------------------------
# re-zip the database
# --------------------------------------------------------------------------
oldWd <- getwd()
setwd(file.path('inst', 'exampledata'))
DatabaseConnector::createZipFile(
  zipFile = 'results.sqlite.zip',
  files = 'results.sqlite'
)
setwd(oldWd)

message('SCC example data added to inst/exampledata/results.sqlite.zip')
