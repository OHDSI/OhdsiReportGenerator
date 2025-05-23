% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/EstimationQueries.R
\name{getCmMetaEstimation}
\alias{getCmMetaEstimation}
\title{Extract the cohort method meta analysis results}
\usage{
getCmMetaEstimation(
  connectionHandler,
  schema,
  cmTablePrefix = "cm_",
  cgTablePrefix = "cg_",
  esTablePrefix = "es_",
  targetIds = NULL,
  outcomeIds = NULL,
  comparatorIds = NULL
)
}
\arguments{
\item{connectionHandler}{A connection handler that connects to the database and extracts sql queries.  Create a connection handler via `ResultModelManager::ConnectionHandler$new()`.}

\item{schema}{The result database schema (e.g., 'main' for sqlite)}

\item{cmTablePrefix}{The prefix used for the cohort method results tables}

\item{cgTablePrefix}{The prefix used for the cohort generator results tables}

\item{esTablePrefix}{The prefix used for the evidence synthesis results tables}

\item{targetIds}{A vector of integers corresponding to the target cohort IDs}

\item{outcomeIds}{A vector of integers corresponding to the outcome cohort IDs}

\item{comparatorIds}{A vector of integers corresponding to the comparator cohort IDs}
}
\value{
Returns a data.frame with the columns:
\itemize{
 \item{databaseName the name of the database}
 \item{analysisId the analysis unique identifier}
 \item{description a description of the analysis}
 \item{targetName the target cohort name}
 \item{targetId the target cohort unique identifier}
 \item{comparatorName the comparator cohort name}
 \item{comparatorId the comparator cohort unique identifier}
 \item{outcomeName the outcome name}
 \item{outcomeId the outcome cohort unique identifier}
 \item{calibratedRr the calibrated relative risk}
 \item{calibratedRrCi95Lb the calibrated relative risk 95 percent confidence interval lower bound}
 \item{calibratedRrCi95Ub the calibrated relative risk 95 percent confidence interval upper bound}
 \item{calibratedP the two sided calibrated p value}
 \item{calibratedOneSidedP the one sided calibrated p value}
 \item{calibratedLogRr the calibrated relative risk logged}
 \item{calibratedSeLogRr the standard error of the calibrated relative risk logged}
 
 \item{targetSubjects the number of people in the target cohort across included database}
 \item{comparatorSubjects the number of people in the comparator cohort across included database}
 \item{targetDays the total number of days at risk across the target cohort people across included database}
 \item{comparatorDays the total number of days at risk across the comparator cohort people across included database}
 \item{targetOutcomes the total number of outcomes occuring during the time at risk for the target cohort people across included database}
 \item{comparatorOutcomes the total number of outcomes occuring during the time at risk for the comparator cohort people across included database}
 
 \item{nDatabases the number of databases included}
 }
}
\description{
This function extracts any meta analysis estimation results for cohort method.
}
\details{
Specify the connectionHandler, the schema and the target/comparator/outcome cohort IDs
}
\examples{
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)

cmMeta <- getCmMetaEstimation(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetIds = 1,
  outcomeIds = 3
)

}
\seealso{
Other Estimation: 
\code{\link{getCMEstimation}()},
\code{\link{getCmDiagnosticsData}()},
\code{\link{getSccsDiagnosticsData}()},
\code{\link{getSccsEstimation}()},
\code{\link{getSccsMetaEstimation}()},
\code{\link{plotCmEstimates}()},
\code{\link{plotSccsEstimates}()}
}
\concept{Estimation}
