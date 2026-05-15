test_that("viewIncidenceRate", {
  
  incidenceData <- getIncidenceRates(
    connectionHandler = connectionHandler , 
    schema = schema
  )
 # incidence data does not have rate values to imputing them
  incidenceData$incidenceRateP100py <- 1+sample(c(-1,1),replace = TRUE)*runif(nrow(incidenceData))
  incidenceData$incidenceProportionP100p<- 0.5+sample(c(-1,1),replace = TRUE)*runif(nrow(incidenceData))

  ageData <- getBinaryTargetBaseline(
    connectionHandler = connectionHandler, 
    schema = schema,  
    analysisIds = 3
  )

  genderData <- getBinaryTargetBaseline(
    connectionHandler = connectionHandler, 
    schema = schema,  
    analysisIds = 1
  )

  p <- viewIncidenceRate(
    incidenceData = incidenceData,
    ageData = ageData,
    genderData = genderData
    )
  testthat::expect_s3_class(p, 'gt_tbl')
})


test_that("plotAgeDistributions", {
  ageData <- getCharacterizationDemographics(
    connectionHandler = connectionHandler, 
    schema = 'main',
    targetId = 1, 
    outcomeId = 3, 
    type = 'age'
  )
  p <- plotAgeDistributions(ageData = ageData)
  testthat::expect_s3_class(p, 'ggplot')
})

test_that("plotSexDistributions", {
  sexData <- getCharacterizationDemographics(
    connectionHandler = connectionHandler, 
    schema = 'main',
    targetId = 1, 
    outcomeId = 3, 
    type = 'sex'
  )
  p <- plotSexDistributions(sexData = sexData)
  testthat::expect_s3_class(p, 'ggplot')
})