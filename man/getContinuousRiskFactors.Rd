% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CharacterzationQueries.R
\name{getContinuousRiskFactors}
\alias{getContinuousRiskFactors}
\title{A function to extract non-case and case continuous characterization results}
\usage{
getContinuousRiskFactors(
  connectionHandler,
  schema,
  cTablePrefix = "c_",
  cgTablePrefix = "cg_",
  databaseTable = "database_meta_data",
  targetId = NULL,
  outcomeId = NULL,
  analysisIds = NULL
)
}
\arguments{
\item{connectionHandler}{A connection handler that connects to the database and extracts sql queries.  Create a connection handler via `ResultModelManager::ConnectionHandler$new()`.}

\item{schema}{The result database schema (e.g., 'main' for sqlite)}

\item{cTablePrefix}{The prefix used for the characterization results tables}

\item{cgTablePrefix}{The prefix used for the cohort generator results tables}

\item{databaseTable}{The name of the table with the database details (default 'database_meta_data')}

\item{targetId}{An integer corresponding to the target cohort ID}

\item{outcomeId}{Am integer corresponding to the outcome cohort ID}

\item{analysisIds}{The feature extraction analysis ID of interest (e.g., 201 is condition)}
}
\value{
A data.frame with the characterization results for the cases and non-cases
}
\description{
A function to extract non-case and case continuous characterization results
}
\details{
Specify the connectionHandler, the schema and the target/outcome cohort IDs
}
\examples{
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)

rf <- getContinuousRiskFactors(
  connectionHandler = connectionHandler, 
  schema = 'main',
  targetId = 1, 
  outcomeId = 3
)

}
\seealso{
Other Characterization: 
\code{\link{getBinaryCaseSeries}()},
\code{\link{getBinaryRiskFactors}()},
\code{\link{getCaseBinaryFeatures}()},
\code{\link{getCaseContinuousFeatures}()},
\code{\link{getCaseCounts}()},
\code{\link{getCharacterizationDemographics}()},
\code{\link{getContinuousCaseSeries}()},
\code{\link{getDechallengeRechallenge}()},
\code{\link{getIncidenceRates}()},
\code{\link{getTargetBinaryFeatures}()},
\code{\link{getTargetContinuousFeatures}()},
\code{\link{getTargetCounts}()},
\code{\link{getTimeToEvent}()},
\code{\link{plotAgeDistributions}()},
\code{\link{plotSexDistributions}()}
}
\concept{Characterization}
