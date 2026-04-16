# Extract the database used in the analyses

This function extracts the databases and their information.

## Usage

``` r
getDatabaseDetails(
  connectionHandler,
  schema,
  databaseTable = "database_meta_data"
)
```

## Arguments

- connectionHandler:

  A connection handler that connects to the database and extracts sql
  queries. Create a connection handler via
  \`ResultModelManager::ConnectionHandler\$new()\`.

- schema:

  The result database schema (e.g., 'main' for sqlite)

- databaseTable:

  The name of the table with the database details (default
  'database_meta_data')

## Value

Returns a data.frame with the columns:

- databaseFullName the full name of the database

- databaseName the friendly name of the database

- cdmHolder the license holder of the database

- sourceDescription a description of the database

- sourceDocumentationReference a link to the database information
  document

- cdmEtlReference a link to the ETL document

- sourceReleaseDatethe release date for the source database

- (cdmReleaseDate the release date for the database mapped to the OMOP
  CDM)

- cdmVersion the OMOP CDM version of the database

- cdmVersionConceptId the CDM version concept ID

- vocabularyVersion the database's vocabulary version

- databaseId a unique identifier for the database

- maxObsPeriodEndDate the last observational period end date in the
  database

## Details

Specify the connectionHandler, the schema and the database table name

## Examples

``` r
conDet <- getExampleConnectionDetails()

connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#> Connecting using SQLite driver

ir <- getIncidenceRates(
connectionHandler = connectionHandler, 
schema = 'main'
)
```
