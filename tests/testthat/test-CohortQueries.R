test_that("getCohortDefinitions", {
  
  cohorts <- getCohortDefinitions(
    connectionHandler = connectionHandler,
    schema = schema
  )
  
  testthat::expect_true(nrow(cohorts) > 0)
  
  testthat::expect_true('cohortDefinitionId' %in% colnames(cohorts))
  testthat::expect_true('cohortName' %in% colnames(cohorts))
  testthat::expect_true('description' %in% colnames(cohorts))
  testthat::expect_true('json' %in% colnames(cohorts))
  testthat::expect_true('sqlCommand' %in% colnames(cohorts))
  testthat::expect_true('subsetParent' %in% colnames(cohorts))
  testthat::expect_true('isSubset' %in% colnames(cohorts))
  testthat::expect_true('subsetDefinitionId' %in% colnames(cohorts))
  
})

test_that("processCohorts", {
  
  cohorts <- getCohortDefinitions(
    connectionHandler = connectionHandler,
    schema = schema
  )

  parents <- processCohorts(cohorts)
  
  # check correct number of parents
  testthat::expect_true(sum(is.na(cohorts$subsetDefinitionId)) == length(parents$parents))
  
  # check all cohorts are in the parents list
  testthat::expect_true(nrow(do.call('rbind', parents$cohortList)) == nrow(cohorts))
  
})


test_that("getCohortSubsetDefinitions", {
  
  subsetDef <- getCohortSubsetDefinitions(
    connectionHandler,
    schema
    )
  
  # make sure results are returned
  testthat::expect_true(nrow(subsetDef) > 0)
  
  firstJson <- ParallelLogger::convertJsonToSettings(subsetDef$json[1])
  
  # check key entries
  testthat::expect_true('name' %in% names(firstJson))
  testthat::expect_true('definitionId' %in% names(firstJson))
  testthat::expect_true('subsetOperators' %in% names(firstJson))
  
})


test_that("getCohortInclusionStats", {
  
  result <- getCohortInclusionStats(
    connectionHandler,
    schema
  )
  
  # check key entries
  testthat::expect_true('databaseId' %in% colnames(result))
  testthat::expect_true('databaseName' %in% colnames(result))
  testthat::expect_true('cohortDefinitionId' %in% colnames(result))
  testthat::expect_true('cohortName' %in% colnames(result))
  testthat::expect_true('inclusionRuleMask' %in% colnames(result))
  testthat::expect_true('personCount' %in% colnames(result))
  testthat::expect_true('modeId' %in% colnames(result))
})


test_that("getCohortInclusionRules", {
  
  result <- getCohortInclusionRules(
    connectionHandler,
    schema
  )
  
  # check key entries
  testthat::expect_true('cohortDefinitionId' %in% colnames(result))
  testthat::expect_true('cohortName' %in% colnames(result))
  testthat::expect_true('ruleName' %in% colnames(result))
  testthat::expect_true('ruleSequence' %in% colnames(result))
})

test_that("getCohortInclusionSummary", {
  
  result <- getCohortInclusionSummary(
    connectionHandler,
    schema
  )
  
  # check key entries
  testthat::expect_true('cohortDefinitionId' %in% colnames(result))
  testthat::expect_true('cohortName' %in% colnames(result))
  testthat::expect_true('baseCount' %in% colnames(result))
  testthat::expect_true('finalCount' %in% colnames(result))
  testthat::expect_true('modeId' %in% colnames(result))
  testthat::expect_true('databaseName' %in% colnames(result))
  testthat::expect_true('databaseId' %in% colnames(result))
})


test_that("getCohortMeta", {
  
  result <- getCohortMeta(
    connectionHandler,
    schema
  )
  
  # check key entries
  testthat::expect_true('cohortId' %in% colnames(result))
  testthat::expect_true('cohortName' %in% colnames(result))
  testthat::expect_true('generationStatus' %in% colnames(result))
  testthat::expect_true('startTime' %in% colnames(result))
  testthat::expect_true('endTime' %in% colnames(result))
  testthat::expect_true('databaseName' %in% colnames(result))
  testthat::expect_true('databaseId' %in% colnames(result))
})


test_that("getCohortCounts", {
  
  result <- getCohortCounts(
    connectionHandler,
    schema
  )
  
  # check key entries
  testthat::expect_true('cohortId' %in% colnames(result))
  testthat::expect_true('cohortName' %in% colnames(result))
  testthat::expect_true('cohortEntries' %in% colnames(result))
  testthat::expect_true('cohortSubjects' %in% colnames(result))
  testthat::expect_true('databaseName' %in% colnames(result))
  testthat::expect_true('databaseId' %in% colnames(result))
})

test_that("getCohortAttrition", {
  
  result <- getCohortAttrition(
    connectionHandler,
    schema
  )

    # check key entries
  testthat::expect_true('databaseId' %in% colnames(result))
  testthat::expect_true('databaseName' %in% colnames(result))
  testthat::expect_true('cohortDefinitionId' %in% colnames(result))
  testthat::expect_true('modeId' %in% colnames(result))
  testthat::expect_true('cohortEntry' %in% colnames(result))
  testthat::expect_true('ruleSequence' %in% colnames(result))
  testthat::expect_true('ruleName' %in% colnames(result))
  testthat::expect_true('personCount' %in% colnames(result))  
})

test_that("getCohortSubsetAttrition", {
  
  result <- getCohortSubsetAttrition(
    connectionHandler,
    schema
  )

    # check key entries
  testthat::expect_true('databaseId' %in% colnames(result))
  testthat::expect_true('databaseName' %in% colnames(result))
  testthat::expect_true('cohortDefinitionId' %in% colnames(result))
  testthat::expect_true('subsetDefinitionId' %in% colnames(result))
  testthat::expect_true('subsetParentId' %in% colnames(result))
  testthat::expect_true('modeId' %in% colnames(result))
  testthat::expect_true('cohortEntry' %in% colnames(result))
  testthat::expect_true('operatorSequence' %in% colnames(result))
  testthat::expect_true('operatorName' %in% colnames(result))
  testthat::expect_true('operatorType' %in% colnames(result))
  testthat::expect_true('countValue' %in% colnames(result))  
})

test_that("getCohortAttrition and getCohortSubsetAttrition throw warnings when CG version < 1.1", {
  # Override the .getCgVersion function to 
  # return 1 for this test
  original <- get(".getCgVersion", envir = asNamespace("OhdsiReportGenerator"))
  assignInNamespace(
    ".getCgVersion",
    function(connectionHandler, schema, ...) 1,
    ns = "OhdsiReportGenerator"
  )
  on.exit({
    assignInNamespace(".getCgVersion", original, ns = "OhdsiReportGenerator")
  })
  
  testthat::expect_warning(
    getCohortAttrition(
      connectionHandler,
      schema
    )
  )

  testthat::expect_warning(
    getCohortSubsetAttrition(
      connectionHandler,
      schema
    )
  )
})



test_that("test processCohortDefinitionsForQuarto", {

  # nest to cohort 10
  sub1Json <- '{
  "name": "madeup",
  "definitionId": 1,
  "subsetOperators": [
    {
      "name": "made 1",
      "subsetType": "CohortSubsetOperator",
      "cohortIds": [10],
      "cohortCombinationOperator": "all",
      "negate": false,
      "windows": []
    }
  ],
  "packageVersion": "1.0.2",
  "identifierExpression": "targetId * 1000 + definitionId",
  "operatorNameConcatString": ", ",
  "subsetCohortNameTemplate": "@baseCohortName - @subsetDefinitionName"
}' 
  
  sub2Json <- '
  {
  "name": "madeup 2",
  "definitionId": 2,
  "subsetOperators": [
    {
      "name": "aged 18+",
      "subsetType": "DemographicSubsetOperator",
      "ageMin": 18,
      "ageMax": 99999
    }
  ],
  "packageVersion": "1.0.2",
  "identifierExpression": "targetId * 1000 + definitionId",
  "operatorNameConcatString": ", ",
  "subsetCohortNameTemplate": "@baseCohortName - @subsetDefinitionName"
} 
  '
  
  sub3Json <- '
  {
  "name": "madeup 3",
  "definitionId": 3,
  "subsetOperators": [
    {
      "name": "aged 18+",
      "subsetType": "DemographicSubsetOperator",
      "ageMin": 18,
      "ageMax": 99999
    },
  {
      "name": "made 1",
      "subsetType": "CohortSubsetOperator",
      "cohortIds": [5],
      "cohortCombinationOperator": "all",
      "negate": false,
      "windows": []
    }
  ],
  "packageVersion": "1.0.2",
  "identifierExpression": "targetId * 1000 + definitionId",
  "operatorNameConcatString": ", ",
  "subsetCohortNameTemplate": "@baseCohortName - @subsetDefinitionName"
} 
  '
  
  cohortDef <- data.frame(
    cohortDefinitionId = c(1,2,3,4,5),
    cohortName = c(1,2,3,4,5), 
    subsetParent = c(1,1,1,2,5),
    isSubset = c(0,1,1,1,0),
    subsetDefinitionId = c(NA,1,2,3,NA),
    subsetDefinitionJson = c(NA, sub1Json, sub2Json, sub3Json, NA)
  )
  
  cohortDefinitionsPro <- processCohortDefinitionsForQuarto(
    cohortDefinitions = cohortDef,
    friendlyCohortIds = c(1,2,3,4,5),
    friendlyCohortNames = paste0('cohort ', 1:5),
    restrictTargetToIndications = FALSE,
    indicationIds = 10
  )
  
  testthat::expect_true(sum(colnames(cohortDef) %in% colnames(cohortDefinitionsPro) ) == ncol(cohortDef))
  testthat::expect_true(nrow(cohortDef) == nrow(cohortDefinitionsPro))
  testthat::expect_true('friendlyName' %in% colnames(cohortDefinitionsPro))
  testthat::expect_true('subsetText' %in% colnames(cohortDefinitionsPro))
  
  testthat::expect_true(cohortDefinitionsPro$subsetText[1] == "")
  testthat::expect_true(cohortDefinitionsPro$subsetText[5] == "")
  
  testthat::expect_true(cohortDefinitionsPro$subsetText[2] == "In cohorts id 10.")
  testthat::expect_true(cohortDefinitionsPro$subsetText[3] == "Aged between 18 to 99999.")
  testthat::expect_true(cohortDefinitionsPro$subsetText[4] == "Aged between 18 to 99999. In cohorts cohort 5.")
  
  # now check when restrictTargetToIndications is set to TRUE
  cohortDefinitionsPro <- processCohortDefinitionsForQuarto(
    cohortDefinitions = cohortDef,
    friendlyCohortIds = c(1,2,3,4,5),
    friendlyCohortNames = paste0('cohort ', 1:5),
    restrictTargetToIndications = TRUE,
    indicationIds = c(5,10)
  )
  testthat::expect_true(sum(colnames(cohortDef) %in% colnames(cohortDefinitionsPro) ) == ncol(cohortDef))
  testthat::expect_true(nrow(cohortDef) == nrow(cohortDefinitionsPro))
  testthat::expect_true('friendlyName' %in% colnames(cohortDefinitionsPro))
  testthat::expect_true('subsetText' %in% colnames(cohortDefinitionsPro))
  testthat::expect_true('indicationOfInt' %in% colnames(cohortDefinitionsPro))
  
  testthat::expect_true(cohortDefinitionsPro$subsetText[2] == "In cohorts id 10.")
  testthat::expect_true(cohortDefinitionsPro$subsetText[3] == "Aged between 18 to 99999.")
  testthat::expect_true(cohortDefinitionsPro$subsetText[4] == "Aged between 18 to 99999. In cohorts cohort 5.")
  
  testthat::expect_true(cohortDefinitionsPro$indicationOfInt[1] == FALSE)
  testthat::expect_true(cohortDefinitionsPro$indicationOfInt[2] == TRUE)
  testthat::expect_true(cohortDefinitionsPro$indicationOfInt[3] == FALSE)
  testthat::expect_true(cohortDefinitionsPro$indicationOfInt[4] == TRUE)
  testthat::expect_true(cohortDefinitionsPro$indicationOfInt[5] == FALSE)
  
})


test_that("test restrictCohortDefinitionsForQuarto", {
  
  sub1Json <- '{
  "name": "madeup",
  "definitionId": 1,
  "subsetOperators": [
    {
      "name": "made 1",
      "subsetType": "CohortSubsetOperator",
      "cohortIds": [10],
      "cohortCombinationOperator": "all",
      "negate": false,
      "windows": []
    }
  ],
  "packageVersion": "1.0.2",
  "identifierExpression": "targetId * 1000 + definitionId",
  "operatorNameConcatString": ", ",
  "subsetCohortNameTemplate": "@baseCohortName - @subsetDefinitionName"
}' 
  
  sub2Json <- '
  {
  "name": "madeup 2",
  "definitionId": 2,
  "subsetOperators": [
    {
      "name": "aged 18+",
      "subsetType": "DemographicSubsetOperator",
      "ageMin": 18,
      "ageMax": 99999
    }
  ],
  "packageVersion": "1.0.2",
  "identifierExpression": "targetId * 1000 + definitionId",
  "operatorNameConcatString": ", ",
  "subsetCohortNameTemplate": "@baseCohortName - @subsetDefinitionName"
} 
  '
  
  sub3Json <- '
  {
  "name": "madeup 3",
  "definitionId": 3,
  "subsetOperators": [
    {
      "name": "aged 18+",
      "subsetType": "DemographicSubsetOperator",
      "ageMin": 18,
      "ageMax": 99999
    },
  {
      "name": "made 1",
      "subsetType": "CohortSubsetOperator",
      "cohortIds": [5],
      "cohortCombinationOperator": "all",
      "negate": false,
      "windows": []
    }
  ],
  "packageVersion": "1.0.2",
  "identifierExpression": "targetId * 1000 + definitionId",
  "operatorNameConcatString": ", ",
  "subsetCohortNameTemplate": "@baseCohortName - @subsetDefinitionName"
} 
  '
  
  cohortDef <- data.frame(
    cohortDefinitionId = c(1,2,3,4,5,6,10),
    cohortName = c(1,2,3,4,5,6,10), 
    subsetParent = c(1,1,1,4,5,4,10),
    isSubset = c(0,1,1,1,0,1,0),
    subsetDefinitionId = c(NA,1,2,3,NA,1,NA),
    subsetDefinitionJson = c(NA, sub1Json, sub2Json, sub3Json, NA,sub1Json,NA)
  )
  cohortDefinitionsPro <- processCohortDefinitionsForQuarto(
    cohortDefinitions = cohortDef,
    friendlyCohortIds = c(1,2,3,4,5),
    friendlyCohortNames = paste0('cohort ', 1:5),
    restrictTargetToIndications = TRUE,
    indicationIds = c(10)
  )
  
  cohorts <- restrictCohortDefinitionsForQuarto(
    cohortDefinitions = cohortDefinitionsPro, 
    targetId = 1, 
    outcomeIds = 5, 
    comparatorIds = 4, 
    includeCohortMethod = FALSE, 
    indicationIds = NULL, 
    restrictTargetToIndications = FALSE
  )
  
  testthat::expect_true(sum(c(1,2,3) %in% cohorts$targetIdsOfInterest) == 3)
  testthat::expect_true(length(cohorts$targetIdsOfInterest) == 3)
  testthat::expect_true(cohorts$outcomeIdsOfInterest == 5)
  testthat::expect_true(sum(c(4,6) %in% cohorts$comparatorIdsOfInterest) == 2)
  testthat::expect_true(length(cohorts$comparatorIdsOfInterest) == 2)
  testthat::expect_true(is.null(cohorts$indicationIdsOfInterest))
  
  
  # now with indications
  cohorts <- restrictCohortDefinitionsForQuarto(
    cohortDefinitions = cohortDefinitionsPro, 
    targetId = 1, 
    outcomeIds = 5, 
    comparatorIds = 4, 
    includeCohortMethod = FALSE, 
    indicationIds = 10, 
    restrictTargetToIndications = FALSE
  )
  
  testthat::expect_true(sum(c(1,2,3) %in% cohorts$targetIdsOfInterest) == 3)
  testthat::expect_true(length(cohorts$targetIdsOfInterest) == 3)
  testthat::expect_true(cohorts$outcomeIdsOfInterest == 5)
  testthat::expect_true(sum(c(4,6) %in% cohorts$comparatorIdsOfInterest) == 2)
  testthat::expect_true(length(cohorts$comparatorIdsOfInterest) == 2)
  testthat::expect_true(cohorts$indicationIdsOfInterest == 10)
  
  
  # now test restricting target to indication 10
  cohorts <- restrictCohortDefinitionsForQuarto(
    cohortDefinitions = cohortDefinitionsPro, 
    targetId = 1, 
    outcomeIds = 5, 
    comparatorIds = 4, 
    includeCohortMethod = FALSE, 
    indicationIds = 10, 
    restrictTargetToIndications = TRUE
  )
  testthat::expect_true(cohorts$targetIdsOfInterest == 2)
  testthat::expect_true(cohorts$outcomeIdsOfInterest == 5)
  testthat::expect_true(cohorts$comparatorIdsOfInterest == 6)
  testthat::expect_true(cohorts$indicationIdsOfInterest == 10)
  
})
