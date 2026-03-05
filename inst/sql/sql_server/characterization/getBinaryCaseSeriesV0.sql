SELECT 
 d.CDM_SOURCE_ABBREVIATION as database_name,
 d.database_id,
 target.cohort_name as target_name,
cov.TARGET_COHORT_ID,
outcome.cohort_name as outcome_name,
cov.Outcome_COHORT_ID,
  max(case 
  when cov.cohort_type = 'CasesBefore' then cov.sum_value
  else 0 
  end) as sum_value_before,
  max(case 
  when cov.cohort_type = 'CasesBefore' then cov.average_value
  else 0 
  end) as average_value_before,
  
  max(case 
  when cov.cohort_type = 'CasesBetween' then cov.sum_value
  else 0 
  end) as sum_value_during,
  max(case 
  when cov.cohort_type = 'CasesBetween' then cov.average_value
  else 0 
  end) as average_value_during,
  
    max(case 
  when cov.cohort_type = 'CasesAfter' then cov.sum_value
  else 0 
  end) as sum_value_after,
  max(case 
  when cov.cohort_type = 'CasesAfter' then cov.average_value
  else 0 
  end) as average_value_after,
  
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
          @schema.@c_table_prefixcovariates cov
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
          and cr.analysis_id in (109, 110, 217, 218, 305, 417, 418, 505, 605, 713, 805, 926, 927)
  {@use_min_val}?{and cov.average_value >= @min_val}   
  {@use_concepts}?{and cr.concept_id in (@concept_ids)}
  
  
  GROUP BY
   d.CDM_SOURCE_ABBREVIATION, d.database_id,
 target.cohort_name, cov.TARGET_COHORT_ID,
outcome.cohort_name, cov.Outcome_COHORT_ID,
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