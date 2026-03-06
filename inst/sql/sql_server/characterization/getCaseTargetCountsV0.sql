select distinct
  targets.database_name,
  targets.database_id,
  target_cohorts.cohort_name as target_name,
  targets.target_id,
  outcome_cohorts.cohort_name as outcome_name,
  targets.outcome_id,
  case when excludes.row_count is NULL then targets.row_count else
  targets.row_count - excludes.row_count end as row_count,
  case when excludes.person_count is NULL then targets.person_count
  when (excludes.person_count < 0 AND targets.person_count > 0) then targets.person_count - FLOOR(ABS(excludes.person_count)/2)
  when targets.person_count < 0 then targets.person_count
  else targets.person_count - excludes.person_count end as person_count,
  targets.person_count as without_excluded_person_count,
  targets.min_prior_observation,
  99999 as limit_to_first_in_n_days,
  targets.outcome_washout_days
  
  from
  
  (select 
  d.CDM_SOURCE_ABBREVIATION as database_name,
  d.database_id,
  cc.target_cohort_ID as target_id,
  s2.outcome_cohort_id as outcome_id,
  cc.row_count,
  cc.person_count,
  cc.min_prior_observation,
  s2.outcome_washout_days

  from 
  @schema.@c_table_prefixcohort_counts cc
  inner join
  @schema.@database_table_name d
  on cc.database_id = d.database_id
  
  inner join
(
select distinct 
tcd.target_cohort_id,
tcd.outcome_cohort_id,
ts.outcome_washout_days

from
@schema.@c_table_prefixsettings ts
inner join
@schema.@c_table_prefixcohort_details tcd
on ts.setting_id = tcd.setting_id
and ts.database_id = tcd.database_id

where tcd.outcome_cohort_id != 0
{@use_target}?{ and tcd.target_cohort_id in (@target_id)}
{@use_outcome}?{ and tcd.outcome_cohort_id in (@outcome_id)}
) s2

on  
cc.target_cohort_id = s2.target_cohort_id

  where 
    cc.COHORT_TYPE in ('Target')
{@use_target}?{ and cc.TARGET_COHORT_ID in (@target_id)}
{@use_database}?{ and cc.database_id in (@database_id)}
    ) targets
    
    left join
 
  (select 
  d.CDM_SOURCE_ABBREVIATION as database_name,
  cc.target_cohort_ID as target_id,
  cc.outcome_cohort_ID as outcome_id,
  cc.row_count as row_count,
  cc.person_count as person_count,
  cc.min_prior_observation,
  cc.outcome_washout_days

  from 
  @schema.@c_table_prefixcohort_counts cc
  inner join
  @schema.@database_table_name d
  on cc.database_id = d.database_id

  where 
  cc.COHORT_TYPE in ('Exclude')
  {@use_target}?{ and cc.TARGET_COHORT_ID in (@target_id)}
  {@use_outcome}?{ and cc.outcome_COHORT_ID in (@outcome_id)}
   
  ) excludes
  
  on targets.database_name = excludes.database_name
  and targets.target_id = excludes.target_id
  and targets.min_prior_observation = excludes.min_prior_observation
  
  inner join @schema.@cg_table_prefixcohort_definition target_cohorts
    on target_cohorts.cohort_definition_id = targets.target_id
    
  left join @schema.@cg_table_prefixcohort_definition outcome_cohorts
    on outcome_cohorts.cohort_definition_id = targets.outcome_id
  
  ;