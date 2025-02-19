context("Helpers")

test_that("getExampleConnectionDetails", {
  
  con <- getExampleConnectionDetails()
  testthat::expect_s3_class(con, 'ConnectionDetails')
  
})

test_that("removeSpaces", {
  testthat::expect_true(removeSpaces(x = 'test ') == 'test_')
  testthat::expect_true(removeSpaces(x = 't e s t ') == 't_e_s_t_')
})

test_that("formatCohortType", {
  
  x <- formatCohortType(
    cohortType = c('Target', 'Target', 'Cases')
    )
  testthat::expect_true(length(x) == 3)
  testthat::expect_true(sum(x == 'outcome') == 1)
  testthat::expect_true(sum(x == 'No outcome') == 2)
  testthat::expect_true(x[3] == 'outcome')
  
})


test_that("getTars", {
  
  x <- getTars(
    data = data.frame(
      madeUp = c(1,2,'dfdf'),
      tarStartWith = c('cohort start', 'cohort end', 'cohort start'),
      tarStartOffset = c(1,90,30),
      tarEndWith = c('cohort start', 'cohort end', 'cohort start'),
      tarEndOffset = c(2,91,23)
    ), 
    tarColumnNames = c("tarStartWith","tarStartOffset","tarEndWith","tarEndOffset")
  )
  
  testthat::expect_true(length(x) == 3)
  testthat::expect_true(x[[1]]$tarStartWith == 'cohort start')
  testthat::expect_true(x[[1]]$tarStartOffset == 1)
  testthat::expect_true(x[[1]]$tarEndWith == 'cohort start')
  testthat::expect_true(x[[1]]$tarEndOffset == 2)
  testthat::expect_true(x[[2]]$tarStartWith == 'cohort end')
  testthat::expect_true(x[[2]]$tarStartOffset == 90)
  testthat::expect_true(x[[2]]$tarEndWith == 'cohort end')
  testthat::expect_true(x[[2]]$tarEndOffset == 91)
  testthat::expect_true(x[[3]]$tarStartWith == 'cohort start')
  testthat::expect_true(x[[3]]$tarStartOffset == 30)
  testthat::expect_true(x[[3]]$tarEndWith == 'cohort start')
  testthat::expect_true(x[[3]]$tarEndOffset == 23)
})

test_that("getTars", {
  
  x <- addTar(
    data = data.frame(
      madeUp = c(1,2,'dfdf'),
      riskWindowStart = c('cohort start', 'cohort end', 'cohort start'),
      startAnchor = c(1,90,30),
      riskWindowEnd = c('cohort start', 'cohort end', 'cohort start'),
      endAnchor = c(2,91,23)
    )
  )
  
  testthat::expect_true(x[1] == 'cohort startcohort start12')
  testthat::expect_true(x[2] == 'cohort endcohort end9091')
  testthat::expect_true(x[3] == 'cohort startcohort start3023')
})

test_that("getAnalyses", {
  
  x <- getAnalyses(
    server = conDet$server(),
    username = conDet$user(),
    password = conDet$password(),
    dbms = conDet$dbms,
    schema = schema
  )
  
  testthat::expect_true(sum(colnames(x) %in% c('prefix', 'name')) == 2)
  testthat::expect_true(sum(x$prefix %in% c('cd', 'cg', 'cm', 'sccs', 'plp', 'c', 'ci')) == 7)
  testthat::expect_true(nrow(x) == 7)
})

# TODO finish this
test_that("getDbs", {
  
  x <- OhdsiReportGenerator:::getDbs(
    schema = schema,
    connectionHandler = connectionHandler,
    dbDetails = data.frame(
      CDM_SOURCE_ABBREVIATION = c(
        "eunomia"
      ),
      type = c('synthetic')
  )
  )
  
})

test_that("kableDark", {
result <- kableDark( data = data.frame(a=1,b=4), 
           caption = 'A made up table to demonstrate this function',
           position = 'h')

testthat::expect_is(result, 'knitr_kable')
})
