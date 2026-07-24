SELECT 
          d.CDM_SOURCE_ABBREVIATION as database_name,
          d.database_id,
          target_cohorts.cohort_name as target_name,
          tte.target_cohort_definition_id as characterization_target_id,
          tte.target_cohort_definition_id as target_id,
          NULL as limit_to_first_in_n_days,
          NULL as min_prior_observation,
          NULL as nesting_cohort_id,
          NULL as  nesting_name,
          NULL as min_age,
          NULL as max_age,
          NULL as study_start,
          NULL as study_end,
          NULL as gender_concept_ids,
          outcome_cohorts.cohort_name as outcome_name,
          tte.outcome_cohort_definition_id as outcome_id,
          tte.outcome_type,
          tte.target_outcome_type,
          tte.time_to_event,
          tte.num_events,
          tte.time_scale
           
          FROM @schema.@c_table_prefixTIME_TO_EVENT tte
          inner join @schema.@database_table d
          on tte.database_id = d.database_id

           inner join @schema.@cg_table_prefixcohort_definition target_cohorts
           on target_cohorts.cohort_definition_id = tte.TARGET_COHORT_DEFINITION_ID

           inner join @schema.@cg_table_prefixcohort_definition outcome_cohorts
           on outcome_cohorts.cohort_definition_id = tte.OUTCOME_COHORT_DEFINITION_ID
           
          where 1 = 1
          {@use_characterization_target}?{ and tte.TARGET_COHORT_DEFINITION_ID in (@characterization_target_id)}
          {@use_outcome}?{ and tte.OUTCOME_COHORT_DEFINITION_ID in (@outcome_id)}

           
          ;