select 
d.CDM_SOURCE_ABBREVIATION as database_name,
t.database_id,
target.cohort_name as target_name,
t.TARGET_COHORT_ID,
outcome.cohort_name as outcome_name,
t.Outcome_COHORT_ID,
t.min_prior_observation,
t.outcome_washout_days,
t.risk_window_start,
t.risk_window_end,
t.start_anchor,
t.end_anchor,
t.covariate_name,
t.covariate_id,
t.count_value,
t.min_value,
t.max_value,
t.average_value,
t.standard_deviation,
t.median_value,
t.p_10_value,
t.p_25_value,
t.p_75_value,
t.p_90_value
 
FROM 

(select 
c.database_id,
c.TARGET_COHORT_ID,
c.Outcome_COHORT_ID,
s.min_prior_observation,
s.outcome_washout_days,
s.risk_window_start,
s.risk_window_end,
s.start_anchor,
s.end_anchor,
coi.covariate_name,
coi.covariate_id,
c.count_value,
c.min_value,
c.max_value,
c.average_value,
c.standard_deviation,
c.median_value,
c.p_10_value,
c.p_25_value,
c.p_75_value,
c.p_90_value

from @schema.@c_table_prefixCOVARIATES_CONTINUOUS c
 inner join
(
select * from @schema.@c_table_prefixCOVARIATE_REF 
{@use_analysis}?{ where analysis_id in (@analysis_ids)}
) coi

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

where 
cd.COHORT_TYPE = 'Cases'
{@use_target}?{ and c.TARGET_COHORT_ID in (@target_id)}
{@use_outcome}?{ and c.outcome_cohort_id in (@outcome_id)}
{@use_database}?{ and c.database_id in (@database_id)}

  {@use_risk_window_start}?{ and s.RISK_WINDOW_START in (@risk_window_start)}  
  {@use_risk_window_end}?{ and s.RISK_WINDOW_END in (@risk_window_end)}
  {@use_start_anchor}?{ and s.START_ANCHOR in (@start_anchor)}
  {@use_end_anchor}?{ and s.END_ANCHOR in (@end_anchor)}

) t

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