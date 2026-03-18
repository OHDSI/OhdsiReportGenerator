select 
d.CDM_SOURCE_ABBREVIATION as database_name,
c.database_id,
target.cohort_name as target_name,
cd.TARGET_COHORT_ID,
outcome.cohort_name as outcome_name,
cd.Outcome_COHORT_ID,
s.min_prior_observation,
s.outcome_washout_days,
s.RISK_WINDOW_START,
s.RISK_WINDOW_END,
s.START_ANCHOR,
s.END_ANCHOR,
coi.covariate_id,
coi.covariate_name,
c.sum_value,
c.average_value

from @schema.@c_table_prefixCOVARIATES c

inner join
@schema.@c_table_prefixCOHORT_DETAILS cd

on 
cd.setting_id = c.setting_id 
and cd.database_id = c.database_id 
and cd.TARGET_COHORT_ID = c.TARGET_COHORT_ID
and cd.OUTCOME_COHORT_ID = c.OUTCOME_COHORT_ID
and cd.COHORT_TYPE = c.COHORT_TYPE

 inner join
  {@use_analysis}?{
(
select * from @schema.@c_table_prefixCOVARIATE_REF 
  where analysis_id in (@analysis_ids)
)}:{@schema.@c_table_prefixCOVARIATE_REF } coi

on 
c.setting_id = coi.setting_id and
c.database_id = coi.database_id and
c.covariate_id = coi.covariate_id

inner join
@schema.@database_table d
on 
c.database_id = d.database_id

inner join @schema.@c_table_prefixsettings s
on s.database_id = c.database_id
and s.setting_id = c.setting_id

  inner join 
  @schema.@cg_table_prefixcohort_definition target
  on target.cohort_definition_id = cd.target_cohort_ID
    
  inner join 
  @schema.@cg_table_prefixcohort_definition outcome
  on outcome.cohort_definition_id = cd.outcome_cohort_ID
  
where 
cd.COHORT_TYPE in ('Cases')
{@use_target}?{ and c.TARGET_COHORT_ID in (@target_id)}
{@use_outcome}?{ and c.OUTCOME_COHORT_ID in (@outcome_id)}
{@use_database}?{ and c.database_id in (@database_id)}
  {@use_risk_window_start}?{ and s.RISK_WINDOW_START in (@risk_window_start)}  
  {@use_risk_window_end}?{ and s.RISK_WINDOW_END in (@risk_window_end)}
  {@use_start_anchor}?{ and s.START_ANCHOR in (@start_anchor)}
  {@use_end_anchor}?{ and s.END_ANCHOR in (@end_anchor)}
;