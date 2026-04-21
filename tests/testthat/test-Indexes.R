test_that("Characterization indexes", {
  
  # now add indexes
  nullReturn <- createCharacterizationIndexes(
    connectionHandler = connectionHandler, 
    schema = schema, 
    cTablePrefix = 'c_'
  )
  testthat::expect_true(is.null(nullReturn))

  cTargets <- getCharacterizationTargets(
    connectionHandler = connectionHandler, 
    schema = schema, 
    cTablePrefix = 'c_', 
    cgTablePrefix = 'cg_'
  )
  
  testthat::expect_true(nrow(cTargets) >0)
  
})


test_that("Cohort indexes", {
  
  # now add indexes
  nullReturn <- createCohortIndexes(
    connectionHandler = connectionHandler, 
    schema = schema, 
    cgTablePrefix = 'cg_'
  )
  testthat::expect_true(is.null(nullReturn))
  
  ccounts <- getCohortCounts(
    connectionHandler = connectionHandler, 
    schema = schema, 
    cgTablePrefix = 'cg_'
  )
  
  testthat::expect_true(nrow(ccounts) >0)
  
})

test_that("Cohort incidence indexes", {
  
  # now add indexes
  nullReturn <- createIncidenceIndexes(
    connectionHandler = connectionHandler, 
    schema = schema, 
    ciTablePrefix = 'ci_'
  )
  testthat::expect_true(is.null(nullReturn))
  
  cinc <- getIncidenceRates(
    connectionHandler = connectionHandler, 
    schema = schema, 
    ciTablePrefix = 'ci_',
    cgTablePrefix = 'cg_'
  )
  
  testthat::expect_true(nrow(cinc) >0)
  
})



test_that("createSccsIndexes indexes", {
  
  # now add indexes
  nullReturn <- createSccsIndexes(
    connectionHandler = connectionHandler, 
    schema = schema, 
    sccsTablePrefix = 'sccs_'
  )
  testthat::expect_true(is.null(nullReturn))
  
  sccsE <- getSccsEstimation(
    connectionHandler = connectionHandler, 
    schema = schema, 
    sccsTablePrefix = 'sccs_',
    cgTablePrefix = 'cg_'
  )
  
  testthat::expect_true(nrow(sccsE) >0)
  
})

