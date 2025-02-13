# loading example

pathToSpec <- system.file(
  "testdata",
  'cdmModulesAnalysisSpecifications.json', 
  package = "Strategus"
)
spec <- ParallelLogger::loadSettingsFromJson(pathToSpec)


outputFolder <- './exampleStratNew'
database <- 'eunomia'
cdmDatabase <- 'main'
connectionDetails <- Eunomia::getEunomiaConnectionDetails()

if(F){
con <- DatabaseConnector::connect(connectionDetails)
cohort <- DatabaseConnector::querySql(con, 'select * from main.cohort;')
con_era <- DatabaseConnector::querySql(con, 'select * from main.condition_era;')
drug_era <- DatabaseConnector::querySql(con, 'select * from main.drug_era;')
DatabaseConnector::disconnect(con)
}

# install the latest Strategus, then run:
#remotes::install_githib('ohdsi/Strategus')
Strategus::execute(
  analysisSpecifications = spec, 
  executionSettings = Strategus::createCdmExecutionSettings(
    workDatabaseSchema = 'main', 
    cdmDatabaseSchema = cdmDatabase,
    cohortTableNames = CohortGenerator::getCohortTableNames('cohort'), 
    workFolder = file.path(outputFolder, 'work'), 
    resultsFolder = file.path(outputFolder, 'result')#, 
    #modulesToExecute = c('CohortGeneratorModule','SelfControlledCaseSeriesModule')
    ), 
  connectionDetails = connectionDetails
)


Strategus::createResultDataModel(
  analysisSpecifications = spec, 
  resultsDataModelSettings = Strategus::createResultsDataModelSettings(
    resultsDatabaseSchema = 'main', 
    resultsFolder = file.path(outputFolder, 'result')
  ), 
  resultsConnectionDetails = DatabaseConnector::createConnectionDetails(
    dbms = 'sqlite', 
    server = './inst/exampledata/results.sqlite'
  )
)
Strategus::uploadResults(
  analysisSpecifications = spec, 
  resultsDataModelSettings = Strategus::createResultsDataModelSettings(
    resultsDatabaseSchema = 'main', 
    resultsFolder = file.path(outputFolder, 'result')
  ), 
  resultsConnectionDetails = DatabaseConnector::createConnectionDetails(
    dbms = 'sqlite', 
    server = './inst/exampledata/results.sqlite'
    )
)

# manually add dechal-rechal tables as not possible in eunomia
if(F){
  resultsConnectionDetails = DatabaseConnector::createConnectionDetails(
    dbms = 'sqlite', 
    server = './inst/exampledata/results.sqlite'
  )
con <- DatabaseConnector::connect(resultsConnectionDetails)
DatabaseConnector::insertTable(
  connection = con, 
  databaseSchema = 'main', 
  tableName = 'c_dechallenge_rechallenge', 
  data = data.frame(
    database_id = 388020256,
    DECHALLENGE_STOP_INTERVAL = 30,
    DECHALLENGE_EVALUATION_WINDOW = 30,
    TARGET_COHORT_DEFINITION_ID = 1,
    OUTCOME_COHORT_DEFINITION_ID = 3,
    NUM_EXPOSURE_ERAS = 100,
    NUM_PERSONS_EXPOSED = 80,
    NUM_CASES = 20,
    DECHALLENGE_ATTEMPT = 15,
    DECHALLENGE_FAIL = 10,
    DECHALLENGE_SUCCESS = 5,
    RECHALLENGE_ATTEMPT = 5,
    RECHALLENGE_FAIL = 1,
    RECHALLENGE_SUCCESS = 4,
    PCT_DECHALLENGE_ATTEMPT = 0.75,
    PCT_DECHALLENGE_SUCCESS = 0.33,
    PCT_DECHALLENGE_FAIL = 0.67,
    PCT_RECHALLENGE_ATTEMPT = 1,
    PCT_RECHALLENGE_SUCCESS = 0.8,
    PCT_RECHALLENGE_FAIL = 0.2
  ), 
  dropTableIfExists = T)

#"c_rechallenge_fail_case_series"
DatabaseConnector::insertTable(
  connection = con, 
  databaseSchema = 'main', 
  tableName = 'c_rechallenge_fail_case_series', 
  data = data.frame(
    database_id = 388020256,
    DECHALLENGE_STOP_INTERVAL = 30,
    DECHALLENGE_EVALUATION_WINDOW = 30,
    TARGET_COHORT_DEFINITION_ID = 1,
    OUTCOME_COHORT_DEFINITION_ID = 3,
    PERSON_KEY = 1,
    SUBJECT_ID = 1,
    DECHALLENGE_EXPOSURE_NUMBER = 2,
    DECHALLENGE_EXPOSURE_START_DATE_OFFSET = 20,
    DECHALLENGE_EXPOSURE_END_DATE_OFFSET = 24,
    DECHALLENGE_OUTCOME_NUMBER = 1,
    DECHALLENGE_OUTCOME_START_DATE_OFFSET = 22,
    RECHALLENGE_EXPOSURE_NUMBER = 3,
    RECHALLENGE_EXPOSURE_START_DATE_OFFSET = 36,
    RECHALLENGE_EXPOSURE_END_DATE_OFFSET = 38,
    RECHALLENGE_OUTCOME_NUMBER = 2,
    RECHALLENGE_OUTCOME_START_DATE_OFFSET = 36
  ), 
  dropTableIfExists = T)
DatabaseConnector::disconnect(con)
}

# evidence synth
resultsDatabaseSchema <- 'main'
resultsConnectionDetails = DatabaseConnector::createConnectionDetails(
  dbms = 'sqlite', 
  server = './inst/exampledata/results.sqlite'
)
esModuleSettingsCreator = EvidenceSynthesisModule$new()
evidenceSynthesisSourceCm <- esModuleSettingsCreator$createEvidenceSynthesisSource(
  sourceMethod = "CohortMethod",
  likelihoodApproximation = "adaptive grid"
)
metaAnalysisCm <- esModuleSettingsCreator$createBayesianMetaAnalysis(
  evidenceSynthesisAnalysisId = 1,
  alpha = 0.05,
  evidenceSynthesisDescription = "Bayesian random-effects alpha 0.05 - adaptive grid",
  evidenceSynthesisSource = evidenceSynthesisSourceCm
)
evidenceSynthesisSourceSccs <- esModuleSettingsCreator$createEvidenceSynthesisSource(
  sourceMethod = "SelfControlledCaseSeries",
  likelihoodApproximation = "adaptive grid"
)
metaAnalysisSccs <- esModuleSettingsCreator$createBayesianMetaAnalysis(
  evidenceSynthesisAnalysisId = 2,
  alpha = 0.05,
  evidenceSynthesisDescription = "Bayesian random-effects alpha 0.05 - adaptive grid",
  evidenceSynthesisSource = evidenceSynthesisSourceSccs
)
evidenceSynthesisAnalysisList <- list(metaAnalysisCm, metaAnalysisSccs)
evidenceSynthesisAnalysisSpecifications <- esModuleSettingsCreator$createModuleSpecifications(
  evidenceSynthesisAnalysisList
)
esAnalysisSpecifications <- Strategus::createEmptyAnalysisSpecificiations() |>
  Strategus::addModuleSpecifications(evidenceSynthesisAnalysisSpecifications)

resultsExecutionSettings <- Strategus::createResultsExecutionSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = file.path(outputFolder,"results", "evidence_sythesis", "strategusOutput"),
  workFolder = file.path(outputFolder,"results", "evidence_sythesis", "strategusWork")
)

Strategus::execute(
  analysisSpecifications = esAnalysisSpecifications,
  executionSettings = resultsExecutionSettings,
  connectionDetails = resultsConnectionDetails
)

resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = resultsExecutionSettings$resultsFolder
)

Strategus::createResultDataModel(
  analysisSpecifications = esAnalysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)

Strategus::uploadResults(
  analysisSpecifications = esAnalysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)
