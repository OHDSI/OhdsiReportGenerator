select 
d.CDM_SOURCE_ABBREVIATION as database_name,
t.database_id,
target.cohort_name as target_name,
t.TARGET_COHORT_ID,
outcome.cohort_name as outcome_name,
t.Outcome_COHORT_ID,
t.min_prior_observation,
t.outcome_washout_days,
t.covariate_id,
t.covariate_name,
case when e.sum_value is NULL then t.sum_value
when (e.sum_value < 0 AND t.sum_value > 0) then t.sum_value - ABS(e.sum_value)/2 
when t.sum_value < 0 then t.sum_value
else t.sum_value - e.sum_value end as sum_value,
t.sum_value as raw_sum,
t.average_value as raw_average
 
FROM 

(select 
c.database_id,
cd.TARGET_COHORT_ID,
s2.Outcome_COHORT_ID,
s.min_prior_observation,
s2.outcome_washout_days,
coi.covariate_id,
coi.covariate_name,
c.sum_value,
c.average_value

from @schema.@c_table_prefixCOVARIATES c
 inner join 
  {@use_analysis}?{
(select * from @schema.@c_table_prefixCOVARIATE_REF 
  where analysis_id in (@analysis_ids))
  }:{
  @schema.@c_table_prefixCOVARIATE_REF  
  } coi

on 
c.database_id = coi.database_id and
c.setting_id = coi.setting_id and
c.covariate_id = coi.covariate_id

inner join
@schema.@c_table_prefixCOHORT_DETAILS cd

on cd.TARGET_COHORT_ID = c.TARGET_COHORT_ID
and cd.OUTCOME_COHORT_ID = c.OUTCOME_COHORT_ID
and cd.COHORT_TYPE = c.COHORT_TYPE
and cd.database_id = c.database_id 
and cd.setting_id = c.setting_id 

inner join @schema.@c_table_prefixsettings s
on s.setting_id = c.setting_id
and s.database_id = c.database_id

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
on cd.target_cohort_id = s2.target_cohort_id

where 
cd.COHORT_TYPE = 'Target'
{@use_target}?{ and c.TARGET_COHORT_ID in (@target_id)}
{@use_database}?{ and c.database_id in (@database_id)}
) t

left join

( select 
  c.database_id,
  cd.TARGET_COHORT_ID,
  cd.Outcome_COHORT_ID,
  s.min_prior_observation,
  s.outcome_washout_days,
  coi.covariate_id,
  coi.covariate_name,
  c.sum_value
  
  from 
  @schema.@c_table_prefixCOHORT_DETAILS cd
  
  inner join 
  @schema.@c_table_prefixCOVARIATES c
  on 
  cd.TARGET_COHORT_ID = c.TARGET_COHORT_ID
  and cd.OUTCOME_COHORT_ID = c.OUTCOME_COHORT_ID
  and cd.COHORT_TYPE = c.COHORT_TYPE
  and cd.database_id = c.database_id 
  and cd.setting_id = c.setting_id 
  
  inner join
{@use_analysis}?{
(select * from @schema.@c_table_prefixCOVARIATE_REF 
  where analysis_id in (@analysis_ids))
  }:{
  @schema.@c_table_prefixCOVARIATE_REF  
  } coi
  on 
  c.database_id = coi.database_id
  and c.setting_id = coi.setting_id
  and c.covariate_id = coi.covariate_id
  
  inner join 
  @schema.@c_table_prefixsettings s
  on 
  s.setting_id = c.setting_id
  and s.database_id = c.database_id
  
  where 
  cd.COHORT_TYPE = 'Exclude'
  {@use_target}?{ and c.TARGET_COHORT_ID in (@target_id)}
  {@use_outcome}?{ and c.OUTCOME_COHORT_ID in (@outcome_id)}
) e

on 
t.database_id = e.database_id 
and t.TARGET_COHORT_ID = e.TARGET_COHORT_ID
and t.outcome_COHORT_ID = e.outcome_COHORT_ID
and t.min_prior_observation = e.min_prior_observation
and t.outcome_washout_days = e.outcome_washout_days
and t.covariate_name = e.covariate_name
and t.covariate_id = e.covariate_id

  inner join
  @schema.@database_table d
  on 
  t.database_id = d.database_id

  inner join 
  @schema.@cg_table_prefixcohort_definition target
  on 
  target.cohort_definition_id = t.target_cohort_ID
    
  inner join 
  @schema.@cg_table_prefixcohort_definition outcome
  on 
  outcome.cohort_definition_id = t.outcome_cohort_ID

;