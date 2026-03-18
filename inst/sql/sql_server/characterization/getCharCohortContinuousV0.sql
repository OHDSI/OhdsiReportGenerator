select  
          cov.target_cohort_id as cohort_id,
          --cd.cohort_name,
          d.CDM_SOURCE_ABBREVIATION as database_name,
          ref.covariate_name, 
          s.min_prior_observation,
          99999 AS limit_to_first_in_n_days,
          cov.*
          
          from   
    @schema.@c_table_prefixCOVARIATES_continuous cov 
    
    inner join 
    @schema.@c_table_prefixcovariate_ref ref
    on cov.covariate_id = ref.covariate_id
    and cov.setting_id = ref.setting_id
    and cov.database_id = ref.database_id
    
    inner join
    @schema.@c_table_prefixsettings s 
    on cov.setting_id = s.setting_id
    and cov.database_id = s.database_id
    
    inner join 
    @schema.@database_meta_table d 
    on s.database_id = d.database_id
    
    where cov.cohort_type = 'Target' 
    {@use_targets}?{AND cov.target_cohort_id in (@target_ids)}
    {@use_databases}?{AND cov.database_id in (@database_ids)}