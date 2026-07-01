pickPlotCharacterizationTarget <- function() {
  counts <- getTargetCounts(
    connectionHandler = connectionHandler,
    schema = schema
  )

  if (nrow(counts) == 0) {
    return(NULL)
  }

  counts$characterizationTargetId[1]
}

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

  p <- suppressWarnings(viewIncidenceRate(
    incidenceData = incidenceData,
    ageData = ageData,
    genderData = genderData
    ))
  testthat::expect_s3_class(p, 'gt_tbl')
})


test_that("plotAgeDistributions", {
  targetId <- pickPlotCharacterizationTarget()
  testthat::skip_if(is.null(targetId), "No characterization target in example data")

  ageData <- getCharacterizationDemographics(
    connectionHandler = connectionHandler, 
    schema = 'main',
    characterizationTargetId = targetId,
    type = 'age'
  )

  testthat::skip_if(nrow(ageData) == 0, "No age characterization demographics rows in example data")

  p <- plotAgeDistributions(ageData = ageData)
  testthat::expect_s3_class(p, 'ggplot')
})

test_that("plotSexDistributions", {
  targetId <- pickPlotCharacterizationTarget()
  testthat::skip_if(is.null(targetId), "No characterization target in example data")

  sexData <- getCharacterizationDemographics(
    connectionHandler = connectionHandler, 
    schema = 'main',
    characterizationTargetId = targetId,
    type = 'sex'
  )

  testthat::skip_if(nrow(sexData) == 0, "No sex characterization demographics rows in example data")

  p <- plotSexDistributions(sexData = sexData)
  testthat::expect_s3_class(p, 'ggplot')
})