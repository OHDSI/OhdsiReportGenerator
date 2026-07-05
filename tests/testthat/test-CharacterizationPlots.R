test_that("viewIncidenceRate", {
  
  incidenceData <- getIncidenceRates(
    connectionHandler = connectionHandler , 
    schema = schema, 
    targetIds = 1
  )
 # incidence data does not have rate values to imputing them
  incidenceData$incidenceRateP100py <- 1+sample(c(-1,1),replace = TRUE)*runif(nrow(incidenceData))
  incidenceData$incidenceProportionP100p<- 0.5+sample(c(-1,1),replace = TRUE)*runif(nrow(incidenceData))

  cTarIds <- getCharacterizationTargetSettings(
    connectionHandler = connectionHandler, 
    schema = schema, 
    targetIds = 1
    )
  
  cTarIds <- cTarIds %>%
    dplyr::filter(.data$limitToFirstInNDays == 99999 &
                    .data$databaseComparator > 0 
                    ) %>%
    dplyr::pull("characterizationTargetId")
  
  ageData <- getBinaryTargetBaseline(
    connectionHandler = connectionHandler, 
    schema = schema,  
    characterizationTargetIds = cTarIds[1],
    analysisIds = 3
  )

  genderData <- getBinaryTargetBaseline(
    connectionHandler = connectionHandler, 
    schema = schema,  
    characterizationTargetIds = cTarIds[1],
    analysisIds = 1
  )

  p <- suppressWarnings(viewIncidenceRate(
    incidenceData = incidenceData,
    ageData = ageData,
    genderData = genderData
    ))
  testthat::expect_s3_class(p, 'gt_tbl')
})


test_that("plotAgeDistributions", {
  characterizationTargetId <- 30
  testthat::skip_if(is.null(characterizationTargetId), "No characterization target in example data")

  ageData <- getCharacterizationDemographics(
    connectionHandler = connectionHandler, 
    schema = 'main',
    characterizationTargetId = characterizationTargetId,
    type = 'age'
  )

  testthat::skip_if(nrow(ageData) == 0, "No age characterization demographics rows in example data")

  p <- plotAgeDistributions(ageData = ageData)
  testthat::expect_s3_class(p, 'ggplot')
})

test_that("plotSexDistributions", {
  characterizationTargetId <- 30
  testthat::skip_if(is.null(characterizationTargetId), "No characterization target in example data")

  sexData <- getCharacterizationDemographics(
    connectionHandler = connectionHandler, 
    schema = 'main',
    characterizationTargetId = characterizationTargetId,
    type = 'sex'
  )

  testthat::skip_if(nrow(sexData) == 0, "No sex characterization demographics rows in example data")

  p <- plotSexDistributions(sexData = sexData)
  testthat::expect_s3_class(p, 'ggplot')
})