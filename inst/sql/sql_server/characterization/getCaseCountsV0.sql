select 
  d.cdm_source_abbreviation as database_name,
  d.database_id,
  target_cohorts.cohort_name as target_name,
  cc.target_cohort_ID as target_id,
  outcome_cohorts.cohort_name as outcome_name,
  cc.outcome_cohort_ID as outcome_id,
  cc.row_count,
  cc.person_count,
  cc.min_prior_observation,
  99999 as limit_to_first_in_n_days,
  cc.outcome_washout_days,
  cc.risk_window_start,
  cc.risk_window_end,
  cc.start_anchor,
  cc.end_anchor

  from 
  
  @schema.@c_table_prefixcohort_counts cc
  inner join
  @schema.@database_table d
  on cc.database_id = d.database_id

  inner join 
  @schema.@cg_table_prefixcohort_definition target_cohorts
  on target_cohorts.cohort_definition_id = cc.target_cohort_ID
    
  inner join 
  @schema.@cg_table_prefixcohort_definition outcome_cohorts
  on outcome_cohorts.cohort_definition_id = cc.outcome_cohort_ID
  
    where 
    cc.COHORT_TYPE in ('Cases')
    {@use_target}?{ and cc.TARGET_COHORT_ID in (@target_id)}
  {@use_outcome}?{ and cc.OUTCOME_COHORT_ID in (@outcome_id)}
  {@use_database}?{ and d.database_id in (@database_id)}
  
  {@use_risk_window_start}?{ and cc.RISK_WINDOW_START in (@risk_window_start)}  
  {@use_risk_window_end}?{ and cc.RISK_WINDOW_END in (@risk_window_end)}
  {@use_start_anchor}?{ and cc.START_ANCHOR in (@start_anchor)}
  {@use_end_anchor}?{ and cc.END_ANCHOR in (@end_anchor)}