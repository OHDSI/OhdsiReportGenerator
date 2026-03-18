select 
    d.cdm_source_abbreviation as database_name, 
    d.database_id,
    cg1.cohort_name as target_name,
    i.target_cohort_definition_id as target_id,
    cg2.cohort_name as outcome_name,
    i.outcome_cohort_definition_id as outcome_id, 
    
    i.clean_window,
    i.subgroup_name,
    i.age_group_name,
    i.gender_name,
    i.start_year,
    i.tar_start_with,
    i.tar_start_offset,
    i.tar_end_with,
    i.tar_end_offset,
    
    i.persons_at_risk_pe,
    i.persons_at_risk,
    i.person_days_pe,
    i.person_days,
    i.person_outcomes_pe,
    i.person_outcomes,
    i.outcomes_pe,
    i.outcomes,
    i.incidence_proportion_p100p,
    i.incidence_rate_p100py
    
    from 
    (select od.outcome_cohort_definition_id, od.clean_window, agd.age_group_name, 
    tad.tar_start_with, tad.tar_start_offset, tad.tar_end_with, tad.tar_end_offset,
    sd.subgroup_name, i.*
  from @schema.@ci_table_prefixINCIDENCE_SUMMARY i
  join @schema.@ci_table_prefixOUTCOME_DEF 
  od on i.outcome_id = od.outcome_id
    and i.ref_id = od.ref_id
  join @schema.@ci_table_prefixTAR_DEF tad on i.tar_id = tad.tar_id
    and i.ref_id = tad.ref_id
  join @schema.@ci_table_prefixSUBGROUP_DEF sd on i.subgroup_id = sd.subgroup_id
    and i.ref_id = sd.ref_id
  left join @schema.@ci_table_prefixAGE_GROUP_DEF agd on i.age_group_id = agd.age_group_id
    and i.ref_id = agd.ref_id
 ) i
    inner join @schema.@database_table_name d
    on d.database_id = i.database_id
    
    inner join @schema.@cg_table_prefixcohort_definition cg1 
    on cg1.cohort_definition_id = i.target_cohort_definition_id
    
    inner join @schema.@cg_table_prefixcohort_definition cg2
    on cg2.cohort_definition_id = i.outcome_cohort_definition_id
    
    where 
    1 = 1
    {@use_target}?{ and target_cohort_definition_id in (@target_id)}
    {@use_outcome}?{ and outcome_cohort_definition_id in (@outcome_id)}
    ;