OhdsiReportGenerator v2.2.0.9999
======================
- fixed bug in SMD formula for binary covariates 
- fixed bug in index breakdown when generating the full report
- edited the estimation template in the full report to remove repeats of the comparison cohort 

OhdsiReportGenerator v2.2.0
======================
- added functions to create indexes for the results database to speed up data fetch
- updated estimation forrest plots
- added plot/table for cohort incidence 
- fixed SCCS result extraction
- added prediction intervals in estimation extraction 
- added nesting id specification when extracting cohort method
- removed presentation generator as it was not being used and was getting outdated (can use a LLM to convert the report to a presentation instead)

OhdsiReportGenerator v2.1.0
======================
- started to move SQL into the inst folder and have SQL version based on the result version
- updated SQL to support Characterization v3, CohortMethod v6 and CohortGenerator v1.1

OhdsiReportGenerator v2.0.2
======================
- fixed odd bug with different TimeAtRisks in prediction
- edited cohort generator queries to work with new and old table column name change
- updated example results to prevent errorReports

OhdsiReportGenerator v2.0.1
======================
- fixed odd bug when generating full report with !!targetId being in the code
- updated prediction queries 

OhdsiReportGenerator v2.0.0
======================
- added new functions to extract prediction results
- added functions to extract cohort details
- added more functions to extract cohort method and self controlled case series results
- added summary report for prediction 

OhdsiReportGenerator v1.1.1
======================
- added skip quarto tests on CRAN if quarto:::find_quarto() errors as it means quarto not installed correctly 
- fixed issue with CM/SCCS if evidence synth tables do not exist
- pass drivers path for connection into generate
- fixing indication in SCCS results
- adding message to risk factors in Characterization to state when there are no results.

OhdsiReportGenerator v1.1.0
======================
- Added full report function generateFullReport() that generates a html file with all the results for a given target, set of outcomes, indications and comparators.
- Added column covariateId to data.frame output when running getCaseBinaryFeatures(), getTargetBinaryFeatures() and processBinaryRiskFactorFeatures()
- Added columns rawSum and rawAverage to getTargetBinaryFeatures() that has the target counts without removing any excluded people who had the outcome during the washout.
- Added time-at-risk columns to output of getCaseContinuousFeatures()
- Added column unblindForEvidenceSynthesis for getCMEstimation()
- Added columns indicationName, indicationId and calibratedOneSidedP to getCmMetaEstimation()
- Added columns indicationName and indicationId to getSccsDiagnosticsData() and getSccsMetaEstimation()
- added new helper functions addTarColumn() and formatBinaryCovariateName()


OhdsiReportGenerator v1.0.1
======================
- Compressed example results sqlite database to save space
- Removed SqlRender dependancy 

OhdsiReportGenerator v1.0.0
======================
- Initial package for generating study reports