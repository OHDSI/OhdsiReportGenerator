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