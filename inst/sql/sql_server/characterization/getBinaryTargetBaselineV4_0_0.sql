SELECT
c.setting_id,
c.database_id,
{@include_names}?{d.cdm_source_abbreviation as database_name,}
ts.characterization_target_id,
{@include_names}?{target.cohort_name as target_name,}
ts.target_id as target_cohort_id,
ts.min_prior_observation,
ts.limit_to_first_in_n_days,
ts.nesting_cohort_id,
{@include_names}?{cg2.cohort_name as nesting_name,}
ts.min_age,
ts.max_age,
ts.study_start,
ts.study_end,
ts.gender_concept_ids,
c.covariate_id,
coi.covariate_name,
coi.analysis_id,
--coi.analysis_name,
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

{@include_names}?{
INNER JOIN @schema.@database_table d
ON c.database_id = d.database_id
}

{@include_names}?{
INNER JOIN @schema.@cg_table_prefixcohort_definition target
ON target.cohort_definition_id = ts.target_id
}

{@include_names}?{
LEFT JOIN @schema.@cg_table_prefixcohort_definition cg2
ON cg2.cohort_definition_id = ts.nesting_cohort_id
}
  
WHERE 1 = 1
{@use_characterization_targets}?{AND c.characterization_target_id in (@characterization_target_ids)}
{@use_database}?{AND c.database_id in (@database_ids) }
{@use_covariate}?{and coi.covariate_id in (@covariate_ids)}
{@use_analysis}?{and coi.analysis_id in (@analysis_ids)}
{@use_concept}?{and coi.concept_id in (@concept_ids)}
{@use_threshold}?{AND abs(c.average_value) >= @min_threshold}
;

