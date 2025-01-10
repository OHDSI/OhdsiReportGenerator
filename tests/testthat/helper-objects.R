# create connection handler for tests to example result database
conDet <- OhdsiReportGenerator:::getExampleConnectionDetails()
connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)

schema <- 'main'
