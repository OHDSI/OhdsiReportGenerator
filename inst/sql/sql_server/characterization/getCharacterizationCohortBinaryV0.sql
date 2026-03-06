select  
          ref.covariate_name,
          ref.covariate_id,
          s.min_prior_observation,
          99999 as limit_to_first_in_n_days,
          cov.target_cohort_id as cohort_id,
          cov.database_id,
          cov.sum_value,
          cov.average_value
          from   
    @schema.@c_table_prefixCOVARIATES cov 
    inner join 
    @schema.@c_table_prefixcovariate_ref ref
    on cov.covariate_id = ref.covariate_id
    and cov.setting_id = ref.setting_id
    and cov.database_id = ref.database_id
    inner join 
    @schema.@c_table_prefixsettings s
    on s.database_id = cov.database_id
    and s.setting_id = cov.setting_id
    
    where 
    cov.cohort_type = 'Target'
    {@use_targets}?{AND cov.target_cohort_id in (@target_ids) }
    {@use_databases}?{AND cov.database_id in (@database_ids)}
    AND abs(cov.average_value) >= @min_threshold;