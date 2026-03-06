select
    cg.cohort_name, 
    cd.target_cohort_id as cohort_definition_id,
    'riskFactors' as type,
    1 as value
    
    from (select distinct target_cohort_id from @schema.@c_table_prefixcohort_details
    where cohort_type in ('Cases')) cd
    inner join 
     @schema.@cg_table_prefixcohort_definition cg
     on cd.target_cohort_id = cg.cohort_definition_id
    ;