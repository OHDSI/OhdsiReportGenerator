SELECT DISTINCT
parent_cohort_definition_id,
parent_cohort_name,
setting_id,
characterization_target_id,
cohort_definition_id,
cohort_name,
limit_to_first_in_n_days,
min_prior_observation,
nesting_cohort_id,
nesting_name,
min_age,
max_age,
study_start,
study_end,
gender_concept_ids,
MAX(time_to_event) as time_to_event,
MAX(dechal_rechal) as dechal_rechal,
MAX(database_comparator) as database_comparator,
MAX(cohort_comparator) as cohort_comparator,
MAX(risk_factors) as risk_factors,
MAX(case_series) as case_series
{@add_database_details}?{
,database_id
,database_name
}

FROM

(
SELECT
cg1.subset_parent as parent_cohort_definition_id,
parent.cohort_name as parent_cohort_name,
'madeup' AS setting_id,
cd.target_cohort_id AS characterization_target_id,
cd.target_cohort_id AS cohort_definition_id,
cg1.cohort_name,
99999 AS limit_to_first_in_n_days,
s.min_prior_observation,
0 AS nesting_cohort_id,
NULL AS nesting_name,
0 AS min_age,
999 AS max_age,
NULL AS study_start,
NULL AS study_end,
NULL AS gender_concept_ids,
0 AS time_to_event,
0 AS dechal_rechal,
1 AS database_comparator,
1 AS cohort_comparator,
1 AS risk_factors,
1 AS case_series
{@add_database_details}?{
,d.database_id
,d.cdm_source_abbreviation as database_name
}

    
FROM (select distinct setting_id, database_id, target_cohort_id from @schema.@c_table_prefixcohort_details
    where cohort_type in ('Target')) cd
    
INNER JOIN @schema.@c_table_prefixsettings s
ON s.setting_id = cd.setting_id
AND s.database_id = cd.database_id

INNER JOIN @schema.@cg_table_prefixcohort_definition cg1
ON cg1.cohort_definition_id = cd.target_cohort_id

INNER join @schema.@cg_table_prefixcohort_definition parent
ON parent.cohort_definition_id = cg1.subset_parent

{@add_database_details}?{
  INNER JOIN @schema.@database_table d
  ON cd.database_id = d.database_id
}

WHERE 1=1
{@use_target}?{ and cd.target_cohort_id in (@target_id)}
{@use_characterization_target}?{ and cd.target_cohort_id in (@characterization_target_id)}



UNION


SELECT
cg1.subset_parent as parent_cohort_definition_id,
parent.cohort_name as parent_cohort_name,
'madeup' AS setting_id,
tte.target_cohort_definition_id AS characterization_target_id,
tte.target_cohort_definition_id AS cohort_definition_id,
cg1.cohort_name,
0 AS limit_to_first_in_n_days,
0 AS min_prior_observation,
0 AS nesting_cohort_id,
NULL AS nesting_name,
0 AS min_age,
999 AS max_age,
NULL AS study_start,
NULL AS study_end,
NULL AS gender_concept_ids,
1 AS time_to_event,
0 AS dechal_rechal,
0 AS database_comparator,
0 AS cohort_comparator,
0 AS risk_factors,
0 AS case_series
{@add_database_details}?{
,d.database_id
,d.cdm_source_abbreviation as database_name
}


FROM (SELECT DISTINCT 
{@add_database_details}?{database_id,}
target_cohort_definition_id 
FROM @schema.@c_table_prefixtime_to_event) tte

INNER JOIN @schema.@cg_table_prefixcohort_definition cg1
ON cg1.cohort_definition_id = tte.target_cohort_definition_id

INNER join @schema.@cg_table_prefixcohort_definition parent
ON parent.cohort_definition_id = cg1.subset_parent

{@add_database_details}?{
  INNER JOIN @schema.@database_table d
  ON tte.database_id = d.database_id
}

WHERE 1=1
{@use_target}?{ and tte.target_cohort_definition_id in (@target_id)}
{@use_characterization_target}?{ and tte.target_cohort_definition_id in (@characterization_target_id)}




UNION


SELECT
cg1.subset_parent as parent_cohort_definition_id,
parent.cohort_name as parent_cohort_name,
'madeup' AS setting_id,
dcrc.target_cohort_definition_id AS characterization_target_id,
dcrc.target_cohort_definition_id AS cohort_definition_id,
cg1.cohort_name,
0 AS limit_to_first_in_n_days,
0 AS min_prior_observation,
0 AS nesting_cohort_id,
NULL AS nesting_name,
0 AS min_age,
999 AS max_age,
NULL AS study_start,
NULL AS study_end,
NULL AS gender_concept_ids,
0 AS time_to_event,
1 AS dechal_rechal,
0 AS database_comparator,
0 AS cohort_comparator,
0 AS risk_factors,
0 AS case_series
{@add_database_details}?{
,d.database_id
,d.cdm_source_abbreviation as database_name
}


FROM (SELECT DISTINCT 
{@add_database_details}?{database_id,}
target_cohort_definition_id 
FROM @schema.@c_table_prefixdechallenge_rechallenge) dcrc

INNER JOIN @schema.@cg_table_prefixcohort_definition cg1
ON cg1.cohort_definition_id = dcrc.target_cohort_definition_id

INNER join @schema.@cg_table_prefixcohort_definition parent
ON parent.cohort_definition_id = cg1.subset_parent

{@add_database_details}?{
  INNER JOIN @schema.@database_table d
  ON dcrc.database_id = d.database_id
}

WHERE 1=1
{@use_target}?{ and dcrc.target_cohort_definition_id in (@target_id)}
{@use_characterization_target}?{ and dcrc.target_cohort_definition_id in (@characterization_target_id)}


) temp

GROUP BY
parent_cohort_definition_id,
parent_cohort_name,
setting_id,
characterization_target_id,
cohort_definition_id,
cohort_name,
limit_to_first_in_n_days,
min_prior_observation,
nesting_cohort_id,
nesting_name,
min_age,
max_age,
study_start,
study_end,
gender_concept_ids
{@add_database_details}?{
,database_id
,database_name
}
;


