#' Extract the top N predictors per model
#' @description
#' This function extracts the top N predictors per model from the prediction results tables 
#'
#' @details
#' Specify the connectionHandler, the resultDatabaseSettings and (optionally) any targetIds or outcomeIds to restrict models to
#'
#' @template connectionHandler
#' @template schema
#' @template plpTablePrefix
#' @template cgTablePrefix
#' @template targetIds
#' @template outcomeIds
#' @param numberPredictors the number of predictors per model to return
#' @family Prediction
#' @return
#' Returns a data.frame with the columns: 
#' \itemize{
#'  \item{databaseName the name of the database the model was developed on}
#'  \item{tarStartDay the time-at-risk start day}
#'  \item{tarStartAnchor whether the time-at-risk start is relative to cohort start or end}
#'  \item{tarEndDay the time-at-risk end day}
#'  \item{tarEndAnchor whether the time-at-risk end is relative to cohort start or end}
#'  \item{performanceId a unique identifier for the performance}
#'  \item{covariateId the FeatureExtraction covariate identifier}
#'  \item{covariateName the name of the covariate}
#'  \item{conceptId the covariates corresponding concept or 0}
#'  \item{covariateValue the feature importance or coefficient value}
#'  \item{covariateCount how many people had the covariate}
#'  \item{covariateMean the fraction of the target population with the covariate}
#'  \item{covariateStDev the standard deviation}
#'  \item{withNoOutcomeCovariateCount the number of the target population without the outcome with the covariate}
#'  \item{withNoOutcomeCovariateMean the fraction of the target population without the outcome with the covariate}
#'  \item{withNoOutcomeCovariateStDev the covariate standard deviation of the target population without the outcome}
#'  \item{withOutcomeCovariateCount the number of the target population with the outcome with the covariate}
#'  \item{withOutcomeCovariateMean the fraction of the target population with the outcome with the covariate}
#'  \item{withOutcomeCovariateStDev the covariate standard deviation of the target population with the outcome}
#'  \item{standardizedMeanDiff the standardized mean difference comparing the target population with outcome and without the outcome}
#'  \item{rn the row number showing the covariate rank}
#' }
#'
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' topPreds <- getPredictionTopPredictors(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   targetIds = 1,
#'   outcomeIds = 3
#' )
#' 
getPredictionTopPredictors <- function(
    connectionHandler,
    schema,
    plpTablePrefix = 'plp_',
    cgTablePrefix = 'cg_',
    targetIds = NULL,
    outcomeIds = NULL,
    numberPredictors = 100
){

  # get performance_id - TODO add cohort and outcome names?
  sql <- "
  select * from 
  
  (select d.cdm_source_abbreviation as database_name,
  tars.tar_start_day, tars.tar_start_anchor,
  tars.tar_end_day, tars.tar_end_anchor,
  cov.*,
  ROW_NUMBER() OVER(
  PARTITION BY p.performance_id, d.cdm_source_abbreviation,
  tars.tar_start_day, tars.tar_start_anchor,
  tars.tar_end_day, tars.tar_end_anchor
  ORDER BY ABS(cov.covariate_value) DESC
  ) AS rn
  
  from @schema.@plp_table_prefixmodel_designs md 
  
  inner join @schema.@plp_table_prefixperformances p
  on md.model_design_id = p.model_design_id
  
  inner join @schema.@plp_table_prefixcovariate_summary cov
  on p.performance_id = cov.performance_id
  
  inner join @schema.@plp_table_prefixdatabase_details dd
  on dd.database_id = p.development_database_id
  
  inner join @schema.database_meta_data d
  on d.database_id = dd.database_meta_data_id 
  
  inner join @schema.@plp_table_prefixtars tars
  on tars.tar_id = p.tar_id 
  
  inner join @schema.@plp_table_prefixcohorts t
  on t.cohort_id = md.target_id
  
  -- join to CG table to get target name
  
  inner join @schema.plp_cohorts o
  on o.cohort_id = md.outcome_id
  
  -- join to CG table to get outcome name
  
  {@outcome_restrict | @target_restrict}?{ where }
  {@outcome_restrict}?{o.cohort_definition_id in (@outcome_ids)}
  {@outcome_restrict & @target_restrict}?{ and } 
  {@target_restrict}?{t.cohort_definition_id in (@target_ids)}
  
  ) temp
  
  where rn <= @number_predictors;"
  
  result <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    plp_table_prefix = plpTablePrefix,
    #cg_table_prefix = cgTablePrefix,
    outcome_restrict = !is.null(outcomeIds),
    outcome_ids = paste0(outcomeIds, collapse = ','),
    target_restrict = !is.null(targetIds),
    target_ids = paste0(targetIds, collapse = ','),
    number_predictors = numberPredictors
  )
  
  return(result)
}

#' Extract a complete set of cohorts used in the prediction results
#' @description
#' This function extracts the target and outcome cohorts used to develop any model in the results
#'
#' @details
#' Specify the connectionHandler, the resultDatabaseSettings and any targetIds or outcomeIds to restrict models to
#'
#' @template connectionHandler
#' @template schema
#' @template plpTablePrefix
#' @template cgTablePrefix
#' @family Prediction
#' @return
#' Returns a data.frame with the columns: 
#' \itemize{
#'  \item{cohortId the cohort definition ID}
#'  \item{cohortName the name of the cohort}
#'  \item{type whether the cohort was used as a target or outcome cohort}
#'}
#'
#' @export
#' @examples 
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' predCohorts <- getPredictionCohorts(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getPredictionCohorts <- function(
    connectionHandler,
    schema,
    plpTablePrefix = 'plp_',
    cgTablePrefix = 'cg_'
){
  
  allres <- c()
  for(type in c('target','outcome')){
    sql <- "SELECT distinct 
    cohorts.cohort_id, 
    cohorts.cohort_name,
    '@type' as type

       FROM
          @schema.@plp_table_prefixmodel_designs as model_designs
          inner join
        (SELECT c.cohort_id, cd.cohort_name FROM @schema.@plp_table_prefixcohorts c
        inner join @schema.@cg_table_prefixcohort_definition cd
        on c.cohort_definition_id = cd.cohort_definition_id
        ) AS cohorts
        ON model_designs.@type_id = cohorts.cohort_id
        ;"
    
    result <- connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      plp_table_prefix = plpTablePrefix,
      cg_table_prefix = cgTablePrefix,
      type = type
    )
    
    allres <- rbind(allres, result)
    
  }
  
  allres <- unique(allres)

  return(allres)
}

#' Extract the model designs and aggregate performances for the prediction results
#' @description
#' This function extracts the model design settings and min/max/mean AUROC values of the models developed
#' using the model design across databases
#'
#' @details
#' Specify the connectionHandler, the resultDatabaseSettings and (optionally) any targetIds or outcomeIds to restrict model designs to
#'
#' @template connectionHandler
#' @template schema
#' @template plpTablePrefix
#' @template cgTablePrefix
#' @template targetIds
#' @template outcomeIds
#' @family Prediction
#' @return
#' Returns a data.frame with the columns:
#' \itemize{ 
#'  \item{modelDesignId a unique identifier in the database for the model design}
#'  \item{modelType the type of classifier or surival model}
#'  \item{developmentTargetId a unique identifier for the development target ID}
#'  \item{developmentTargetName the name of the development target cohort}
#'  \item{developmentTargetJson the json of the target cohort}
#'  \item{developmentOutcomeId a unique identifier for the development outcome ID}
#'  \item{developmentOutcomeName the name of the development outcome cohort}
#'  \item{timeAtRisk the time at risk string}
#'  \item{developmentOutcomeJson the json of the outcome cohort}
#'  \item{covariateSettingsJson the covariate settings json}
#'  \item{populationSettingsJson the population settings json}
#'  \item{tidyCovariatesSettingsJson the tidy covariate settings json}
#'  \item{plpDataSettingsJson the plp data extraction settings json}
#'  \item{featureEngineeringSettingsJson the feature engineering settings json}
#'  \item{splitSettingsJson the split settings json}
#'  \item{sampleSettingsJson the sample settings json}
#'  \item{minAuroc the min AUROC value of models developed using the model design across databases}
#'  \item{meanAuroc the mean AUROC value of models developed using the model design across databases}
#'  \item{maxAuroc the max AUROC value of models developed using the model design across databases}
#'  \item{noDiagnosticDatabases the number of databases where the model design diagnostics were generated}
#'  \item{noDevelopmentDatabases the number of databases where the model design was used to develop models}
#'  \item{noValidationDatabases the number of databases where the models developed using the model design was externally validated}
#' }
#' 
#' @export
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' modDesign <- getPredictionModelDesigns(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getPredictionModelDesigns <- function(
    connectionHandler,
    schema,
    plpTablePrefix = 'plp_',
    cgTablePrefix = 'cg_',
    targetIds = NULL,
    outcomeIds = NULL
){
  
  sql <- "SELECT
          model_designs.model_design_id,
          model_settings.model_type model_type,
          targets.cohort_definition_id AS development_target_id,
          targets.cohort_name AS development_target_name,
          targets.json AS development_target_json,
          outcomes.cohort_definition_id AS development_outcome_id,
          outcomes.cohort_name AS development_outcome_name,
          outcomes.json AS development_outcome_json,
          tars.tar_start_day,
          tars.tar_start_anchor,
          tars.tar_end_day,
          tars.tar_end_anchor,
          covariate_settings.covariate_settings_json,
          population_settings.population_settings_json,
          tidy_covariates_settings.tidy_covariates_settings_json,
          plp_data_settings.plp_data_settings_json,
          feature_engineering_settings.feature_engineering_settings_json,
          split_settings.split_settings_json,
          sample_settings.sample_settings_json,
          MIN(p.value) AS min_auroc,
          AVG(p.value) AS mean_auroc,
          MAX(p.value) AS max_auroc,
          COUNT(distinct diag.database_id) AS no_diagnostic_databases,
          COUNT(distinct d.database_id) AS no_development_databases,
          COUNT(distinct v.database_id) AS no_validation_databases

       FROM
          @schema.@plp_table_prefixmodel_designs as model_designs

          inner join
          @schema.@plp_table_prefixmodel_settings as model_settings
          on model_designs.model_setting_id = model_settings.model_setting_id

          inner join
          @schema.@plp_table_prefixcovariate_settings as covariate_settings
          on model_designs.covariate_setting_id = covariate_settings.covariate_setting_id

          inner join
          @schema.@plp_table_prefixpopulation_settings as population_settings
          on model_designs.population_setting_id = population_settings.population_setting_id

          inner join
          @schema.@plp_table_prefixtidy_covariates_settings as tidy_covariates_settings
          on model_designs.tidy_covariates_setting_id = tidy_covariates_settings.tidy_covariates_setting_id

          inner join
          @schema.@plp_table_prefixsample_settings as sample_settings
          on model_designs.sample_setting_id = sample_settings.sample_setting_id

          inner join
          @schema.@plp_table_prefixfeature_engineering_settings as feature_engineering_settings
          on model_designs.feature_engineering_setting_id = feature_engineering_settings.feature_engineering_setting_id

          inner join
          @schema.@plp_table_prefixsplit_settings as split_settings
          on model_designs.split_setting_id = split_settings.split_setting_id

          inner join
          @schema.@plp_table_prefixplp_data_settings as plp_data_settings
          on model_designs.plp_data_setting_id = plp_data_settings.plp_data_setting_id

          LEFT JOIN
          @schema.@plp_table_prefixperformances AS results

           on model_designs.model_design_id = results.model_design_id

        LEFT JOIN
        (select * from @schema.@plp_table_prefixEVALUATION_STATISTICS
        where EVALUATION = 'Test' and METRIC = 'AUROC') p
           on p.performance_id = results.performance_id

        LEFT JOIN
        (SELECT c.cohort_id, cd.cohort_name, cd.json, cd.cohort_definition_id
        FROM @schema.@plp_table_prefixcohorts c
        inner join @schema.@cg_table_prefixcohort_definition cd
        on c.cohort_definition_id = cd.cohort_definition_id
        ) AS targets
        ON model_designs.target_id = targets.cohort_id

        LEFT JOIN
        (SELECT c.cohort_id, cd.cohort_name, cd.json, cd.cohort_definition_id
        FROM @schema.@plp_table_prefixcohorts c
        inner join @schema.@cg_table_prefixcohort_definition cd
        on c.cohort_definition_id = cd.cohort_definition_id
        ) AS outcomes
        ON model_designs.outcome_id = outcomes.cohort_id

        LEFT JOIN @schema.@plp_table_prefixtars AS tars
        ON model_designs.tar_id = tars.tar_id

        LEFT JOIN @schema.@plp_table_prefixdatabase_details AS d
        ON results.development_database_id = d.database_id

        LEFT JOIN @schema.@plp_table_prefixdatabase_details AS v
        ON results.validation_database_id = v.database_id

        LEFT JOIN @schema.@plp_table_prefixdiagnostics AS diag
        ON results.development_database_id = diag.database_id

        where 1 == 1
        {@target_restrict} ? { and  targets.cohort_definition_id in (@target_ids) }
        {@outcome_restrict} ? { and  outcomes.cohort_definition_id in (@outcome_ids) }


        GROUP BY
        model_designs.model_design_id,
        model_settings.model_type,
        targets.cohort_definition_id,
        targets.cohort_name,
        targets.json,
        outcomes.cohort_definition_id,
        outcomes.cohort_name,
        outcomes.json,
        tars.tar_start_day,
        tars.tar_start_anchor,
        tars.tar_end_day,
        tars.tar_end_anchor,
        covariate_settings.covariate_settings_json,
        population_settings.population_settings_json,
        tidy_covariates_settings.tidy_covariates_settings_json,
        feature_engineering_settings.feature_engineering_settings_json,
        split_settings.split_settings_json,
        plp_data_settings.plp_data_settings_json,
        sample_settings.sample_settings_json;"
  
  summaryTable <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    plp_table_prefix = plpTablePrefix,
    cg_table_prefix = cgTablePrefix,
    target_restrict = !is.null(targetIds),
    target_ids = paste(targetIds, collapse = ','),
    outcome_restrict = !is.null(outcomeIds),
    outcome_ids = paste(outcomeIds, collapse = ',')
  )
  
  
  summaryTable <- summaryTable %>%
    dplyr::mutate(timeAtRisk = paste0('( ',.data$tarStartAnchor, '+', .data$tarStartDay, ' ) - ',
                                      '( ',.data$tarEndAnchor, '+', .data$tarEndDay, ' )'
    )) %>%
    dplyr::select(-"tarStartAnchor", - "tarStartDay", -"tarEndAnchor", -"tarEndDay") %>%
    dplyr::relocate("timeAtRisk", .after = "developmentOutcomeName")
  
  return(summaryTable)
  
}

# can be used per modelDesignId to explore specific models
# or per modelDesignId and developmentDatabaseId to find validations

#' Extract the model performances 
#' @description
#' This function extracts the model performances
#'
#' @details
#' Specify the connectionHandler, the resultDatabaseSettings and (optionally) a modelDesignId and/or developmentDatabaseId to restrict models to
#'
#' @template connectionHandler
#' @template schema
#' @template plpTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param databaseTablePrefix A prefix to the database table, either '' or 'plp_'
#' @param modelDesignId The identifier for a model design  to restrict results to
#' @param developmentDatabaseId The identifier for the development database to restrict results to
#' @family Prediction
#' @return
#' Returns a data.frame with the columns:
#' \itemize{  
#'  \item{performanceId the unique identifier for the performance}
#'  \item{modelDesignId the unique identifier for the model design}
#'  \item{developmentDatabaseId the unique identifier for the database used to develop the model}
#'  \item{validationDatabaseId the unique identifier for the database used to validate the model}
#'  \item{developmentTargetId the unique cohort id for the development target population}
#'  \item{developmentTargetName the name for the development target population}
#'  \item{developmentOutcomeId the unique cohort id for the development outcome}
#'  \item{developmentOutcomeName the name for the development outcome}
#'  \item{developmentDatabase the name for the database used to develop the model}
#'  \item{validationDatabase the name for the database used to validate the model}
#'  \item{validationTargetName the name for the validation target population}
#'  \item{validationOutcomeName the name for the validation outcome}
#'  \item{timeStamp the date/time when the analysis occurred}
#'  \item{auroc the test/validation AUROC value for the model}
#'  \item{auroc95lb the test/validation lower bound of the 95 percent CI AUROC value for the model}
#'  \item{auroc95ub the test/validation upper bound of the 95 percent CI AUROC value for the model}
#'  \item{calibrationInLarge the test/validation calibration in the large value for the model}
#'  \item{eStatistic the test/validation calibration e-statistic value for the model}
#'  \item{brierScore the test/validation brier value for the model}
#'  \item{auprc the test/validation discrimination AUPRC value for the model}
#'  \item{populationSize the test/validation population size used to develop the model}
#'  \item{outcomeCount the test/validation outcome count used to develop the model}
#'  \item{evalPercent the percentage of the development data used as the test set}
#'  \item{outcomePercent the outcome percent in the development data}
#'  \item{validationTimeAtRisk time at risk for the validation}
#'  \item{predictionResultType development or validation}
#'  
#'}
#' 
#' @export
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' perf <- getPredictionPerformances(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getPredictionPerformances <- function(
    connectionHandler,
    schema,
    plpTablePrefix = 'plp_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    databaseTablePrefix = '',
    modelDesignId = NULL,
    developmentDatabaseId = NULL
){
  
  sql <- "SELECT distinct
       results.performance_id,
       results.model_design_id,
       results.development_database_id,
       results.validation_database_id,
       devtargets.cohort_definition_id AS development_target_id,
       devtargets.cohort_name AS development_target_name,
       devoutcomes.cohort_definition_id AS development_outcome_id,
       devoutcomes.cohort_name AS development_outcome_name,
       d.database_acronym AS development_database,
       v.database_acronym AS validation_database,
       targets.cohort_name AS validation_target_name,
       outcomes.cohort_name AS validation_outcome_name,
       results.execution_date_time AS time_stamp,
       tars.tar_start_day,
       tars.tar_start_anchor,
       tars.tar_end_day,
       tars.tar_end_anchor,
       aucResult.auc AS auroc,
       auclbResult.auclb AS auroc_95lb,
       aucubResult.aucub AS auroc_95ub,
       calibration_in_large_result.calibration_in_large AS calibration_in_large,
       estat.value as e_statistic,
       brier.value as brier_score,
       auprcResult.auprc AS auprc,
       nResult.population_size,
       oResult.outcome_count,
       nTest.test_size*100.0/nResult.population_size AS eval_percent,
       oResult.outcome_count*100.0/nResult.population_size AS outcome_percent,
       results.model_development AS model_development_flag

       FROM

       (select * from @schema.@plp_table_prefixperformances
        {@model_design_restrict | @development_database_id_restrict} ?{ where }
        {@model_design_restrict} ? {model_design_id = @model_design_id}
        {@model_design_restrict & @development_database_id_restrict} ?{ and }
        {@development_database_id_restrict} ? {development_database_id = @development_database_id}
       )

       AS results

    inner join @schema.@plp_table_prefixmodel_designs as model_designs
    on model_designs.model_design_id = results.model_design_id

    LEFT JOIN
        (SELECT c.cohort_id, c.cohort_definition_id, cd.cohort_name FROM @schema.@plp_table_prefixcohorts c
        inner join @schema.@cg_table_prefixcohort_definition cd
        on c.cohort_definition_id = cd.cohort_definition_id
        ) AS devtargets ON model_designs.target_id = devtargets.cohort_id

        LEFT JOIN
        (SELECT c.cohort_id, c.cohort_definition_id, cd.cohort_name FROM @schema.@plp_table_prefixcohorts c
        inner join @schema.@cg_table_prefixcohort_definition cd
        on c.cohort_definition_id = cd.cohort_definition_id
        ) AS targets ON results.target_id = targets.cohort_id

        LEFT JOIN
        (SELECT c.cohort_id, c.cohort_definition_id, cd.cohort_name FROM @schema.@plp_table_prefixcohorts c
        inner join @schema.@cg_table_prefixcohort_definition cd
        on c.cohort_definition_id = cd.cohort_definition_id
        ) AS outcomes ON results.outcome_id = outcomes.cohort_id

        LEFT JOIN
        (SELECT c.cohort_id, c.cohort_definition_id, cd.cohort_name FROM @schema.@plp_table_prefixcohorts c
        inner join @schema.@cg_table_prefixcohort_definition cd
        on c.cohort_definition_id = cd.cohort_definition_id
        ) AS devoutcomes ON model_designs.target_id = devoutcomes.cohort_id


        LEFT JOIN
        (select dd.database_id, md.cdm_source_abbreviation database_acronym
         from @schema.@database_table_prefix@database_table md inner join
         @schema.@plp_table_prefixdatabase_details dd
         on md.database_id = dd.database_meta_data_id
        ) AS d ON results.development_database_id = d.database_id

        LEFT JOIN
        (select dd.database_id, md.cdm_source_abbreviation database_acronym
         from @schema.@database_table_prefix@database_table md inner join
         @schema.@plp_table_prefixdatabase_details dd
         on md.database_id = dd.database_meta_data_id
         ) AS v ON results.validation_database_id = v.database_id

        LEFT JOIN @schema.@plp_table_prefixtars AS tars ON results.tar_id = tars.tar_id
        LEFT JOIN (SELECT performance_id, value AS auc FROM @schema.@plp_table_prefixevaluation_statistics where metric = 'AUROC' and evaluation in ('Test','Validation') ) AS aucResult ON results.performance_id = aucResult.performance_id
        LEFT JOIN (SELECT performance_id, value AS auprc FROM @schema.@plp_table_prefixevaluation_statistics where metric = 'AUPRC' and evaluation in ('Test','Validation') ) AS auprcResult ON results.performance_id = auprcResult.performance_id
        LEFT JOIN (SELECT performance_id, sum(value) AS population_size FROM @schema.@plp_table_prefixevaluation_statistics where metric = 'populationSize' and evaluation in ('Train','Test','Validation') group by performance_id) AS nResult ON results.performance_id = nResult.performance_id
        LEFT JOIN (SELECT performance_id, sum(value) AS outcome_count FROM @schema.@plp_table_prefixevaluation_statistics where metric = 'outcomeCount' and evaluation in ('Train','Test','Validation') group by performance_id) AS oResult ON results.performance_id = oResult.performance_id
        
        LEFT JOIN (select performance_id, value from @schema.@plp_table_prefixEVALUATION_STATISTICS where EVALUATION in ('Test','Validation') and METRIC = 'brier score scaled') AS brier
        on brier.performance_id = results.performance_id  
        
        LEFT JOIN (select performance_id, value from @schema.@plp_table_prefixEVALUATION_STATISTICS where EVALUATION in ('Test','Validation') and METRIC = 'Eavg') AS estat
        on estat.performance_id = results.performance_id   
        
        LEFT JOIN (SELECT performance_id, value AS test_size FROM @schema.@plp_table_prefixevaluation_statistics where metric = 'populationSize' and evaluation in ('Test', 'Validation') ) AS nTest ON results.performance_id = nTest.performance_id

        LEFT JOIN (SELECT performance_id, value AS auclb FROM @schema.@plp_table_prefixevaluation_statistics where metric = '95% lower AUROC' and evaluation in ('Test','Validation') ) AS auclbResult ON results.performance_id = auclbResult.performance_id
        LEFT JOIN (SELECT performance_id, value AS aucub FROM @schema.@plp_table_prefixevaluation_statistics where metric = '95% upper AUROC' and evaluation in ('Test','Validation') ) AS aucubResult ON results.performance_id = aucubResult.performance_id
        LEFT JOIN (SELECT performance_id, value AS calibration_in_large FROM @schema.@plp_table_prefixevaluation_statistics where metric = 'calibrationInLarge intercept' and evaluation in ('Test','Validation') ) AS calibration_in_large_result ON results.performance_id = calibration_in_large_result.performance_id

    ;"
  
  
  summaryTable <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    plp_table_prefix = plpTablePrefix,
    model_design_id = modelDesignId,
    model_design_restrict = !is.null(modelDesignId),
    development_database_id = developmentDatabaseId,
    development_database_id_restrict = !is.null(developmentDatabaseId),
    database_table_prefix = databaseTablePrefix,
    database_table = databaseTable,
    cg_table_prefix = cgTablePrefix
  )
  
  summaryTable <- summaryTable %>%
    dplyr::mutate(validationTimeAtRisk = paste0('( ',.data$tarStartAnchor, '+', .data$tarStartDay, ' ) - ',
                                                '( ',.data$tarEndAnchor, '+', .data$tarEndDay, ' )'
    )) %>%
    dplyr::select(-"tarStartAnchor", - "tarStartDay", -"tarEndAnchor", -"tarEndDay")
  
  summaryTable$validationTargetName <- trimws(summaryTable$validationTargetName )
  summaryTable$validationOutcomeName <- trimws(summaryTable$validationOutcomeName)
  summaryTable$validationTargetName  <- as.factor(summaryTable$validationTargetName )
  summaryTable$validationOutcomeName <- as.factor(summaryTable$validationOutcomeName)
  
  summaryTable$predictionResultType <- ifelse(summaryTable$modelDevelopmentFlag == 1, 'Development', 'Validation')
  
  summaryTable <- summaryTable %>%
    dplyr::select(-"modelDevelopmentFlag")
  
  return(summaryTable)
}

#' Extract the model design diagnostics for a specific development database
#' @description
#' This function extracts the PROBAST diagnostics 
#'
#' @details
#' Specify the connectionHandler, the resultDatabaseSettings and (optionally) a modelDesignId and threshold1_2 a threshold value to use for the PROBAST 1.2 
#'
#' @template connectionHandler
#' @template schema
#' @template plpTablePrefix
#' @template cgTablePrefix
#' @template databaseTable
#' @param databaseTablePrefix The prefix for the database table either '' or 'plp_'
#' @param modelDesignId The identifier for a model design  to restrict results to
#' @param threshold1_2 A threshold for probast 1.2
#' @family Prediction
#' @return
#' Returns a data.frame with the columns:
#' \itemize{   
#'  \item{modelDesignId the unique identifier for the model design}
#'  \item{diagnosticId the unique identifier for diagnostic result}
#'  \item{developmentDatabaseName the name for the database used to develop the model}
#'  \item{developmentTargetName the name for the development target population}
#'  \item{developmentOutcomeName the name for the development outcome}
#'  \item{probast1_1 Were appropriate data sources used, e.g., cohort, RCT, or nested case-control study data?}
#'  \item{probast1_2 Were all inclusions and exclusions of paticipants appropriate?}
#'  \item{probast2_1 Were predictors defined and assessed in a similar way for all participants?}
#'  \item{probast2_2 Were predictors assessments made without knowledge of outcome data?}
#'  \item{probast2_3 All all predictors available at the time the model is intended to be used?}
#'  \item{probast3_4 Was the outcome defined and determined in a similar way for all participants?}
#'  \item{probast3_6 Was the time interval between predictor assessment and outcome determination appropriate?}
#'  \item{probast4_1 Were there a reasonable number of participants with the outcome?}
#'  }
#' 
#' @export
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' diag <- getPredictionDiagnostics(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#' 
getPredictionDiagnostics <- function(
    connectionHandler,
    schema,
    plpTablePrefix = 'plp_',
    cgTablePrefix = 'cg_',
    databaseTable = 'database_meta_data',
    databaseTablePrefix = '',
    modelDesignId = NULL,
    threshold1_2 = 0.9
){
  
  sql <- "SELECT distinct
          design.MODEL_DESIGN_ID,
          diagnostics.diagnostic_id,
          database.DATABASE_NAME as development_DATABASE_NAME,
          cohortT.COHORT_NAME development_target_name,
          cohortO.COHORT_NAME development_outcome_name,
          summary.PROBAST_ID,
          summary.RESULT_VALUE

          from
          (select * from @schema.@plp_table_prefixDIAGNOSTICS
          {@model_design_restrict} ? {where MODEL_DESIGN_ID = @model_design_id}
          ) as diagnostics
          inner join
          @schema.@plp_table_prefixMODEL_DESIGNS design
          on diagnostics.MODEL_DESIGN_ID = design.MODEL_DESIGN_ID

          inner join
          @schema.@plp_table_prefixDIAGNOSTIC_SUMMARY summary
          on diagnostics.DIAGNOSTIC_ID = summary.DIAGNOSTIC_ID

          inner join
          (select dd.database_id, md.cdm_source_abbreviation as database_name
                   from @schema.@database_table_prefix@database_table md inner join
                   @schema.@plp_table_prefixdatabase_details dd
                   on md.database_id = dd.database_meta_data_id) as database
          on database.database_id = diagnostics.database_id

         inner join
          @schema.@plp_table_prefixCOHORTS cohortT
         on cohortT.cohort_id = design.target_id

          inner join
          @schema.@plp_table_prefixCOHORTS cohortO
          on cohortO.cohort_id = design.outcome_id;
  "
  
  summaryTable <- connectionHandler$queryDb(
    sql = sql,
    schema = schema,
    plp_table_prefix = plpTablePrefix,
    model_design_id = modelDesignId,
    model_design_restrict = !is.null(modelDesignId),
    database_table_prefix = databaseTablePrefix,
    database_table = databaseTable
  )
  
  if(nrow(summaryTable)==0){
    message("No diagnostic summary")
    return(NULL)
  }
  
  summary <- summaryTable %>%
    dplyr::mutate(
      probastId = paste0('probast',gsub('\\.','_',.data$probastId))
    ) %>%
    dplyr::arrange(.data$probastId) %>%
    tidyr::pivot_wider(
      id_cols = c(
        'modelDesignId',
        'diagnosticId',
        'developmentDatabaseName',
        'developmentTargetName',
        'developmentOutcomeName'
      ),
      names_from = 'probastId',
      values_from = 'resultValue'
    )
  
  summary$probast1_2 <- ifelse(
    apply(summary[,grep('probast1_2_', colnames(summary))] > threshold1_2, 1, sum) == length(grep('probast1_2_', colnames(summary))),
    'Pass',
    'Fail'
  )
  
  summary <- summary[, - grep('probast1_2_', colnames(summary))] %>%
    dplyr::relocate("probast1_2", .after = "probast1_1")
  
  return(summary)
}


# get results table for specific performance
#' Extract specific results table
#' @description
#' This function extracts the specified table
#'
#' @details
#' Specify the connectionHandler, the resultDatabaseSettings, the table of interest and (optionally) a performanceId to filter to 
#'
#' @template connectionHandler
#' @template schema
#' @template plpTablePrefix
#' @param table The table to extract
#' @param performanceId (optional) restrict to the input performanceId
#' @family Prediction
#' @return
#' Returns a data.frame with the specified table
#' 
#' @export
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' attrition <- getPredictionPerformanceTable(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   table = 'attrition'
#' )
#' 
getPredictionPerformanceTable <- function(
    connectionHandler,
    schema,
    plpTablePrefix = 'plp_',
    table = 'attrition',
    performanceId = NULL
){
  
  if(!is.null(performanceId)){
    
    sql <- "SELECT * FROM @schema.@plp_table_prefix@table
     WHERE performance_id = @performance_id;"
    
    result  <- connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      table = table,
      performance_id = performanceId,
      plp_table_prefix = plpTablePrefix
    )
    
    return(result)
  }
  
}

#' Extract specific diagnostic table
#' @description
#' This function extracts the specified diagnostic table
#'
#' @details
#' Specify the connectionHandler, the resultDatabaseSettings, the table of interest and (optionally) a diagnosticId to filter to 
#'
#' @template connectionHandler
#' @template schema
#' @template plpTablePrefix
#' @param table The table to extract
#' @param diagnosticId (optional) restrict to the input diagnosticId
#' @family Prediction
#' @return
#' Returns a data.frame with the specified table
#' 
#' @export
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' diagPred <- getPredictionDiagnosticTable(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main',
#'   table = 'diagnostic_predictors'
#' )
#' 
getPredictionDiagnosticTable <- function(
    connectionHandler,
    schema,
    plpTablePrefix = 'plp_',
    table = 'diagnostic_participants', # 'diagnostic_participants','diagnostic_predictors','diagnostic_outcomes'
    diagnosticId = NULL
){
  
  if(!is.null(diagnosticId)){
    
    sql <- "SELECT * FROM @schema.@plp_table_prefix@table
     WHERE diagnostic_id = @diagnostic_id;"
    
    result  <- connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      table = table,
      diagnostic_id = diagnosticId,
      plp_table_prefix = plpTablePrefix
    )
    
    if('design' %in% colnames(result)){
      result$parameter <- unlist(
        lapply(
          result$design,
          function(x){strsplit(x, ':')[[1]][1]}
        )
      )
      result$paramvalue <- unlist(
        lapply(
          result$design,
          function(x){gsub(' ', '', strsplit(x, ':')[[1]][2])}
        )
      )
      
      result <- result %>% dplyr::select(-"design")
    }
    
    return(result)
  }
  
}


#===== model extraction

#' Extract hyper parameters details
#' @description
#' This function extracts the hyper parameters details
#'
#' @details
#' Specify the connectionHandler, the resultDatabaseSettings, the modelDesignId and the databaseId
#'
#' @template connectionHandler
#' @template schema
#' @template plpTablePrefix
#' @param modelDesignId The identifier for a model design  to restrict to
#' @param databaseId The identifier for the development database to restrict  to
#' @family Prediction
#' @return
#' Returns a data.frame with the columns:
#' \itemize{
#'  \item{metric the hyperparameter optimization metric}
#'  \item{fold the fold in cross validation}
#'  \item{value the metric value for the fold with the specified hyperparameter combination}
#'  } 
#'  plus columns for all the hyperparameters and their values
#' 
#' 
#' @export
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' hyperParams <- getPredictionHyperParamSearch(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#'
getPredictionHyperParamSearch <- function(
    connectionHandler,
    schema,
    plpTablePrefix = 'plp_',
    modelDesignId = NULL,
    databaseId = NULL
){
  
  if(!is.null(modelDesignId) & !is.null(databaseId)){
    
    sql <- "SELECT train_details
            FROM @schema.@plp_table_prefixmodels
            WHERE database_id = @database_id
            and model_design_id = @model_design_id;"
    
    models <- connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      database_id = databaseId,
      model_design_id = modelDesignId,
      plp_table_prefix = plpTablePrefix
    )
    trainDetails <- ParallelLogger::convertJsonToSettings(models$trainDetails)
    
    return(trainDetails$hyperParamSearch)
  } else{
    warning('Please enter a modelDesignId and databaseId')
  }
}

#' Extract model interception (for logistic regression)
#' @description
#' This function extracts the interception value
#'
#' @details
#' Specify the connectionHandler, the resultDatabaseSettings, the modelDesignId and the databaseId
#'
#' @template connectionHandler
#' @template schema
#' @template plpTablePrefix
#' @param modelDesignId The identifier for a model design  to restrict to
#' @param databaseId The identifier for the development database to restrict  to
#' @family Prediction
#' @return
#' Returns a single value corresponding to the model intercept or NULL if not a logistic regression model
#' 
#' @export
#' @examples
#' conDet <- getExampleConnectionDetails()
#' 
#' connectionHandler <- ResultModelManager::ConnectionHandler$new(conDet)
#' 
#' intercepts <- getPredictionIntercept(
#'   connectionHandler = connectionHandler, 
#'   schema = 'main'
#' )
#'
getPredictionIntercept <- function(
    connectionHandler,
    schema,
    plpTablePrefix = 'plp_',
    modelDesignId = NULL,
    databaseId = NULL
){
  
  if(!is.null(modelDesignId) & !is.null(databaseId)){
    sql <- "SELECT intercept
          FROM @schema.@plp_table_prefixmodels
          WHERE database_id = @database_id
          and model_design_id = @model_design_id"
    
    models <- connectionHandler$queryDb(
      sql = sql,
      schema = schema,
      database_id = databaseId,
      model_design_id = modelDesignId,
      plp_table_prefix = plpTablePrefix
    )
    
    intercept <- models$intercept
    
    if(is.null(intercept)){
      return(0)
    }
    return(intercept)
  } else{
    warning('Please enter a modelDesignId and databaseId')
  }
}
