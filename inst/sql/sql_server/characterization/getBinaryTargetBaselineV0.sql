SELECT

0 as setting_id,
{@include_names}?{d.cdm_source_abbreviation as database_name,}
c.database_id,
{@include_names}?{target.cohort_name as target_name,}
c.target_cohort_id as characterization_target_id,
c.target_cohort_id,
s.min_prior_observation,
99999 as limit_to_first_in_n_days,
  NULL AS nesting_cohort_id,
  NULL AS  nesting_name,
  NULL AS min_age,	
  NULL AS max_age,
  NULL AS study_start,	
  NULL AS study_end,	
  NULL AS gender_concept_ids,
  
c.covariate_id,
coi.covariate_name,
coi.analysis_name,
c.sum_value,
c.average_value

from 
@schema.@c_table_prefixCOVARIATES c
 inner join 
@schema.@c_table_prefixCOVARIATE_REF coi

on 
c.database_id = coi.database_id and
c.setting_id = coi.setting_id and
c.covariate_id = coi.covariate_id

inner join @schema.@c_table_prefixsettings s
on s.setting_id = c.setting_id
and s.database_id = c.database_id

{@include_names}?{
  inner join
  @schema.@database_table d
  on 
  c.database_id = d.database_id
}

{@include_names}?{
  inner join 
  @schema.@cg_table_prefixcohort_definition target
  on 
  target.cohort_definition_id = c.target_cohort_id
  }
  
  WHERE
  c.TARGET_COHORT_ID = @characterization_target_id AND 
  c.COHORT_TYPE = 'Target'
  {@use_database}?{AND c.database_id in (@database_id) }
  {@use_analysis}?{and coi.analysis_id in (@analysis_ids)}
  {@use_concepts}?{and coi.concept_id in (@concept_ids)}
  {@use_threshold}?{AND abs(c.average_value) >= @min_threshold}
;