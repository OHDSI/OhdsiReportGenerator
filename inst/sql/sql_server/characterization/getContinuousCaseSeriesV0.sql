SELECT 
 d.CDM_SOURCE_ABBREVIATION as database_name,
 cov.database_id,
 target.cohort_name as target_name,
cov.TARGET_COHORT_ID,
outcome.cohort_name as outcome_name,
cov.Outcome_COHORT_ID,
  max(case when cov.cohort_type = 'CasesBefore' then cov.count_value
  else 0 end) as count_value_before,
  max(case when cov.cohort_type = 'CasesBefore' then cov.min_value
  else 0 end) as min_value_before,
  max(case when cov.cohort_type = 'CasesBefore' then cov.max_value
  else 0 end) as max_value_before,
  max(case when cov.cohort_type = 'CasesBefore' then cov.average_value
  else 0 end) as average_value_before,
  max(case when cov.cohort_type = 'CasesBefore' then cov.standard_deviation
  else 0 end) as standard_deviation_before,
  max(case when cov.cohort_type = 'CasesBefore' then cov.median_value
  else 0 end) as median_value_before,
  max(case when cov.cohort_type = 'CasesBefore' then cov.p_10_value
  else 0 end) as p_10_value_before,
  max(case when cov.cohort_type = 'CasesBefore' then cov.p_25_value
  else 0 end) as p_25_value_before,
  max(case when cov.cohort_type = 'CasesBefore' then cov.p_75_value
  else 0 end) as p_75_value_before,
  max(case when cov.cohort_type = 'CasesBefore' then cov.p_90_value
  else 0 end) as p_90_value_before,
  
  max(case when cov.cohort_type = 'CasesBetween' then cov.count_value
  else 0 end) as count_value_during,
  max(case when cov.cohort_type = 'CasesBetween' then cov.min_value
  else 0 end) as min_value_during,
  max(case when cov.cohort_type = 'CasesBetween' then cov.max_value
  else 0 end) as max_value_during,
  max(case when cov.cohort_type = 'CasesBetween' then cov.average_value
  else 0 end) as average_value_during,
  max(case when cov.cohort_type = 'CasesBetween' then cov.standard_deviation
  else 0 end) as standard_deviation_during,
  max(case when cov.cohort_type = 'CasesBetween' then cov.median_value
  else 0 end) as median_value_during,
  max(case when cov.cohort_type = 'CasesBetween' then cov.p_10_value
  else 0 end) as p_10_value_during,
  max(case when cov.cohort_type = 'CasesBetween' then cov.p_25_value
  else 0 end) as p_25_value_during,
  max(case when cov.cohort_type = 'CasesBetween' then cov.p_75_value
  else 0 end) as p_75_value_during,
  max(case when cov.cohort_type = 'CasesBetween' then cov.p_90_value
  else 0 end) as p_90_value_during,
  
  max(case when cov.cohort_type = 'CasesAfter' then cov.count_value
  else 0 end) as count_value_after,
  max(case when cov.cohort_type = 'CasesAfter' then cov.min_value
  else 0 end) as min_value_after,
  max(case when cov.cohort_type = 'CasesAfter' then cov.max_value
  else 0 end) as max_value_after,
  max(case when cov.cohort_type = 'CasesAfter' then cov.average_value
  else 0 end) as average_value_after,
  max(case when cov.cohort_type = 'CasesAfter' then cov.standard_deviation
  else 0 end) as standard_deviation_after,
  max(case when cov.cohort_type = 'CasesAfter' then cov.median_value
  else 0 end) as median_value_after,
  max(case when cov.cohort_type = 'CasesAfter' then cov.p_10_value
  else 0 end) as p_10_value_after,
  max(case when cov.cohort_type = 'CasesAfter' then cov.p_25_value
  else 0 end) as p_25_value_after,
  max(case when cov.cohort_type = 'CasesAfter' then cov.p_75_value
  else 0 end) as p_75_value_after,
  max(case when cov.cohort_type = 'CasesAfter' then cov.p_90_value
  else 0 end) as p_90_value_after,
  
  cr.covariate_name, 
  cr.covariate_id, 
  s.min_prior_observation, 
  99999 as limit_to_first_in_n_days,
  s.outcome_washout_days,
  s.case_post_outcome_duration, 
  s.case_pre_target_duration,
  s.risk_window_start,
  s.start_anchor,
  s.risk_window_end,
  s.end_anchor

          from
          @schema.@c_table_prefixcovariates_continuous cov
          inner join  @schema.@c_table_prefixcovariate_ref cr
          on cov.setting_id = cr.setting_id and 
          cov.database_id = cr.database_id and 
          cov.covariate_id = cr.covariate_id
          
          inner join @schema.@c_table_prefixsettings s
          on cov.setting_id = s.setting_id
          and cov.database_id = s.database_id
          
            inner join
  @schema.@database_table d
  on 
  cov.database_id = d.database_id
  
    inner join 
  @schema.@cg_table_prefixcohort_definition target
  on 
  target.cohort_definition_id = cov.target_cohort_ID
    
  inner join 
  @schema.@cg_table_prefixcohort_definition outcome
  on 
  outcome.cohort_definition_id = cov.outcome_cohort_ID

          where cov.target_cohort_id = @target_id
          and cov.outcome_cohort_id = @outcome_id
  {@use_database}?{and cov.database_id in (@database_ids)}
  {@use_risk_window_start}?{and s.risk_window_start = @risk_window_start}
  {@use_risk_window_end}?{and s.risk_window_end = @risk_window_end}
  {@use_start_anchor}?{and s.start_anchor = '@start_anchor'}
  {@use_end_anchor}?{and s.end_anchor = '@end_anchor'}
  and cov.cohort_type in ('CasesBetween','CasesAfter','CasesBefore')
          
  GROUP BY
   d.CDM_SOURCE_ABBREVIATION,
 cov.database_id,
 target.cohort_name,
cov.TARGET_COHORT_ID,
outcome.cohort_name,
cov.Outcome_COHORT_ID,
  cr.covariate_name, 
  cr.covariate_id, 
  s.min_prior_observation, 
  s.outcome_washout_days,
  s.case_post_outcome_duration, 
  s.case_pre_target_duration,
  s.risk_window_start,
  s.start_anchor,
  s.risk_window_end,
  s.end_anchor
          
          
;