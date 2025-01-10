context("CharacterizationPlots")

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