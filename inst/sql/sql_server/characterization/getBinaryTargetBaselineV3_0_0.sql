SELECT

d.cdm_source_abbreviation as database_name,
c.database_id,
target.cohort_name as target_name,
ts.target_id as target_cohort_id,
ts.min_prior_observation,
ts.limit_to_first_in_n_days,
c.covariate_id,
coi.covariate_name,
coi.analysis_id,
c.sum_value,
c.average_value

FROM @schema.@c_table_prefixtarget_covariates c
INNER JOIN @schema.@c_table_prefixcovariate_ref coi
ON c.database_id = coi.database_id
AND c.setting_id = coi.setting_id
AND c.covariate_id = coi.covariate_id

INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON ts.setting_id = c.setting_id
AND ts.database_id = c.database_id
AND ts.characterization_target_id = c.characterization_target_id

INNER JOIN @schema.@database_table d
ON c.database_id = d.database_id

INNER JOIN @schema.@cg_table_prefixcohort_definition target
ON target.cohort_definition_id = ts.target_id
  
WHERE 1 = 1
{@use_targets}?{AND ts.target_id in (@target_ids)}
{@use_database}?{AND c.database_id in (@database_ids) }
{@use_covariate}?{and coi.covariate_id in (@covariate_ids)}
{@use_analysis}?{and coi.analysis_id in (@analysis_ids)}
{@use_concept}?{and coi.concept_id in (@concept_ids)}
;