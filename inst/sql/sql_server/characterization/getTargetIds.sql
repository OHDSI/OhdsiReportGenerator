SELECT DISTINCT 
ts.target_id AS cohort_definition_id,
cg1.cohort_name,
max(CAST(ts.time_to_event_settings AS INT)) AS time_to_event,
max(CAST(ts.dechallenge_rechallenge_settings AS INT))  AS dechal_rechal,
max(CAST(ts.target_baseline_settings AS INT))  AS database_comparator,
max(CAST(ts.target_baseline_settings AS INT))  AS cohort_comparator,
max(CAST(ts.risk_factor_settings AS INT))  AS risk_factors,
max(CAST(ts.case_series_settings AS INT))  AS case_series

FROM @schema.@c_table_prefixtarget_settings ts

INNER JOIN @schema.@cg_table_prefixcohort_definition cg1
ON cg1.cohort_definition_id = ts.target_id

GROUP BY 
ts.target_id,
cg1.cohort_name
;


