SELECT 
 d.cdm_source_abbreviation AS database_name,
 cov.database_id,
 target.cohort_name AS target_name,
 ts.target_id,
 outcome.cohort_name AS outcome_name,
 cs.outcome_id,

 cov.before_count_value AS count_value_before,
 cov.before_min_value AS min_value_before,	
 cov.before_max_value AS max_value_before,	
 cov.before_average_value AS average_value_before,	
 cov.before_standard_deviation AS standard_deviation_before,	
 cov.before_median_value AS median_value_before,	
 cov.before_p_10_value AS p_10_value_before,	
 cov.before_p_25_value AS p_25_value_before,	
 cov.before_p_75_value AS p_75_value_before,
 cov.before_p_90_value AS p_90_value_before,

 cov.during_count_value AS count_value_during,
 cov.during_min_value AS min_value_during,	
 cov.during_max_value AS max_value_during,	
 cov.during_average_value AS average_value_during,	
 cov.during_standard_deviation AS standard_deviation_during,	
 cov.during_median_value AS median_value_during,	
 cov.during_p_10_value AS p_10_value_during,	
 cov.during_p_25_value AS p_25_value_during,	
 cov.during_p_75_value AS p_75_value_during,
 cov.during_p_90_value AS p_90_value_during,

 cov.after_count_value AS count_value_after,
 cov.after_min_value AS min_value_after,	
 cov.after_max_value AS max_value_after,	
 cov.after_average_value AS average_value_after,	
 cov.after_standard_deviation AS standard_deviation_after,	
 cov.after_median_value AS median_value_after,	
 cov.after_p_10_value AS p_10_value_after,	
 cov.after_p_25_value AS p_25_value_after,	
 cov.after_p_75_value AS p_75_value_after,
 cov.after_p_90_value AS p_90_value_after,

 cr.covariate_name, 
 cr.covariate_id, 
 ts.min_prior_observation, 
 ts.limit_to_first_in_n_days,
 cs.outcome_washout_days,
 css.case_post_outcome_duration, 
 css.case_pre_target_duration,
 cs.risk_window_start,
 cs.start_anchor,
 cs.risk_window_end,
 cs.end_anchor

 FROM @schema.@c_table_prefixcase_series_covariates_continuous cov
 INNER JOIN @schema.@c_table_prefixcase_settings cs
 ON cs.database_id = cov.database_id
 AND cs.setting_id = cov.setting_id
 AND cs.characterization_case_id = cov.characterization_case_id
 
 INNER JOIN @schema.@c_table_prefixtarget_settings ts
 ON cs.database_id = ts.database_id
 AND cs.setting_id = ts.setting_id
 AND cs.characterization_target_id = ts.characterization_target_id
 
 INNER JOIN  @schema.@c_table_prefixcovariate_ref cr
 ON cov.setting_id = cr.setting_id
 AND cov.database_id = cr.database_id 
 AND cov.covariate_id = cr.covariate_id
          
 INNER JOIN @schema.@c_table_prefixcase_series_settings css
 ON cov.setting_id = css.setting_id
 
 
 INNER JOIN @schema.@database_table d
 ON cov.database_id = d.database_id
  
 INNER JOIN @schema.@cg_table_prefixcohort_definition target
 ON target.cohort_definition_id = ts.target_id
    
 INNER JOIN @schema.@cg_table_prefixcohort_definition outcome
 ON outcome.cohort_definition_id = cs.outcome_id

 WHERE ts.target_id = @target_id
 AND cs.outcome_id = @outcome_id
 {@use_database}?{AND cov.database_id IN (@database_ids)}
 {@use_risk_window_start}?{AND cs.risk_window_start = @risk_window_start}
 {@use_risk_window_end}?{AND cs.risk_window_end = @risk_window_end}
 {@use_start_anchor}?{AND cs.start_anchor = '@start_anchor'}
 {@use_end_anchor}?{AND cs.end_anchor = '@end_anchor'}
;