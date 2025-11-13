# Package index

## Database Extraction

These functions can be used to extract details about the databases.

- [`getDatabaseDetails()`](getDatabaseDetails.md) : Extract the database
  used in the analyses

## Cohort Extraction

These functions can be used to extract analyses cohort details.

- [`getCohortCounts()`](getCohortCounts.md) : Extract the cohort counds
- [`getCohortDefinitions()`](getCohortDefinitions.md) : Extract the
  cohort definition details
- [`getCohortInclusionRules()`](getCohortInclusionRules.md) : Extract
  the cohort inclusion rules
- [`getCohortInclusionStats()`](getCohortInclusionStats.md) : Extract
  the cohort inclusion stats
- [`getCohortInclusionSummary()`](getCohortInclusionSummary.md) :
  Extract the cohort inclusion summary
- [`getCohortMeta()`](getCohortMeta.md) : Extract the cohort meta
- [`getCohortSubsetDefinitions()`](getCohortSubsetDefinitions.md) :
  Extract the cohort subset definition details
- [`processCohorts()`](processCohorts.md) : Extract the cohort parents
  and children cohorts (cohorts derieved from the parent cohort)

## Characterization Extractions and Plots

These functions can be used to extract results from characterization and
cohort incidence analyses and plot results.

- [`getBinaryCaseSeries()`](getBinaryCaseSeries.md) : A function to
  extract case series characterization results
- [`getBinaryRiskFactors()`](getBinaryRiskFactors.md) : A function to
  extract non-case and case binary characterization results
- [`getCaseBinaryFeatures()`](getCaseBinaryFeatures.md) : Extract
  aggregate statistics of binary feature analysis IDs of interest for
  cases
- [`getCaseContinuousFeatures()`](getCaseContinuousFeatures.md) :
  Extract aggregate statistics of continuous feature analysis IDs of
  interest for targets
- [`getCaseCounts()`](getCaseCounts.md) : Extract the outcome cohort
  counts result
- [`getCaseTargetBinaryFeatures()`](getCaseTargetBinaryFeatures.md) :
  Extract aggregate statistics of binary feature analysis IDs of
  interest for targets
- [`getCaseTargetCounts()`](getCaseTargetCounts.md) : Extract the target
  cohort counts result
- [`getCharacterizationCohortBinary()`](getCharacterizationCohortBinary.md)
  : A function to extract cohort aggregate binary feature
  characterization results
- [`getCharacterizationCohortContinuous()`](getCharacterizationCohortContinuous.md)
  : A function to extract cohort aggregate continuous feature
  characterization results
- [`getCharacterizationDemographics()`](getCharacterizationDemographics.md)
  : Extract the binary age groups for the cases and targets
- [`getCharacterizationOutcomes()`](getCharacterizationOutcomes.md) : A
  function to extract the outcomes found in characterization
- [`getCharacterizationTargets()`](getCharacterizationTargets.md) : A
  function to extarct the targets found in characterization
- [`getContinuousCaseSeries()`](getContinuousCaseSeries.md) : A function
  to extract case series continuous feature characterization results
- [`getContinuousRiskFactors()`](getContinuousRiskFactors.md) : A
  function to extract non-case and case continuous characterization
  results
- [`getDechallengeRechallenge()`](getDechallengeRechallenge.md) :
  Extract the dechallenge rechallenge results
- [`getDechallengeRechallengeFails()`](getDechallengeRechallengeFails.md)
  : A function to extract the failed dechallenge-rechallenge cases
- [`getIncidenceOutcomes()`](getIncidenceOutcomes.md) : A function to
  extract the outcomes found in incidence
- [`getIncidenceRates()`](getIncidenceRates.md) : Extract the cohort
  incidence result
- [`getIncidenceTargets()`](getIncidenceTargets.md) : A function to
  extract the targets found in incidence
- [`getTargetBinaryFeatures()`](getTargetBinaryFeatures.md) : Extract
  aggregate statistics of binary feature analysis IDs of interest for
  targets (ignoring excluding people with prior outcome)
- [`getTargetContinuousFeatures()`](getTargetContinuousFeatures.md) :
  Extract aggregate statistics of continuous feature analysis IDs of
  interest for targets
- [`getTimeToEvent()`](getTimeToEvent.md) : Extract the time to event
  result
- [`plotAgeDistributions()`](plotAgeDistributions.md) : Plots the age
  distributions using the binary age groups
- [`plotSexDistributions()`](plotSexDistributions.md) : Plots the sex
  distributions using the sex features

## Estimation Extractions and Plots

These functions can be used to extract results from estimation studies
and plot results.

- [`getCMEstimation()`](getCMEstimation.md) : Extract the cohort method
  results
- [`getCmDiagnosticsData()`](getCmDiagnosticsData.md) : Extract the
  cohort method diagostic results
- [`getCmMetaEstimation()`](getCmMetaEstimation.md) : Extract the cohort
  method meta analysis results
- [`getCmNegativeControlEstimates()`](getCmNegativeControlEstimates.md)
  : Extract the cohort method negative controls
- [`getCmOutcomes()`](getCmOutcomes.md) : A function to extract the
  outcomes found in cohort method
- [`getCmPropensityModel()`](getCmPropensityModel.md) : Extract the
  cohort method model
- [`getCmTable()`](getCmTable.md) : Extract the cohort method table
  specified
- [`getCmTargets()`](getCmTargets.md) : A function to extract the
  targets found in cohort method
- [`getSccsDiagnosticsData()`](getSccsDiagnosticsData.md) : Extract the
  self controlled case series (sccs) diagostic results
- [`getSccsEstimation()`](getSccsEstimation.md) : Extract the self
  controlled case series (sccs) results
- [`getSccsMetaEstimation()`](getSccsMetaEstimation.md) : Extract the
  self controlled case series (sccs) meta analysis results
- [`getSccsModel()`](getSccsModel.md) : Extract the SCCS model table
- [`getSccsNegativeControlEstimates()`](getSccsNegativeControlEstimates.md)
  : Extract the SCCS negative controls
- [`getSccsOutcomes()`](getSccsOutcomes.md) : A function to extract the
  outcomes found in self controlled case series
- [`getSccsTable()`](getSccsTable.md) : Extract the SCCS table specified
- [`getSccsTargets()`](getSccsTargets.md) : A function to extract the
  targets found in self controlled case series
- [`getSccsTimeToEvent()`](getSccsTimeToEvent.md) : Extract the SCCS
  time-to-event
- [`plotCmEstimates()`](plotCmEstimates.md) : Plots the cohort method
  results for one analysis
- [`plotSccsEstimates()`](plotSccsEstimates.md) : Plots the self
  controlled case series results for one analysis

## Prediction Extractions and Plots

These functions can be used to extract results from prediction studies
and plot results.

- [`getFullPredictionPerformances()`](getFullPredictionPerformances.md)
  : Extract the model performances per evaluation
- [`getPredictionAggregateTopPredictors()`](getPredictionAggregateTopPredictors.md)
  : Extract the top N predictors across a set of models
- [`getPredictionCohorts()`](getPredictionCohorts.md) : Extract a
  complete set of cohorts used in the prediction results
- [`getPredictionCovariates()`](getPredictionCovariates.md) : Extract
  covariate summary details
- [`getPredictionDiagnosticTable()`](getPredictionDiagnosticTable.md) :
  Extract specific diagnostic table
- [`getPredictionDiagnostics()`](getPredictionDiagnostics.md) : Extract
  the model design diagnostics for a specific development database
- [`getPredictionHyperParamSearch()`](getPredictionHyperParamSearch.md)
  : Extract hyper parameters details
- [`getPredictionIntercept()`](getPredictionIntercept.md) : Extract
  model interception (for logistic regression)
- [`getPredictionLift()`](getPredictionLift.md) : Extract model lift at
  given model sensitivity
- [`getPredictionModelDesigns()`](getPredictionModelDesigns.md) :
  Extract the model designs from the prediction results
- [`getPredictionOutcomes()`](getPredictionOutcomes.md) : A function to
  extract the outcomes found in prediction
- [`getPredictionPerformanceTable()`](getPredictionPerformanceTable.md)
  : Extract specific results table
- [`getPredictionPerformances()`](getPredictionPerformances.md) :
  Extract the model performances
- [`getPredictionTargets()`](getPredictionTargets.md) : A function to
  extarct the targets found in prediction
- [`getPredictionTopPredictors()`](getPredictionTopPredictors.md) :
  Extract the top N predictors per model

## Reporting

These functions can be used to generate reports using quarto templates.

- [`createPredictionReport()`](createPredictionReport.md) :
  createPredictionReport
- [`generateFullReport()`](generateFullReport.md) : generateFullReport
- [`generatePresentation()`](generatePresentation.md) :
  generatePresentation
- [`generatePresentationMultiple()`](generatePresentationMultiple.md) :
  generatePresentationMultiple
- [`generateSummaryPredictionReport()`](generateSummaryPredictionReport.md)
  : generateSummaryPredictionReport

## Helpers

These functions are used to help result extraction.

- [`addTarColumn()`](addTarColumn.md) : addTarColumn
- [`formatBinaryCovariateName()`](formatBinaryCovariateName.md) :
  formatBinaryCovariateName
- [`getExampleConnectionDetails()`](getExampleConnectionDetails.md) :
  create a connection detail for an example OHDSI results database
- [`getOutcomeTable()`](getOutcomeTable.md) : Extract the outcome
  cohorts and where they are used in the analyses.
- [`getTargetTable()`](getTargetTable.md) : Extract the target cohorts
  and where they are used in the analyses.
- [`kableDark()`](kableDark.md) : output a nicely formatted html table
- [`printReactable()`](printReactable.md) : prints a reactable in a
  quarto document
- [`removeSpaces()`](removeSpaces.md) : removeSpaces

## OhdsiReportGenerator

A package for extracting analyses results and generating reports.

- [`OhdsiReportGenerator-package`](OhdsiReportGenerator.md)
  [`OhdsiReportGenerator`](OhdsiReportGenerator.md) :
  OhdsiReportGenerator
