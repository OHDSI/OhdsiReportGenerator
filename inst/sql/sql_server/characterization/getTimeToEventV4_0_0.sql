SELECT 
          d.CDM_SOURCE_ABBREVIATION as database_name,
          d.database_id,
          tte.characterization_target_id,
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
          tte.outcome_cohort_definition_id as outcome_id,
          tte.outcome_type,
          tte.target_outcome_type,
          tte.time_to_event,
          tte.num_events,
          tte.time_scale
           
          FROM @schema.@c_table_prefixTIME_TO_EVENT tte
          
          INNER JOIN 
          @schema.@c_table_prefixtarget_settings ts
          
          ON tte.characterization_target_id = ts.characterization_target_id
          AND tte.database_id = ts.database_id
          
          inner join @schema.@database_table d
          on tte.database_id = d.database_id

           inner join @schema.@cg_table_prefixcohort_definition target_cohorts
           on target_cohorts.cohort_definition_id = ts.TARGET_ID

           inner join @schema.@cg_table_prefixcohort_definition outcome_cohorts
           on outcome_cohorts.cohort_definition_id = tte.OUTCOME_COHORT_DEFINITION_ID
           
           LEFT join @schema.@cg_table_prefixcohort_definition nesting_cohorts
           on nesting_cohorts.cohort_definition_id = ts.nesting_cohort_id
           
          where 1 = 1
          {@use_characterization_target}?{ and tte.characterization_TARGET_ID in (@characterization_target_id)}
          {@use_outcome}?{ and tte.OUTCOME_COHORT_DEFINITION_ID in (@outcome_id)}

           
          ;