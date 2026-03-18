SELECT DISTINCT
  cs.outcome_id as cohort_definition_id,
  cs.risk_window_start,
  cs.risk_window_end,
  cs.start_anchor,
  cs.end_anchor,
  cs.outcome_washout_days
  
FROM @schema.@c_table_prefixcase_settings cs
{@use_target}?{
INNER JOIN @schema.@c_table_prefixtarget_settings ts
ON cs.characterization_target_id = ts.characterization_target_id
AND ts.target_id IN (@target_ids)
}
;