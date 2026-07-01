select distinct

cg.subset_parent as parent_cohort_definition_id,
parent.cohort_name as parent_cohort_name,
0 AS setting_id,
0 AS characterization_target_id,
ci.target_cohort_definition_id AS cohort_definition_id,
cg.cohort_name,
0 AS limit_to_first_in_n_days,
0 AS min_prior_observation,
NULL AS nesting_cohort_id,
NULL AS nesting_name,
NULL AS min_age,
NULL AS max_age,
NULL AS study_start,
NULL AS study_end,
NULL AS gender_concept_ids,
0 AS time_to_event,
0 AS dechal_rechal,
0 AS database_comparator,
0 AS cohort_comparator,
0 AS risk_factors,
0 AS case_series,
1 as cohort_incidence
  
  from @schema.@ci_table_prefixtarget_def as ci
  
  inner join @schema.@cg_table_prefixcohort_definition cg
  on ci.target_cohort_definition_id = cg.cohort_definition_id
  
  INNER join @schema.@cg_table_prefixcohort_definition parent
  ON parent.cohort_definition_id = cg.subset_parent

{@use_target}?{WHERE ci.target_cohort_definition_id in (@target_id)}
;