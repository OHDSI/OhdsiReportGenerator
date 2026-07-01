SELECT 
          d.CDM_SOURCE_ABBREVIATION as database_name,
          d.database_id,
          dr.characterization_target_id,
          target_cohorts.cohort_name as target_name,
          ts.target_id as target_id,
          ts.limit_to_first_in_n_days,
          ts.min_prior_observation,
          ts.nesting_cohort_id,
          nesting_cohorts.cohort_name as nesting_name,
          ts.min_age,
          ts.max_age,
          ts.study_start,
          ts.study_end,
          ts.gender_concept_ids,
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
          
          INNER JOIN @schema.@c_table_prefixtarget_settings ts
          ON dr.characterization_target_id = ts.characterization_target_id
          AND dr.database_id = ts.database_id
          
          INNER JOIN @schema.@database_table d
          ON dr.database_id = d.database_id
          
          INNER JOIN @schema.@cg_table_prefixcohort_definition target_cohorts
          ON target_cohorts.cohort_definition_id = ts.TARGET_ID

          INNER JOIN @schema.@cg_table_prefixcohort_definition outcome_cohorts
          ON outcome_cohorts.cohort_definition_id = dr.OUTCOME_COHORT_DEFINITION_ID
          
          LEFT JOIN @schema.@cg_table_prefixcohort_definition nesting_cohorts
          ON nesting_cohorts.cohort_definition_id = ts.nesting_cohort_id
           
          where 1 = 1
          {@use_characterization_target}?{ and dr.characterization_TARGET_ID in (@characterization_target_id)}
          {@use_outcome}?{ and dr.OUTCOME_COHORT_DEFINITION_ID in (@outcome_id)}

           
          ;