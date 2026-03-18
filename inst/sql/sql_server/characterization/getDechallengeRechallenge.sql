SELECT 
          d.CDM_SOURCE_ABBREVIATION as database_name,
          d.database_id,
          target_cohorts.cohort_name as target_name,
          dr.target_cohort_definition_id as target_id,
          outcome_cohorts.cohort_name as outcome_name,
          dr.outcome_cohort_definition_id as outcome_id,
          dr.dechallenge_stop_interval,
          dr.dechallenge_evaluation_window,
          dr.num_exposure_eras,
          dr.num_persons_exposed,
          dr.num_cases,
          dr.dechallenge_attempt,
          dr.dechallenge_fail,
          dr.dechallenge_success,
          dr.rechallenge_attempt,
          dr.rechallenge_fail,
          dr.rechallenge_success,
          dr.pct_dechallenge_attempt,
          dr.pct_dechallenge_fail,
          dr.pct_dechallenge_success,
          dr.pct_rechallenge_attempt,
          dr.pct_rechallenge_fail,
          dr.pct_rechallenge_success
          
          FROM @schema.@c_table_prefixDECHALLENGE_RECHALLENGE dr 
          inner join @schema.@database_table d
          on dr.database_id = d.database_id
          
           inner join @schema.@cg_table_prefixcohort_definition target_cohorts
           on target_cohorts.cohort_definition_id = dr.TARGET_COHORT_DEFINITION_ID

           inner join @schema.@cg_table_prefixcohort_definition outcome_cohorts
           on outcome_cohorts.cohort_definition_id = dr.OUTCOME_COHORT_DEFINITION_ID
           
          where 1 = 1
          {@use_target}?{ and dr.TARGET_COHORT_DEFINITION_ID in (@target_id)}
          {@use_outcome}?{ and dr.OUTCOME_COHORT_DEFINITION_ID in (@outcome_id)}

           
          ;