# create connection handler for tests to example result database
conDet <- OhdsiReportGenerator:::getExampleConnectionDetails()
connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)

schema <- 'main'

# CRAN failed when find_quarto() errored, so only run quarto if this
# does not fail
quartoInstalled <- tryCatch({quarto:::find_quarto()}, error = function(e) return(""))
skipQuarto <- quartoInstalled == ""
