select 
d.cdm_source_abbreviation as database_name,
t.database_id,
target.cohort_name as target_name,
t.target_cohort_id,
t.min_prior_observation,
99999 as limit_to_first_in_n_days,
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
cd.target_cohort_id,
s.min_prior_observation,
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

on cd.target_cohort_id = c.target_cohort_id
and cd.cohort_type = c.cohort_type
and cd.database_id = c.database_id 
and cd.setting_id = c.setting_id 

inner join @schema.@c_table_prefixsettings s
on s.setting_id = c.setting_id
and s.database_id = c.database_id

where 
cd.COHORT_TYPE = 'Target'
{@use_target}?{ and c.target_cohort_id in (@target_id)}
{@use_database}?{ and c.database_id in (@database_id)}
) t

  inner join
  @schema.@database_table d
  on 
  t.database_id = d.database_id

  inner join 
  @schema.@cg_table_prefixcohort_definition target
  on 
  target.cohort_definition_id = t.target_cohort_id
    
;